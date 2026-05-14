# Guide 05: Remove TypeScript Syntax

## Problem

~45 seed files contain TypeScript syntax that the JsxCompiler (Babel with only the React preset) cannot parse. This causes a compile error when the seed is saved to the database.

## The JsxCompiler

The compiler uses Babel with this config:
```javascript
Babel.transform(source, {
  presets: [['react', { runtime: 'automatic' }]]
}).code
```

It does NOT have the TypeScript preset, so any TypeScript-specific syntax will throw a parse error.

## TypeScript Patterns to Remove

### 1. The `satisfies` keyword (~30 seeds)

```typescript
// Before:
const chartConfig = {
  desktop: { label: "Desktop", color: "var(--chart-1)" },
} satisfies ChartConfig;

// After:
const chartConfig = {
  desktop: { label: "Desktop", color: "var(--chart-1)" },
};
```

Rule: Remove `satisfies TypeName` entirely. It's a compile-time type assertion with no runtime effect.

### 2. Type annotations on variables and parameters (~15 seeds)

```typescript
// Before:
const onSubmit = async (data: LoginFormData) => { ... }
const [api, setApi] = useState<CarouselApi>()
const [date, setDate] = React.useState<DateRange | undefined>(...)
function Component({ items }: { items: Item[] }) { ... }

// After:
const onSubmit = async (data) => { ... }
const [api, setApi] = useState()
const [date, setDate] = React.useState(...)
function Component({ items }) { ... }
```

Rules:
- Remove `: TypeName` after parameter names
- Remove `<TypeName>` generic type arguments on function calls like `useState<T>()` becomes `useState()`
- Remove `<TypeName>` on React.useState, useRef, etc.
- Remove type annotations on destructured parameters: `{ items }: { items: Item[] }` becomes `{ items }`

### 3. Type/Interface declarations (~10 seeds)

```typescript
// Before:
type LoginFormData = z.infer<typeof loginSchema>;
type Message = { id: string; text: string; sender: "user" | "bot" }
interface ChartData { month: string; value: number }

// After:
// (remove the entire line — these are compile-time only)
```

Rule: Remove entire `type` and `interface` declaration lines. They produce no runtime code.

### 4. Type imports

```typescript
// Before:
import type { ChartConfig } from "@/components/ui/chart"
import { type CarouselApi, Carousel } from "@/components/ui/carousel"

// After:
// Remove the entire `import type` line
import { Carousel } from "@/components/ui/carousel"
```

Rules:
- Remove entire `import type { ... }` lines
- In mixed imports like `import { type Foo, Bar }`, remove the `type Foo,` part and keep the rest
- If removing the type import leaves an empty import `import { } from "..."`, remove the entire line

### 5. `as` type assertions

```typescript
// Before:
const value = someObj as Record<string, number>
const el = document.getElementById("foo") as HTMLInputElement

// After:
const value = someObj
const el = document.getElementById("foo")
```

Rule: Remove `as TypeName` expressions.

### 6. Non-null assertions (`!`)

```typescript
// Before:
const ext = filename.split(".").pop()!.toLowerCase()

// After:
const ext = filename.split(".").pop()?.toLowerCase()
```

Rule: Replace `!.` with `?.` (optional chaining) or just `.` if the value is guaranteed non-null.

## What to Keep

- Regular JavaScript/JSX syntax
- `?.` optional chaining (valid JS)
- `??` nullish coalescing (valid JS)
- `...` spread/rest operators (valid JS)
- Arrow functions, destructuring, template literals, etc. (all valid JS)

## Files to Process

All `.jsx` files in:
- `app/javascript/seeds/blocks/` (all subdirectories)
- `app/javascript/seeds/examples/` (all subdirectories)

Only process files that actually contain TypeScript syntax. Quick ways to identify them:
- Contains `satisfies` keyword (outside strings)
- Contains generic type parameters on function calls: `useState<`
- Contains `type ` or `interface ` declarations at top level
- Contains `import type`
- Contains `as ` type assertions (careful: `as` also appears in `asChild` prop — only target `as TypeName` patterns)

## Verification

After transformation:
- No `satisfies` keyword should remain
- No `type` or `interface` top-level declarations
- No `: TypeName` annotations on function parameters
- No `<TypeName>` generic type parameters on function calls (but JSX `<Component>` is fine — JSX components start with uppercase)
- No `import type` statements
- The file should be valid JavaScript/JSX parseable by Babel with only the React preset
