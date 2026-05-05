# Custom Pages: Specification and Plan

## Overview

A system for serving experimental pages composed of independently-developed modules. Each module pairs a data-retrieval function with a render function. Pages, modules, and the functions they reference are all stored in the database and editable at runtime. The same Rails controller and view serve every custom page; what differs is which modules are placed on it.

The system is designed for experimentation. Functions can be hot-swapped from the browser console without page reload, shared state persists across reloads via IndexedDB, and modules can share data with each other through named stores.

## Goals

- Pages composed of reusable modules, with per-page customisation.
- Independent reuse of data functions and render functions — same data function with different renderers, same renderer with different data functions, on different pages with different config.
- Shared state between modules on the same page, with persistence across reloads.
- Runtime mutation of any function from the browser console.
- Support for both plain JavaScript and JSX render functions, with JSX compiled server-side and cached.

## Non-goals

- Production-grade authoring UI (out of scope for this phase).
- Authorisation model for who can edit functions (assume internal/trusted for now; flagged as a gap to address before any external exposure).
- Versioning of stored functions (flagged for later).
- Cross-page shared state (each page has its own stores).

## Domain model

Four tables.

**`custom_pages`** — one row per URL path. Owns an ordered list of placements.

| column | type | notes |
|---|---|---|
| path | string | unique, e.g. `/dashboards/sales` |
| title | string | for display |

**`data_functions`** — reusable data-retrieval functions. JavaScript source, no compile step.

| column | type | notes |
|---|---|---|
| name | string | unique, human-readable |
| language | string | `javascript` |
| source | text | ES module exporting a default async function |
| compiled_source | text | mirror of source for now; field exists for symmetry with renderers |
| compiled_digest | string | SHA256 of source, used for cache busting |

**`render_functions`** — reusable render functions. JavaScript or JSX. JSX is compiled server-side on save.

| column | type | notes |
|---|---|---|
| name | string | unique |
| language | string | `javascript` or `jsx` |
| source | text | original source (JSX or JS) |
| compiled_source | text | post-compilation JS (for JSX) or copy of source (for JS) |
| compiled_digest | string | SHA256 of source, used for cache busting |

**`page_modules`** — placements. Each row pairs one data function with one render function on a specific page, with the config and share-keys for that placement.

| column | type | notes |
|---|---|---|
| custom_page_id | fk | |
| data_function_id | fk | |
| render_function_id | fk | |
| position | integer | ordering within the page |
| slot | string | optional CSS class hint for layout |
| config | jsonb | passed to data function as second arg |
| shares | jsonb | array of store-key strings this module reads/writes |

`page_modules` is the join. `data_functions` and `render_functions` rows are reused across many `page_modules` rows. The same `(data_function, render_function)` pair can appear on multiple pages with different `config` and `shares`.

`PageModule` is the Ruby class name (Ruby's `Module` is a built-in constant).

## Server-side function delivery

Each function is served as an ES module at a digest-stamped URL.

```
GET /data_functions/:id.js?digest=<digest>
GET /render_functions/:id.js?digest=<digest>
```

When the digest in the URL matches the current `compiled_digest`, the response gets `Cache-Control: public, max-age=31536000, immutable`. Edits change the digest, the URL changes, browsers fetch fresh.

The view embeds the digest-stamped URL in a data attribute. The browser dynamically imports it.

## JSX compilation

Performed server-side in a `before_save` callback on `RenderFunction` whenever `language == "jsx"` and the source has changed. The compiled output is plain JavaScript that browsers can import directly. Bare specifiers like `import React from "react"` are preserved and resolved at runtime via the page's importmap.

The compiler implementation (esbuild via subprocess, SWC via mini_racer, etc.) is out of scope for this spec; treat it as `JsxCompiler.compile(source) -> String`.

The browser-side WASM JSX compiler is reserved for the *editor* (live preview of unsaved edits). End users viewing a custom page never run a JSX compiler — they only ever import already-compiled JS.

## Routing

```ruby
resources :data_functions,   only: [:show], defaults: { format: :js }
resources :render_functions, only: [:show], defaults: { format: :js }

get "*path", to: "custom_pages#show",
    constraints: ->(req) { CustomPage.exists?(path: req.path) }
```

The catch-all is mounted last. The constraint prevents it from masking real routes.

For paths with parameters (e.g. `/customers/:id`), see "Open question: path matching" below.

## The Rails controller

One action, one view.

```ruby
class CustomPagesController < ApplicationController
  def show
    @page = CustomPage.find_by!(path: request.path)
    @page_modules = @page.page_modules.includes(:data_function, :render_function)
  end
end
```

## The view

Same template every time. Iterates placements, emits one mount point per module with the URLs and config baked into data attributes.

```erb
<div data-controller="custom-page" data-custom-page-page-id-value="<%= @page.id %>">
  <% @page_modules.each do |mod| %>
    <div data-controller="custom-module"
         data-custom-module-id-value="<%= mod.id %>"
         data-custom-module-data-fn-url-value="<%= data_function_path(mod.data_function, digest: mod.data_function.compiled_digest) %>"
         data-custom-module-render-fn-url-value="<%= render_function_path(mod.render_function, digest: mod.render_function.compiled_digest) %>"
         data-custom-module-config-value="<%= mod.config.to_json %>"
         data-custom-module-shares-value="<%= mod.shares.to_json %>"
         class="<%= mod.slot %>"></div>
  <% end %>
</div>
```

## Browser runtime

Two Stimulus controllers.

### `custom-page` controller

Owns the per-page DPP store registry. Exposes `findOrCreateStore(key)` on `this.element.page` so child module controllers can resolve named stores.

- First call for a key boots a DPP instance backed by `storeName: "page-<id>:<key>"` in IndexedDB and returns `{ dpp, proxy }`.
- Subsequent calls for the same key return the same entry.
- Each store gets its own IndexedDB object store, so `save`/`delete` events on one store don't fire for unrelated state.

```javascript
// app/javascript/controllers/custom_page_controller.js
import { Controller } from "@hotwired/stimulus"
import { createDPP } from "https://cdn.jsdelivr.net/gh/robtweed/DPP/src/dpp_browser.min.js"

export default class extends Controller {
  static values = { pageId: String }

  async connect() {
    this.stores = new Map()
    this.element.page = {
      findOrCreateStore: (key) => this.findOrCreateStore(key)
    }
  }

  async findOrCreateStore(key) {
    if (this.stores.has(key)) return this.stores.get(key)
    const dpp = await createDPP({ storeName: `page-${this.pageIdValue}:${key}` })
    const proxy = await dpp.start()
    const entry = { dpp, proxy }
    this.stores.set(key, entry)
    return entry
  }
}
```

### `custom-module` controller

Generic. Same controller drives every module on every page.

On `connect`:

1. Walk up to the `custom-page` controller, get the store registry.
2. Resolve every key in the `shares` array via `findOrCreateStore`, store the resulting proxies on `this.shared`.
3. Dynamic-import the data function URL and render function URL.
4. Bind both to `this` (the controller) and assign as `this.fetchData` and `this.render`.
5. Expose `this` on `this.element.module` for console access.
6. Subscribe each shared store's `save` event to `this.load()`.
7. Call `this.load()`.

`load()` calls `this.fetchData(this.shared, this.configValue)`, stores the result on `this.lastData`, and calls `this.render(data)`.

```javascript
// app/javascript/controllers/custom_module_controller.js
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
    this.page = this.element.closest("[data-controller~='custom-page']").page

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
  }

  async load() {
    const data = await this.fetchData(this.shared, this.configValue)
    this.lastData = data
    this.render(data)
  }
}
```

### Function shape

Stored functions are ES modules with a default export.

**Data function:**

```javascript
export default async function (shared, config) {
  const { region } = shared.filters.proxy
  return (await fetch(`/api/something?region=${region}`)).json()
}
```

**Render function (compiled from JSX):**

```javascript
export default function (data) {
  if (!this.update) {
    const root = createRoot(this.element)
    root.render(<Component initialData={data} registerUpdater={fn => this.update = fn} />)
  } else {
    this.update(data)
  }
}
```

The render function uses `this.element`, `this.update`, `this.mounted`, etc. — whatever it needs to remember between calls is stashed on the controller. The controller does not prescribe what those properties look like; that's the renderer's contract with itself.

### Why `this`-binding works (and its trap)

`bind(this)` works for regular function declarations but is a no-op on arrow functions. A stored function written as `export default (data) => {...}` will have `this` undefined and silently break.

Mitigation: validate at save time that stored sources use `function` syntax, not arrow, for the default export. Reject arrows with a clear error message.

### Shared state via DPP

Each named store is a separate DPP-backed deep proxy. Modules read and write through `shared[key].proxy`. Writes trigger DPP's `save` event, which the module controller has subscribed to — every subscribed module re-runs `load()` and re-renders.

A module that only writes to a store (e.g., a filter panel) still receives its own `save` events and re-fetches. For most use cases this is harmless (the fetcher is `noop` or cheap), but if it matters the module can declare reads vs writes separately. Out of scope for v1; flag for later.

DPP has no `off()` API. On Turbo navigation, listeners on disconnected modules remain registered. Mitigations: either fork DPP to add unsubscribe, wrap every handler in a `if (this.disconnected) return` guard, or accept the leak (each navigation creates a new module instance and the old one's `update` setter is harmless to call). For experimental pages, accept the leak.

### React singleton

For React render functions to work, `react`, `react-dom/client`, and `react/jsx-runtime` must resolve to the same instances regardless of which module imported them. Achieved via importmap pins on the page; bare specifiers in dynamically imported modules inherit the document's importmap per the HTML spec.

## Console mutation workflow

The whole point of the architecture. Examples:

```javascript
// swap a renderer
const m = document.querySelector('[data-custom-module-id-value="42"]').module
m.render = function (data) { /* new */ }
m.load()                           // refetch + render
m.render(m.lastData)               // just re-render with current data

// poke shared state directly
const page = document.querySelector("[data-controller~='custom-page']").page
const filters = await page.findOrCreateStore("filters")
filters.proxy.region = "EU"        // triggers DPP save, all subscribed modules respond
```

Because `fetchData` and `render` are properties on the controller (which is on `element.module`), they're trivially mutable. State the renderer accumulates between calls (`this.update`, `this.mounted`, etc.) is also on the controller, so swapping a renderer means clearing whatever state the *new* renderer doesn't expect — typically `this.update = null` and `this.element.innerHTML = ""` if the React tree needs to remount.

## Implementation phases

**Phase 1 — schema and the static path.** Migrations and models for the four tables. `CustomPagesController#show` with exact-path matching only. Function-delivery controllers with digest-stamped URLs and immutable caching. Manual seeding of pages, modules, and functions via console or fixtures. No editor UI.

**Phase 2 — browser runtime.** `custom-page` and `custom-module` Stimulus controllers. DPP integration. A worked example: filter panel + chart sharing `filters`, both stored as DB rows. Verify hot-swapping from console works end-to-end. Verify shared state survives reload.

**Phase 3 — JSX compilation pipeline.** Server-side `JsxCompiler` (decision point: esbuild subprocess, SWC via mini_racer, or external service). `before_save` hook on `RenderFunction`. Cached compiled output. Verify a JSX render function authored in the DB renders correctly.

**Phase 4 — pattern paths.** Extend `CustomPage.find_by!(path: ...)` to handle parameterised paths. Recommended: [Mustermann](https://github.com/sinatra/mustermann) for matching with priority. Pass extracted URL params to the data function via config or a separate value attribute.

**Phase 5 — editor.** Out of scope for this spec. The editor is where browser-side WASM JSX compilation comes in (live preview of unsaved edits). Stored functions are still compiled server-side on save.

## Open questions to resolve before building

1. **JSX compiler choice.** esbuild subprocess is the safest default (well-maintained, fast, used by Rails' jsbundling-rails already). SWC via mini_racer keeps everything in-process but adds a heavy native dep. Pick before phase 3.

2. **Path matching strategy.** Exact match works for phase 1. Mustermann is the recommended choice for phase 4. Confirm before exposing parameterised pages.

3. **`shares` data integrity.** Currently a free JSON array; nothing enforces that two modules referring to `"filters"` mean the same thing. Acceptable for experimentation; revisit if real users start authoring.

4. **Stored function isolation.** Stored functions run with the same privileges as any other JS on the page — full DOM, full fetch, full access to other modules' state. This is intentional (it's what makes the system useful) but means stored functions are effectively trusted code. Anyone who can edit a function can do anything any script on the page can do. Resolve auth model before opening editing to anyone other than the system's developers.

5. **Function naming.** Currently globally unique per function table. If multiple authors should be able to have their own `fetch_revenue`, scope uniqueness (per-user, per-page, per-namespace) before that becomes a problem.

## Known gaps and risks

- **No version history.** First edit that breaks production has no rollback path. Add `paper_trail` or a manual `*_versions` table before this becomes painful.
- **No DPP unsubscribe.** Listeners leak across Turbo navigation. Tolerable for experimentation; will need addressing if memory or duplicate-fire issues appear.
- **Catch-all route.** Mounted last, but typo'd URLs to other parts of the app will fall through to a `CustomPage.find_by!` 404 rather than the normal 404 path. Consider namespacing under `/p/*path` to make the boundary explicit.
- **Editor security.** When the editor lands, untrusted JSX going through a browser-side WASM compiler must not run with the same CSP context as live pages. Authoring environment needs a sandbox.
