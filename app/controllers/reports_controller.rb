class ReportsController < ApplicationController
  before_action :authenticate_user!

  def aluno
    require_student_for_aluno!
    @data = Reports::StudentPerformance.new(user: current_user, tenant: ActsAsTenant.current_tenant).call
  end

  def turma
    require_staff_for_turma!
    @data = Reports::ClassPerformance.new(tenant: ActsAsTenant.current_tenant).call
  end

  def escola
    require_admin_for_escola!
    @data = Reports::TenantOverview.new(tenant: ActsAsTenant.current_tenant).call
  end

  private

  def require_student_for_aluno!
    return if current_user.student?

    redirect_to root_path, alert: "Relatório disponível apenas para alunos."
  end

  def require_staff_for_turma!
    return if current_user.instructor? || current_user.tenant_admin? || current_user.super_admin?

    redirect_to root_path, alert: "Relatório da turma disponível para instrutores e administradores."
  end

  def require_admin_for_escola!
    return if current_user.tenant_admin? || current_user.super_admin?

    redirect_to root_path, alert: "Relatório da escola disponível apenas para administradores do cursinho."
  end
end
