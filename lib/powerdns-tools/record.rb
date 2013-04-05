module Powerdns
	class Record < ActiveResource::Base
		self.element_name = "record"
    self.format = :json
    Record.site = Powerdns.site_base
    Record.user = Powerdns.api_key

    class << self
      def reset_key!
        Record.site = Powerdns.site_base
        Record.user = Powerdns.api_key
      end
    end
  end
end
