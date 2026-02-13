# frozen_string_literal: true

# Base para controllers da API V1 que exigem autenticação
class Api::V1::BaseController < ApplicationController
  include ApiAuthorizable

  before_action :authenticate_user!
end
