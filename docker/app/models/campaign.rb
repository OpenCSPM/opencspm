# frozen_string_literal: true

#
# Campaign
#
class Campaign < ApplicationRecord
  belongs_to :user
  before_save :update_control_count

  validates :name, presence: true, length: { maximum: 120 }

  #
  # Return the Controls that match this Campaign's filters
  #
  def controls
    search_filter = filters['search'] ? ['%', filters['search'], '%'].join : nil
    status_filter = filters['status'] != 'any' ? filters['status'] : nil
    impact_filter = ActiveRecord::Base.connection.type_cast(impact_range(filters['impact']))
    tags_filter = filters['tags']
    must_have_all_tags = !tags_filter.empty? && filters['tag_mode'] == 'all'

    # controls = Control.with_mapped_tags
    controls = Control.with_mapped_tags

    # filters MUST have an Impact Range
    controls = controls.where('impact <@ ?::int4range', impact_filter)
    # filters MAY have a Search filter
    controls = controls.where('title ILIKE ?', search_filter) if search_filter
    # filters MAY have a Status filter
    controls = controls.where(status: status_filter) if status_filter
    # filters MAY have a Tags filter
    controls = controls.where(tags: { name: tags_filter }) if tags_filter && !tags_filter.empty?
    # filters MAY have "all" tags flag set
    controls = controls.having('json_agg(tags.name)::jsonb @> ?::jsonb', tags_filter.to_s) if must_have_all_tags

    controls
  end

  #
  # Return all Results for the Controls that match this Campaign's filters
  #
  def results
    # TODO: refactor to a JOIN controls
    # TODO: limit results to last 90 days
    Result.where(control_id: controls.pluck(:id))
  end

  def update_control_count
    self.control_count = controls.length
  end

  private

  #
  # Return the numeric range of the named impact
  #
  def impact_range(impact)
    impact = impact.downcase.to_sym

    ranges = {
      any: 1..10,
      critical: 10..10,
      high: 8..9,
      moderate: 4..7,
      medium: 4..7,
      low: 1..3
    }

    ranges[impact] || ranges[:any]
  end

  def valid_terms; end

  def valid_statuses; end

  def valid_impacts; end

  def valid_tags; end
end
