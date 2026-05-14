# Guide 08: Fix Relative/Local Module Imports

## Problem

~15 seed files import from relative paths (e.g., `./icons`, `./store`, `./cart-item`) but those files don't exist in the seed directory. Each seed directory only contains 3 files: `config.json`, `data.js`, and `render.jsx`.

These seeds were originally multi-file components that weren't fully copied over.

## The Correct Approach

Inline the referenced module's code directly into `render.jsx`. Each seed must be entirely self-contained in its 3 files.

## Affected Seeds

- `blocks/ecommerce/shopping-cart-1` through `shopping-cart-4` (import `./cart-line`, `./store`, `./cart-item`, `./cart-item-row`)
- `blocks/ecommerce/product-quickview-1` and `2` (import `./product-quickview-modal`)
- `blocks/ecommerce/store-navigation-1` (import `./icons`)
- `blocks/ecommerce/checkout-page-2` (import `../1`)
- `blocks/ecommerce-charts-2` (import `./data`)
- `blocks/dashboard-ui/sidebar-layouts-1`, `page-layouts-1/2/3` (import `./app-sidebar`, `./app-header`, `./components/*`)
- `blocks/marketing/pricing-table-2/3` (import `./data`)
- `examples/payment-methods-1/2` (import `./icons`)
- `examples/chat-bubbles-2` (import `./message-list-item`, `./data`)

## Strategy

### Option A: Inline the Referenced Code (Preferred)

If you can determine what the imported module should contain based on how it's used, define it directly in the render.jsx file.

```jsx
// Before:
import { CartItem } from "./cart-item"
import { useStore } from "./store"

// After: Define them inline in the same file
function CartItem({ name, price, quantity }) {
  return (
    <div className="tw-flex tw-justify-between">
      <span>{name}</span>
      <span>${price} x {quantity}</span>
    </div>
  )
}

function useStore() {
  const [items, setItems] = React.useState([])
  return { items, setItems }
}
```

### Option B: Stub with Placeholder (If the module is complex/unknown)

If the imported module's implementation is unclear, create a minimal stub:

```jsx
// Before:
import { PaymentIcons } from "./icons"

// After: Stub with minimal implementation
function PaymentIcons({ type }) {
  const icons = { visa: "💳", mastercard: "💳", paypal: "💳" }
  return <span>{icons[type] || "💳"}</span>
}
```

### Option C: Remove the Feature (If it's a minor enhancement)

If the relative import provides a non-essential feature (like custom icons), simplify by removing that functionality:

```jsx
// Before:
import { AnimatedBackground } from "./animated-bg"
// ... uses <AnimatedBackground /> somewhere

// After: Replace with a simple div or remove entirely
// ... replace <AnimatedBackground /> with <div className="tw-bg-gray-100" />
```

## Rules

1. Every seed MUST be self-contained — no relative imports (`./`, `../`) should remain
2. Imports from the import map (`@/components/ui/*`, `react`, `lucide-react`, etc.) are fine
3. If inlining, place the inlined code ABOVE where it's used in the file
4. Maintain the same API/props interface that the existing code expects

## Special Case: `../1` Import

The `checkout-page-2` imports from `../1` which references another seed variant. This should be inlined or the component should be rewritten to be standalone.

## Special Case: `./data` Import

Some seeds import data from a `./data` module. This data should be moved to either:
- Inline constants at the top of `render.jsx`
- Or moved to `config.json` and accessed via the `data` parameter

## Verification

After transformation:
- No `import ... from "./"` or `import ... from "../"` statements should remain
- The file should only import from package specifiers (starting with a letter or `@`)
- The component should still render correctly (no undefined references)
