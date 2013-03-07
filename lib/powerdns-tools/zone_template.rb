require 'zonefile'

module Powerdns
  class ZoneTemplate < ActiveResource::Base
    ZoneTemplate.site = Powerdns.site_base
    ZoneTemplate.user = Powerdns.api_key
    self.format = :json

    class << self
      def reset_key!
        ZoneTemplate.site = Powerdns.site_base
        ZoneTemplate.user = Powerdns.api_key
      end

      def query(zt)
        find(:first, :params => {:api_key => Powerdns.api_key, :name => zt})
      end

      def from_zonefile(data, name)
        zf = Zonefile.new(data)

        @records = []

        @zt = ZoneTemplate.new(:name => name)

        #
        # The zonefile gem names a bunch of things differently from what our PDNS
        # code wants.  Renaming for now
        #
        @soa = zf.soa.dup
        @soa[:primary_ns] = @soa.delete(:primary)
        @soa[:minimum] = @soa.delete(:minimumTTL)
        @soa[:contact] = @soa.delete(:email)

        @soa.delete(:origin)

        @zt.add_record('SOA', '@', nil, @soa)

        zf.records.each { |type, entries| 
          entries.each { |e|
            type = type.to_s.upcase
            @zt.add_record(type, e[:name], e[:host], {:ttl => e[:ttl], :prio => e[:pri]})
          }
        }

        @zt.save
      end
    end

    def to_zone
      self.record_templates.each {  |r| r.to_s }.join("\n")
    end


    def add_record(record_type, name, content, params = {})
      self.attributes[:records] ||= []

      r = Powerdns::ZoneTemplate::RecordTemplate.new(:record_type => record_type, :name => name, :content => content)
#      r.zone_template_id = self.id
#      r.zone_template = self
      params.each { |k, v|
        r.attributes[k] = v  
      }

      self.attributes[:records] << r
#      r.save
      r
    end

    class Powerdns::ZoneTemplate::RecordTemplate < ActiveResource::Base
      Powerdns::ZoneTemplate::RecordTemplate.user = Powerdns.api_key
      Powerdns::ZoneTemplate::RecordTemplate.site = "#{Powerdns.site_base}/zone_templates/:zone_template_id"
      self.format = :json

      class << self
        def reset_key!
          Powerdns::ZoneTemplate::RecordTemplate.user = Powerdns.api_key
          Powerdns::ZoneTemplate::RecordTemplate.site = "#{Powerdns.site_base}/zone_templates/:zone_template_id"
        end

        def element_path(id, prefix_options = {}, query_options = nil)
          zone_template_id = prefix_options.delete(:zone_template_id)
          prefix_options, query_options = split_options(prefix_options) if query_options.nil?
          "/zone_templates/#{zone_template_id}/record_templates/#{URI.escape id.to_s}.#{format.extension}#{query_string(query_options)}"
        end
      end

      def collection_path(prefix_options = {}, query_options = nil)
        "/zone_templates/#{self.zone_template_id}/record_templates.json"
      end

      def new_element_path(prefix_options = {})
        "/zone_templates/#{self.zone_template_id}/new.#{format.extension}"
      end

      def element_path(options = nil)
        tmp = options || prefix_options
        tmp[:zone_template_id] = self.zone_template_id
        self.class.element_path(to_param, tmp)
      end

      def to_s
        sep = "\t"
        #puts self.inspect
        [self.attributes[:name],
         self.attributes[:ttl],
         self.attributes[:record_type],
         self.attributes[:content]].join(sep)
      end
    end

  end
end
