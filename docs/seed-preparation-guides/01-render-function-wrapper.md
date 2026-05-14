# Guide 01: Wrap Render Function in Jigsaw Contract

## Problem

The seed `render.jsx` files export standalone React components:

```jsx
export default function HeroSection() {
  return (<div>...</div>)
}
```

The Jigsaw runtime expects a render function that imperatively mounts into `this.element`:

```jsx
export default function(data) {
  if (!this._root) this._root = createRoot(this.element)
  this._root.render(<Component {...data} />)
}
```

## How the Runtime Works

The `custom_module_controller.js` Stimulus controller:
1. Imports the render module as an ES module
2. Calls `renderModule.default.bind(this)` where `this` is the Stimulus controller instance
3. Calls `this.render(data)` passing the data returned by the data function

The render function receives `data` as its first argument and `this` is bound to the Stimulus controller. `this.element` is the DOM container for the slot.

## The Correct Pattern

```jsx
import { createRoot } from "react-dom/client"

// The component itself (internal, not exported as default)
function MyComponent({ title, description }) {
  return (
    <div>
      <h1>{title}</h1>
      <p>{description}</p>
    </div>
  )
}

// The Jigsaw render function (exported as default)
export default function(data) {
  if (!this._root) this._root = createRoot(this.element)
  this._root.render(<MyComponent {...data} />)
}
```

## Key Rules

1. The default export MUST be an anonymous function (not a named component)
2. The function receives `data` as its only parameter
3. `this` is bound to the Stimulus controller — access `this.element` for the DOM container
4. Cache the React root as `this._root` to avoid creating a new root on every render call
5. Always check `if (!this._root)` before creating the root — the render function is called multiple times (whenever data changes)
6. Spread `data` into the component as props, or pass it however the component expects
7. The `import { createRoot } from "react-dom/client"` MUST be at the top of the file

## Transformation Steps

For each `render.jsx` file:

1. Add `import { createRoot } from "react-dom/client"` to the imports (if not already present)
2. Rename the default export function to a named (non-default) function. For example:
   - `export default function HeroSection()` becomes `function HeroSection()`
3. Add the Jigsaw wrapper as the new default export at the bottom of the file:
   ```jsx
   export default function(data) {
     if (!this._root) this._root = createRoot(this.element)
     this._root.render(<HeroSection {...data} />)
   }
   ```
4. If the component has hardcoded data (not from props), just spread `data` anyway — it won't break anything and positions the component for future data extraction

## Example Transformation

### Before:
```jsx
import { ArrowRightIcon } from "lucide-react"
import { Button } from "@/components/ui/button"

export default function HeroSection() {
  return (
    <div className="mx-auto max-w-2xl">
      <h1>Empower Your Creativity</h1>
      <Button size="lg">Get started</Button>
    </div>
  )
}
```

### After:
```jsx
import { createRoot } from "react-dom/client"
import { ArrowRightIcon } from "lucide-react"
import { Button } from "@/components/ui/button"

function HeroSection() {
  return (
    <div className="mx-auto max-w-2xl">
      <h1>Empower Your Creativity</h1>
      <Button size="lg">Get started</Button>
    </div>
  )
}

export default function(data) {
  if (!this._root) this._root = createRoot(this.element)
  this._root.render(<HeroSection {...data} />)
}
```

## Files to Process

All `.jsx` files in:
- `app/javascript/seeds/blocks/` (all subdirectories)
- `app/javascript/seeds/examples/` (all subdirectories)

Do NOT modify the `ide-*` or `main-menu` seeds — they already follow the correct pattern.

## Verification

After transformation, the file must:
- Have `import { createRoot } from "react-dom/client"` in imports
- Have NO `export default function SomeName()` (named default exports)
- Have exactly one `export default function(data)` anonymous function at the end
- Contain `this._root = createRoot(this.element)` inside that function
- Contain `this._root.render(<...>)` inside that function
