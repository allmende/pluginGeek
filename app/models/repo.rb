# == Schema Information
#
# Table name: repos
#
#  created_at         :datetime         not null
#  description        :text
#  full_name          :text             not null
#  github_description :text
#  github_updated_at  :datetime
#  homepage_url       :text
#  id                 :integer          not null, primary key
#  knight_score       :integer          default(0)
#  name               :text
#  owner              :text
#  staff_pick         :boolean          default(FALSE)
#  stars              :integer          default(0)
#  update_success     :boolean          default(FALSE)
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_repos_on_full_name     (full_name) UNIQUE
#  index_repos_on_knight_score  (knight_score)
#

class Repo < ActiveRecord::Base
  # Friendly ID
  extend FriendlyId
  friendly_id :full_name

  # Audits
  audited only: [:description]

  # Validations
  validates :full_name, presence: true, uniqueness: true
  validates :description, length: {maximum: 360}

  # Parents
  has_many :parent_child_relationships,
    class_name:   'RepoRelationship',
    foreign_key:  :child_id,
    dependent:    :destroy # REVIEW: Really?
  has_many :parents,
    through:      :parent_child_relationships,
    source:       :parent,
    uniq:         true

  # Children
  has_many :child_parent_relationships,
    class_name:   'RepoRelationship',
    foreign_key:  :parent_id,
    dependent:    :destroy # TODO: Really?
  has_many :children,
    through:      :child_parent_relationships,
    source:       :child,
    uniq:         true

  # NOTE: Move to decorator
  def has_parents?
    !parents.empty?
  end

  def has_children?
    !children.empty?
  end

  def child_list
    children.pluck(:full_name).join(', ')
  end

  def parents_and_children
    parents | children
  end

  # Categories
  has_many :categorizations
  has_many :categories,
    through: :categorizations,
    uniq: true,
    order: 'categories.knight_score DESC'

  def has_categories?
    categories.size > 0
  end

  # To create a tag-like input
  def category_list
    categories.map(&:full_name).join(', ')
  end

  # handle tag-input shpanges
  def category_list=(new_list)
    if new_list != category_list
      # Review: more efficient 'pluck' breaks
      old_ones = categories.map(&:full_name)

      full_names = new_list.
                    split(', ').
                    select(&:present?).
                    compact.
                    map(&:strip)

      self.categories = full_names.map do |full_name|
        Category.where(full_name: full_name).first_or_create!
      end

      new_ones = categories.map(&:full_name)

      # Expire caches
      Category.expire(old_ones | new_ones)
      self.touch # expire self
    end
  end

  # Languages
  has_many :language_classifications,
    as: :classifier
  has_many :languages,
    through: :language_classifications,
    uniq: true

  def language_list
    languages.map(&:name).join(', ')
  end

  # Links
  has_many :link_relationships,
    as: :linkable
  has_many :links,
    through: :link_relationships,
    uniq: true,
    order: 'links.published_at DESC'

  # Field defaults and virtual attributes
  # Owner and name
  def name
    self[:name] || full_name.split('/')[1]
  end

  def owner
    self[:owner] || full_name.split('/')[0]
  end

  # Urls
  def github_url
    "https://github.com/#{full_name}"
  end

  def homepage_url
    self[:homepage_url].present? ? self[:homepage_url] : github_url
  end

  # Descriptions
  def github_description
    self[:github_description].present? ? self[:github_description] : ''
  end

  def description
    self[:description].present? ? self[:description] : github_description
  end

  # Timestamps
  def github_updated_at
    self[:github_updated_at].present? ? self[:github_updated_at].utc : 2.years.ago.utc
  end

  # NOTE: Move to Decorator
  def timestamp
    github_updated_at.utc # jQuery timeago input format
  end

  # Scopes
  # Ordering by score
  scope :order_by_score, order('repos.knight_score DESC')

  # All repos except the given one, so that parent cannot be set to self in repo#edit
  def self.all_except(repo)
    order_by_score - [repo] # REVIEW: There's a method for that
  end

  # Find all repos without any associated categories,
  # parents or children, to probably clean them up
  def self.all_without_associations
    full_names = []
    Repo.find_each do |repo|
      full_names << repo.full_name if
        repo.categories.empty? && repo.parents.empty? && repo.children.empty?
    end

    Repo.where(full_name: full_names)
  end

  # Callbacks
  # Deduce languages from categories' languages
  before_save :set_languages
  def set_languages
    self.languages = categories.flat_map(&:languages).uniq
  end

  # Changes in repo (e.g. adding staff pick flag) need
  # to expire associated categories
  after_commit :expire_categories, if: :persisted?

  # Retrieve record from Github if the full name changed
  # to handle renaming of repos and movements between owners
  after_save :update_from_github, if: :full_name_changed?

  private

  def expire_categories
    categories.each(&:touch)
  end

  # Update record from Github
  def update_from_github
    RepoUpdater.new.perform(full_name)
  end

  # Whitelisting attributes for mass assignment
  attr_accessible :full_name, :description, :category_list, :parent_ids, :staff_pick
end
