# Guide 04: Remove "use client" Directives

## Problem

~121 seed files start with `"use client";` or `"use client"`. This is a Next.js App Router directive that tells the framework to render the component on the client side. It has no meaning in the Jigsaw runtime and is noise.

## The Fix

Remove the `"use client"` line entirely.

## Rules

1. Remove any line that is exactly `"use client";` or `"use client"` (with or without semicolon)
2. It's always at the very top of the file (line 1 or after an empty line)
3. Do not remove it if it appears inside a string or comment (extremely unlikely)
4. Remove any blank line left behind after removal (keep the file tidy — first non-blank line should be an import statement or code)

## Example

### Before:
```jsx
"use client";

import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"

export default function MyComponent() {
  ...
}
```

### After:
```jsx
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"

export default function MyComponent() {
  ...
}
```

## Files to Process

All `.jsx` files in:
- `app/javascript/seeds/blocks/` (all subdirectories)
- `app/javascript/seeds/examples/` (all subdirectories)

Only process files that contain the `"use client"` directive.

## Verification

After transformation:
- No file should have `"use client"` as a standalone line
- The first meaningful line should be an import statement or code
