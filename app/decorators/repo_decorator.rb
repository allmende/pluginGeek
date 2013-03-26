class RepoDecorator < Draper::Decorator
  delegate_all
  decorates_association :categories
  decorates_association :parents_and_children

  def owner
    model[:owner].present? ? model[:owner] : full_name.split('/')[0]
  end

  def name
    model[:name].present? ? model[:name] : full_name.split('/')[1]
  end

  def description
    model[:description].present? ? model[:description] : github_description
  end

  def github_description
    model[:github_description].present? ? model[:github_description] : ""
  end

  def homepage_url
    model[:homepage_url].present? ? model[:homepage_url] : github_url
  end

  def github_url
    "https://github.com/#{ full_name }"
  end

  def github_updated_at
    time = model[:github_updated_at].present? ? model[:github_updated_at] : 2.years.ago
    time.utc
  end

  def timestamp
    # jQuery timeago compatible
    github_updated_at.utc
  end

  # Somehow there are ActiveRecord errors when using order clauses for this
  # and using .includes(:links) queries a few levels deep, thus sorting is right now done in Ruby
  def sorted_links
    links.sort_by(&:published_at).reverse
  end
end
