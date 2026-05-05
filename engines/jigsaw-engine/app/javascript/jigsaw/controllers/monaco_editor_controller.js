import { Controller } from "@hotwired/stimulus"
import monaco, { initVimMode, VimMode } from "monaco"

export default class extends Controller {
  static targets = ["container", "status", "field"]

  connect() {
    const initialValue = this.hasFieldTarget ? this.fieldTarget.value : ""

    this.editor = monaco.editor.create(this.containerTarget, {
      value: initialValue,
      language: this.data.get("language") || "javascript",
      theme: "vs-dark",
      automaticLayout: true,
      minimap: { enabled: false },
      fontSize: 14
    })

    if (this.hasStatusTarget) {
      this.vimMode = initVimMode(this.editor, this.statusTarget)
    }

    if (this.hasFieldTarget) {
      this.editor.onDidChangeModelContent(() => {
        this.fieldTarget.value = this.editor.getValue()
      })
    }

    this.element.addEventListener("keydown", (e) => {
      if (e.key === "Escape" || e.keyCode === 27) e.stopPropagation()
      if (e.key === "Tab" || e.keyCode === 9) e.stopPropagation()
    })
  }

  setValue(value, language) {
    const model = this.editor.getModel()
    if (language) monaco.editor.setModelLanguage(model, language)
    this.editor.setValue(value)
  }

  getValue() {
    return this.editor.getValue()
  }

  disconnect() {
    if (this.vimMode) this.vimMode.dispose()
    if (this.editor) this.editor.dispose()
  }
}
