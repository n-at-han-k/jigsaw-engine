# Seed Preparation Guides

These guides cover the transformations needed to make the seed files in `app/javascript/seeds/` compatible with the Jigsaw runtime. Each guide addresses a single issue and can be tackled independently.

## Recommended Order of Operations

| # | Guide | Priority | Scope | Notes |
|---|-------|----------|-------|-------|
| 04 | [Remove "use client"](./04-remove-use-client.md) | HIGH | 121 files | Trivial, do first |
| 05 | [Remove TypeScript syntax](./05-typescript-syntax.md) | HIGH | ~45 files | Must fix before JSX compilation works |
| 03 | [Replace next/image and next/link](./03-replace-next-imports.md) | HIGH | ~95 files | Removes unresolvable imports |
| 01 | [Wrap render function](./01-render-function-wrapper.md) | HIGH | 219 files | Core contract fix |
| 02 | [Add tw- prefix to Tailwind classes](./02-tailwind-prefix.md) | HIGH | 219 files | No styling without this |
| 08 | [Fix relative imports](./08-relative-imports.md) | HIGH | ~15 files | Blocks compilation |
| 07 | [Add third-party import map pins](./07-third-party-imports.md) | HIGH | importmap.rb | Infrastructure (one-time) |
| 06 | [Build missing shadcn/ui components](./06-missing-shadcn-components.md) | HIGH | ~34 modules to build | Infrastructure (one-time, largest effort) |
| 09 | [Extract data into config.json](./09-empty-config-data.md) | LOW | 219 files | Enhancement, not blocking |

## Scope

These guides apply to seed files in:
- `app/javascript/seeds/blocks/` (all subdirectories)
- `app/javascript/seeds/examples/` (all subdirectories)

The following seeds already follow the correct pattern and should NOT be modified:
- `app/javascript/seeds/ide-editor/`
- `app/javascript/seeds/ide-file-tree/`
- `app/javascript/seeds/ide-preview/`
- `app/javascript/seeds/ide-terminal/`
- `app/javascript/seeds/main-menu/`

## The Correct Seed Format

A properly formatted seed has three files:

### config.json
```json
{
  "title": "My Component",
  "items": [...]
}
```

### data.js
```javascript
export default function(shared, config) {
  return {
    title: config.title || "Default",
    items: config.items || []
  }
}
```

### render.jsx
```jsx
import { createRoot } from "react-dom/client"
import { Button } from "@/components/ui/button"

function MyComponent({ title, items }) {
  return (
    <div className="tw-p-4">
      <h1 className="tw-text-2xl tw-font-bold">{title}</h1>
      {items.map(item => (
        <div key={item.id} className="tw-mt-2">{item.name}</div>
      ))}
      <Button>Action</Button>
    </div>
  )
}

export default function(data) {
  if (!this._root) this._root = createRoot(this.element)
  this._root.render(<MyComponent {...data} />)
}
```

Key characteristics:
- `createRoot` from `react-dom/client` (cached on `this._root`)
- All Tailwind classes prefixed with `tw-`
- No Next.js imports
- No TypeScript
- No `"use client"`
- No relative imports
- Default export is anonymous function receiving `data`, with `this` bound to Stimulus controller
- Component defined as a regular (non-exported) function above the default export
