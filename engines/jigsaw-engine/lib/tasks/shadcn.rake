namespace :jigsaw do
  namespace :shadcn do
    desc "Install shadcn components into the engine. Usage: rake jigsaw:shadcn:install[button,dropdown-menu,sheet]"
    task :install, [:components] => :environment do |_t, args|
      components = args[:components]&.split(",") || []
      components += args.extras if args.extras.any?

      if components.empty?
        puts "Usage: rake jigsaw:shadcn:install[button,dropdown-menu,sheet]"
        abort "Error: No components specified."
      end

      engine_root = Jigsaw::Engine.root
      components_dir = engine_root.join("app/javascript/jigsaw/components/ui")
      importmap_path = engine_root.join("config/importmap.rb")

      # Create temp project for shadcn CLI
      require "tmpdir"
      Dir.mktmpdir("shadcn") do |tmpdir|
        puts "Setting up temporary shadcn project..."

        # Minimal package.json
        File.write("#{tmpdir}/package.json", <<~JSON)
          {
            "name": "shadcn-tmp",
            "private": true,
            "type": "module",
            "dependencies": {
              "react": "^19.0.0",
              "react-dom": "^19.0.0"
            }
          }
        JSON

        # Minimal tsconfig
        File.write("#{tmpdir}/tsconfig.json", <<~JSON)
          {
            "compilerOptions": {
              "target": "ESNext",
              "module": "ESNext",
              "moduleResolution": "bundler",
              "jsx": "react-jsx",
              "baseUrl": ".",
              "paths": { "@/*": ["./src/*"] }
            }
          }
        JSON

        # shadcn components.json
        File.write("#{tmpdir}/components.json", <<~JSON)
          {
            "$schema": "https://ui.shadcn.com/schema.json",
            "style": "new-york",
            "rsc": false,
            "tsx": true,
            "tailwind": {
              "config": "tailwind.config.js",
              "css": "src/index.css",
              "baseColor": "neutral",
              "cssVariables": true
            },
            "aliases": {
              "components": "@/components",
              "utils": "@/lib/utils",
              "ui": "@/components/ui",
              "lib": "@/lib",
              "hooks": "@/hooks"
            },
            "iconLibrary": "lucide"
          }
        JSON

        # Minimal tailwind config (required by shadcn CLI)
        File.write("#{tmpdir}/tailwind.config.js", "export default { content: ['./src/**/*.{ts,tsx}'] }\n")

        # Required directories and utility file
        FileUtils.mkdir_p("#{tmpdir}/src/lib")
        FileUtils.mkdir_p("#{tmpdir}/src/components/ui")
        FileUtils.mkdir_p("#{tmpdir}/src/hooks")

        File.write("#{tmpdir}/src/lib/utils.ts", <<~TS)
          import { clsx, type ClassValue } from "clsx"

          export function cn(...inputs: ClassValue[]) {
            return clsx(inputs)
          }
        TS

        File.write("#{tmpdir}/src/index.css", "@tailwind base;\n@tailwind components;\n@tailwind utilities;\n")

        # Download components via shadcn CLI
        puts "Downloading components: #{components.join(', ')}"
        system("cd #{tmpdir} && npx shadcn@latest add #{components.join(' ')} --yes --overwrite", exception: true)

        # Compile TSX → JS with esbuild
        puts "\nCompiling TSX → JS..."
        FileUtils.mkdir_p("#{tmpdir}/out")

        Dir.glob("#{tmpdir}/src/components/ui/*.tsx").each do |file|
          basename = File.basename(file, ".tsx")
          outfile = "#{tmpdir}/out/#{basename}.js"

          system(
            "npx esbuild #{file}" \
            " --bundle" \
            " --format=esm" \
            " --target=esnext" \
            " --jsx=automatic" \
            " --external:react" \
            " --external:react-dom" \
            " --external:react/jsx-runtime" \
            " '--external:@radix-ui/*'" \
            " --external:clsx" \
            " --external:class-variance-authority" \
            " --external:lucide-react" \
            " --outfile=#{outfile}",
            exception: true
          )
          puts "  Compiled: #{basename}.js"
        end

        # Compile utils
        utils_file = "#{tmpdir}/src/lib/utils.ts"
        if File.exist?(utils_file)
          system(
            "npx esbuild #{utils_file}" \
            " --bundle" \
            " --format=esm" \
            " --target=esnext" \
            " --external:clsx" \
            " --external:tailwind-merge" \
            " --outfile=#{tmpdir}/out/utils.js",
            exception: true
          )
          puts "  Compiled: utils.js"
        end

        # Install compiled files
        puts "\nInstalling to #{components_dir}..."
        FileUtils.mkdir_p(components_dir)

        importmap_content = File.read(importmap_path)

        Dir.glob("#{tmpdir}/out/*.js").each do |file|
          basename = File.basename(file)
          pin_name = File.basename(file, ".js")

          FileUtils.cp(file, components_dir.join(basename))
          puts "  Installed: #{basename}"

          # Add importmap pin if not present
          pin_path = if pin_name == "utils"
            "@/lib/utils"
          else
            "@/components/ui/#{pin_name}"
          end

          if importmap_content.exclude?(pin_path)
            pin_line = "pin \"#{pin_path}\", to: \"jigsaw/components/ui/#{basename}\"\n"
            File.open(importmap_path, "a") { |f| f.write(pin_line) }
            puts "  Added importmap pin: #{pin_path}"
          end
        end
      end

      puts "\nDone! Next steps:"
      puts "  1. Edit files in #{components_dir}/ to replace Tailwind classes with Fomantic-UI classes"
      puts "  2. Add any missing Radix importmap pins to config/importmap.rb"
    end
  end
end
