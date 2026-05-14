# Guide 09: Extract Hardcoded Data into config.json and data.js

## Problem

All 219 block/example seeds have empty configs and pass-through data functions:

```json
// config.json
{}
```

```javascript
// data.js
export default function(shared, config) { return config }
```

All display data is hardcoded inside `render.jsx`. This means the templates aren't configurable — they're static blocks with no way to customize content without editing the render source.

## The Correct Pattern

The Jigsaw architecture separates concerns:

- **config.json** — static configuration for the slot (customizable by the user through UI)
- **data.js** — transforms config + shared state into data for rendering
- **render.jsx** — purely presentational, receives data as props

### Working Example: `main-menu`

```json
// config.json
{
  "brand": "Jigsaw",
  "links": [
    { "label": "Home", "href": "/" },
    { "label": "About", "href": "/about" }
  ]
}
```

```javascript
// data.js
export default function(shared, config) {
  return {
    brand: config.brand || "Jigsaw",
    links: config.links || []
  }
}
```

```jsx
// render.jsx — uses data.brand and data.links, no hardcoded values
export default function(data) {
  if (!this._root) this._root = createRoot(this.element)
  this._root.render(<MainMenu brand={data.brand} links={data.links} />)
}
```

## What to Extract

Look for hardcoded content in `render.jsx` that a user would want to customize:

### Text Content
- Headlines, titles, descriptions
- Button labels
- List items, feature descriptions

### Media
- Image URLs
- Avatar URLs

### Configuration
- Colors, sizes
- Number of items to show
- Feature flags (show/hide sections)

### Structured Data
- Product lists, pricing tiers
- Team members, testimonials
- Navigation links

## Transformation Steps

### Step 1: Identify Data in render.jsx

Look for hardcoded arrays, objects, and string content:

```jsx
// These are all candidates for extraction:
const products = [{ name: "Shirt", price: 29.99 }, ...]
const features = ["Fast", "Secure", "Scalable"]
<h1>Empower Your Creativity</h1>
<p>Unlock your potential with...</p>
<img src="https://images.unsplash.com/..." />
```

### Step 2: Move Data to config.json

```json
{
  "headline": "Empower Your Creativity",
  "description": "Unlock your potential with...",
  "heroImage": "https://images.unsplash.com/...",
  "cta": {
    "primary": { "label": "Get Started", "href": "#" },
    "secondary": { "label": "Learn More", "href": "#" }
  }
}
```

### Step 3: Update data.js to Pass Config Through (With Defaults)

```javascript
export default function(shared, config) {
  return {
    headline: config.headline || "Default Headline",
    description: config.description || "Default description text",
    heroImage: config.heroImage || "https://placehold.co/800x600",
    cta: config.cta || {
      primary: { label: "Get Started", href: "#" },
      secondary: { label: "Learn More", href: "#" }
    }
  }
}
```

### Step 4: Update render.jsx to Use Props

```jsx
function HeroSection({ headline, description, heroImage, cta }) {
  return (
    <div>
      <h1>{headline}</h1>
      <p>{description}</p>
      <img src={heroImage} alt="" />
      <a href={cta.primary.href}>{cta.primary.label}</a>
    </div>
  )
}

export default function(data) {
  if (!this._root) this._root = createRoot(this.element)
  this._root.render(<HeroSection {...data} />)
}
```

## Priority

This transformation is LOW PRIORITY — the seeds will work without it (the components just won't be configurable). Focus on the other guides first. This is an enhancement to make templates actually useful as reusable, customizable blocks.

## Guidelines

1. Don't over-extract — some things (like icon choices, layout structure) should stay in the render
2. Keep config.json flat or max 2 levels deep — deeply nested configs are hard to edit
3. Always provide defaults in data.js so the component works even with `{}`
4. Use descriptive key names that make sense without context

## Verification

After transformation:
- `config.json` contains meaningful, editable values
- `data.js` passes config values through with sensible defaults
- `render.jsx` uses `data.*` props instead of hardcoded strings
- The component renders identically with the provided config as it did with hardcoded values
