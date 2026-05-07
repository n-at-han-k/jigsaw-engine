import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    id:           Number,
    dataFnUrl:    String,
    renderFnUrl:  String,
    config:       Object,
    shares:       { type: Array, default: [] }
  }

  async connect() {
    try {
      if (!this.dataFnUrlValue || !this.renderFnUrlValue) return

      const pageEl = this.element.closest("[data-controller~='custom-page']")
      if (!pageEl) return

      if (!pageEl.page) {
        await new Promise(resolve => {
          const interval = setInterval(() => {
            if (pageEl.page) { clearInterval(interval); resolve() }
          }, 10)
        })
      }
      this.page = pageEl.page

      this.shared = {}
      for (const key of this.sharesValue) {
        this.shared[key] = await this.page.findOrCreateStore(key)
      }

      const dataModule   = await import(this.dataFnUrlValue)
      const renderModule = await import(this.renderFnUrlValue)

      this.fetchData = dataModule.default.bind(this)
      this.render    = renderModule.default.bind(this)

      this.element.module = this

      for (const key of this.sharesValue) {
        this.shared[key].dpp.on("save", () => this.load())
      }

      await this.load()
    } catch (err) {
      console.error(`[custom-module #${this.idValue}]`, err)
    }
  }

  async load() {
    const data = await this.fetchData(this.shared, this.configValue)
    this.lastData = data
    this.render(data)
  }
}
