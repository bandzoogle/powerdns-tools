require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Powerdns::Domain do
	before(:each) do
		setup_powerdns
	end

	describe "Adding a domain" do
		it "should create the domain" do
			VCR.use_cassette('create-domain') do
				@domain = Powerdns::Domain.add("new-domain1.net", "usersite")

				@domain.zone_templates.first.name.should == "usersite"
				# puts @domain.records.first.type
				# @domain.records.de { |r| r.type == "CNAME" }.name.should == "www"
			end
		end

		it "should freak out when it already exists" do
			VCR.use_cassette('create-existing-domain', :record => :new_episodes) do
				lambda {
					@domain = Powerdns::Domain.add("new-domain1.net", "usersite")
				}.should raise_error
			end
		end

		it "should require a zone template" do
			VCR.use_cassette('create-domain-no-template', :record => :new_episodes) do
				lambda {
					@domain = Powerdns::Domain.add("new-domain-blah.net", "faketemplate")
				}.should raise_error
			end
		end
	end

	describe "Removing a domain" do
		it "should destroy the domain when it exists" do
			VCR.use_cassette('delete-domain') do
				@dns = Powerdns::Domain.query("foo3.com")
				@dns.destroy.code.should == "204"
			end
		end

		it "works via domain.delete" do
			VCR.use_cassette('create-deletable-domain', :record => :new_episodes) do
				@domain = Powerdns::Domain.add("deleteme.net", "usersite")
			end

			VCR.use_cassette('delete-domain-2', :record => :new_episodes) do
				@domain = Powerdns::Domain.delete("deleteme.net")
			end

			VCR.use_cassette('query-missing-domain', :record => :new_episodes) do
				lambda {
					@dns = Powerdns::Domain.query("deleteme.net")
				}.should raise_error
			end
		end

		it "should freak out when it doesn't exist" do
			VCR.use_cassette('delete-domain') do
				lambda {
					@dns = Powerdns::Domain.query("happyserverfofofofo.com")
					@dns.destroy
				}.should raise_error
			end
		end
	end

	describe "Adding a record to a domain" do
		it "should add the record" do
			VCR.use_cassette('create-deletable-domain', :record => :new_episodes) do
				@domain = Powerdns::Domain.add("deleteme.net", "usersite")
			end

			VCR.use_cassette('create-record-on-domain') do
				result = @domain.add_record("CNAME", "mobile.somewherelse.com", {
					name: "mobile.deleteme.net",
					ttl: 300
				})

				result.type.should == "CNAME"
				result.name.should == "mobile.deleteme.net"
				result.attributes[:ttl].to_i.should == 300
				result.attributes[:content].should == "mobile.somewherelse.com"
			end
		end
	end

	describe "Querying a domain" do
		it "should return the domain when it exists" do
			VCR.use_cassette('query-happyserver') do
				@dns = Powerdns::Domain.query("happyserver.com")
				@dns.as_string.should include("www.happyserver.com")
			end
		end

		it "should have records" do
			VCR.use_cassette('query-happyserver') do
				@dns = Powerdns::Domain.query("happyserver.com")
				@dns.records.first.to_s.should include("info.happyserver.com")
			end
		end

		it "should have templates" do
			VCR.use_cassette('query-happyserver') do
				@dns = Powerdns::Domain.query("happyserver.com")
				@dns.zone_templates.size.should == 1
				@dns.zone_templates.first.name.should == "happyserver"
			end			
		end

		it "should return 404 for missing domains" do
			VCR.use_cassette('query-404') do
				lambda {
					@dns = Powerdns::Domain.query("happyserver404.com")
				}.should raise_error
			end
		end
	end


	describe "Removing template from a domain" do
		it "should work when it exists" do
			VCR.use_cassette('remove-zone-template-from-domain', :record => :new_episodes) do
				@domain = Powerdns::Domain.add("remove-me.net", "happyserver")
				@domain.zone_templates.size.should == 1

				@zt = Powerdns::ZoneTemplate.query("happyserver")
				@domain.remove_zone_template(@zt).code.should == "204"

				@domain = Powerdns::Domain.query("remove-me.net")
				@domain.zone_templates.size.should == 0
			end
		end

		it "should throw error when not part of domain" do
			VCR.use_cassette('remove-missing-zone-template-from-domain', :record => :new_episodes) do
				@domain = Powerdns::Domain.add("junky-test3000.net", "happyserver")
				@domain.zone_templates.size.should == 1

				@zt = Powerdns::ZoneTemplate.query("usersite")

				lambda {
					@domain.remove_zone_template(@zt)
				}.should raise_error

				@domain = Powerdns::Domain.query("junky-test3000.net")
				@domain.zone_templates.size.should == 1
			end
		end
	end

	describe "Adding template to a domain" do
		it "should work when it exists" do
			VCR.use_cassette('add-zone-template-to-domain', :record => :new_episodes) do
				@domain = Powerdns::Domain.add("happy-test-25.net", "happyserver")
				@domain.zone_templates.size.should == 1

				@zt = Powerdns::ZoneTemplate.query("usersite")
				@domain.add_zone_template(@zt) #.code.should == "204"

				@domain = Powerdns::Domain.query("happy-test-25.net")
				@domain.zone_templates.size.should == 2
			end
		end
	end
end
