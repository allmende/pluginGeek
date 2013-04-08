class CategoryDecorator < Draper::Decorator
  delegate_all

  decorates_association :repos
  decorates_association :similar_categories
  decorates_association :extended_links

  def description
    description = model.description.presence || ""
    h.word_wrap(description)
  end

  def stars
    stars = model.stars.presence || 0
    text = h.number_with_delimiter(stars)
    h.icon_tag(:star, text)
  end

  def score
    model.score.presence || 0
  end

  def repo_names
    list = model.repo_list
    (list.presence && list.split(", ")) || []
  end

  def popular_repo_names
    names = repo_names[0..1]
    (names.presence && names.join(", ")) || ""
  end

  def further_repo_names
    names = repo_names[2..200]
    (names.presence && names.join(", ")) || ""
  end

  # TODO: Specs
  def show_repos_link_text
    if repos_count > 3
      " and #{ repos_count - 2 } more &raquo;".html_safe
    else
      " &raquo;".html_safe
    end
  end
end