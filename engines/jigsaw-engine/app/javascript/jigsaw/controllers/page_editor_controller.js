import { Controller } from "@hotwired/stimulus"
import { generateLayoutCss, generateLayoutHtml } from "jigsaw/lib/generate_layout_css"

export default class extends Controller {
  static targets = [
    "grid",
    "cell",
    "panel",
    "configHidden",
    "colTrackControls",
    "rowTrackControls",
    "cssOutput",
    "htmlOutput",
    "jsonOutput"
  ]

  connect() {
    this._loadConfig()
    this._applyGridStyles()
    this._renderOutput()
  }

  _loadConfig() {
    try {
      this.config = JSON.parse(this.configHiddenTarget.value)
    } catch {
      this.config = {}
    }
  }

  _applyGridStyles() {
    if (!this.hasGridTarget) return
    const grid = this.gridTarget
    const c = this.config

    if (!c.areas || !c.columns || !c.rows) return

    grid.style.display = "grid"
    grid.style.width = c.gridWidth || "100%"
    grid.style.gridTemplateColumns = c.columns.join(" ")
    grid.style.gridTemplateRows = c.rows.join(" ")
    grid.style.gap = `${c.rowGap}${c.rowGapUnit || "px"} ${c.colGap}${c.colGapUnit || "px"}`
    grid.style.gridTemplateAreas = c.areas.map(row => `"${row.join(" ")}"`).join(" ")
  }

  _renderOutput() {
    if (!this.config) return
    const css = generateLayoutCss(this.config)
    const html = generateLayoutHtml(this.config)
    if (this.hasCssOutputTarget) this.cssOutputTarget.textContent = css
    if (this.hasHtmlOutputTarget) this.htmlOutputTarget.textContent = html
    if (this.hasJsonOutputTarget) this.jsonOutputTarget.textContent = JSON.stringify(this.config, null, 2)
  }
}
