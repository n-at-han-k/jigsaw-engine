DocType(:html)

Html {
  Head {
    Title { text @page_title || "Jigsaw" }
    Meta(charset: "utf-8")
    Meta(name: "viewport", content: "width=device-width,initial-scale=1")
    CsrfMetaTags()
    CspMetaTag()
    StylesheetLink("stylesheets.css")
    Link(rel: "stylesheet", href: "/monaco-editor/index.css")
    Script(src: "https://cdn.tailwindcss.com")
    Script { text "tailwind.config = { corePlugins: { preflight: false } }" }
    text fui_javascript_tags
    JavascriptImportmap()
  }
  Body {
    Flyout(direction: :right) { |c|
      c.content {
        Wrapper(data: { controller: "flyout-resize" }) {
          TurboFrame(id: "editor")
        }
      }
    }

    Pusher {
      text yield
    }

    Modal(turbo: true, blurring: true)
  }
}
