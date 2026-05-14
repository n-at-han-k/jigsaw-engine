# Guide 07: Add Missing Third-Party Package Import Map Pins

## Problem

~60+ seed files import from NPM packages that are not pinned in the import map. These imports will fail to resolve at runtime.

## Where to Add Pins

`engines/jigsaw-engine/config/importmap.rb`

## The Correct Pattern

Use esm.sh CDN with `external=react,react-dom,react%2Fjsx-runtime` to prevent duplicate React instances:

```ruby
pin "recharts", to: "https://esm.sh/recharts@2?bundle&external=react,react-dom,react%2Fjsx-runtime"
```

## Packages Needed

### High Priority (many seeds depend on these)

| Package | Import Used | Seeds | Pin |
|---------|-------------|-------|-----|
| recharts | `import { Bar, BarChart, XAxis, ... } from "recharts"` | ~34 | `pin "recharts", to: "https://esm.sh/recharts@2?bundle&external=react,react-dom,react%2Fjsx-runtime"` |
| react-hook-form | `import { useForm } from "react-hook-form"` | ~14 | `pin "react-hook-form", to: "https://esm.sh/react-hook-form@7?bundle&external=react,react-dom,react%2Fjsx-runtime"` |
| zod | `import { z } from "zod"` | ~14 | `pin "zod", to: "https://esm.sh/zod@3?bundle"` |
| @hookform/resolvers/zod | `import { zodResolver } from "@hookform/resolvers/zod"` | ~14 | `pin "@hookform/resolvers/zod", to: "https://esm.sh/@hookform/resolvers@3/zod?bundle&external=react-hook-form,zod"` |
| motion/react | `import { motion, AnimatePresence } from "motion/react"` | ~10 | `pin "motion/react", to: "https://esm.sh/motion@12/react?bundle&external=react,react-dom,react%2Fjsx-runtime"` |

### Medium Priority

| Package | Import Used | Seeds | Pin |
|---------|-------------|-------|-----|
| date-fns | `import { format, ... } from "date-fns"` | ~3 | `pin "date-fns", to: "https://esm.sh/date-fns@4?bundle"` |
| embla-carousel-autoplay | `import Autoplay from "embla-carousel-autoplay"` | ~2 | `pin "embla-carousel-autoplay", to: "https://esm.sh/embla-carousel-autoplay@8?bundle"` |
| react-day-picker | `import { DayPicker } from "react-day-picker"` | ~2 | `pin "react-day-picker", to: "https://esm.sh/react-day-picker@9?bundle&external=react,react-dom,react%2Fjsx-runtime"` |
| zustand | `import { create } from "zustand"` | ~2 | `pin "zustand", to: "https://esm.sh/zustand@5?bundle&external=react,react-dom,react%2Fjsx-runtime"` |

### Low Priority (1 seed each)

| Package | Pin |
|---------|-----|
| input-otp | `pin "input-otp", to: "https://esm.sh/input-otp@1?bundle&external=react,react-dom,react%2Fjsx-runtime"` |
| use-mask-input | `pin "use-mask-input", to: "https://esm.sh/use-mask-input@3?bundle&external=react,react-dom,react%2Fjsx-runtime"` |
| react-use-measure | `pin "react-use-measure", to: "https://esm.sh/react-use-measure@2?bundle&external=react,react-dom,react%2Fjsx-runtime"` |

## esm.sh Query Parameters

- `?bundle` — bundles all internal dependencies so the import is a single HTTP request
- `&external=react,react-dom,react%2Fjsx-runtime` — tells esm.sh to NOT bundle these packages (they're already available from our existing pins). `%2F` is URL-encoded `/`
- `@2` or `@7` etc — version constraints (major version)
- `/zod` or `/react` — subpath within the package

## How to Determine the Right Version

Check what version the seeds expect by looking at their API usage. Generally use the latest major version:
- recharts v2
- react-hook-form v7
- zod v3
- framer-motion/motion v12
- date-fns v4

## Subpath Imports

Some packages are imported via subpaths:

```ruby
# Package: @hookform/resolvers, subpath: /zod
pin "@hookform/resolvers/zod", to: "https://esm.sh/@hookform/resolvers@3/zod?bundle&external=react-hook-form,zod"

# Package: motion, subpath: /react
pin "motion/react", to: "https://esm.sh/motion@12/react?bundle&external=react,react-dom,react%2Fjsx-runtime"
```

## Verification

For each pin added:
1. The import specifier in the pin matches exactly what the seeds use in their import statements
2. Loading the URL in a browser returns valid JavaScript (test by visiting the esm.sh URL)
3. The `external` params include all packages already pinned (especially react, react-dom, react/jsx-runtime)
4. Seeds that use the package can load without console errors

## Finding Which Seeds Use What

```bash
# Find all unique non-local imports across all seeds
grep -rhE "^import .* from ['\"]" engines/jigsaw-engine/app/javascript/seeds/blocks/ | \
  grep -v "@/components" | grep -v "react" | grep -v "lucide" | grep -v "next/" | \
  sed 's/.*from ["\x27]//; s/["\x27].*//' | sort -u
```

This gives you the complete list of external package imports that need pins.
