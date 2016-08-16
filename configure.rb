class Configure
    @@one = "AKIAJNFVHNCXMSLWZOAA"
    @@two = "dAUvcucpwYiqfldA3PTKyVO0O5hk0iH+OifqZ8Gi"
    @@three = "chrisunicefchallenge"

    @@account_sid = "AC3fd82687f1494464dfabcbb450aa05aa"
    @@auth_token = "2e2353776aaf3fed6106c66e062cfa5e"

	def self.getOne()
		return @@one
	end

	def self.getTwo()
		return @@two
	end

	def self.getThree()
		return @@three
	end

	def self.getAccountSID()
		return @@account_sid
	end

	def self.getAuthToken()
		return @@auth_token
	end
end