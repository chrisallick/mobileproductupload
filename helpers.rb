require './configure.rb'

class Helpers
    def self.s3_upload(fdata, extension, uuid)
        name = uuid + extension

        connection = Fog::Storage.new(
            :provider                 => 'AWS',
            :aws_secret_access_key    => Configure.getTwo(),
            :aws_access_key_id        => Configure.getOne()
        )

        directory = connection.directories.create(
            :key    => Configure.getThree(),
            :public => true
        )
    
        content_type = case extension
        when ".gif"
            "image/gif"
        when ".png"
            "image/png"
        when ".jpeg" || ".jpg"
            "image/jpeg"
        else
            ""
        end

        file = directory.files.create(
            :key    => name,
            :body   => fdata,
            :content_type => content_type,
            :public => true
        )

        return "https://chrisunicefchallenge.s3.amazonaws.com/#{name}"
    end
end