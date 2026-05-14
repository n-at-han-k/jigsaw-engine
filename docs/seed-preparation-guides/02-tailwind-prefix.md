# Guide 02: Add `tw-` Prefix to Tailwind CSS Classes

## Problem

The Tailwind config uses `prefix: 'tw-'`. All CSS utilities are generated with this prefix (e.g., `tw-flex`, `tw-items-center`, `tw-p-4`). The seed files use unprefixed classes which won't match any generated CSS.

## The Correct Pattern

Every Tailwind utility class must be prefixed with `tw-`:

```jsx
// WRONG:
<div className="flex items-center gap-2 p-4 bg-white rounded-lg">

// CORRECT:
<div className="tw-flex tw-items-center tw-gap-2 tw-p-4 tw-bg-white tw-rounded-lg">
```

## Where Classes Appear

Classes appear in several contexts that all need transformation:

### 1. Simple className strings
```jsx
// Before:
className="flex items-center gap-2"
// After:
className="tw-flex tw-items-center tw-gap-2"
```

### 2. Template literals
```jsx
// Before:
className={`flex items-center ${isActive ? "bg-blue-500" : "bg-gray-200"}`}
// After:
className={`tw-flex tw-items-center ${isActive ? "tw-bg-blue-500" : "tw-bg-gray-200"}`}
```

### 3. cn() utility calls (from @/lib/utils)
```jsx
// Before:
className={cn("flex items-center", isActive && "bg-blue-500")}
// After:
className={cn("tw-flex tw-items-center", isActive && "tw-bg-blue-500")}
```

### 4. Conditional/ternary expressions
```jsx
// Before:
className={active ? "text-white bg-primary" : "text-gray-400 bg-gray-800"}
// After:
className={active ? "tw-text-white tw-bg-primary" : "tw-text-gray-400 tw-bg-gray-800"}
```

### 5. Array joins or clsx-style
```jsx
// Before:
className={["flex", "items-center", condition && "hidden"].filter(Boolean).join(" ")}
// After:
className={["tw-flex", "tw-items-center", condition && "tw-hidden"].filter(Boolean).join(" ")}
```

## Rules for Prefixing

1. **Every space-separated token** inside a className string that is a Tailwind utility gets `tw-` prepended
2. **Responsive prefixes** go BEFORE the `tw-` prefix: `sm:tw-flex`, `md:tw-grid-cols-2`, `lg:tw-px-8`
   - Pattern: `sm:` `md:` `lg:` `xl:` `2xl:` stay as-is, then `tw-` goes after
   - Example: `sm:flex` becomes `sm:tw-flex`
3. **State prefixes** also go before: `hover:tw-bg-blue-500`, `focus:tw-ring-2`, `dark:tw-bg-gray-900`
   - Pattern: `hover:` `focus:` `active:` `disabled:` `dark:` `group-hover:` etc.
   - Example: `hover:bg-blue-500` becomes `hover:tw-bg-blue-500`
4. **Arbitrary values** get prefixed too: `tw-w-[350px]`, `tw-grid-cols-[1fr_2fr]`
5. **Negative values** with leading dash: `-mt-4` becomes `-tw-mt-4`
6. **Typography plugin classes**: `prose` becomes `tw-prose`, `dark:prose-invert` becomes `dark:tw-prose-invert`
7. **The `container` class** — this is disabled in the Tailwind config (`corePlugins: { container: false }`), so `container` should NOT get a `tw-` prefix. Leave it as `container`.

## Compound Modifier Pattern

When multiple modifiers are stacked:
```
sm:hover:bg-blue-500       -> sm:hover:tw-bg-blue-500
supports-[backdrop-filter]:bg-background/60 -> supports-[backdrop-filter]:tw-bg-background/60
@min-[theme(--breakpoint-lg)]:w-1/3 -> @min-[theme(--breakpoint-lg)]:tw-w-1/3
```

The rule: everything before the last `:` is a modifier chain. The `tw-` goes on the utility itself (the part after the last `:`).

## What NOT to Prefix

- The literal string `container` (disabled in config)
- Class names from third-party libraries (e.g., recharts internal classes)
- Component prop values that aren't className (e.g., `variant="ghost"` is not a class)
- Arbitrary CSS properties in bracket notation that aren't utilities

## Files to Process

All `.jsx` files in:
- `app/javascript/seeds/blocks/` (all subdirectories)
- `app/javascript/seeds/examples/` (all subdirectories)

Do NOT modify `ide-*` or `main-menu` seeds — they already use the `tw-` prefix.

## Verification

After transformation:
- No bare Tailwind utility (like `flex`, `p-4`, `text-sm`, `bg-white`, etc.) should appear without the `tw-` prefix inside any className expression
- Responsive/state modifiers should remain in their natural position before `tw-`: `sm:tw-flex`, `hover:tw-bg-blue-500`
- The `container` class (if present) should remain unprefixed
