# Guide 06: Build Missing shadcn/ui Component Modules

## Problem

The seeds import ~34 shadcn/ui components from `@/components/ui/*`, but only 4 exist in the import map:
- `@/components/ui/button` mapped to `jigsaw/components/ui/button.js`
- `@/components/ui/dropdown-menu` mapped to `jigsaw/components/ui/dropdown-menu.js`
- `@/components/ui/sheet` mapped to `jigsaw/components/ui/sheet.js`
- `@/lib/utils` mapped to `jigsaw/components/ui/utils.js`

Each missing component needs a pre-compiled JavaScript module and an import map pin.

## Where Built Components Live

```
engines/jigsaw-engine/app/javascript/jigsaw/components/ui/
├── button.js          (exists)
├── dropdown-menu.js   (exists)
├── sheet.js           (exists)
└── utils.js           (exists)
```

## Import Map Location

`engines/jigsaw-engine/config/importmap.rb`

## The Correct Pattern for Building a Component

Each component module must:

1. Import React and dependencies from the import map (using the same module specifiers pinned in importmap.rb)
2. Use `tw-` prefixed Tailwind classes everywhere
3. Export named exports matching what the seeds expect to import
4. Be valid ES module JavaScript (no TypeScript, no JSX — pre-compiled to createElement or jsx-runtime calls)

### Reference: How the existing `button.js` works

Key characteristics:
- Uses `React.createElement` or jsx-runtime `_jsx` calls (not JSX syntax)
- Imports from pinned modules: `react`, `@radix-ui/react-slot`, `class-variance-authority`, `@/lib/utils`
- All Tailwind classes have `tw-` prefix
- Uses `cva()` for variant-based styling
- Uses `React.forwardRef` for ref forwarding
- Exports named components: `export { Button, buttonVariants }`

### Reference: How the `cn()` utility works (from `@/lib/utils`)

```javascript
import { clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs) {
  return twMerge(clsx(inputs))
}
```

## Components Needed (Priority Order by Usage Count)

| Component | Import Path | Radix Dependency | Approx Usage |
|-----------|-------------|------------------|--------------|
| card | `@/components/ui/card` | None | ~120 seeds |
| badge | `@/components/ui/badge` | None | ~40 seeds |
| input | `@/components/ui/input` | None | ~30 seeds |
| label | `@/components/ui/label` | `@radix-ui/react-label` | ~20 seeds |
| avatar | `@/components/ui/avatar` | `@radix-ui/react-avatar` | ~20 seeds |
| separator | `@/components/ui/separator` | `@radix-ui/react-separator` | ~15 seeds |
| select | `@/components/ui/select` | `@radix-ui/react-select` | ~15 seeds |
| chart | `@/components/ui/chart` | None (wraps recharts) | ~34 seeds |
| form | `@/components/ui/form` | None (wraps react-hook-form) | ~14 seeds |
| carousel | `@/components/ui/carousel` | None (wraps embla) | ~12 seeds |
| tabs | `@/components/ui/tabs` | `@radix-ui/react-tabs` | ~6 seeds |
| radio-group | `@/components/ui/radio-group` | `@radix-ui/react-radio-group` | ~10 seeds |
| checkbox | `@/components/ui/checkbox` | `@radix-ui/react-checkbox` | ~8 seeds |
| progress | `@/components/ui/progress` | `@radix-ui/react-progress` | ~8 seeds |
| tooltip | `@/components/ui/tooltip` | `@radix-ui/react-tooltip` | ~8 seeds |
| dialog | `@/components/ui/dialog` | `@radix-ui/react-dialog` | ~6 seeds |
| navigation-menu | `@/components/ui/navigation-menu` | `@radix-ui/react-navigation-menu` | ~6 seeds |
| textarea | `@/components/ui/textarea` | None | ~3 seeds |
| switch | `@/components/ui/switch` | `@radix-ui/react-switch` | ~3 seeds |
| collapsible | `@/components/ui/collapsible` | `@radix-ui/react-collapsible` | ~4 seeds |
| popover | `@/components/ui/popover` | `@radix-ui/react-popover` | ~4 seeds |
| breadcrumb | `@/components/ui/breadcrumb` | None | ~4 seeds |
| calendar | `@/components/ui/calendar` | None (wraps react-day-picker) | ~4 seeds |
| accordion | `@/components/ui/accordion` | `@radix-ui/react-accordion` | ~3 seeds |
| toggle-group | `@/components/ui/toggle-group` | `@radix-ui/react-toggle-group` | ~3 seeds |
| slider | `@/components/ui/slider` | `@radix-ui/react-slider` | ~1 seed |
| scroll-area | `@/components/ui/scroll-area` | `@radix-ui/react-scroll-area` | ~2 seeds |
| sidebar | `@/components/ui/sidebar` | None (custom) | ~4 seeds |
| input-otp | `@/components/ui/input-otp` | None (wraps input-otp pkg) | ~1 seed |
| drawer | `@/components/ui/drawer` | None (wraps vaul) | ~1 seed |
| command | `@/components/ui/command` | None (wraps cmdk) | ~1 seed |
| stepper | `@/components/ui/stepper` | None (custom) | ~1 seed |

## Steps for Each Component

1. **Get the shadcn/ui source** for the component from https://ui.shadcn.com/docs/components/[name]
2. **Identify Radix UI dependencies** — if a Radix package is needed, ensure it's pinned in importmap.rb:
   ```ruby
   pin "@radix-ui/react-avatar", to: "https://esm.sh/@radix-ui/react-avatar@1?bundle&external=react,react-dom,react%2Fjsx-runtime"
   ```
3. **Convert JSX to JavaScript** — replace all JSX with `React.createElement()` calls or use jsx-runtime:
   ```jsx
   // JSX:
   <div className="tw-flex">{children}</div>
   // Becomes:
   React.createElement("div", { className: "tw-flex" }, children)
   ```
4. **Prefix all Tailwind classes with `tw-`**
5. **Export named components** matching what seeds import. Check actual imports used in seeds with grep:
   ```bash
   grep -rh "from \"@/components/ui/card\"" app/javascript/seeds/ | sort -u
   ```
   This tells you exactly which named exports are needed (e.g., `Card`, `CardHeader`, `CardTitle`, `CardContent`, `CardFooter`, `CardDescription`, `CardAction`).
6. **Save to** `app/javascript/jigsaw/components/ui/[name].js`
7. **Pin in importmap.rb**:
   ```ruby
   pin "@/components/ui/card", to: "jigsaw/components/ui/card.js"
   ```
8. **Test** that the module loads without errors in the browser console

## Import Map Pins for Radix Dependencies

For each Radix UI package needed, add to `config/importmap.rb`:
```ruby
pin "@radix-ui/react-avatar", to: "https://esm.sh/@radix-ui/react-avatar@1?bundle&external=react,react-dom,react%2Fjsx-runtime"
```

The `?bundle&external=react,react-dom,react%2Fjsx-runtime` query params tell esm.sh to:
- Bundle all of the package's internal dependencies
- Externalize react/react-dom so they use the already-pinned versions

## Checking What Exports Are Needed

For any component, grep the seeds to see exactly what named imports are used:

```bash
grep -rh "@/components/ui/card" engines/jigsaw-engine/app/javascript/seeds/ | sort -u
```

Example output:
```
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Card, CardAction, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Card, CardContent } from "@/components/ui/card";
```

This tells you the component must export: `Card`, `CardContent`, `CardDescription`, `CardFooter`, `CardHeader`, `CardTitle`, `CardAction`.

## Verification

For each built component:
- File exists at `app/javascript/jigsaw/components/ui/[name].js`
- Pin exists in `config/importmap.rb`
- All Tailwind classes use `tw-` prefix
- No JSX syntax remains (pre-compiled)
- No TypeScript syntax
- Named exports match what seeds actually import
- Radix dependencies are pinned in importmap.rb
- Module loads without console errors in browser
