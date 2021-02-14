# frozen_string_literal: true

class Api::SourcesController < ApplicationController
  before_action :set_source, only: %i[show update destroy]

  # GET /sources
  def index
    # re-read config.yml sources
    Source.new.refresh

    @sources = Source.all.order(id: :asc)

    render json: @sources
  end

  # GET /sources/1
  def show
    render json: @source
  end

  # POST /sources
  def create
    @source = Source.new(source_params)

    if @source.save
      render json: @source, status: :created, location: @source
    else
      render json: @source.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /sources/1
  def update
    if @source.update(source_params)
      @source.schedule_worker
      render json: @source
    else
      render json: @source.errors, status: :unprocessable_entity
    end
  end

  # DELETE /sources/1
  def destroy
    @source.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_source
    @source = Source.find(params[:id])
  end

  # Only allow a trusted parameter "allow list" through.
  def source_params
    params.require(:source).permit(:name, :status)
  end
end
