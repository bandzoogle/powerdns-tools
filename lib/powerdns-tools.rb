require 'active_resource'

require 'active_support'
require 'active_support/core_ext/module/attribute_accessors'

module Powerdns
  mattr_accessor :site_base
  mattr_accessor :api_key

  # default to whatever is specified in these environment variables

  class << self
    def site_base=(x)
      @@site_base = x
      do_reset_keys
      x
    end
    def api_key=(x)
      @@api_key = x
      do_reset_keys
      x
    end

    def do_reset_keys
      Powerdns::Domain.reset_key!
      Powerdns::Domain::DomainTemplate.reset_key!
      Powerdns::Domain::Record.reset_key!
      Powerdns::ZoneTemplate.reset_key!
      Powerdns::ZoneTemplate::RecordTemplate.reset_key!
      Powerdns::Registration.reset_key!

      true
    end
  end

  @@site_base ||= ENV["POWERDNS_API_URL"]
  @@api_key ||= ENV["POWERDNS_API_KEY"]

  module Tools
    code_path = File.join(File.dirname(__FILE__))
    require "#{code_path}/powerdns-tools/version.rb"
    require "#{code_path}/powerdns-tools/zone_template.rb"
    require "#{code_path}/powerdns-tools/domain.rb"
    require "#{code_path}/powerdns-tools/registration.rb"
  end
end
