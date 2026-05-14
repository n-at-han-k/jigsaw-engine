import { Controller } from "@hotwired/stimulus"

let areaIdCounter = 0
function generateAreaId() {
  areaIdCounter++
  return `a-${Date.now().toString(36).slice(-4)}${areaIdCounter}`
}

function deepClone(obj) {
  return JSON.parse(JSON.stringify(obj))
}

export default class extends Controller {
  static targets = ["preview", "cssOutput", "htmlOutput", "jsonOutput", "configHidden", "panel"]
  static values = {
    slotsByArea:     { type: Object, default: {} },
    slotEditPaths:   { type: Object, default: {} }
  }

  connect() {
    this._loadConfig()
    this._render()
  }

  _loadConfig() {
    try {
      this.state = JSON.parse(this.configHiddenTarget.value)
    } catch {
      this.state = this._defaultConfig()
    }
    if (!this.state.areas || !this.state.columns || !this.state.rows) {
      this.state = this._defaultConfig()
    }
    this.selectedAreas = new Set()
  }

  _defaultConfig() {
    return {
      type: "grid",
      areas: [
        ["header", "header", "header"],
        ["left", "main", "right"],
        ["footer", "footer", "footer"]
      ],
      columns: ["120px", "4fr", "1fr"],
      rows: ["160px", "1fr", "80px"],
      gridWidth: "100%",
      gridHeight: "100%",
      rowGap: 8,
      colGap: 8,
      rowGapUnit: "px",
      colGapUnit: "px"
    }
  }

  rebuild() {
    this._readSidebarFields()
    this._render()
  }

  _readSidebarFields() {
    const val = (id) => this.element.querySelector(`#${id}`)?.value
    if (val("gridWidth")) this.state.gridWidth = val("gridWidth")
    if (val("gridHeight")) this.state.gridHeight = val("gridHeight")
    const rowGap = parseFloat(val("rowGap"))
    if (!isNaN(rowGap)) this.state.rowGap = rowGap
    const colGap = parseFloat(val("colGap"))
    if (!isNaN(colGap)) this.state.colGap = colGap
    const rowGapUnit = this.element.querySelector("#rowGapUnit")?.textContent.trim()
    if (rowGapUnit) this.state.rowGapUnit = rowGapUnit
    const colGapUnit = this.element.querySelector("#colGapUnit")?.textContent.trim()
    if (colGapUnit) this.state.colGapUnit = colGapUnit
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

  // --- Grid operations (ported from grid-generator) ---

  insertColumn(index) {
    const targetIndex = index + 1
    const areaId = generateAreaId()

    this.state.columns.splice(targetIndex, 0, "1fr")
    this.state.areas = this.state.areas.map((area) => {
      const areaName = area[index]
      if (areaName === area[targetIndex]) {
        area = area.map((col, i) => (col === areaName ? `${col}-${i > index ? 1 : 0}` : col))
      }
      const newArea = [...area]
      newArea.splice(targetIndex, 0, areaId)
      return newArea
    })
    this.selectedAreas.clear()
    this._render()
  }

  removeColumn(index) {
    if (this.state.columns.length <= 1) return
    this.state.columns.splice(index, 1)
    this.state.areas = this.state.areas.map((area) => {
      const newArea = [...area]
      newArea.splice(index, 1)
      return newArea
    })
    this.selectedAreas.clear()
    this._render()
  }

  insertRow(index) {
    const targetIndex = index + 1
    const areaId = generateAreaId()
    const prevArea = this.state.areas[index]
    const nextArea = this.state.areas[targetIndex]

    this.state.rows.splice(targetIndex, 0, "1fr")

    if (prevArea && nextArea) {
      prevArea.forEach((areaName, c) => {
        if (nextArea[c] !== areaName) return
        this.state.areas.forEach((row, i) => {
          const col = row[c]
          row[c] = col === areaName ? `${col}-${i > index ? 1 : 0}` : col
        })
      })
    }

    const newRow = Array.from({ length: this.state.columns.length }, () => areaId)
    const newAreas = [...this.state.areas]
    newAreas.splice(targetIndex, 0, newRow)
    this.state.areas = newAreas

    this.selectedAreas.clear()
    this._render()
  }

  removeRow(index) {
    if (this.state.rows.length <= 1) return
    this.state.rows.splice(index, 1)
    const newAreas = [...this.state.areas]
    newAreas.splice(index, 1)
    this.state.areas = newAreas
    this.selectedAreas.clear()
    this._render()
  }

  splitArea(areaName) {
    let i = 0
    this.state.areas = this.state.areas.map((row) =>
      row.map((col) => (col === areaName ? `${col}-${i++}` : col))
    )
    this.selectedAreas.clear()
    this._render()
  }

  combineArea(areaName) {
    this.state.areas = this.state.areas.map((row) =>
      row.map((col) => (this.selectedAreas.has(col) ? areaName : col))
    )
    this.selectedAreas.clear()
    this._render()
  }

  renameArea(oldName, newName) {
    if (newName.match(/^[\d|.]/)) return
    if (newName.trim() === "") return
    this.state.areas = this.state.areas.map((row) =>
      row.map((col) => (col === oldName ? newName : col))
    )
    this.selectedAreas.clear()
    this._render()
  }

  updateColumn(index, value) {
    this.state.columns[index] = value
    this._render()
  }

  updateRow(index, value) {
    this.state.rows[index] = value
    this._render()
  }

  toggleSelectArea(areaName) {
    if (this.selectedAreas.has(areaName)) {
      this.selectedAreas.delete(areaName)
    } else {
      this.selectedAreas.add(areaName)
    }
    this._renderGrid()
  }

  get uniqueAreaKeys() {
    return [...new Set(this.state.areas.flat())].filter(a => a !== ".")
  }

  get areaCount() {
    return this.state.areas.flat().reduce((map, area) => {
      map[area] = (map[area] || 0) + 1
      return map
    }, {})
  }

  get isCombinable() {
    const keys = [...this.selectedAreas]
    if (keys.length < 2) return false

    const c = this.state.columns.length
    const flat = this.state.areas.flat()

    const minCoords = keys.map((area) => {
      const idx = flat.indexOf(area)
      return [Math.floor(idx % c), Math.floor(idx / c)]
    })
    const maxCoords = keys.map((area) => {
      const idx = flat.lastIndexOf(area)
      return [Math.floor(idx % c), Math.floor(idx / c)]
    })

    const min = minCoords.reduce((prev, curr) => [
      Math.min(prev[0], curr[0]),
      Math.min(prev[1], curr[1])
    ])
    const max = maxCoords.reduce((prev, curr) => [
      Math.max(prev[0], curr[0]),
      Math.max(prev[1], curr[1])
    ])

    for (let row = min[1]; row <= max[1]; row++) {
      for (let col = min[0]; col <= max[0]; col++) {
        if (!this.selectedAreas.has(this.state.areas[row][col])) return false
      }
    }
    return true
  }

  // --- Rendering ---

  _render() {
    this._renderPreview()
    this._renderOutput()
    this.configHiddenTarget.value = JSON.stringify(this.state)
  }

  _renderPreview() {
    const el = this.previewTarget
    el.innerHTML = ""

    const colControls = document.createElement("div")
    colControls.className = "track-controls track-controls--col"
    colControls.style.gridTemplateColumns = this.state.columns.join(" ")
    colControls.style.columnGap = `${this.state.colGap}${this.state.colGapUnit || "px"}`
    this.state.columns.forEach((value, i) => {
      colControls.appendChild(this._trackControl("col", i, value))
    })
    el.appendChild(colControls)

    const main = document.createElement("div")
    main.className = "preview-main"

    const grid = document.createElement("section")
    grid.className = "preview-grid"
    grid.style.display = "grid"
    grid.style.width = this.state.gridWidth || "100%"
    grid.style.height = this.state.gridHeight || "100%"
    grid.style.gridTemplateColumns = this.state.columns.join(" ")
    grid.style.gridTemplateRows = this.state.rows.join(" ")
    grid.style.gap = `${this.state.rowGap}${this.state.rowGapUnit || "px"} ${this.state.colGap}${this.state.colGapUnit || "px"}`
    if (this.state.areas) {
      grid.style.gridTemplateAreas = this.state.areas.map(row => `"${row.join(" ")}"`).join(" ")
    }

    const seen = new Set()
    let moduleIndex = 0
    const rows = this.state.areas.length
    const cols = this.state.columns.length

    for (let r = 0; r < rows; r++) {
      for (let c = 0; c < cols; c++) {
        const name = this.state.areas[r][c]
        if (name === "." || seen.has(name)) continue
        seen.add(name)
        moduleIndex++

        const cell = document.createElement("div")
        cell.className = "preview-cell"
        cell.style.gridArea = name

        const isMultiple = this.areaCount[name] > 1
        const isSelected = this.selectedAreas.has(name)

        const bg = document.createElement("div")
        bg.className = `grid-cell-bg${isSelected ? " selected" : ""}${isSelected && this.isCombinable ? " combinable" : ""}`
        cell.appendChild(bg)

        const inner = document.createElement("div")
        inner.className = "grid-cell-inner"

        const input = document.createElement("input")
        input.type = "text"
        input.className = "area-name-input focus-input"
        input.value = name
        input.addEventListener("input", (e) => {
          this.renameArea(name, e.target.value)
        })
        inner.appendChild(input)

        // Slot edit pencil button (opens flyout with slot editor)
        const slotEditPath = this.slotEditPathsValue?.[name]
        if (slotEditPath) {
          const editBtn = document.createElement("button")
          editBtn.type = "button"
          editBtn.className = "slot-edit-btn"
          editBtn.title = "Edit slot content"
          editBtn.innerHTML = '<i class="pencil icon"></i>'
          editBtn.addEventListener("click", (e) => {
            e.stopPropagation()
            const flyout = document.querySelector(".ui.flyout")
            const editorFrame = document.querySelector("#editor")
            if (editorFrame) editorFrame.src = slotEditPath
            if (flyout && window.jQuery) window.jQuery(flyout).flyout("show")
          })
          inner.appendChild(editBtn)
        } else {
          // No slot exists yet (newly added area - user must save first)
          const placeholder = document.createElement("div")
          placeholder.className = "slot-edit-btn slot-edit-btn-disabled"
          placeholder.title = "Save layout to enable slot editing"
          placeholder.innerHTML = '<i class="pencil icon"></i>'
          inner.appendChild(placeholder)
        }

        cell.addEventListener("click", (e) => {
          if (e.target === input) return
          e.stopPropagation()
          this.toggleSelectArea(name)
        })

        if (isMultiple) {
          const splitBtn = document.createElement("button")
          splitBtn.className = "grid-action-btn split"
          splitBtn.textContent = "Split"
          splitBtn.addEventListener("click", (e) => {
            e.stopPropagation()
            this.splitArea(name)
          })
          inner.appendChild(splitBtn)
        }

        if (isSelected && this.isCombinable) {
          const combineBtn = document.createElement("button")
          combineBtn.className = "grid-action-btn combine"
          combineBtn.textContent = "Combine"
          combineBtn.addEventListener("click", (e) => {
            e.stopPropagation()
            this.combineArea(name)
          })
          inner.appendChild(combineBtn)
        }

        cell.appendChild(inner)
        grid.appendChild(cell)
      }
    }

    main.appendChild(grid)
    el.appendChild(main)

    const rowControls = document.createElement("div")
    rowControls.className = "track-controls track-controls--row"
    rowControls.style.gridTemplateRows = this.state.rows.join(" ")
    rowControls.style.rowGap = `${this.state.rowGap}${this.state.rowGapUnit || "px"}`
    this.state.rows.forEach((value, i) => {
      rowControls.appendChild(this._trackControl("row", i, value))
    })
    el.appendChild(rowControls)
  }

  _renderGrid() {
    this._renderPreview()
    this._renderOutput()
    this.configHiddenTarget.value = JSON.stringify(this.state)
  }

  _trackControl(axis, index, value) {
    const wrapper = document.createElement("div")
    wrapper.className = "track-control"

    const input = document.createElement("input")
    input.type = "text"
    input.className = "track-value-input"
    input.value = value
    input.dataset.axis = axis
    input.dataset.index = index
    input.addEventListener("input", () => {
      if (axis === "col") this.updateColumn(index, input.value)
      else this.updateRow(index, input.value)
    })

    const removeBtn = document.createElement("button")
    removeBtn.type = "button"
    removeBtn.className = "grid-action-btn track-remove"
    removeBtn.textContent = "-"
    removeBtn.addEventListener("click", (e) => {
      e.stopPropagation()
      if (axis === "col") this.removeColumn(index)
      else this.removeRow(index)
    })

    const insertBtn = document.createElement("button")
    insertBtn.type = "button"
    insertBtn.className = "grid-action-btn track-insert"
    insertBtn.textContent = "+"
    insertBtn.addEventListener("click", (e) => {
      e.stopPropagation()
      if (axis === "col") this.insertColumn(index)
      else this.insertRow(index)
    })

    wrapper.appendChild(input)
    wrapper.appendChild(removeBtn)
    wrapper.appendChild(insertBtn)

    if (axis === "col") {
      const thumb = document.createElement("div")
      thumb.className = "track-thumb-ew"
      thumb.draggable = true
      let startX = 0, startWidth = 0
      thumb.addEventListener("dragstart", (e) => {
        startX = e.clientX
        startWidth = wrapper.offsetWidth
      })
      thumb.addEventListener("drag", (e) => {
        if (e.x === 0 && e.y === 0) return
        const newWidth = Math.max(20, startWidth - startX + e.clientX)
        this.updateColumn(index, `${newWidth}px`)
      })
      wrapper.appendChild(thumb)
    } else {
      const thumb = document.createElement("div")
      thumb.className = "track-thumb-ns"
      thumb.draggable = true
      let startY = 0, startHeight = 0
      thumb.addEventListener("dragstart", (e) => {
        startY = e.clientY
        startHeight = wrapper.offsetHeight
      })
      thumb.addEventListener("drag", (e) => {
        if (e.x === 0 && e.y === 0) return
        const newHeight = Math.max(20, startHeight - startY + e.clientY)
        this.updateRow(index, `${newHeight}px`)
      })
      wrapper.appendChild(thumb)
    }

    return wrapper
  }

  _renderOutput() {
    const css = this._generateCss()
    const html = this._generateHtml()

    if (this.hasCssOutputTarget) this.cssOutputTarget.textContent = css
    if (this.hasHtmlOutputTarget) this.htmlOutputTarget.textContent = html
    if (this.hasJsonOutputTarget) this.jsonOutputTarget.textContent = JSON.stringify(this.state, null, 2)
  }

  _generateCss() {
    const s = this.state
    let css = `.container {\n  display: grid;\n`
    css += `  width: ${s.gridWidth || "100%"};\n`
    css += `  height: ${s.gridHeight || "100%"};\n`
    css += `  grid-template-areas: ${s.areas.map(row => `"${row.join(" ")}"`).join("\n    ")};\n`
    css += `  grid-template-columns: ${s.columns.join(" ")};\n`
    css += `  grid-template-rows: ${s.rows.join(" ")};\n`
    css += `  gap: ${s.rowGap}${s.rowGapUnit || "px"} ${s.colGap}${s.colGapUnit || "px"};\n`
    css += `}\n`

    const uniqueAreas = [...new Set(s.areas.flat())].filter(a => a !== ".")
    for (const name of uniqueAreas) {
      css += `\n.${name} {\n  grid-area: ${name};\n}`
    }

    return css
  }

  _generateHtml() {
    const uniqueAreas = [...new Set(this.state.areas.flat())].filter(a => a !== ".")
    const children = uniqueAreas.map(name => `  <div class="${name}">${name}</div>`).join("\n")
    return `<div class="container">\n${children}\n</div>`
  }
}
