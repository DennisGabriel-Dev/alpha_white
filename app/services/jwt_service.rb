# frozen_string_literal: true

class JwtService
  ALGORITHM = "HS256"
  DEFAULT_EXPIRY = 7.days

  class << self
    def encode(user:, exp: DEFAULT_EXPIRY.from_now)
      payload = {
        sub: user.id,
        tenant_id: user.tenant_id,
        exp: exp.to_i
      }
      JWT.encode(payload, secret, ALGORITHM)
    end

    def decode(token)
      payload, _header = JWT.decode(token, secret, true, { algorithm: ALGORITHM })
      payload.with_indifferent_access
    rescue JWT::DecodeError
      nil
    end

    private

    def secret
      Rails.application.secret_key_base
    end
  end
end
