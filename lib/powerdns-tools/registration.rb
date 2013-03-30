module Powerdns
  class Registration < ActiveResource::Base
    Registration.site = Powerdns.site_base
    Registration.user = Powerdns.api_key
    self.format = :json

    class << self
      def reset_key!
        Registration.site = Powerdns.site_base
        Registration.user = Powerdns.api_key
      end

      def query(d)
        find(:one, :from => "/registrations.json", :params => {:api_key => Registration.user, :name => d})
      end

      def register(name, opts)
        create(opts.merge(name:name))
      end

      def renew(d)
        Registration.new(name:d).post(:renew)
      end

      def transfer(d, opts)
        Registration.new(opts.merge(name:d)).post(:transfer)
      end
    end
  end
end
