# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Devise auth layout (sem menu lateral)", type: :request do
  let(:tenant) { create(:tenant, :merma) }
  let(:headers) { { "HOST" => "#{tenant.subdomain}.lvh.me" } }

  it "login não renderiza a sidebar Merma" do
    get new_user_session_path, headers: headers

    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include('id="merma-sidebar-search"')
  end

  it "cadastro não renderiza a sidebar Merma" do
    get new_user_registration_path, headers: headers

    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include('id="merma-sidebar-search"')
  end
end
