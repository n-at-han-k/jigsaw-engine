namespace :jigsaw do
  namespace :install do
    desc "Install Jigsaw seed files into app/javascript/seeds/"
    task :seeds do
      source = Jigsaw::Engine.root.join("app/javascript/seeds")
      destination = Rails.root.join("app/javascript/seeds")

      unless source.exist?
        abort "[jigsaw] Source seeds directory not found: #{source}"
      end

      installed = 0
      skipped = 0

      Dir.glob(source.join("**/*")).each do |src_file|
        next if File.directory?(src_file)

        relative = Pathname.new(src_file).relative_path_from(source)
        dest_file = destination.join(relative)

        if dest_file.exist?
          skipped += 1
          next
        end

        FileUtils.mkdir_p(dest_file.dirname)
        FileUtils.cp(src_file, dest_file)
        installed += 1
      end

      puts "[jigsaw] Installed #{installed} seed files to #{destination}"
      puts "[jigsaw] Skipped #{skipped} existing files" if skipped > 0
    end
  end
end
