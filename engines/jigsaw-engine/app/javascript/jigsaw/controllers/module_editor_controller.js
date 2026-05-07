import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "editorContainer"]
  static values = {
    moduleId:       Number,
    dataSource:     String,
    renderSource:   String,
    renderLanguage: String,
    config:         String
  }

  connect() {
    this.activeTab = "render"
    this.sources = {
      data:   this.dataSourceValue,
      render: this.renderSourceValue,
      config: this.configValue
    }

    setTimeout(() => this._loadEditor(), 100)
  }

  _loadEditor() {
    const editor = this._editorCtrl()
    if (editor) {
      editor.setValue(this.sources[this.activeTab], "javascript")
    }
  }

  switchTab(e) {
    const tabName = e.currentTarget.dataset.tab
    const editor = this._editorCtrl()

    if (editor) {
      this.sources[this.activeTab] = editor.getValue()
    }

    this.activeTab = tabName

    this.tabTargets.forEach(t => {
      t.classList.toggle("active", t.dataset.tab === tabName)
    })

    if (editor) {
      const lang = tabName === "config" ? "json" : "javascript"
      editor.setValue(this.sources[tabName], lang)
    }
  }

  _editorCtrl() {
    const el = this.element.querySelector("[data-controller~='monaco-editor']")
    if (!el) return null
    return this.application.getControllerForElementAndIdentifier(el, "monaco-editor")
  }

  _moduleCtrl() {
    const el = document.querySelector(
      `[data-controller~='custom-module'][data-custom-module-id-value='${this.moduleIdValue}']`
    )
    return el?.module
  }

  async hotSwap() {
    const editor = this._editorCtrl()
    if (!editor) return

    this.sources[this.activeTab] = editor.getValue()
    const source = this.sources[this.activeTab]
    const moduleCtrl = this._moduleCtrl()
    if (!moduleCtrl) return

    try {
      if (this.activeTab === "config") {
        moduleCtrl.configValue = JSON.parse(source)
        await moduleCtrl.load()
        return
      }

      let jsSource = source
      if (this.activeTab === "render" && this.renderLanguageValue === "jsx") {
        jsSource = await this._compileJsx(source)
      }

      const blob = new Blob([jsSource], { type: "text/javascript" })
      const url = URL.createObjectURL(blob)
      const mod = await import(url)
      URL.revokeObjectURL(url)

      if (this.activeTab === "data") {
        moduleCtrl.fetchData = mod.default.bind(moduleCtrl)
      } else if (this.activeTab === "render") {
        moduleCtrl.render = mod.default.bind(moduleCtrl)
      }

      await moduleCtrl.load()
    } catch (err) {
      console.error("[module-editor] hot-swap failed:", err)
    }
  }

  async save() {
    const editor = this._editorCtrl()
    if (!editor) return

    this.sources[this.activeTab] = editor.getValue()

    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content
    const headers = {
      "Content-Type": "application/json",
      "X-CSRF-Token": csrfToken
    }

    try {
      const resp = await fetch(`/jigsaw/page_modules/${this.moduleIdValue}`, {
        method: "PATCH", headers,
        body: JSON.stringify({
          page_module: {
            data_source: this.sources.data,
            render_source: this.sources.render,
            config: this.sources.config
          }
        })
      })
      if (!resp.ok) throw new Error(`Save failed: ${resp.status}`)
    } catch (err) {
      console.error("[module-editor] save failed:", err)
    }
  }

  async _compileJsx(source) {
    if (!this._swc) {
      const swc = await import("https://esm.sh/@swc/wasm-web@1")
      await swc.default()
      this._swc = swc
    }
    const result = this._swc.transformSync(source, {
      jsc: {
        parser: { syntax: "ecmascript", jsx: true },
        transform: { react: { runtime: "automatic" } }
      },
      module: { type: "es6" }
    })
    return result.code
  }
}
