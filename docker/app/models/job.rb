# frozen_string_literal: true

#
# Generic Job
#
class Job < ApplicationRecord
  has_many :results

  enum status: {
    running: 0,
    complete: 1,
    failed: -1
  }
  enum kind: {
    run: 0,
    load: 1,
    analyze: 2,
    parse: 3,
    cleanup: 4
  }, _prefix: :job

  #
  # Send an external webhook
  #
  def send_webhook
    config = Rails.application.config_for(:webhooks)

    return unless config.webhooks

    config.webhooks.each do |_k, webhook|
      next if webhook.nil?

      url = URI(webhook)
      headers = { 'content-type' => 'application/json' }
      payload = {
        'job_id' => id,
        'job_type' => kind,
        'status' => status,
        'results' => results.count
      }.to_json
      res = Net::HTTP.post(URI(url), payload, headers)

      res.code
    end
  end
end
