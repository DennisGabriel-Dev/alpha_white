class Api::V1::BaseController < ApplicationController
  include ApiAuthorizable
  include ApiHateoas
  include ApiJwtAuthenticatable
end
