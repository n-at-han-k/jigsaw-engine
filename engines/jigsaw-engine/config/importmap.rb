pin_all_from Jigsaw::Engine.root.join("app/javascript/jigsaw/controllers"),
  under: "controllers", to: "jigsaw/controllers"

pin "jigsaw/lib/generate_layout_css", to: "jigsaw/lib/generate_layout_css.js"

pin "monaco", to: "/monaco-editor/index.js"
pin "dpp", to: "https://cdn.jsdelivr.net/gh/robtweed/DPP/src/dpp_browser.min.js"
pin "react", to: "https://esm.sh/react@19?dev"
pin "react-dom", to: "https://esm.sh/react-dom@19?dev"
pin "react-dom/client", to: "https://esm.sh/react-dom@19/client?dev"
pin "react/jsx-runtime", to: "https://esm.sh/react@19/jsx-runtime?dev"
