# == Schema Information
#
# Table name: links
#
#  author       :text
#  author_url   :text
#  created_at   :datetime         not null
#  id           :integer          not null, primary key
#  published_at :date             not null
#  title        :text             not null
#  updated_at   :datetime         not null
#  url          :text             not null
#

require 'spec_helper'

describe Link do
  subject(:link) { Fabricate.build(:link) }
  it { should be_valid }

  it { should validate_presence_of(:url) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:published_at) }

  it { should have_many(:link_relationships) }
  it { should have_many(:repos).through(:link_relationships) }
  it { should have_many(:categories).through(:link_relationships) }

  it "includes the repos' categories into categories"
end
