# frozen-string-literal: true

# Custom patch to flatten keys and sanitize values
module Enumerable
  def flatten_with_path(parent_prefix = nil)
    res = {}

    self.each_with_index do |elem, i|
      if elem.is_a?(Array)
        k, v = elem
      else
        k, v = i, elem
      end

      key = parent_prefix ? "#{parent_prefix}_#{k}" : k # assign key name for result hash
      key = key.gsub(/-/,'_').gsub(/\./, '_dot_').gsub(/\//, '_slash_')

      if v.is_a? Enumerable
        res.merge!(v.flatten_with_path(key)) # recursive call to flatten child elements
      else
        if v.is_a?(String)
          res[key] = sanitize_value(v)
        elsif v.nil?
          res[key] = 'null'
        else
          res[key] = v
        end
      end
    end

    res
  end

  def sanitize_value(value)
    value = CGI.escape(value) if value.start_with?('{')
    value&.gsub(%r{/^//}, '')
  end
end
