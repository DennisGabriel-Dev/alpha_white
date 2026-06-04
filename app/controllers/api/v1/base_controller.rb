class Api::V1::BaseController < ApplicationController
  include ApiAuthorizable
  include ApiHateoas
  include ApiJwtAuthenticatable
  include ApiQuizSecrecy

  skip_before_action :ensure_user_belongs_to_current_tenant!
  skip_before_action :verify_authenticity_token
end
