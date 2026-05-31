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

  def tenant_admin?
    return false unless user_signed_in?

    current_user.super_admin? || current_user.tenant_admin?
  end

  def instructor?
    return false unless user_signed_in?

    current_user.instructor?
  end

  def reports_aluno_path_allowed?
    user_signed_in? && current_user.student?
  end

  def reports_turma_path_allowed?
    user_signed_in? && (current_user.instructor? || current_user.tenant_admin? || current_user.super_admin?)
  end

  def reports_escola_path_allowed?
    user_signed_in? && (current_user.tenant_admin? || current_user.super_admin?)
  end

  def me_achievements_path_allowed?
    user_signed_in? && current_user.student?
  end

  def staff_users_path_allowed?
    tenant_admin?
  end
end
