class Configure
    @@S3_KEY = "AKIAJNFVHNCXMSLWZOAA"
    @@S3_SECRET = "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"
    @@S3_BUCKET = "chrisunicefchallenge"

    @@account_sid = "AC3fd82687f1494464dfabcbb450aa05aa"
    @@auth_token = "2e2353776aaf3fed6106c66e062cfa5e"

	def self.getKey()
		return @@S3_KEY
	end

	def self.getSecret()
		return @@S3_SECRET
	end

	def self.getBucket()
		return @@S3_BUCKET
	end

	def self.getAccountSID()
		return @@account_sid
	end

	def self.getAuthToken()
		return @@auth_token
	end
end