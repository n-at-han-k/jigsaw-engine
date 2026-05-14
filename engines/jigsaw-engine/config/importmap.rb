pin_all_from Jigsaw::Engine.root.join("app/javascript/jigsaw/controllers"),
  under: "controllers", to: "jigsaw/controllers"

pin "jigsaw/lib/generate_layout_css", to: "jigsaw/lib/generate_layout_css.js"

pin "monaco", to: "/monaco-editor/index.js"
pin "dpp", to: "https://cdn.jsdelivr.net/gh/robtweed/DPP/src/dpp_browser.min.js"
pin "react", to: "https://esm.sh/react@19?dev"
pin "react-dom", to: "https://esm.sh/react-dom@19?dev"
pin "react-dom/client", to: "https://esm.sh/react-dom@19/client?dev"
pin "react/jsx-runtime", to: "https://esm.sh/react@19/jsx-runtime?dev"

# Radix UI primitives
pin "@radix-ui/react-dropdown-menu", to: "https://esm.sh/@radix-ui/react-dropdown-menu@2?bundle&external=react,react-dom,react%2Fjsx-runtime"
pin "@radix-ui/react-dialog", to: "https://esm.sh/@radix-ui/react-dialog@1?bundle&external=react,react-dom,react%2Fjsx-runtime"
pin "@radix-ui/react-slot", to: "https://esm.sh/@radix-ui/react-slot@1?bundle&external=react,react-dom,react%2Fjsx-runtime"

# Utilities
pin "clsx", to: "https://esm.sh/clsx@2?bundle"
pin "class-variance-authority", to: "https://esm.sh/class-variance-authority@0.7?bundle"
pin "lucide-react", to: "https://esm.sh/lucide-react@0.460?bundle&external=react,react%2Fjsx-runtime"
pin "@/components/ui/button", to: "jigsaw/components/ui/button.js"
pin "@/components/ui/dropdown-menu", to: "jigsaw/components/ui/dropdown-menu.js"
pin "@/components/ui/sheet", to: "jigsaw/components/ui/sheet.js"
pin "@/lib/utils", to: "jigsaw/components/ui/utils.js"

# WebContainer IDE
pin "@webcontainer/api", to: "https://esm.sh/@webcontainer/api@1?bundle"
pin "@monaco-editor/react", to: "https://esm.sh/@monaco-editor/react@4?bundle&external=react,react-dom,react%2Fjsx-runtime"
pin "@monaco-editor/loader", to: "https://esm.sh/@monaco-editor/loader@1?bundle"
pin "@radix-ui/react-context-menu", to: "https://esm.sh/@radix-ui/react-context-menu@2?bundle&external=react,react-dom,react%2Fjsx-runtime"
pin "@radix-ui/react-label", to: "https://esm.sh/@radix-ui/react-label@2?bundle&external=react,react-dom,react%2Fjsx-runtime"
pin "xterm", to: "https://esm.sh/xterm@5?bundle"
pin "xterm-addon-fit", to: "https://esm.sh/xterm-addon-fit@0.8?bundle"
pin "xterm-addon-web-links", to: "https://esm.sh/xterm-addon-web-links@0.9?bundle"
