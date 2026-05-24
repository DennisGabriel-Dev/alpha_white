# frozen_string_literal: true

# https://resend.com/docs/send-with-ruby
Resend.api_key = ENV.fetch("RESEND_API_KEY", nil)
