# jigsaw-engine

## Setup

This repo contains the `jigsaw_engine` gem located in `./engines/jigsaw-engine`.
The root directory of this project is itself a **complete working example** of `jigsaw_engine` that can be run locally or deployed.

### Engine only

```
bundle add jigsaw_engine
bin/rails jigsaw_engine:install:migrations
bin/rails db:migrate
```

### Standalone app

```
git clone https://github.com/general-intelligence-systems/jigsaw-engine
cd jigsaw-engine
bin/setup
```

---

## How It Works

Jigsaw composes web pages from **CSS Grid layouts** containing independently programmable units called **slots**. Each slot is a self-contained module with three parts: a static JSON config, a data function that prepares state, and a render function that mounts a React component into the DOM. Slots can communicate with each other through named shared stores backed by [DPP](https://github.com/robtweed/DPP) (Distributed Persistent Proxies). The entire system runs inside Rails via [Stimulus](https://stimulus.hotwired.dev/) controllers that dynamically import each slot's compiled JavaScript at page load.

---

## Core Concepts

### Page

A top-level resource with a URL path. Each page has one **Layout** that defines its grid structure, and through that layout, a set of **Slots** that provide the page's content.

### Layout

A CSS Grid configuration belonging to a page. Stores the grid definition — areas, columns, rows, and gaps — as a JSON schema. When saved, Jigsaw compiles this config into actual CSS and automatically creates or removes Slot records to match the grid area names.

For example, a layout with areas `[["header","header"],["sidebar","main"],["footer","footer"]]` automatically creates five slots: `header`, `sidebar`, `main`, `footer`.

### Slot

The fundamental building block. A slot occupies one named area in its parent layout's CSS Grid and contains three pieces of user-authored code:

| Part | Language | Purpose |
|------|----------|---------|
| **config** | JSON | Static configuration data (titles, URLs, feature flags, etc.) |
| **data function** | JavaScript | Transforms config + shared state into props for the component |
| **render function** | JSX or JavaScript | Mounts a React component (or raw DOM) into the slot's container |

Slots are edited live in the browser through a built-in Monaco editor with hot-swap support — changes take effect instantly without a full page reload.

### Slot Template

A reusable slot definition with its own config, data source, and render source. Slots can be **linked** to a template, in which case they delegate to the template's code. Changes to the template propagate to all linked slots. Unlinking a slot copies the template's current values into the slot for independent editing.

### Layout Template

A reusable CSS Grid configuration. Layouts can link to a layout template in the same way slots link to slot templates.

---

## The Slot Contract

Every slot (or slot template seed) consists of three files:

### `config.json`

Static configuration passed to the data function. This is plain JSON — no code. Use it for content that changes infrequently: labels, URLs, feature flags, lists of items.

```json
{
  "brand": "Jigsaw",
  "links": [
    { "label": "Home", "href": "/" },
    { "label": "About", "href": "/about" }
  ]
}
```

An optional top-level `shares` array declares which named stores this slot participates in (see [Shared State](#shared-state)):

```json
{
  "shares": ["editor", "selection"],
  "theme": "dark"
}
```

### `data.js`

An ES module whose default export is a function receiving two arguments:

```javascript
export default function(shared, config) {
  return {
    brand: config.brand || "Default",
    links: config.links || []
  }
}
```

| Argument | Type | Description |
|----------|------|-------------|
| `shared` | `Object` | Map of shared DPP store entries (keyed by the names declared in `config.shares`). Each entry has `.proxy` (the reactive data) and `.dpp` (the DPP instance). Empty `{}` if no shares declared. |
| `config` | `Object` | The parsed contents of `config.json`. |

The function can be `async`. The returned object is passed directly to the render function as `data`.

### `render.jsx`

An ES module whose default export is the **Jigsaw render function** — an anonymous function that receives `data` and mounts UI into the DOM:

```jsx
import { createRoot } from "react-dom/client"

function MyComponent({ brand, links }) {
  return (
    <nav>
      <strong>{brand}</strong>
      {links.map(link => (
        <a key={link.href} href={link.href}>{link.label}</a>
      ))}
    </nav>
  )
}

export default function(data) {
  if (!this._root) this._root = createRoot(this.element)
  this._root.render(<MyComponent {...data} />)
}
```

The render function is **not** a React component. It is a plain function that the runtime calls with `this` bound to the Stimulus controller instance. You use it to imperatively mount your React component tree into `this.element`.

---

## Writing React Components

### The Render Function Contract

The default export of `render.jsx` must follow these rules:

1. **Anonymous function** — `export default function(data) { ... }`, never `export default function MyName(data) { ... }`
2. **`this` is the Stimulus controller** — bound automatically by the runtime. Access `this.element` for the slot's DOM container.
3. **Cache the React root** — `createRoot` must only be called once per slot. Cache it on `this._root`.
4. **`data` is the return value of the data function** — spread it into your component as props.

Here is an annotated example:

```jsx
import { createRoot } from "react-dom/client"

// 1. Define your React component(s) as regular functions (NOT default exports)
function PricingCard({ title, price, features }) {
  return (
    <div className="tw-rounded-lg tw-border tw-p-6">
      <h3 className="tw-text-xl tw-font-bold">{title}</h3>
      <p className="tw-text-3xl tw-font-bold tw-mt-2">${price}/mo</p>
      <ul className="tw-mt-4 tw-space-y-2">
        {features.map((f, i) => (
          <li key={i} className="tw-text-sm">{f}</li>
        ))}
      </ul>
    </div>
  )
}

// 2. The Jigsaw render function (always the last thing in the file)
export default function(data) {
  // 3. Create the React root only once, cache it on `this`
  if (!this._root) this._root = createRoot(this.element)
  // 4. Render your component, spreading data as props
  this._root.render(<PricingCard {...data} />)
}
```

### Available Imports

The engine's importmap provides these packages out of the box. Use standard ES `import` statements — they resolve at runtime via the browser's import map.

| Import | Version | Notes |
|--------|---------|-------|
| `react` | 19 | Core React |
| `react-dom/client` | 19 | `createRoot` for mounting |
| `react/jsx-runtime` | 19 | Used automatically by the JSX compiler |
| `lucide-react` | 0.460 | Icon library. `import { Menu, X, ChevronDown } from "lucide-react"` |
| `clsx` | 2 | Classname utility. `import { clsx } from "clsx"` |
| `class-variance-authority` | 0.7 | Variant utility for component styling |
| `@radix-ui/react-dropdown-menu` | 2 | Radix primitive |
| `@radix-ui/react-dialog` | 1 | Radix primitive |
| `@radix-ui/react-slot` | 1 | Radix primitive |
| `@radix-ui/react-context-menu` | 2 | Radix primitive |
| `@radix-ui/react-label` | 2 | Radix primitive |
| `@monaco-editor/react` | 4 | Monaco editor React wrapper |
| `@webcontainer/api` | 1 | WebContainer for in-browser Node.js |
| `xterm` | 5 | Terminal emulator |

### shadcn/ui Components

Pre-compiled [shadcn/ui](https://ui.shadcn.com/) components are available under the `@/components/ui/` path:

```jsx
import { Button } from "@/components/ui/button"
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet"
import { DropdownMenu, DropdownMenuTrigger, DropdownMenuContent, DropdownMenuItem } from "@/components/ui/dropdown-menu"
import { cn } from "@/lib/utils"
```

To install additional shadcn/ui components, use the rake task (see [Rake Tasks](#rake-tasks)).

### Tailwind CSS: The `tw-` Prefix

Jigsaw uses a scoped Tailwind configuration with the `tw-` prefix to avoid collisions with Fomantic-UI (used by the admin interface). **All Tailwind classes inside slot render functions must use the `tw-` prefix.**

```jsx
// Correct
<div className="tw-flex tw-items-center tw-gap-4 tw-p-6">

// Wrong — these classes will not apply
<div className="flex items-center gap-4 p-6">
```

This applies to all utility classes: `tw-text-sm`, `tw-bg-white`, `tw-rounded-lg`, `tw-hover:tw-bg-gray-100`, etc.

### Rules

| Rule | Reason |
|------|--------|
| No TypeScript | JSX is compiled server-side with Babel. TypeScript syntax will cause compilation errors. |
| No `"use client"` | This is not Next.js. The directive is meaningless and should be omitted. |
| No Next.js imports | `next/image`, `next/link`, `next/router` etc. do not exist. Use plain `<img>`, `<a>`, and `window.location`. |
| No relative imports | Slots are stored in the database and served individually. `import "./utils"` will not resolve. Use importmap paths (`@/lib/utils`, `lucide-react`, etc.). |
| Anonymous default export only | The runtime calls `renderModule.default.bind(this)`. Named default exports work syntactically but violate the convention and can cause confusion. |
| Cache the React root | `createRoot` must be called once. The render function is invoked every time data changes (including shared store updates). Creating a new root each time will throw React warnings and cause flickering. |

### Plain JavaScript (Non-React) Slots

Not every slot needs React. For simple content, you can write plain DOM manipulation:

```javascript
export default function(data) {
  this.element.innerHTML = `
    <div style="padding: 1em; text-align: center;">
      <h2>${data.title}</h2>
      <p>${data.subtitle}</p>
    </div>
  `
}
```

Set the slot's `render_language` to `"javascript"` (instead of `"jsx"`) to skip Babel compilation.

---

## Shared State

Slots are isolated by default — each has its own config, data, and render cycle. But slots can communicate through **named shared stores** backed by DPP (Distributed Persistent Proxies), which provide reactive, persistent, client-side state.

### Declaring Shared Stores

Add a `shares` array to the slot's `config.json` (or to the config JSON in the database):

```json
{
  "shares": ["editor"],
  "defaultFile": "index.js"
}
```

Every slot that declares the same store name gets access to the same reactive proxy object.

### Using Shared State in the Data Function

The `shared` argument is a map of store entries keyed by the names in `shares`. Each entry has:

- **`proxy`** — a JavaScript Proxy backed by IndexedDB. Read and write properties on it like a plain object.
- **`dpp`** — the underlying DPP instance (for advanced use like listening to events).

```javascript
export default function(shared, config) {
  // Read from the shared store
  const currentFile = shared.editor?.proxy?.currentFile || config.defaultFile

  return {
    currentFile,
    files: config.files || []
  }
}
```

### Writing to Shared State

Write to a shared store from within the render function (e.g., in an event handler). The runtime automatically re-runs `load()` (data function then render function) on every slot subscribed to that store when it saves.

```jsx
import { createRoot } from "react-dom/client"

function FileTree({ files, currentFile, onSelect }) {
  return (
    <ul>
      {files.map(f => (
        <li
          key={f}
          onClick={() => onSelect(f)}
          className={f === currentFile ? "tw-font-bold" : ""}
        >
          {f}
        </li>
      ))}
    </ul>
  )
}

export default function(data) {
  if (!this._root) this._root = createRoot(this.element)

  const onSelect = (file) => {
    // Write to the shared store — all subscribers re-render
    this.shared.editor.proxy.currentFile = file
    this.shared.editor.dpp.save()
  }

  this._root.render(
    <FileTree
      files={data.files}
      currentFile={data.currentFile}
      onSelect={onSelect}
    />
  )
}
```

### How Reactivity Works

1. Slot A writes to `shared.editor.proxy.currentFile` and calls `shared.editor.dpp.save()`
2. DPP persists the change to IndexedDB and fires a `"save"` event
3. The `custom-module` controller on Slot B (which also declares `"editor"` in its shares) is subscribed to that event
4. Slot B's `load()` is called — the data function re-runs with the updated proxy, and the render function re-renders with the new data

Data flows one direction: **store write** → **save event** → **data function** → **render function**. There is no two-way binding.

---

## Runtime Architecture

### Page Load Sequence

When a Jigsaw page loads, the following happens in order:

1. **`custom-page` Stimulus controller connects** — creates an empty `Map` of shared stores and exposes a `findOrCreateStore(key)` method on `this.element.page`. This is the page-level store registry.

2. **For each slot, a `custom-module` Stimulus controller connects:**
   - Locates the parent `custom-page` controller (waits if it hasn't connected yet)
   - For each key in the slot's `shares` array, calls `page.findOrCreateStore(key)` which lazily creates a DPP persistent proxy (backed by IndexedDB, namespaced to the page ID and store key)
   - Dynamically imports the compiled data function: `import(dataFnUrl)` — this fetches the ES module from the server's `slots/:id/data_source` endpoint
   - Dynamically imports the compiled render function: `import(renderFnUrl)` — fetched from `slots/:id/render_source`
   - Binds both functions: `dataModule.default.bind(this)` and `renderModule.default.bind(this)` — so `this` inside the functions refers to the Stimulus controller
   - Subscribes to `"save"` events on each shared store — when any store saves, `load()` is called again
   - Calls `load()` for the initial render

3. **`load()` executes the slot pipeline:**
   ```
   const data = await this.fetchData(this.shared, this.configValue)
   this.lastData = data
   this.render(data)
   ```

### JSX Compilation

Slots with `render_language: "jsx"` have their render source compiled to plain JavaScript before being served to the browser.

**Server-side (on save):** The `JsxCompiler` uses [MiniRacer](https://github.com/rubyjs/mini_racer) to run Babel inside a V8 isolate with the `react` preset configured for the automatic JSX runtime. The compiled output is stored in `render_compiled_source` and served as `text/javascript` with a digest-based cache key.

```ruby
# Simplified — what happens when a slot is saved with render_language "jsx"
Babel.transform(source, {
  presets: [['react', { runtime: 'automatic' }]]
}).code
```

**Client-side (hot-swap in editor):** The built-in Monaco editor compiles JSX on the fly using `@swc/wasm-web`, creates a `Blob` URL from the output, and hot-swaps the function on the live controller — no server roundtrip needed for previewing changes.

### Template Linking

When a slot is linked to a `SlotTemplate`, all `effective_*` accessors (used by the view and controllers) delegate to the template:

```ruby
def effective_render_source
  if linked_to_template? && slot_template
    slot_template.render_source
  else
    render_source
  end
end
```

This means updating a template's render source instantly affects every linked slot. Calling `slot.unlink_from_template!` copies the template's current values into the slot's own columns and clears the link, allowing independent editing.

### Endpoint Routes

All slot endpoints are mounted under the engine's namespace (default `/jigsaw`):

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/jigsaw/slots/:id/data_source` | GET | Serves compiled data function as `text/javascript` |
| `/jigsaw/slots/:id/render_source` | GET | Serves compiled render function as `text/javascript` |
| `/jigsaw/slots/:id/edit` | GET | Opens the Monaco editor for a slot |
| `/jigsaw/slots/:id` | PATCH | Saves slot source code + config |
| `/jigsaw/slot_templates/:id/data_source` | GET | Serves template's compiled data function |
| `/jigsaw/slot_templates/:id/render_source` | GET | Serves template's compiled render function |

---

## Seed Templates

Seeds are pre-built slot definitions shipped with the engine. Each seed is a directory containing the three contract files.

### Directory Structure

```
engines/jigsaw-engine/app/javascript/seeds/
  main-menu/
    config.json
    data.js
    render.jsx
  ide-editor/
    config.json
    data.js
    render.jsx
  ide-file-tree/
    ...
```

### Creating a New Seed

1. Create a directory under `app/javascript/seeds/` with a descriptive name:

```
mkdir engines/jigsaw-engine/app/javascript/seeds/hero-banner
```

2. Add the three files following the slot contract:

**`config.json`**
```json
{
  "heading": "Welcome to Jigsaw",
  "subheading": "Build dynamic pages with composable slots",
  "ctaLabel": "Get Started",
  "ctaHref": "/docs"
}
```

**`data.js`**
```javascript
export default function(shared, config) {
  return {
    heading: config.heading || "Hello",
    subheading: config.subheading || "",
    ctaLabel: config.ctaLabel || "Learn More",
    ctaHref: config.ctaHref || "#"
  }
}
```

**`render.jsx`**
```jsx
import { createRoot } from "react-dom/client"
import { Button } from "@/components/ui/button"

function HeroBanner({ heading, subheading, ctaLabel, ctaHref }) {
  return (
    <section className="tw-flex tw-flex-col tw-items-center tw-justify-center tw-py-20 tw-px-4 tw-text-center">
      <h1 className="tw-text-4xl tw-font-bold tw-tracking-tight sm:tw-text-5xl">
        {heading}
      </h1>
      <p className="tw-mt-4 tw-max-w-xl tw-text-lg tw-text-muted-foreground">
        {subheading}
      </p>
      <a href={ctaHref} className="tw-mt-8">
        <Button size="lg">{ctaLabel}</Button>
      </a>
    </section>
  )
}

export default function(data) {
  if (!this._root) this._root = createRoot(this.element)
  this._root.render(<HeroBanner {...data} />)
}
```

3. Install seeds into the host app:

```bash
bin/rails jigsaw:install:seeds
```

This copies the seed directories to `app/javascript/seeds/` in the host app (existing files are skipped).

---

## Rake Tasks

### Install seed templates

Copies the engine's JavaScript seed files (slot template configs, data, and render sources) into `app/javascript/seeds/`. Existing files are skipped.

```bash
bin/rails jigsaw:install:seeds
```

### Install shadcn/ui components

Downloads shadcn/ui components, compiles TSX to ESM JavaScript, and installs them into the engine at `app/javascript/jigsaw/components/ui/` with importmap pins auto-added.

```bash
bin/rails jigsaw:shadcn:install[button,dropdown-menu,sheet]
```

After installation, replace Tailwind classes with Fomantic-UI classes and add any missing Radix importmap pins to `config/importmap.rb`.

## Testing

Docker Compose provides a PostgreSQL test database (port 6432).

```bash
# Start docker services (if not already running)
docker compose up -d

# Run engine tests from within the engine directory
cd engines/jigsaw-engine
RAILS_ENV=test bin/rails db:create db:migrate   # first time only
RAILS_ENV=test bin/rails test
```
