namespace :achievements do
  desc "Anexa imagens de app/assets/images/achievements/{slug}.png às conquistas (ignora default.png)"
  task attach_images: :environment do
    dir = Rails.root.join("app/assets/images/achievements")
    unless dir.directory?
      puts "Pasta não encontrada: #{dir}"
      next
    end

    Dir.glob(dir.join("*.png")).each do |path|
      slug = File.basename(path, ".png")
      next if slug == "default"

      achievement = Achievement.find_by(slug: slug)
      unless achievement
        puts "  ⚠️  Sem conquista com slug #{slug}"
        next
      end

      achievement.badge_image.attach(
        io: File.open(path),
        filename: File.basename(path),
        content_type: "image/png"
      )
      puts "  ✅ #{slug}"
    end
  end
end
