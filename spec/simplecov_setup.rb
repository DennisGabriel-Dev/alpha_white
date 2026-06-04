# frozen_string_literal: true

# Carregado no início de spec_helper.rb (antes do Rails).
require "simplecov"
require "simplecov-cobertura"

PROJECT_ROOT = File.expand_path("..", __dir__)

SimpleCov.start "rails" do
  root PROJECT_ROOT
  coverage_dir File.join(PROJECT_ROOT, "coverage")

  add_filter "/spec/"
  add_filter "/vendor/"
  add_filter "/db/"
  add_filter "/bin/"
  add_filter "/tmp/"

  add_group "Controllers", "app/controllers"
  add_group "Models", "app/models"
  add_group "Services", "app/services"
  add_group "Jobs", "app/jobs"
  add_group "Lib", "lib"

  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::CoberturaFormatter,
    SimpleCov::Formatter::HTMLFormatter
  ])
end
