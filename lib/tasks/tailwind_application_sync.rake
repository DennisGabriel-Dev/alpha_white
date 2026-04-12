# frozen_string_literal: true

# tailwindcss-rails sempre grava em app/assets/builds/tailwind.css; os layouts usam
# stylesheet_link_tag "application" → app/assets/builds/application.css
Rake::Task["tailwindcss:build"].enhance do
  require "fileutils"
  src = Rails.root.join("app/assets/builds/tailwind.css")
  dest = Rails.root.join("app/assets/builds/application.css")
  FileUtils.cp(src, dest) if File.exist?(src)
end
