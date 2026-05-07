import { Controller } from "@hotwired/stimulus"
import { generateLayoutCss, generateLayoutHtml, trackStr, trackListStr, autoFlowStr, gridGapStr } from "jigsaw/lib/generate_layout_css"

export default class extends Controller {
  static targets = [
    "grid",
    "previewContainer",
    "cell",
    "panel",
    "configHidden",
    "colTrackControls",
    "rowTrackControls",
    "cssOutput",
    "htmlOutput",
    "jsonOutput",
    "gridFields",
    "flexFields"
  ]

  connect() {
    //this.rebuildCss()
  }

  //rebuildCss() {
  //  const config = this._readConfig()
  //  this._applyGridStyles(config)
  //  this._syncTrackControls(config)
  //  if (this.hasConfigHiddenTarget) {
  //    this.configHiddenTarget.value = JSON.stringify(config)
  //  }

  //  const css = generateLayoutCss(config)
  //  const html = generateLayoutHtml(config)
  //  if (this.hasCssOutputTarget) this.cssOutputTarget.textContent = css
  //  if (this.hasHtmlOutputTarget) this.htmlOutputTarget.textContent = html
  //  if (this.hasJsonOutputTarget) this.jsonOutputTarget.textContent = JSON.stringify(config, null, 2)
  //}

  //cycleUnit(event) {
  //  const btn = event.currentTarget
  //  const units = (btn.dataset.units || "fr,px,auto").split(",")
  //  const idx = units.indexOf(btn.textContent.trim())
  //  btn.textContent = units[(idx + 1) % units.length]
  //  this.rebuildCss()
  //}

  //cycleRowsMode(event) {
  //  const btn = event.currentTarget
  //  const modes = (btn.dataset.units || "number,auto-fit,auto-fill").split(",")
  //  const idx = modes.indexOf(btn.textContent.trim())
  //  btn.textContent = modes[(idx + 1) % modes.length]
  //  const rowCountInput = this.element.querySelector("#rowCount")
  //  if (rowCountInput) {
  //    rowCountInput.disabled = btn.textContent.trim() !== "number"
  //  }
  //  this.rebuildCss()
  //}

  //setTypeGrid() { this._setType("grid") }
  //setTypeFlex() { this._setType("flex") }

  //_setType(type) {
  //  const gridBtn = this.element.querySelector("#typeGrid")
  //  const flexBtn = this.element.querySelector("#typeFlex")

  //  if (type === "grid") {
  //    gridBtn.classList.add("active")
  //    flexBtn.classList.remove("active")
  //    if (this.hasGridFieldsTarget) this.gridFieldsTarget.style.display = ""
  //    if (this.hasFlexFieldsTarget) this.flexFieldsTarget.style.display = "none"
  //  } else {
  //    gridBtn.classList.remove("active")
  //    flexBtn.classList.add("active")
  //    if (this.hasGridFieldsTarget) this.gridFieldsTarget.style.display = "none"
  //    if (this.hasFlexFieldsTarget) this.flexFieldsTarget.style.display = ""
  //  }

  //  this.rebuildCss()
  //}

  //// --- CSS-only grid update (never touches module DOM) ---

  //_applyGridStyles(config) {
  //  const grid = this.gridTarget

  //  if (config.type === "grid") {
  //    grid.style.display = "grid"

  //    const rows = config.rows
  //    const cols = config.columns
  //    grid.style.gridTemplateRows = trackListStr(rows)
  //    grid.style.gridTemplateColumns = trackListStr(cols)
  //    grid.style.gap = gridGapStr(config)

  //    if (config.areas && config.areas.flat().some(a => a !== ".")) {
  //      grid.style.gridTemplateAreas = config.areas.map(row => `"${row.join(" ")}"`).join(" ")
  //    } else {
  //      grid.style.gridTemplateAreas = ""
  //    }

  //    const flow = autoFlowStr(config)
  //    grid.style.gridAutoFlow = flow || ""

  //    const ca = config.containerAlignment || {}
  //    grid.style.justifyContent = (ca.horizontal && ca.horizontal !== "stretch") ? ca.horizontal : ""
  //    grid.style.alignContent = (ca.vertical && ca.vertical !== "stretch") ? ca.vertical : ""

  //    const ch = config.childrenAlignment || {}
  //    grid.style.justifyItems = (ch.horizontal && ch.horizontal !== "stretch") ? ch.horizontal : ""
  //    grid.style.alignItems = (ch.vertical && ch.vertical !== "stretch") ? ch.vertical : ""

  //    // Clear flex properties
  //    grid.style.flexDirection = ""
  //    grid.style.flexWrap = ""
  //  } else {
  //    grid.style.display = "flex"
  //    grid.style.gap = `${config.gap}${config.gapUnit || "px"}`
  //    grid.style.flexDirection = (config.direction && config.direction !== "row") ? config.direction : ""
  //    grid.style.flexWrap = (config.wrap && config.wrap !== "nowrap") ? config.wrap : ""

  //    const ca = config.containerAlignment || {}
  //    grid.style.justifyContent = (ca.mainAxis && ca.mainAxis !== "flex-start") ? ca.mainAxis : ""
  //    grid.style.alignItems = (ca.crossAxis && ca.crossAxis !== "stretch") ? ca.crossAxis : ""

  //    // Clear grid properties
  //    grid.style.gridTemplateRows = ""
  //    grid.style.gridTemplateColumns = ""
  //    grid.style.gridTemplateAreas = ""
  //    grid.style.gridAutoFlow = ""
  //    grid.style.justifyItems = ""
  //    grid.style.alignContent = ""
  //  }
  //}

  //// --- Track controls (safe to rebuild — no Stimulus controllers inside) ---

  //_syncTrackControls(config) {
  //  if (config.type !== "grid") {
  //    if (this.hasColTrackControlsTarget) this.colTrackControlsTarget.innerHTML = ""
  //    if (this.hasRowTrackControlsTarget) this.rowTrackControlsTarget.innerHTML = ""
  //    return
  //  }

  //  const cols = config.columns
  //  const rows = config.rows
  //  const rowTracks = Array.isArray(rows) ? rows : []

  //  if (this.hasColTrackControlsTarget && Array.isArray(cols)) {
  //    const el = this.colTrackControlsTarget
  //    el.innerHTML = ""
  //    el.style.gridTemplateColumns = cols.map(t => trackStr(t)).join(" ")
  //    el.style.columnGap = `${config.colGap}${config.colGapUnit}`
  //    cols.forEach((t, i) => el.appendChild(this._trackControl("col", i, t)))
  //  }

  //  if (this.hasRowTrackControlsTarget && rowTracks.length > 0) {
  //    const el = this.rowTrackControlsTarget
  //    el.innerHTML = ""
  //    el.style.gridTemplateRows = rowTracks.map(t => trackStr(t)).join(" ")
  //    el.style.rowGap = `${config.rowGap}${config.rowGapUnit}`
  //    rowTracks.forEach((t, i) => el.appendChild(this._trackControl("row", i, t)))
  //  }
  //}

  //_trackControl(axis, index, track) {
  //  const wrapper = document.createElement("div")
  //  wrapper.className = "track-control"

  //  const input = document.createElement("input")
  //  input.type = "text"
  //  input.className = "track-value-input"
  //  input.value = track.unit === "auto" ? "" : track.value
  //  input.disabled = track.unit === "auto"
  //  input.dataset.axis = axis
  //  input.dataset.index = index
  //  input.dataset.action = "input->page-editor#rebuildCss"

  //  const btn = document.createElement("button")
  //  btn.type = "button"
  //  btn.className = "track-unit-btn"
  //  btn.textContent = track.unit
  //  btn.dataset.axis = axis
  //  btn.dataset.index = index
  //  btn.dataset.units = "fr,px,auto"
  //  btn.dataset.action = "click->page-editor#cycleUnit"

  //  wrapper.appendChild(input)
  //  wrapper.appendChild(btn)
  //  return wrapper
  //}

  //// --- Read config from sidebar DOM ---

  //_currentType() {
  //  const flexBtn = this.element.querySelector("#typeFlex")
  //  return flexBtn && flexBtn.classList.contains("active") ? "flex" : "grid"
  //}

  //_readConfig() {
  //  const type = this._currentType()
  //  if (type === "flex") return this._readFlexConfig()
  //  return this._readGridConfig()
  //}

  //_readGridConfig() {
  //  const val = (id) => this.element.querySelector(`#${id}`)?.value || ""
  //  const unit = (id) => this.element.querySelector(`#${id}`)?.textContent.trim() || "fr"

  //  const rowsMode = unit("rowsMode")
  //  const rows = parseInt(val("rowCount")) || 3
  //  const cols = parseInt(val("colCount")) || 3
  //  const childrenCount = this.cellTargets.length
  //  const defaultRowTrack = { value: parseFloat(val("rowHeight")) || 1, unit: unit("rowHeightUnit") }
  //  const defaultColTrack = { value: parseFloat(val("colWidth")) || 1, unit: unit("colWidthUnit") }

  //  let rowTracks
  //  if (rowsMode === "auto-fit" || rowsMode === "auto-fill") {
  //    rowTracks = { repeat: rowsMode, value: defaultRowTrack.value, unit: defaultRowTrack.unit }
  //  } else {
  //    rowTracks = this._readTracks("row", rows, defaultRowTrack)
  //  }
  //  const colTracks = this._readTracks("col", cols, defaultColTrack)

  //  const areas = this._readAreas(rows, cols)
  //  const hasAreas = areas.flat().some(a => a !== ".")

  //  const config = {
  //    type: "grid",
  //    childrenCount,
  //    rows: rowTracks,
  //    columns: colTracks,
  //    rowGap: val("rowGap") !== "" ? parseFloat(val("rowGap")) : 8,
  //    rowGapUnit: unit("rowGapUnit"),
  //    colGap: val("colGap") !== "" ? parseFloat(val("colGap")) : 8,
  //    colGapUnit: unit("colGapUnit"),
  //    direction: unit("gridDirection"),
  //    emptySpace: unit("gridEmptySpace"),
  //    containerAlignment: {
  //      horizontal: unit("gridContainerH"),
  //      vertical: unit("gridContainerV")
  //    },
  //    childrenAlignment: {
  //      horizontal: unit("gridChildrenH"),
  //      vertical: unit("gridChildrenV")
  //    }
  //  }

  //  const gridAreasMode = unit("gridAreasMode")
  //  if (gridAreasMode !== "names") {
  //    config.gridAreasMode = gridAreasMode
  //  }

  //  if (hasAreas) config.areas = areas

  //  return config
  //}

  //_readFlexConfig() {
  //  const val = (id) => this.element.querySelector(`#${id}`)?.value || ""
  //  const unit = (id) => this.element.querySelector(`#${id}`)?.textContent.trim() || ""

  //  const childrenCount = this.cellTargets.length

  //  let children = []
  //  try {
  //    const prev = JSON.parse(this.configHiddenTarget.value)
  //    if (prev.children) children = prev.children
  //  } catch {}

  //  while (children.length < childrenCount) {
  //    children.push({ grow: 0, shrink: 1, basis: "auto", margin: false })
  //  }
  //  children = children.slice(0, childrenCount)

  //  return {
  //    type: "flex",
  //    childrenCount,
  //    gap: val("flexGap") !== "" ? parseFloat(val("flexGap")) : 16,
  //    gapUnit: unit("flexGapUnit") || "px",
  //    direction: unit("flexDirection") || "row",
  //    wrap: unit("flexWrap") || "nowrap",
  //    containerAlignment: {
  //      mainAxis: unit("flexMainAxis") || "flex-start",
  //      crossAxis: unit("flexCrossAxis") || "stretch"
  //    },
  //    children
  //  }
  //}

  //_readTracks(axis, count, defaultTrack) {
  //  let storedTracks = []
  //  try {
  //    const prev = JSON.parse(this.configHiddenTarget.value)
  //    const tracks = axis === "row" ? (prev.rows || []) : (prev.columns || [])
  //    if (Array.isArray(tracks)) storedTracks = tracks
  //  } catch {}

  //  const container = axis === "col" ? this.colTrackControlsTarget : this.rowTrackControlsTarget
  //  const input = container?.querySelector(`.track-value-input[data-axis="${axis}"]`)

  //  if (input) {
  //    const tracks = []
  //    for (let i = 0; i < count; i++) {
  //      const inp = container.querySelector(`.track-value-input[data-axis="${axis}"][data-index="${i}"]`)
  //      const btn = container.querySelector(`.track-unit-btn[data-axis="${axis}"][data-index="${i}"]`)
  //      if (inp && btn) {
  //        tracks.push({ value: parseFloat(inp.value) || 1, unit: btn.textContent.trim() })
  //      } else {
  //        tracks.push({ ...defaultTrack })
  //      }
  //    }
  //    const storedAllSame = storedTracks.length > 0 && storedTracks.every(t =>
  //      t.value === storedTracks[0].value && t.unit === storedTracks[0].unit
  //    )
  //    const tracksMatchStored = tracks.length === storedTracks.length && tracks.every((t, i) =>
  //      t.value === storedTracks[i]?.value && t.unit === storedTracks[i]?.unit
  //    )
  //    if (storedAllSame && tracksMatchStored &&
  //        (defaultTrack.value !== storedTracks[0].value || defaultTrack.unit !== storedTracks[0].unit)) {
  //      return Array.from({ length: count }, () => ({ ...defaultTrack }))
  //    }
  //    return tracks
  //  }

  //  if (storedTracks.length === count) {
  //    return storedTracks.map(t => ({ value: t.value, unit: t.unit }))
  //  }
  //  return Array.from({ length: count }, () => ({ ...defaultTrack }))
  //}

  //_readAreas(rows, cols) {
  //  let areas
  //  try {
  //    const prev = JSON.parse(this.configHiddenTarget.value)
  //    areas = prev.areas
  //  } catch {}

  //  if (!areas || areas.length !== rows || (areas[0] && areas[0].length !== cols)) {
  //    areas = Array.from({ length: rows }, (_, r) =>
  //      Array.from({ length: cols }, (_, c) => `c${r * cols + c + 1}`)
  //    )
  //  }

  //  return areas
  //}

}
