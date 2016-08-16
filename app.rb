require 'sinatra'
require 'sinatra/partial'
require 'sinatra/reloader' if development?
require "sinatra/cookies"

require 'base64'
require 'browser'

require './helpers.rb'

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
end

use Rack::Auth::Basic, "Protected Area" do |username, password|
  username == 'chris' && password == 'a11ick'
end

get '/' do
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

	# not .to_json for json response
	response = { :gid => gid, :s3_url => s3_url, :title => params[:title], :cost => params[:cost], :quantity => params[:quantity] }

    $redis.lpush( "cm_gifs", gid )
    $redis.set( "cm_gif:#{gid}", response.to_json ) #to_json for storage
	
	return { :result => "success", :resp => response, :s3_url => s3_url, :gid => gid }.to_json
end

# return a gif
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