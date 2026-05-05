import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { key: { type: String, default: "flyout-width" } }

  connect() {
    this.flyout = this.element.closest(".ui.flyout")
    if (!this.flyout) return

    this.handle = document.createElement("div")
    this.handle.style.cssText = "position: absolute; left: 0; top: 0; bottom: 0; width: 6px; cursor: col-resize; z-index: 1000;"
    this.flyout.prepend(this.handle)

    const saved = localStorage.getItem(this.keyValue)
    if (saved) this.flyout.style.width = saved

    this._onMouseDown = this._onMouseDown.bind(this)
    this._onMouseMove = this._onMouseMove.bind(this)
    this._onMouseUp = this._onMouseUp.bind(this)

    this.handle.addEventListener("mousedown", this._onMouseDown)
  }

  _onMouseDown(e) {
    e.preventDefault()
    e.stopPropagation()
    this.dragging = true
    // Prevent Fomantic from closing the flyout on click outside during drag
    this._dimmer = document.querySelector(".ui.dimmer")
    if (this._dimmer) this._dimmer.style.pointerEvents = "none"
    document.addEventListener("mousemove", this._onMouseMove, true)
    document.addEventListener("mouseup", this._onMouseUp, true)
  }

  _onMouseMove(e) {
    if (!this.dragging) return
    e.preventDefault()
    e.stopPropagation()
    const width = window.innerWidth - e.clientX
    if (width >= 200 && width <= window.innerWidth * 0.9) {
      this.flyout.style.width = width + "px"
    }
  }

  _onMouseUp(e) {
    if (!this.dragging) return
    e.stopPropagation()
    this.dragging = false
    if (this._dimmer) this._dimmer.style.pointerEvents = ""
    document.removeEventListener("mousemove", this._onMouseMove, true)
    document.removeEventListener("mouseup", this._onMouseUp, true)
    localStorage.setItem(this.keyValue, this.flyout.style.width)
  }

  disconnect() {
    this.handle?.remove()
    document.removeEventListener("mousemove", this._onMouseMove)
    document.removeEventListener("mouseup", this._onMouseUp)
  }
}
