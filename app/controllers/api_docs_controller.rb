# frozen_string_literal: true

# Serve OpenAPI spec and Swagger UI for API documentation.
# Access at /api-docs (use same host/subdomain as your API).
class ApiDocsController < ActionController::Base
  skip_before_action :verify_authenticity_token
  layout false

  def index
    @spec_url = "#{request.base_url}/api-docs/spec"
    render :index, content_type: "text/html"
  end

  def spec
    spec_path = Rails.root.join("config", "openapi", "v1.yaml")
    raise ActiveRecord::RecordNotFound unless spec_path.exist?

    yaml = File.read(spec_path)
    render plain: yaml, content_type: "application/x-yaml"
  end
end
