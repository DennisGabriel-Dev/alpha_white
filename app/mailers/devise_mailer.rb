# frozen_string_literal: true

# Links de reset precisam do subdomínio do tenant (ex.: objetivo.lvh.me).
class DeviseMailer < Devise::Mailer
  def reset_password_instructions(record, token, opts = {})
    @tenant_subdomain = record.tenant&.subdomain
    super
  end

  def default_url_options
    options = super.dup
    return options if @tenant_subdomain.blank?

    base_host = ENV.fetch("MAILER_HOST_BASE", "lvh.me")
    options[:host] = "#{@tenant_subdomain}.#{base_host}"
    options[:protocol] = Rails.env.production? ? "https" : "http"
    options[:port] = 3000 if Rails.env.development?
    options
  end
end
