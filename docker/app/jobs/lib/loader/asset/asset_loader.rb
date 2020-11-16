# frozen-string-literal: true

require_relative 'utils/enumerable'

# Base abstract class for assets to be loaded
class AssetLoader
  def initialize; end

  def load
    raise NotImplementedEror
  end

  private

  # sanitizes json values
  # TODO: utils instead
  def sanitize_value(value)
    value = CGI.escape(value) if value.start_with?('{')
    value&.gsub(%r{^//}, '')
  end

  def graphquery(query, _params = {})
    print '.'
    @db.query(query)
  end

  def fetch_current_properties_as_null(asset_label, asset_name)
    current_properties = graphquery("match(n:#{asset_label} { name: \"#{asset_name}\" }) return (n)").resultset
    return '' if current_properties == []

    # rubocop:disable Layout/LineLength
    current_properties = current_properties.first.first.reduce({}, :merge).tap { |hs| hs.delete('name') }.tap { |hs| hs.delete('asset_type') }.map { |h| "a.#{h[0]} = NULL" }.join ', '
    # rubocop:enable Layout/LineLength

    return '' if current_properties == ''

    current_properties + ', '
  end

  def prepare_properties(asset)
    # rubocop:disable Layout/LineLength
    asset.flatten_with_path.tap { |hs| hs.delete('name') }.tap { |hs| hs.delete('asset_type') }.map { |h| "a.#{h[0]} = \"#{h[1].to_s.gsub(/\"/, '\\"').gsub(/\n/,'\n')}\"" }.join ', '
    # rubocop:enable Layout/LineLength
  end
end
