class ReposController < ApplicationController

  #
  # Repo Actions
  #

  def index
    @repos = Repo.all
  end

  def show
    @repo = Repo.find_or_initialize_by_full_name(full_name_from_params)

    # Always redirect to base
    #   Be sure to return to finish request
    params[:leftover] and return redirect_to @repo

    # Redirect to create action if @repo is a new record
    @repo.new_record? and return redirect_to action: "create"
  end

  def create
    @repo = Repo.find_or_initialize_by_full_name(full_name_from_params)

    @repo.new_record? or flash[:notice] = "Repo '#{@repo.full_name}' already known."
    
    if @repo.first_update_from_github
      flash[:notice] ||= "Repo '#{@repo.full_name}' successfully added."
      redirect_to @repo
    else
      flash[:alert] = "Repo '#{@repo.full_name}' could NOT be added."
      redirect_to root_path
    end
  end

  #
  # User Actions
  #

  def user_show
    @repos = Repo.find_by_owner(params[:owner])
  end

  # List users repos + give ability to add more directly from github
  def user_new
    @repos = Repo.find_by_owner(params[:owner])
  end

  # Process input from user_new
  def user_create

  end



protected

  def full_name_from_params(owner = params[:owner], name = params[:name])
    "#{owner}/#{name}"
  end

end