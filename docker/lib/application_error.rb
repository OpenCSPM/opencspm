#
# Generic error class - http://abhisheksarka.github.io/custom-errors-in-rails/
#
class ApplicationError < StandardError
  # responds to all the below attributes
  attr_accessor :config,
                :code,
                :message,
                :http_code

  # We pass config hash of the sort
  # {code: 100, message: 'Some Error Message', http_code: 501}
  def initialize(config)
    @config = config
    @code = config[:code]
    @message = config[:message]
    @http_code = config[:http_code]
  end

  class << self
    # Whenever we call something like ApplicationError::SomeCustomError
    # this method is triggered. We then do a look up in an error configuration
    # file, discussed below, and then determine what error object to instantiate
    def const_missing(name)
      I18n.reload!
      err_hash = t(name)
      if err_hash.is_a? Hash
        err_hash[:name] = name
        ApplicationError.new(err_hash)
      else
        super
      end
    end

    def t(error_name)
      I18n.t("error.#{error_name.to_s.underscore}")
    end
  end
end
