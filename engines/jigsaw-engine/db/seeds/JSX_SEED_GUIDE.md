# Converting shadcn/Next.js Components to Seeds

## Allowed Changes (ONLY these, nothing else)

1. Remove `"use client";`
2. Remove `import Link from "next/link";` — replace `<Link` with `<a` and `</Link>` with `</a>`
3. Remove `import Image from "next/image";` — replace `<Image` with `<img` and `</Image>` with `</img>`
4. Strip TypeScript type annotations
5. Change `export default function ComponentName()` → `function ComponentName()`
6. Add `import { createRoot } from "react-dom/client"`
7. Add the render wrapper before the component function:

```jsx
export default function(data) {
  if (!this._root) this._root = createRoot(this.element)
  this._root.render(<ComponentName />)
}
```

8. For packages not in the importmap (like `motion/react`, `react-use-measure`, `radix-ui`), convert to full esm.sh URLs with `?bundle&external=react,react-dom,react/jsx-runtime`

## NEVER do any of the following

- Replace or remove components (e.g. VisuallyHidden) — just fix the import path
- Simplify or replace SVGs with placeholders
- Remove or rewrite any JSX
- Extract hardcoded data into config/params
- Add or change className values
- "Improve" or refactor anything
- Change the structure or logic of the component in any way

## Seed file template

```ruby
# --- Component Name ---

component_data_fn = Jigsaw::DataFunction.find_or_create_by!(name: "component_data") do |f|
  f.source = <<~JS
    export default async function(shared, config) {
      return {}
    }
  JS
end

component_render_fn = Jigsaw::RenderFunction.find_or_create_by!(name: "component_render") do |f|
  f.language = "jsx"
  f.source = <<~JS
    // converted JSX here — VERBATIM from original with only the allowed changes above
  JS
end

component_page = Jigsaw::CustomPage.find_or_create_by!(path: "demos/component") do |p|
  p.title = "Component Demo"
end

Jigsaw::PageModule.find_or_create_by!(custom_page: component_page, data_function: component_data_fn, render_function: component_render_fn) do |m|
  m.position = 0
  m.config = {}
end
```

## The user's code is sacred. Copy it verbatim with only the mechanical substitutions listed above.
