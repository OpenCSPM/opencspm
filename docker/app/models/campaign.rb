class Campaign < ApplicationRecord
  belongs_to :user
  before_save :update_control_count

  #
  # Return the Controls that match this Campaign's filters
  #
  def controls
    search_filter = filters['search'] ? ['%', filters['search'], '%'].join : nil
    platform_filter = filters['platform'] != 'any' ? filters['platform'] : nil
    impact_filter = ActiveRecord::Base.connection.type_cast(impact_range(filters['impact']))
    tags_filter = filters['tags']
    must_have_all_tags = !tags_filter.empty? && filters['tag_mode'] == 'all'

    controls = Control.includes(:tags)

    # filters MUST have an Impact Range
    controls = controls.where('impact <@ ?::int4range', impact_filter)
    # filters MAY have a Search filter
    controls = controls.where('title ILIKE ?', search_filter) if search_filter
    # filters MAY have a Platform filter
    controls = controls.where('platform ILIKE ?', platform_filter) if platform_filter
    # filters MAY have a Tags filter
    controls = controls.where(tags: { name: tags_filter }) if tags_filter && !tags_filter.empty?
    # filters MAY have "all" tags flag set
    must_have_all_tags ? controls.select { |c| c.tags.map(&:name).sort == tags_filter.sort } : controls
  end

  #
  # Return all Results for the Controls that match this Campaign's filters
  #
  def results
    Result.where(control_id: controls.pluck(:id))
  end

  def update_control_count
    self.control_count = controls.count
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

  def valid_platforms; end

  def valid_impacts; end

  def valid_tags; end
end
