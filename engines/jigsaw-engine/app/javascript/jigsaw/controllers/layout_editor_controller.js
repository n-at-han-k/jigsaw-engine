import { Controller } from "@hotwired/stimulus"
import { generateLayoutCss, generateLayoutHtml } from "jigsaw/lib/generate_layout_css"

// Thin controller: reads DOM state into a config object, feeds it to the
// generator lib, and applies the output. No layout logic lives here.

export default class extends Controller {
  static targets = ["preview", "cssOutput", "htmlOutput", "jsonOutput", "configHidden", "panel"]

  connect() {
    this.rebuild()
  }

  rebuild() {
    const config = this._readConfig()
    const css = generateLayoutCss(config)
    const html = generateLayoutHtml(config)

    this._applyPreview(config)
    this._applyOutput(css, html, config)

    if (this.hasConfigHiddenTarget) {
      this.configHiddenTarget.value = JSON.stringify(config)
    }
  }

  // Called on area name change (after blur) — safe to fully rebuild
  updateOutput() {
    this.rebuild()
  }

  cycleUnit(event) {
    const btn = event.currentTarget
    const units = (btn.dataset.units || "fr,px,auto").split(",")
    const idx = units.indexOf(btn.textContent.trim())
    btn.textContent = units[(idx + 1) % units.length]
    this.rebuild()
  }

  togglePanel() {
    const page = this.element.querySelector(".editor-page")
    page.classList.toggle("full-width")
  }

  // --- Private: read state from DOM ---

  _readConfig() {
    const val = (id) => this.element.querySelector(`#${id}`)?.value || ""
    const unit = (id) => this.element.querySelector(`#${id}`)?.textContent.trim() || "fr"

    const rows = parseInt(val("rowCount")) || 3
    const cols = parseInt(val("colCount")) || 3
    const childrenCount = parseInt(val("childrenCount")) || (rows * cols)
    const defaultRowTrack = { value: parseFloat(val("rowHeight")) || 1, unit: unit("rowHeightUnit") }
    const defaultColTrack = { value: parseFloat(val("colWidth")) || 1, unit: unit("colWidthUnit") }

    // Build track arrays from per-track inputs (in preview) or defaults
    const rowTracks = this._readTracks("row", rows, defaultRowTrack)
    const colTracks = this._readTracks("col", cols, defaultColTrack)

    // Build areas from name inputs in the preview
    const areas = this._readAreas(rows, cols)
    const hasAreas = areas.flat().some(a => a !== ".")

    const config = {
      type: "grid",
      childrenCount,
      rows: rowTracks,
      columns: colTracks,
      rowGap: val("rowGap") !== "" ? parseFloat(val("rowGap")) : 8,
      rowGapUnit: unit("rowGapUnit"),
      colGap: val("colGap") !== "" ? parseFloat(val("colGap")) : 8,
      colGapUnit: unit("colGapUnit"),
    }

    if (hasAreas) config.areas = areas

    return config
  }

  _readTracks(axis, count, defaultTrack) {
    // Read stored tracks from config JSON (source of truth for per-track overrides)
    let storedTracks = []
    try {
      const prev = JSON.parse(this.configHiddenTarget.value)
      storedTracks = axis === "row" ? (prev.rows || []) : (prev.columns || [])
    } catch {}

    // Check if per-track inputs exist and were directly edited
    const input = this.previewTarget.querySelector(`.track-value-input[data-axis="${axis}"]`)
    if (input) {
      // Per-track inputs exist — read from them (user may have edited individual tracks)
      const tracks = []
      for (let i = 0; i < count; i++) {
        const inp = this.previewTarget.querySelector(`.track-value-input[data-axis="${axis}"][data-index="${i}"]`)
        const btn = this.previewTarget.querySelector(`.track-unit-btn[data-axis="${axis}"][data-index="${i}"]`)
        if (inp && btn) {
          tracks.push({ value: parseFloat(inp.value) || 1, unit: btn.textContent.trim() })
        } else {
          tracks.push({ ...defaultTrack })
        }
      }
      // If stored tracks all matched the old default, the sidebar change should win
      const storedAllSame = storedTracks.length > 0 && storedTracks.every(t =>
        t.value === storedTracks[0].value && t.unit === storedTracks[0].unit
      )
      const tracksMatchStored = tracks.length === storedTracks.length && tracks.every((t, i) =>
        t.value === storedTracks[i]?.value && t.unit === storedTracks[i]?.unit
      )
      if (storedAllSame && tracksMatchStored &&
          (defaultTrack.value !== storedTracks[0].value || defaultTrack.unit !== storedTracks[0].unit)) {
        return Array.from({ length: count }, () => ({ ...defaultTrack }))
      }
      return tracks
    }

    // No per-track inputs yet — use stored or default
    if (storedTracks.length === count) {
      return storedTracks.map(t => ({ value: t.value, unit: t.unit }))
    }
    return Array.from({ length: count }, () => ({ ...defaultTrack }))
  }

  _readAreas(rows, cols) {
    // Read previous areas from the JSON config (source of truth)
    let areas
    try {
      const prev = JSON.parse(this.configHiddenTarget.value)
      areas = prev.areas
    } catch {}

    if (!areas || areas.length !== rows || (areas[0] && areas[0].length !== cols)) {
      areas = Array.from({ length: rows }, (_, r) =>
        Array.from({ length: cols }, (_, c) => `c${r * cols + c + 1}`)
      )
    }

    // Apply any changes from visible inputs
    this.previewTarget.querySelectorAll(".area-name-input[data-row]").forEach(input => {
      const r = parseInt(input.dataset.row)
      const c = parseInt(input.dataset.col)
      const name = input.value.trim()
      if (r < rows && c < cols) {
        areas[r][c] = name || `c${r * cols + c + 1}`
      }
    })

    return areas
  }

  // --- Private: apply state to DOM ---

  _applyPreview(config) {
    const el = this.previewTarget
    el.innerHTML = ""

    const rows = config.rows.length
    const cols = config.columns.length

    // Column track controls
    const colControls = document.createElement("div")
    colControls.className = "track-controls track-controls--col"
    colControls.style.gridTemplateColumns = config.columns.map(t => t.unit === "auto" ? "auto" : `${t.value}${t.unit}`).join(" ")
    colControls.style.columnGap = `${config.colGap}${config.colGapUnit}`
    config.columns.forEach((t, i) => colControls.appendChild(this._trackControl("col", i, t)))
    el.appendChild(colControls)

    // Main preview area (relative container for grid + name overlay)
    const main = document.createElement("div")
    main.className = "preview-main"

    // The visible grid
    const grid = document.createElement("section")
    grid.className = "preview-grid"
    Object.assign(grid.style, {
      display: "grid",
      width: "100%",
      gap: `${config.rowGap}${config.rowGapUnit} ${config.colGap}${config.colGapUnit}`,
    })

    grid.style.gridTemplateRows = config.rows.map(t => t.unit === "auto" ? "auto" : `${t.value}${t.unit}`).join(" ")
    grid.style.gridTemplateColumns = config.columns.map(t => t.unit === "auto" ? "auto" : `${t.value}${t.unit}`).join(" ")

    // Build areas grid and apply grid-template-areas
    const areas = config.areas || Array.from({ length: rows }, (_, r) =>
      Array.from({ length: cols }, (_, c) => `c${r * cols + c + 1}`)
    )
    grid.style.gridTemplateAreas = areas.map(row => `"${row.join(" ")}"`).join(" ")

    // Render one div per unique area name — CSS merges cells with same grid-area
    const seen = new Set()
    let moduleIndex = 0
    for (let r = 0; r < rows; r++) {
      for (let c = 0; c < cols; c++) {
        const name = areas[r][c]
        if (name === "." || seen.has(name)) continue
        seen.add(name)
        moduleIndex++

        const cell = document.createElement("div")
        cell.className = "preview-cell"
        cell.style.gridArea = name

        const number = document.createElement("span")
        number.className = "cell-number"
        number.textContent = moduleIndex
        cell.appendChild(number)

        const placeholder = document.createElement("div")
        placeholder.className = "module-placeholder"
        placeholder.textContent = `Module ${moduleIndex}`
        cell.appendChild(placeholder)

        const input = document.createElement("input")
        input.type = "text"
        input.className = "area-name-input"
        input.value = name.startsWith("c") && /^c\d+$/.test(name) ? "" : name
        input.placeholder = "."
        input.dataset.row = r
        input.dataset.col = c
        input.dataset.action = "change->layout-editor#updateOutput"

        cell.appendChild(input)
        grid.appendChild(cell)
      }
    }
    // Dashed grid overlay
    const overlay = document.createElement("div")
    overlay.className = "grid-overlay"
    Object.assign(overlay.style, {
      display: "grid",
      gridTemplateRows: grid.style.gridTemplateRows,
      gridTemplateColumns: grid.style.gridTemplateColumns,
      gap: grid.style.gap,
    })
    for (let i = 0; i < rows * cols; i++) {
      const cell = document.createElement("div")
      cell.className = "grid-overlay-cell"
      overlay.appendChild(cell)
    }
    grid.appendChild(overlay)

    main.appendChild(grid)
    el.appendChild(main)

    // Row track controls
    const rowControls = document.createElement("div")
    rowControls.className = "track-controls track-controls--row"
    rowControls.style.gridTemplateRows = config.rows.map(t => t.unit === "auto" ? "auto" : `${t.value}${t.unit}`).join(" ")
    rowControls.style.rowGap = `${config.rowGap}${config.rowGapUnit}`
    config.rows.forEach((t, i) => rowControls.appendChild(this._trackControl("row", i, t)))
    el.appendChild(rowControls)
  }

  _trackControl(axis, index, track) {
    const wrapper = document.createElement("div")
    wrapper.className = "track-control"

    const input = document.createElement("input")
    input.type = "text"
    input.className = "track-value-input"
    input.value = track.unit === "auto" ? "" : track.value
    input.disabled = track.unit === "auto"
    input.dataset.axis = axis
    input.dataset.index = index
    input.dataset.action = "input->layout-editor#rebuild"

    const btn = document.createElement("button")
    btn.type = "button"
    btn.className = "track-unit-btn"
    btn.textContent = track.unit
    btn.dataset.axis = axis
    btn.dataset.index = index
    btn.dataset.units = "fr,px,auto"
    btn.dataset.action = "click->layout-editor#cycleUnit"

    wrapper.appendChild(input)
    wrapper.appendChild(btn)
    return wrapper
  }

  _applyOutput(css, html, config) {
    if (this.hasCssOutputTarget) this.cssOutputTarget.textContent = css
    if (this.hasHtmlOutputTarget) this.htmlOutputTarget.textContent = html
    if (this.hasJsonOutputTarget) this.jsonOutputTarget.textContent = JSON.stringify(config, null, 2)
  }
}
