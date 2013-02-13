module Powerdns
  class Domain < ActiveResource::Base
    Domain.site = Powerdns.site_base
    Domain.user = Powerdns.api_key
    self.format = :json

    class << self
      def reset_key!
        Domain.site = Powerdns.site_base
        Domain.user = Powerdns.api_key
      end

      def query(d)
        find(:one, :from => "/domains.json", :params => {:api_key => Domain.user, :name => d})
      end

      def add(d, zt)
        attrs = {name: d, zone_template_name: zt}
        create(attrs)
        query(d)
      end

      def delete(d)
        domain = query(d)
        domain.destroy 
      end
    end

    def to_s
      header = [";;", name, "id: #{id}",
       "created: #{created_at}",
       "updated #{updated_at}"].join(" ") + "\n"
      templates = zone_templates.collect(&:to_s)
      recs = records.collect {  |r|
        r
      }.join("\n")
      "#{header}\nTEMPLATES: #{templates}\n#{recs}"
    end

    #
    # This is here to keep serialization routines from freaking out -- otherwise
    # they try and use the class type
    #
    def type
      self.attributes[:type]
    end

    def add_record(type, content, params = {})
      r = Powerdns::Domain::Record.new(:type => type, :content => content)
      r.domain_id = self.id
      params.each { |k, v|
        r.attributes[k] = v
      }
      r.save

      r
    end

    def add_zone_template(zt)
      dt = Powerdns::Domain::DomainTemplate.new(zone_template_id:zt.id, domain_id:self.id)
      dt.save
      dt
    end

    def remove_zone_template(zt)
      dt = Powerdns::Domain::DomainTemplate.find(:one, from:"/domains/#{self.id}/domain_templates.json",
        params:{api_key:Powerdns.api_key, zone_template_id:zt.id})
      dt.attributes[:domain_id] = self.id
      dt.destroy
    end

    class Powerdns::Domain::ZoneTemplate < Powerdns::ZoneTemplate
      def to_s
        "#{self.id} #{self.name}"
      end
    end

    class Powerdns::Domain::DomainTemplate < ActiveResource::Base
      Powerdns::Domain::DomainTemplate.site = "#{Powerdns.site_base}/domains/:domain_id"
      Powerdns::Domain::DomainTemplate.user = Powerdns.api_key
      self.format = :json

      class << self
        def reset_key!
          Powerdns::Domain::DomainTemplate.site = "#{Powerdns.site_base}/domains/:domain_id"
          Powerdns::Domain::DomainTemplate.user = Powerdns.api_key
        end

        def element_path(id, prefix_options = {}, query_options = nil)
          domain_id = prefix_options.dup.delete(:domain_id)
          prefix_options, query_options = split_options(prefix_options) if query_options.nil?
          "/domains/#{domain_id}/domain_templates/#{URI.escape id.to_s}.#{format.extension}#{query_string(query_options)}"
        end
      end

      def domain_id
        self.prefix_options[:domain_id] || self.attributes[:domain_id]
      end

      def collection_path(prefix_options = {}, query_options = nil)
        "/domains/#{self.domain_id}/domain_templates.json"
      end

      # def new_element_path(prefix_options = {})
      #   "/domains/#{self.domain_id}/new.#{format.extension}"
      # end

      def element_path(options = nil)
        tmp = options || prefix_options
        tmp[:domain_id] = self.domain_id
        self.class.element_path(to_param, tmp)
      end
    end

    class Powerdns::Domain::Record < ActiveResource::Base
      self.format = :json
      Powerdns::Domain::Record.site = "#{Powerdns.site_base}/domains/:domain_id"
      Powerdns::Domain::Record.user = Powerdns.api_key

      def type
        self.attributes[:type]
      end

      def name
        self.attributes[:name]
      end

      class << self
        def reset_key!
          Powerdns::Domain::Record.site = "#{Powerdns.site_base}/domains/:domain_id"
          Powerdns::Domain::Record.user = Powerdns.api_key
        end

        def element_path(id, prefix_options = {}, query_options = nil)
          domain_id = prefix_options.delete(:domain_id)
          prefix_options, query_options = split_options(prefix_options) if query_options.nil?
          "/domains/#{domain_id}/records/#{URI.escape id.to_s}.#{format.extension}#{query_string(query_options)}"
        end
      end

      def collection_path(prefix_options = {}, query_options = nil)
        "/domains/#{self.domain_id}/records.json"
      end

      def new_element_path(prefix_options = {})
        "/domains/#{self.domain_id}/new.#{format.extension}"
      end

      def element_path(options = nil)
        tmp = options || prefix_options
        tmp[:domain_id] = self.domain_id
        self.class.element_path(to_param, tmp)
      end

      def to_h
        self.attributes
      end

      def to_s
        sep = "\t"
        [self.attributes[:name],
         self.attributes[:ttl],
         self.attributes[:type],
         self.attributes[:content]].join(sep)
      end
    end

  end

  # == Schema Information
  #
  # Table name: domains
  #
  #  id            :integer(4)      not null, primary key
  #  website_id    :integer(4)
  #  domain        :string(100)
  #  registered_on :date
  #  expires_on    :date
  #  registrar     :integer(4)
  #  created_at    :datetime
  #  updated_at    :datetime
  #  email         :string(255)     default("1")
  #  dns           :boolean(1)      default(TRUE), not null
  #

end
