class TenantSettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_super_admin!

  def edit
    @tenant = current_tenant
    @themes = Tenant::THEMES
  end

  def update
    @tenant = current_tenant

    if @tenant.update(theme_params)
      redirect_to edit_tenant_setting_path, notice: "Tema atualizado com sucesso!"
    else
      @themes = Tenant::THEMES
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def theme_params
    params.require(:tenant).permit(:theme, :primary_color)
  end

  def require_super_admin!
    unless super_admin?
      redirect_to root_path, alert: "Acesso restrito."
    end
  end
end
