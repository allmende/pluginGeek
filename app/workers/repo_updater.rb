class RepoUpdater

  ###
  #
  #   RepoUpdater
  #
  #   Instance Methods:
  #     - perform('repo_owner/repo_name'): Update a single repo from Github
  #
  #   Class Methods:
  #     - perform_async('repo_owner/repo_name'): Schedule a single repo
  #         to be updated from Github asynchronously by the Sidekiq process
  #     - update_repos_sidekiq: Trigger an asynchronous,
  #         Sidekiq-powered update of all repos
  #     - update_repos_serial: Update all repos in serial,
  #         blocking the Thread in which it is called
  #
  ###

  # Include Sidekiq::Worker Module
  include Sidekiq::Worker

 # Github Attribute Mapping
  GITHUB_REPO_ATTRIBUTES = Hash[full_name: 'full_name', name: 'name',
      description: 'description', watchers: 'watchers', forks: 'forks',
      github_url: 'html_url', homepage_url: 'homepage', owner: ['owner', 'login'], github_updated_at: 'pushed_at' ].freeze

  # Initialize a connection pool
  GITHUB_POOL = ConnectionPool.new(size: 12, timeout: 10) { HTTPClient.new }

  def perform(repo_id)
    # Pick a connection from the connection pool
    GITHUB_POOL.with_connection do |github|
      # Find repo
      repo = Repo.find_or_initialize_by_full_name(repo_id)

      # HTTP Request
      res = github.get('https://api.github.com/repos/' + repo.full_name)

      # Exit on error
      # REVIEW: This could be the place for setting a flag is an update job fails for an existing repo
      if res.status != 200
        # Set flag unless repo is a new record
        repo.new_record? and repo.update_attribute('update_success', false)
        return false
      end

      # Success Handling
      github_repo = JSON.parse(res.body)

      # Update every attribute individually
      repo = recursive_update_of_repo_attributes(repo, github_repo)

      # Make homepage_url absolute
      #   will be relative e.g. for 'activeadmin.info'
      #   and assign the github_url to homepage_url if none is given
      if repo[:homepage_url].present?
        repo[:homepage_url] = "http://" + repo[:homepage_url] unless repo[:homepage_url].start_with?('http')
      else
        repo[:homepage_url] = repo[:github_url]
      end

      # Limit description length
      # (only if a repo owner think this is the place for a novel)
      repo[:description] &&= repo[:description].truncate(300)

      # Calculate Knight Score
      repo[:knight_score] = knight_score(github_repo)

      # Save Repo
      if repo.save
        # Validations fine
        Rails.logger.info "Updated repo '#{ repo.full_name }'"
        # Set flag
        repo.update_attribute('update_success', true) unless repo.update_success == true
        true
      else
        # e.g. Validation errors
        Rails.logger.error "Failed updating/saving repo '#{ repo.full_name }'"
        # Log repo validation errors
        repo.errors.full_messages.each { |msg| Rails.logger.error msg }
        # Set flag
        repo.update_attribute('update_success', false)
        false
      end
    end
  end

  # update all repos
  def self.update_repos_sidekiq
    Rails.logger.info 'Scheduling all repos to be updated by Sidekiq asynchronously...'
    Repo.pluck(:full_name).each { |id| perform_async(id) }
    Rails.logger.info 'Finished scheduling all repos to be updated by Sidekiq asynchronously'

  end

  # update all repos sync
  def self.update_repos_serial
    Rails.logger.info 'Updating repos from github in serial...'
    repo_updater = RepoUpdater.new
    Repo.pluck(:full_name).each { |id| repo_updater.perform(id) }
    Rails.logger.info 'Finished updating repos from github in serial'

  end

protected

  # Update Repo Attributes recursively
  def recursive_update_of_repo_attributes(repo, github_repo)
    # Mapped attributes
    GITHUB_REPO_ATTRIBUTES.each do |repo_attr, github_attr|
      # Cast String to Array
      h = github_attr.kind_of?(String) ? github_attr.split : github_attr

      # Recursive lookup and assignment
      h.size.times do |index|
        repo[repo_attr] = index.zero? ? github_repo[h[index]] : repo[repo_attr][h[index]]
      end
    end

    # Return repo
    return repo
  end

  # Calculate Knight Score
  #   calculate knight score
  #   returns knight score as an integer
  def knight_score(github_repo)
    (github_repo['watchers'] * activity_score(github_repo['pushed_at'])).ceil
  end

  # Calculate Acitvity Score
  #   used as a multiplier when calculating a repo's knight score
  def activity_score(time)
    diff = Time.now - time.to_datetime
    score = case diff
            when 0..2.months                    then (2.0 - ( diff /  2.months * 0.4 ))
            when 2.months+1.second..6.months    then (1.6 - ( diff /  6.months * 0.4 ))
            when 6.months+1.second..12.months   then (1.2 - ( diff / 12.months * 0.3 ))
            when 12.months+1.second..18.months  then (0.9 - ( diff / 18.months * 0.2 ))
            when 18.months+1.second..24.months  then (0.7 - ( diff / 24.months * 0.2 ))
            when 24.months+1.second..36.months  then (0.5 - ( diff / 36.months * 0.2 ))
            else  0.3
            end
    score
  end
end