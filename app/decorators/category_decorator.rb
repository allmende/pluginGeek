class CategoryDecorator < Draper::Decorator
  delegate_all

  def main_platform
    @main_platform ||= (platforms.first || Platform.all_platforms).decorate
  end

  def main_repo
    @main_repo ||= repos.first.andand.decorate
  end

  def stars
    h.number_with_delimiter(model.stars)
  end

  def description
    model.description.presence || 
    main_repo.andand.description.presence ||
    h.nbsp
  end

  def platform_names
    @platform_names ||= platforms.sort_by(&:position).map(&:name).join('/')
  end

  def repo_names
    @repo_names ||= repos.sort_by(&:score).reverse.map(&:decorate).map(&:name).to_sentence
  end
end
