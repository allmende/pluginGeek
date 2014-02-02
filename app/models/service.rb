class Service < ActiveRecord::Base
  scope :for_category, ->(category) { category.services.shuffle }
  scope :random, ->(count=1) { ids = pluck(:id).sample(count); where(id: ids).shuffle }

  has_many :categories,
    through: :service_categorizations
  has_many :service_categorizations,
    dependent: :destroy

  validates :name,
    :display_url,
    :target_url,
    :description,
    presence: true
end
