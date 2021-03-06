require 'spec_helper'

describe Service do
  subject(:service) { Fabricate.build(:service) }
  it { should be_valid }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:display_url) }
  it { should validate_presence_of(:target_url) }
  it { should validate_presence_of(:description) }

  it { should have_many(:service_categorizations).dependent(:destroy) }
  it { should have_many(:categories).through(:service_categorizations) }

  describe ".random(count)" do
    it "returns a set of records of the given number" do
      2.times { Fabricate(:service) }
      expect(Service.random(1)).to have(1).item
    end

    it "returns a random set of records" do
      5.times { Fabricate(:service) }
      random_one = Service.random(3)
      random_two = Service.random(3)
      expect(random_one).to_not eq(random_two)
    end
  end

  describe ".for_category(category)" do
    let!(:category) { Fabricate(:category) }
    let!(:service) { service = Fabricate(:service); service.categories |= [category]; service }

    it "returns the category's services" do
      # Other service
      Fabricate(:service)

      services = Service.for_category(category)
      expect(services).to eq([service])
    end

    it "randomizes the services' order" do
      5.times { service = Fabricate(:service); service.categories |= [category]; service }

      services_one, services_two = Service.for_category(category), Service.for_category(category)
      expect(services_one).to_not eq(services_two)
    end
  end
end
