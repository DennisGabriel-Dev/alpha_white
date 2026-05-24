class ApplicationMailer < ActionMailer::Base
  default from: -> { ENV.fetch("MAILER_FROM", "Alpha White <onboarding@resend.dev>") }
  layout "mailer"
end
