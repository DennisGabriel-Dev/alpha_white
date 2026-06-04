class TenantSettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_super_admin!

  def edit
    @tenant = current_tenant
    @themes = Tenant::THEMES
    @feature_flags = Tenant::FEATURE_FLAGS
  end

  def update
    @tenant = current_tenant
    @themes = Tenant::THEMES
    @feature_flags = Tenant::FEATURE_FLAGS

    @tenant.assign_attributes(brand_params.except(:feature_flags))
    @tenant.assign_feature_flags_from_params(params.dig(:tenant, :feature_flags), form: true)

    if @tenant.save
      redirect_to edit_tenant_setting_path, notice: "Configurações atualizadas com sucesso!"
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def brand_params
    params.require(:tenant).permit(:theme, :primary_color, :tagline, :meta_description, :logo, :favicon)
  end

  def require_super_admin!
    unless tenant_admin?
      redirect_to root_path, alert: "Acesso restrito."
    end
  end
end
