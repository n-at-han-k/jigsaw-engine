import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { pageId: String }

  connect() {
    this.stores = new Map()
    this.element.page = {
      findOrCreateStore: (key) => this.findOrCreateStore(key)
    }
  }

  async findOrCreateStore(key) {
    if (this.stores.has(key)) return this.stores.get(key)

    const { createDPP } = await import("dpp")
    const dpp = await createDPP({ storeName: `page-${this.pageIdValue}:${key}` })
    const proxy = await dpp.start()
    const entry = { dpp, proxy }
    this.stores.set(key, entry)
    return entry
  }
}
