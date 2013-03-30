require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Powerdns::Registration do
	before(:each) do
		setup_powerdns
	end

	describe "Querying a domain" do
		it "should work" do
			VCR.use_cassette('query-domain', :record => :new_episodes) do
				@result = Powerdns::Registration.query("new-domain1.net")
			end
			@result.name.should == "new-domain1.net"
			@result.expiration_date.should == "2015-03-06"
		end
	end

	describe "Registering a domain" do
		before(:each) do
      @opts = {
        nameservers: ["dns1.sitezoogle.com", "dns2.sitezoogle.com"],
        years: 1,
        RegistrantFirstName: "Domain",
        RegistrantLastName: "Registrar",
        RegistrantPhone: "+1.2816684674",
        RegistrantAddress1: "14781 Memorial Drive",
        RegistrantAddress2: "Suite 723",
        RegistrantCity: "Houston",
        RegistrantStateProvinceChoice: "S",
        RegistrantStateProvince: "Texas",
        RegistrantPostalCode: "77079",
        RegistrantCountry: "US",
        RegistrantEmailAddress: "domains@sitezoogle.com",
        IgnoreNSFail:"Yes"
      }
		end

		it "should register the domain" do
			VCR.use_cassette('register-domain', :record => :new_episodes) do
				@domain = Powerdns::Registration.register("new-domain123.net", @opts)
			end
		end

		it "should freak out when it already exists" do
			lambda {
				VCR.use_cassette('register-existing-domain', :record => :new_episodes) do
					@domain = Powerdns::Registration.register("new-domain123.net", @opts)
				end
			}.should raise_error
		end
	end

	describe "Renewing a domain" do
		it "should work" do
			VCR.use_cassette('renew-domain', :record => :new_episodes) do
				@result = Powerdns::Registration.renew("new-domain1.net") #new-domain123.net")
			end
			@result.code.should == "200"
		end
	end

	describe "Transferring a domain" do
		it "should raise error" do
			lambda {
				VCR.use_cassette('transfer-domain-no-contact', :record => :new_episodes) do
					@result = Powerdns::Registration.transfer("new-domain123.net", {})
				end
			}.should raise_error
		end

		it "should work" do
      opts = {
        "FirstName" => "First",
        "LastName" => "Last",
        "OrganizationName" => "Org",
        "Address1" => "22 Test Lane",
        "City" => "Montague",
        "StateProvince" => "MA",
        "PostalCode" => "01351",
        "Country" => "USA",
        "EmailAddress" => "test@tester.com",
        "Phone"  => "222.222.2222"
      }

			VCR.use_cassette('transfer-domain', :record => :new_episodes) do
				@result = Powerdns::Registration.transfer("new-domain123.net", opts)
			end
			@result.code.should == "200"
		end
	end

	# 	it "should destroy the domain when it exists" do
	# 		VCR.use_cassette('delete-domain') do
	# 			@dns = Powerdns::Registration.query("foo3.com")
	# 			@dns.destroy.code.should == "204"
	# 		end
	# 	end

	# 	it "works via domain.delete" do
	# 		VCR.use_cassette('create-deletable-domain', :record => :new_episodes) do
	# 			@domain = Powerdns::Registration.add("deleteme.net", "usersite")
	# 		end

	# 		VCR.use_cassette('delete-domain-2', :record => :new_episodes) do
	# 			@domain = Powerdns::Registration.delete("deleteme.net")
	# 		end

	# 		VCR.use_cassette('query-missing-domain', :record => :new_episodes) do
	# 			lambda {
	# 				@dns = Powerdns::Registration.query("deleteme.net")
	# 			}.should raise_error
	# 		end
	# 	end

	# 	it "should freak out when it doesn't exist" do
	# 		VCR.use_cassette('delete-domain') do
	# 			lambda {
	# 				@dns = Powerdns::Registration.query("happyserverfofofofo.com")
	# 				@dns.destroy
	# 			}.should raise_error
	# 		end
	# 	end
	# end

	# describe "Adding a record to a domain" do
	# 	it "should add the record" do
	# 		VCR.use_cassette('create-deletable-domain', :record => :new_episodes) do
	# 			@domain = Powerdns::Registration.add("deleteme.net", "usersite")
	# 		end

	# 		VCR.use_cassette('create-record-on-domain') do
	# 			result = @domain.add_record("CNAME", "mobile.somewherelse.com", {
	# 				name: "mobile.deleteme.net",
	# 				ttl: 300
	# 			})

	# 			result.type.should == "CNAME"
	# 			result.name.should == "mobile.deleteme.net"
	# 			result.attributes[:ttl].to_i.should == 300
	# 			result.attributes[:content].should == "mobile.somewherelse.com"
	# 		end
	# 	end
	# end

	# describe "Querying a domain" do
	# 	it "should return the domain when it exists" do
	# 		VCR.use_cassette('query-happyserver') do
	# 			@dns = Powerdns::Registration.query("happyserver.com")
	# 			@dns.to_s.should include("www.happyserver.com")
	# 		end
	# 	end

	# 	it "should have records" do
	# 		VCR.use_cassette('query-happyserver') do
	# 			@dns = Powerdns::Registration.query("happyserver.com")
	# 			@dns.records.first.to_s.should include("info.happyserver.com")
	# 		end
	# 	end

	# 	it "should have templates" do
	# 		VCR.use_cassette('query-happyserver') do
	# 			@dns = Powerdns::Registration.query("happyserver.com")
	# 			@dns.zone_templates.size.should == 1
	# 			@dns.zone_templates.first.name.should == "happyserver"
	# 		end			
	# 	end

	# 	it "should return 404 for missing domains" do
	# 		VCR.use_cassette('query-404') do
	# 			lambda {
	# 				@dns = Powerdns::Registration.query("happyserver404.com")
	# 			}.should raise_error
	# 		end
	# 	end
	# end


	# describe "Removing template from a domain" do
	# 	it "should work when it exists" do
	# 		VCR.use_cassette('remove-zone-template-from-domain', :record => :new_episodes) do
	# 			@domain = Powerdns::Registration.add("remove-me.net", "happyserver")
	# 			@domain.zone_templates.size.should == 1

	# 			@zt = Powerdns::ZoneTemplate.query("happyserver")
	# 			@domain.remove_zone_template(@zt).code.should == "204"

	# 			@domain = Powerdns::Registration.query("remove-me.net")
	# 			@domain.zone_templates.size.should == 0
	# 		end
	# 	end

	# 	it "should throw error when not part of domain" do
	# 		VCR.use_cassette('remove-missing-zone-template-from-domain', :record => :new_episodes) do
	# 			@domain = Powerdns::Registration.add("junky-test3000.net", "happyserver")
	# 			@domain.zone_templates.size.should == 1

	# 			@zt = Powerdns::ZoneTemplate.query("usersite")

	# 			lambda {
	# 				@domain.remove_zone_template(@zt)
	# 			}.should raise_error

	# 			@domain = Powerdns::Registration.query("junky-test3000.net")
	# 			@domain.zone_templates.size.should == 1
	# 		end
	# 	end
	# end

	# describe "Adding template to a domain" do
	# 	it "should work when it exists" do
	# 		VCR.use_cassette('add-zone-template-to-domain', :record => :new_episodes) do
	# 			@domain = Powerdns::Registration.add("happy-test-25.net", "happyserver")
	# 			@domain.zone_templates.size.should == 1

	# 			@zt = Powerdns::ZoneTemplate.query("usersite")
	# 			@domain.add_zone_template(@zt) #.code.should == "204"

	# 			@domain = Powerdns::Registration.query("happy-test-25.net")
	# 			@domain.zone_templates.size.should == 2
	# 		end
	# 	end
	# end
end