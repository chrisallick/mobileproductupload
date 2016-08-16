require 'sinatra'
require 'sinatra/partial'
require 'sinatra/reloader' if development?
require "sinatra/cookies"

require 'base64'
require 'browser'

# require "open-uri"
require 'open_uri_redirections'
require 'net/https'

require './helpers.rb'

def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ["chris","a11ick"]
end

def protected!
    unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Oops... we need your login name & password\n"])
    end
end

enable :sessions
set :session_secret, '*&(^B234bing_bong_tiffybaby'

configure do
  	redisUri = ENV["REDISTOGO_URL"] || 'redis://localhost:6379'
  	uri = URI.parse(redisUri) 
  	$redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

    if $redis.get("cm_gif_counter")
        $redis.set("cm_gif_counter", $redis.get("cm_gif_counter") )
    else
        $redis.set("cm_gif_counter", 0 )
    end

    set :client, Twilio::REST::Client.new(Configure.getAccountSID(), Configure.getAuthToken())
end

get '/' do
    protected!

	if request.env['X_MOBILE_DEVICE']
		browser = Browser.new( request.env["HTTP_USER_AGENT"] )

		erb :mobile, :layout => :mobile_layout, :locals => {
			:meta => browser.meta
		}
	else
		erb :main, :layout => :main_layout
	end
end

post '/upload/' do
	content_type :json

    $redis.incr( "cm_gif_counter" )
    gid = $redis.get( "cm_gif_counter" )	

	uuid = UUIDTools::UUID.random_create.to_s

	s3_url = Helpers.s3_upload( Base64.decode64(params[:image]), ".png", uuid )

	response = { :gid => gid, :s3_url => s3_url, :title => params[:title], :cost => params[:cost], :quantity => params[:quantity] }

    $redis.lpush( "cm_gifs", gid )
    $redis.set( "cm_gif:#{gid}", response.to_json )
	
	return { :result => "success", :resp => response, :s3_url => s3_url, :gid => gid }.to_json
end

post '/upload/sms/' do
    if params["From"] and params["MediaUrl0"]
        puts params
        body = ["","",""]
        body = params["Body"].split(",")
        
        $redis.incr( "cm_gif_counter" )
        gid = $redis.get( "cm_gif_counter" )
        
        uuid = UUIDTools::UUID.random_create.to_s

        web_contents  = open(params["MediaUrl0"], :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE, :allow_redirections => :all) {|f| f.read }
        s3_url = Helpers.s3_upload( web_contents, ".png", uuid )

        response = { :gid => gid, :s3_url => s3_url, :title => body[0], :cost => body[1], :quantity => body[2] }

        $redis.lpush( "cm_gifs", gid )
        $redis.set( "cm_gif:#{gid}", response.to_json )

        tid = settings.client.account.messages.create(
            :from => "+12402452779",
            :to => "#{params["From"]}",
            :body => "uploaded: http://162.243.220.110/product/#{gid}"
        )
    else
        puts params
        
        if params["Body"] == "add"
            tid = settings.client.account.messages.create(
                :from => "+12402452779",
                :to => "#{params["From"]}",
                :body => "ok, to add send photo with text 'title,price,quantity"
            )
        elsif params["Body"] == "view"
            tid = settings.client.account.messages.create(
                :from => "+12402452779",
                :to => "#{params["From"]}",
                :body => "example (hard coded): http://162.243.220.110/product/1"
            )
        else
            tid = settings.client.account.messages.create(
                :from => "+12402452779",
                :to => "#{params["From"]}",
                :body => "hello: add or view?"
            )
        end
    end

    return ""
end

get '/product/:gid' do
    if params[:gid]
    	image_object = JSON.parse($redis.get("cm_gif:#{params[:gid]}"))

    	if image_object 
	        erb :gif, :layout => :gif_layout, :locals => {
	        	:gid => params[:gid],
	            :s3_url => image_object["s3_url"],
	            :title => image_object["title"],
	            :cost => image_object["cost"],
	            :quantity => image_object["quantity"]
	        }
    	else
    		redirect '/'
    	end
    else
        redirect '/'
    end
end

get '/products' do
	redirect '/products/'
end

get '/products/' do
    products = []
    all = $redis.lrange("cm_gifs", 0, $redis.llen( "cm_gifs" ) )
    all.each do |aid|
        product_object = JSON.parse($redis.get("cm_gif:#{aid}"))
        products.push( product_object )
    end

    erb :all_products, :layout => :all_products_layout, :locals => {
    	:products => products
    }
end