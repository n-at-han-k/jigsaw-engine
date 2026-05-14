# Guide 03: Replace Next.js Imports (next/image, next/link)

## Problem

~95 seed files import from `next/image` and/or `next/link`. These are Next.js framework modules that don't exist in the Jigsaw runtime. They will cause import resolution failures.

## The Correct Approach

Replace Next.js components with standard HTML elements.

## Replacing `next/link`

### Before:
```jsx
import Link from "next/link"

<Link href="/about">About Us</Link>
<Link href="#" className="text-blue-500">Click here</Link>
```

### After:
```jsx
// Remove the import entirely

<a href="/about">About Us</a>
<a href="#" className="text-blue-500">Click here</a>
```

### Rules:
1. Remove `import Link from "next/link"` entirely
2. Replace all `<Link href="...">` with `<a href="...">`
3. Replace all `</Link>` with `</a>`
4. Keep all other props (className, onClick, etc.) — they work on `<a>` too
5. If Link is used with `asChild` on a Button (shadcn pattern), just use the Button directly:
   ```jsx
   // Before:
   <Button asChild><Link href="#">Get started</Link></Button>
   // After:
   <a href="#"><Button>Get started</Button></a>
   ```

## Replacing `next/image`

### Before:
```jsx
import Image from "next/image"

<Image src="/photo.jpg" alt="Photo" width={800} height={600} />
<Image src="/bg.jpg" fill className="object-cover" alt="Background" />
<Image src="https://example.com/pic.jpg" alt="" width={100} height={100} unoptimized />
```

### After:
```jsx
// Remove the import entirely

<img src="/photo.jpg" alt="Photo" width={800} height={600} />
<img src="/bg.jpg" className="tw-object-cover tw-absolute tw-inset-0 tw-w-full tw-h-full" alt="Background" />
<img src="https://example.com/pic.jpg" alt="" width={100} height={100} />
```

### Rules:
1. Remove `import Image from "next/image"` entirely
2. Replace `<Image` with `<img`
3. Handle the `fill` prop: Next.js `fill` makes the image absolutely positioned to fill its container. Replace with appropriate CSS classes:
   ```jsx
   // Before:
   <Image src="..." fill className="object-cover" alt="..." />
   // After:
   <img src="..." className="tw-absolute tw-inset-0 tw-w-full tw-h-full tw-object-cover" alt="..." />
   ```
   Note: the parent container should have `tw-relative` (it usually already does).
4. Remove Next.js-specific props that have no HTML equivalent:
   - `fill` — handled above with CSS
   - `unoptimized` — remove entirely
   - `blurDataURL` — remove entirely
   - `placeholder` — remove entirely (Next.js image placeholder, not the HTML attribute)
   - `priority` — remove entirely
   - `quality` — remove entirely
   - `loader` — remove entirely
5. Keep standard HTML img attributes: `src`, `alt`, `width`, `height`, `className`, `style`

## Edge Case: Image inside a Link

```jsx
// Before:
<Link href="/product/1">
  <Image src="/product.jpg" alt="Product" width={300} height={200} />
</Link>

// After:
<a href="/product/1">
  <img src="/product.jpg" alt="Product" width={300} height={200} />
</a>
```

## Files to Process

All `.jsx` files in:
- `app/javascript/seeds/blocks/` (all subdirectories)
- `app/javascript/seeds/examples/` (all subdirectories)

Only process files that actually contain `import ... from "next/image"` or `import ... from "next/link"`.

## Verification

After transformation:
- No line should contain `from "next/image"` or `from "next/link"`
- No `<Image` or `<Link` components from Next.js should remain
- All images should use `<img` with standard HTML attributes
- All links should use `<a` with `href`
