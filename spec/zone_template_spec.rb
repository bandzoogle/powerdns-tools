require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Powerdns::ZoneTemplate do
	before(:each) do
		setup_powerdns
	end

	describe "querying templates" do
		it "should list zone templates" do
			VCR.use_cassette('query-zone-templates') do
				zones = Powerdns::ZoneTemplate.all
				zones.size.should == 6
				zones.collect(&:name).should include "engineyard"
			end
		end
	end

	describe "creating" do
		it "works" do
			VCR.use_cassette('create-zonetemplate', :record => :new_episodes) do
				result = Powerdns::ZoneTemplate.create(:name => "newzone", :ttl => 1234)

				result.attributes[:name].should == "newzone"
				result.attributes[:ttl].should == 1234
			end
		end

		it "prevents dupes" do
			VCR.use_cassette('create-zonetemplate', :record => :new_episodes) do
				Powerdns::ZoneTemplate.create(:name => "newzone", :ttl => 1234)
			end
			VCR.use_cassette('dupe-zonetemplate', :record => :new_episodes) do
				result = Powerdns::ZoneTemplate.create(:name => "newzone", :ttl => 1234)
				result.persisted?.should == false
			end
		end

		it "can add records" do
			VCR.use_cassette('create-zonetemplate', :record => :new_episodes) do
				@zt = Powerdns::ZoneTemplate.create(:name => "newzone", :ttl => 1234)
			end

			VCR.use_cassette('create-record-for-zonetemplate', :record => :new_episodes) do
				result = @zt.add_record("CNAME", "mobile", "@", {:ttl => 1234})
				result.attributes[:name].should == "mobile"
				result.attributes[:record_type].should == "CNAME"
				result.attributes[:content].should == "@"
				result.attributes[:ttl].should == 1234
			end
		end
	end

end