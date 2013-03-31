# == Schema Information
#
# Table name: categories
#
#  created_at    :datetime         not null
#  description   :text
#  draft         :boolean          default(TRUE)
#  full_name     :text             not null
#  id            :integer          not null, primary key
#  language_list :text
#  repo_list     :text
#  score         :integer          default(0)
#  slug          :text             not null
#  stars         :integer          default(0)
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_categories_on_score  (score)
#  index_categories_on_slug   (slug) UNIQUE
#

Fabricator(:category) do
  full_name { sequence(:full_name) { |n| "Category #{n}"} }
  slug { |attrs| attrs[:full_name].parameterize }
end
