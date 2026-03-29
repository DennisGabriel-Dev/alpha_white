module PermissionHelper
  def tenant_present?
    current_tenant.present?
  end

  def admin_or_instructor?
    return false unless user_signed_in?

    current_user.super_admin? || current_user.tenant_admin? || current_user.instructor?
  end

  def student?
    return false unless user_signed_in?

    current_user.student?
  end

  def super_admin?
    return false unless user_signed_in?

    current_user.super_admin?
  end

  def instructor?
    return false unless user_signed_in?

    current_user.instructor?
  end
end
