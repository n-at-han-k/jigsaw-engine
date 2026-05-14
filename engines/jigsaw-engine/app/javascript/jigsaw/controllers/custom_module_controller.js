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
      console.log(`[custom-module #${this.idValue}] connect`, { dataFnUrl: this.dataFnUrlValue, renderFnUrl: this.renderFnUrlValue, shares: this.sharesValue })

      if (!this.dataFnUrlValue || !this.renderFnUrlValue) {
        console.log(`[custom-module #${this.idValue}] skipping - no URLs`)
        return
      }

      const pageEl = this.element.closest("[data-controller~='custom-page']")
      if (!pageEl) {
        console.log(`[custom-module #${this.idValue}] skipping - no page element`)
        return
      }

      if (!pageEl.page) {
        console.log(`[custom-module #${this.idValue}] waiting for page controller...`)
        await new Promise(resolve => {
          const interval = setInterval(() => {
            if (pageEl.page) { clearInterval(interval); resolve() }
          }, 10)
        })
      }
      this.page = pageEl.page
      console.log(`[custom-module #${this.idValue}] page ready, loading shared stores...`, this.sharesValue)

      this.shared = {}
      for (const key of this.sharesValue) {
        console.log(`[custom-module #${this.idValue}] loading store "${key}"...`)
        this.shared[key] = await this.page.findOrCreateStore(key)
        console.log(`[custom-module #${this.idValue}] store "${key}" loaded`)
      }

      console.log(`[custom-module #${this.idValue}] importing data module...`)
      const dataModule = await import(this.dataFnUrlValue)
      console.log(`[custom-module #${this.idValue}] data module imported`)

      console.log(`[custom-module #${this.idValue}] importing render module...`)
      const renderModule = await import(this.renderFnUrlValue)
      console.log(`[custom-module #${this.idValue}] render module imported`)

      this.fetchData = dataModule.default.bind(this)
      this.render    = renderModule.default.bind(this)

      this.element.module = this

      for (const key of this.sharesValue) {
        this.shared[key].dpp.on("save", () => this.load())
      }

      console.log(`[custom-module #${this.idValue}] calling load()...`)
      await this.load()
      console.log(`[custom-module #${this.idValue}] load() complete`)
    } catch (err) {
      console.error(`[custom-module #${this.idValue}] ERROR:`, err)
    }
  }

  async load() {
    const data = await this.fetchData(this.shared, this.configValue)
    this.lastData = data
    this.render(data)
  }
}
