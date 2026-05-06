import { Controller } from "@hotwired/stimulus"
import { generateLayoutCss, generateLayoutHtml } from "jigsaw/lib/generate_layout_css"

export default class extends Controller {
  static targets = ["preview", "cssOutput", "htmlOutput", "jsonOutput", "configHidden", "panel", "gridFields", "flexFields"]

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

  cycleRowsMode(event) {
    const btn = event.currentTarget
    const modes = (btn.dataset.units || "number,auto-fit,auto-fill").split(",")
    const idx = modes.indexOf(btn.textContent.trim())
    btn.textContent = modes[(idx + 1) % modes.length]
    const rowCountInput = this.element.querySelector("#rowCount")
    if (rowCountInput) {
      rowCountInput.disabled = btn.textContent.trim() !== "number"
    }
    this.rebuild()
  }

  setTypeGrid() {
    this._setType("grid")
  }

  setTypeFlex() {
    this._setType("flex")
  }

  _setType(type) {
    const gridBtn = this.element.querySelector("#typeGrid")
    const flexBtn = this.element.querySelector("#typeFlex")

    if (type === "grid") {
      gridBtn.classList.add("active")
      flexBtn.classList.remove("active")
      if (this.hasGridFieldsTarget) this.gridFieldsTarget.style.display = ""
      if (this.hasFlexFieldsTarget) this.flexFieldsTarget.style.display = "none"
    } else {
      gridBtn.classList.remove("active")
      flexBtn.classList.add("active")
      if (this.hasGridFieldsTarget) this.gridFieldsTarget.style.display = "none"
      if (this.hasFlexFieldsTarget) this.flexFieldsTarget.style.display = ""
    }

    this.rebuild()
  }

  togglePanel() {
    const page = this.element.querySelector(".editor-page")
    page.classList.toggle("full-width")
  }

  toggleTracks() {
    const center = this.element.querySelector(".editor-center")
    center.classList.toggle("hide-tracks")
  }

  // --- Private: read state from DOM ---

  _currentType() {
    const flexBtn = this.element.querySelector("#typeFlex")
    return flexBtn && flexBtn.classList.contains("active") ? "flex" : "grid"
  }

  _readConfig() {
    const type = this._currentType()
    if (type === "flex") {
      return this._readFlexConfig()
    }
    return this._readGridConfig()
  }

  _readGridConfig() {
    const val = (id) => this.element.querySelector(`#${id}`)?.value || ""
    const unit = (id) => this.element.querySelector(`#${id}`)?.textContent.trim() || "fr"

    const rowsMode = unit("rowsMode")
    const rows = parseInt(val("rowCount")) || 3
    const cols = parseInt(val("colCount")) || 3
    const childrenCount = parseInt(val("childrenCount")) || (rows * cols)
    const defaultRowTrack = { value: parseFloat(val("rowHeight")) || 1, unit: unit("rowHeightUnit") }
    const defaultColTrack = { value: parseFloat(val("colWidth")) || 1, unit: unit("colWidthUnit") }

    let rowTracks
    if (rowsMode === "auto-fit" || rowsMode === "auto-fill") {
      rowTracks = { repeat: rowsMode, value: defaultRowTrack.value, unit: defaultRowTrack.unit }
    } else {
      rowTracks = this._readTracks("row", rows, defaultRowTrack)
    }
    const colTracks = this._readTracks("col", cols, defaultColTrack)

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
      direction: unit("gridDirection"),
      emptySpace: unit("gridEmptySpace"),
      containerAlignment: {
        horizontal: unit("gridContainerH"),
        vertical: unit("gridContainerV")
      },
      childrenAlignment: {
        horizontal: unit("gridChildrenH"),
        vertical: unit("gridChildrenV")
      }
    }

    const gridAreasMode = unit("gridAreasMode")
    if (gridAreasMode !== "names") {
      config.gridAreasMode = gridAreasMode
    }

    if (hasAreas) config.areas = areas

    return config
  }

  _readFlexConfig() {
    const val = (id) => this.element.querySelector(`#${id}`)?.value || ""
    const unit = (id) => this.element.querySelector(`#${id}`)?.textContent.trim() || ""

    const childrenCount = parseInt(val("childrenCount")) || 3

    // Read children from stored config
    let children = []
    try {
      const prev = JSON.parse(this.configHiddenTarget.value)
      if (prev.children) children = prev.children
    } catch {}

    // Ensure children array matches count
    while (children.length < childrenCount) {
      children.push({ grow: 0, shrink: 1, basis: "auto", margin: false })
    }
    children = children.slice(0, childrenCount)

    // Read from per-child inputs in preview if they exist
    for (let i = 0; i < childrenCount; i++) {
      const growInput = this.previewTarget.querySelector(`.flex-child-grow[data-index="${i}"]`)
      const shrinkInput = this.previewTarget.querySelector(`.flex-child-shrink[data-index="${i}"]`)
      const marginInput = this.previewTarget.querySelector(`.flex-child-margin[data-index="${i}"]`)
      if (growInput) children[i].grow = parseFloat(growInput.value) || 0
      if (shrinkInput) children[i].shrink = parseFloat(shrinkInput.value) || 1
      if (marginInput) children[i].margin = marginInput.checked
    }

    const config = {
      type: "flex",
      childrenCount,
      gap: val("flexGap") !== "" ? parseFloat(val("flexGap")) : 16,
      gapUnit: unit("flexGapUnit") || "px",
      direction: unit("flexDirection") || "row",
      wrap: unit("flexWrap") || "nowrap",
      containerAlignment: {
        mainAxis: unit("flexMainAxis") || "flex-start",
        crossAxis: unit("flexCrossAxis") || "stretch"
      },
      children
    }

    return config
  }

  _readTracks(axis, count, defaultTrack) {
    let storedTracks = []
    try {
      const prev = JSON.parse(this.configHiddenTarget.value)
      const tracks = axis === "row" ? (prev.rows || []) : (prev.columns || [])
      if (Array.isArray(tracks)) storedTracks = tracks
    } catch {}

    const input = this.previewTarget.querySelector(`.track-value-input[data-axis="${axis}"]`)
    if (input) {
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

    if (storedTracks.length === count) {
      return storedTracks.map(t => ({ value: t.value, unit: t.unit }))
    }
    return Array.from({ length: count }, () => ({ ...defaultTrack }))
  }

  _readAreas(rows, cols) {
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
    if (config.type === "flex") {
      this._applyFlexPreview(config)
    } else {
      this._applyGridPreview(config)
    }
  }

  _applyGridPreview(config) {
    const el = this.previewTarget
    el.innerHTML = ""

    const rows = Array.isArray(config.rows) ? config.rows.length : (parseInt(this.element.querySelector("#rowCount")?.value) || 3)
    const cols = config.columns.length

    // Column track controls
    const colControls = document.createElement("div")
    colControls.className = "track-controls track-controls--col"
    colControls.style.gridTemplateColumns = config.columns.map(t => t.unit === "auto" ? "auto" : `${t.value}${t.unit}`).join(" ")
    colControls.style.columnGap = `${config.colGap}${config.colGapUnit}`
    config.columns.forEach((t, i) => colControls.appendChild(this._trackControl("col", i, t)))
    el.appendChild(colControls)

    // Main preview area
    const main = document.createElement("div")
    main.className = "preview-main"

    const grid = document.createElement("section")
    grid.className = "preview-grid"
    Object.assign(grid.style, {
      display: "grid",
      width: "100%",
      gap: `${config.rowGap}${config.rowGapUnit} ${config.colGap}${config.colGapUnit}`,
    })

    const rowTracks = Array.isArray(config.rows) ? config.rows : Array.from({ length: rows }, () => ({ value: config.rows.value, unit: config.rows.unit }))
    grid.style.gridTemplateRows = rowTracks.map(t => t.unit === "auto" ? "auto" : `${t.value}${t.unit}`).join(" ")
    grid.style.gridTemplateColumns = config.columns.map(t => t.unit === "auto" ? "auto" : `${t.value}${t.unit}`).join(" ")

    const areas = config.areas || Array.from({ length: rows }, (_, r) =>
      Array.from({ length: cols }, (_, c) => `c${r * cols + c + 1}`)
    )
    grid.style.gridTemplateAreas = areas.map(row => `"${row.join(" ")}"`).join(" ")

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

    // Grid overlay
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
    rowControls.style.gridTemplateRows = rowTracks.map(t => t.unit === "auto" ? "auto" : `${t.value}${t.unit}`).join(" ")
    rowControls.style.rowGap = `${config.rowGap}${config.rowGapUnit}`
    rowTracks.forEach((t, i) => rowControls.appendChild(this._trackControl("row", i, t)))
    el.appendChild(rowControls)
  }

  _applyFlexPreview(config) {
    const el = this.previewTarget
    el.innerHTML = ""

    const container = document.createElement("section")
    container.className = "preview-grid preview-flex"
    Object.assign(container.style, {
      display: "flex",
      width: "100%",
      gap: `${config.gap}${config.gapUnit}`,
      flexDirection: config.direction !== "row" ? config.direction : "",
      flexWrap: config.wrap !== "nowrap" ? config.wrap : "",
    })

    const children = config.children || []
    for (let i = 0; i < config.childrenCount; i++) {
      const child = children[i] || { grow: 0, shrink: 1, basis: "auto", margin: false }

      const cell = document.createElement("div")
      cell.className = "preview-cell flex-child"
      if (child.grow > 0) cell.style.flexGrow = child.grow
      if (child.shrink !== 1) cell.style.flexShrink = child.shrink
      if (child.margin) cell.style.marginLeft = "auto"

      // Child controls
      const controls = document.createElement("div")
      controls.className = "flex-child-controls"

      // flex: grow shrink basis
      const flexLabel = document.createElement("label")
      flexLabel.textContent = "flex:"
      flexLabel.className = "flex-label"
      controls.appendChild(flexLabel)

      const growInput = document.createElement("input")
      growInput.type = "text"
      growInput.className = "flex-child-grow track-value-input"
      growInput.value = child.grow
      growInput.dataset.index = i
      growInput.dataset.action = "input->layout-editor#rebuild"
      controls.appendChild(growInput)

      const shrinkInput = document.createElement("input")
      shrinkInput.type = "text"
      shrinkInput.className = "flex-child-shrink track-value-input"
      shrinkInput.value = child.shrink
      shrinkInput.dataset.index = i
      shrinkInput.dataset.action = "input->layout-editor#rebuild"
      controls.appendChild(shrinkInput)

      const basisSpan = document.createElement("span")
      basisSpan.className = "flex-basis-label"
      basisSpan.textContent = child.basis
      controls.appendChild(basisSpan)

      // margin checkbox
      const marginLabel = document.createElement("label")
      marginLabel.textContent = "margin:"
      marginLabel.className = "flex-label"
      controls.appendChild(marginLabel)

      const marginCheck = document.createElement("input")
      marginCheck.type = "checkbox"
      marginCheck.className = "flex-child-margin"
      marginCheck.checked = child.margin
      marginCheck.dataset.index = i
      marginCheck.dataset.action = "change->layout-editor#rebuild"
      controls.appendChild(marginCheck)

      cell.appendChild(controls)

      const placeholder = document.createElement("div")
      placeholder.className = "module-placeholder"
      placeholder.textContent = `Module ${i + 1}`
      cell.appendChild(placeholder)

      const number = document.createElement("span")
      number.className = "cell-number"
      number.textContent = i + 1
      cell.appendChild(number)

      container.appendChild(cell)
    }

    el.appendChild(container)
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
