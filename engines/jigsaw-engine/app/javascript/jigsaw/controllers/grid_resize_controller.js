import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    layoutId: Number,
    areas: { type: Array, default: [] }
  }

  connect() {
    this.grid = this.element
    this.grid.style.position = "relative"

    // Get resolved track sizes in px
    const computed = getComputedStyle(this.grid)
    this.colSizes = computed.gridTemplateColumns.split(" ").map(parseFloat)
    this.rowSizes = computed.gridTemplateRows.split(" ").map(parseFloat)

    // On window resize, recalculate track sizes from the DOM
    this._onWindowResize = () => {
      this.grid.style.gridTemplateColumns = ""
      this.grid.style.gridTemplateRows = ""
      const recomputed = getComputedStyle(this.grid)
      this.colSizes = recomputed.gridTemplateColumns.split(" ").map(parseFloat)
      this.rowSizes = recomputed.gridTemplateRows.split(" ").map(parseFloat)
      this._repositionHandles()
    }
    window.addEventListener("resize", this._onWindowResize)

    // Collect resizable area names
    this.resizableAreas = new Set()
    for (const child of this.grid.children) {
      if (child.dataset.resizable === "true") {
        // The area name is the first class on the div
        const areaName = this._getAreaName(child)
        if (areaName) this.resizableAreas.add(areaName)
      }
    }

    this.handles = []
    this._onMouseMove = this._onMouseMove.bind(this)
    this._onMouseUp = this._onMouseUp.bind(this)

    this._createHandles()
  }

  _getAreaName(el) {
    // The slot div has the area name as its class
    for (const cls of el.classList) {
      if (cls !== "grid-resize-handle") return cls
    }
    return null
  }

  _createHandles() {
    const areas = this.areasValue
    if (!areas || !areas.length) return

    const numRows = areas.length
    const numCols = areas[0].length

    // Column boundaries
    for (let c = 0; c < numCols - 1; c++) {
      // Check if there are resizable areas on both sides of this column boundary
      let hasResizableLeft = false
      let hasResizableRight = false
      for (let r = 0; r < numRows; r++) {
        if (this.resizableAreas.has(areas[r][c])) hasResizableLeft = true
        if (this.resizableAreas.has(areas[r][c + 1])) hasResizableRight = true
      }
      if (hasResizableLeft && hasResizableRight) {
        // Only add handle if there's actually a boundary (left area !== right area)
        let hasBoundary = false
        for (let r = 0; r < numRows; r++) {
          if (areas[r][c] !== areas[r][c + 1]) { hasBoundary = true; break }
        }
        if (hasBoundary) {
          this._createColHandle(c)
        }
      }
    }

    // Row boundaries
    for (let r = 0; r < numRows - 1; r++) {
      let hasResizableTop = false
      let hasResizableBottom = false
      for (let c = 0; c < numCols; c++) {
        if (this.resizableAreas.has(areas[r][c])) hasResizableTop = true
        if (this.resizableAreas.has(areas[r + 1][c])) hasResizableBottom = true
      }
      if (hasResizableTop && hasResizableBottom) {
        // Only add handle where there's actually a row boundary
        let hasBoundary = false
        for (let c = 0; c < numCols; c++) {
          if (areas[r][c] !== areas[r + 1][c]) { hasBoundary = true; break }
        }
        if (hasBoundary) {
          this._createRowHandle(r)
        }
      }
    }
  }

  _createColHandle(colIndex) {
    const handle = document.createElement("div")
    handle.className = "grid-resize-handle grid-resize-handle--col"
    this._positionColHandle(handle, colIndex)
    handle.addEventListener("mousedown", (e) => this._onMouseDown("col", colIndex, e))
    this.grid.appendChild(handle)
    this.handles.push({ el: handle, axis: "col", index: colIndex })
  }

  _createRowHandle(rowIndex) {
    const handle = document.createElement("div")
    handle.className = "grid-resize-handle grid-resize-handle--row"
    this._positionRowHandle(handle, rowIndex)
    handle.addEventListener("mousedown", (e) => this._onMouseDown("row", rowIndex, e))
    this.grid.appendChild(handle)
    this.handles.push({ el: handle, axis: "row", index: rowIndex })
  }

  _positionColHandle(handle, colIndex) {
    const gap = parseFloat(getComputedStyle(this.grid).columnGap) || 0
    let left = 0
    for (let i = 0; i <= colIndex; i++) {
      left += this.colSizes[i]
      if (i < colIndex) left += gap
    }
    left += gap / 2
    handle.style.left = (left - 3) + "px"
    handle.style.top = "0"
    handle.style.bottom = "0"
  }

  _positionRowHandle(handle, rowIndex) {
    const gap = parseFloat(getComputedStyle(this.grid).rowGap) || 0
    let top = 0
    for (let i = 0; i <= rowIndex; i++) {
      top += this.rowSizes[i]
      if (i < rowIndex) top += gap
    }
    top += gap / 2
    handle.style.top = (top - 3) + "px"
    handle.style.left = "0"
    handle.style.right = "0"
  }

  _onMouseDown(axis, trackIndex, e) {
    e.preventDefault()
    e.stopPropagation()
    this._dragging = {
      axis,
      trackIndex,
      startPos: axis === "col" ? e.clientX : e.clientY,
      startSizes: axis === "col" ? [...this.colSizes] : [...this.rowSizes]
    }
    // Mark handle as active
    const handle = this.handles.find(h => h.axis === axis && h.index === trackIndex)
    if (handle) handle.el.classList.add("grid-resize-handle--active")

    document.addEventListener("mousemove", this._onMouseMove, true)
    document.addEventListener("mouseup", this._onMouseUp, true)
  }

  _onMouseMove(e) {
    if (!this._dragging) return
    e.preventDefault()
    e.stopPropagation()

    const { axis, trackIndex, startPos, startSizes } = this._dragging
    const currentPos = axis === "col" ? e.clientX : e.clientY
    const delta = currentPos - startPos

    const sizes = axis === "col" ? this.colSizes : this.rowSizes
    const minSize = 50

    const newLeft = startSizes[trackIndex] + delta
    const newRight = startSizes[trackIndex + 1] - delta

    if (newLeft >= minSize && newRight >= minSize) {
      sizes[trackIndex] = newLeft
      sizes[trackIndex + 1] = newRight
      this._applyTrackSizes()
      this._repositionHandles()
    }
  }

  _onMouseUp(e) {
    if (!this._dragging) return
    e.stopPropagation()

    const handle = this.handles.find(h => h.axis === this._dragging.axis && h.index === this._dragging.trackIndex)
    if (handle) handle.el.classList.remove("grid-resize-handle--active")

    this._dragging = null
    document.removeEventListener("mousemove", this._onMouseMove, true)
    document.removeEventListener("mouseup", this._onMouseUp, true)
    this._save()
  }

  _applyTrackSizes() {
    this.grid.style.gridTemplateColumns = this.colSizes.map(s => s + "px").join(" ")
    this.grid.style.gridTemplateRows = this.rowSizes.map(s => s + "px").join(" ")
  }

  _repositionHandles() {
    for (const h of this.handles) {
      if (h.axis === "col") {
        this._positionColHandle(h.el, h.index)
      } else {
        this._positionRowHandle(h.el, h.index)
      }
    }
  }

  _save() {
    // no-op for now — sizes reset on resize/reload
  }

  disconnect() {
    for (const h of this.handles) {
      h.el.remove()
    }
    this.handles = []
    document.removeEventListener("mousemove", this._onMouseMove, true)
    document.removeEventListener("mouseup", this._onMouseUp, true)
    window.removeEventListener("resize", this._onWindowResize)
  }
}
