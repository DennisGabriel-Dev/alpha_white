class SidekiqSuperAdminGate
  def initialize(app)
    @app = app
  end

  def call(env)
    user = env["warden"]&.user(:user)
    return redirect_to(Rails.application.routes.url_helpers.new_user_session_path) unless user

    return forbidden unless user.super_admin?

    @app.call(env)
  end

  private

  def redirect_to(location)
    [302, { "Location" => location, "Content-Type" => "text/html", "Content-Length" => "0" }, []]
  end

  def forbidden
    [403, { "Content-Type" => "text/plain; charset=utf-8" }, ["Acesso negado."]]
  end
end
