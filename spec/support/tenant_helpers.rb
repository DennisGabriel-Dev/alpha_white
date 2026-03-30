# Helper para definir o tenant atual em qualquer spec.
# Uso: set_tenant(tenant) ou with_tenant { ... }
module TenantHelpers
  def set_tenant(tenant)
    ActsAsTenant.current_tenant = tenant
  end

  def clear_tenant
    ActsAsTenant.current_tenant = nil
  end
end

RSpec.configure do |config|
  config.before(:each) { ActsAsTenant.current_tenant = nil }
  config.after(:each)  { ActsAsTenant.current_tenant = nil }
end
