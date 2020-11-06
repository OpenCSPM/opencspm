class Api::ProfilesController < ApplicationController
  before_action :set_profile, only: %i[show]

  # GET /profiles
  def index
    # @profiles = Profile.all
    @profiles = Profile.all

    # render json: @profiles
    render json: ProfilesSerializer.new(@profiles)
  end

  # GET /profiles/1
  def show
    render json: ProfileSerializer.new(@profile)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_profile
    @profile = Profile.find_by_id!(params[:id])
  end

  # Only allow a trusted parameter "allow list" through.
  def profile_params
    params.require(:profile).permit(:name, :author, :provider, :category, :status)
  end
end
