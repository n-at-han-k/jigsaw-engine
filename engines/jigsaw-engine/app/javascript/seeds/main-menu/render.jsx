import * as React from "react"
import { createRoot } from "react-dom/client"
import { Menu, X } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Sheet, SheetContent, SheetTitle, SheetTrigger } from "@/components/ui/sheet"
import { cn } from "@/lib/utils"

function NavLink({ href, children, className }) {
  return (
    <a
      href={href}
      className={cn(
        "tw-text-sm tw-font-medium tw-text-muted-foreground tw-transition-colors hover:tw-text-foreground",
        className
      )}
    >
      {children}
    </a>
  )
}

function MobileNav({ links, brand }) {
  const [open, setOpen] = React.useState(false)
  return (
    <Sheet open={open} onOpenChange={setOpen}>
      <SheetTrigger asChild>
        <Button variant="ghost" size="icon" className="lg:tw-hidden">
          <Menu className="tw-size-5" />
        </Button>
      </SheetTrigger>
      <SheetContent side="left">
        <SheetTitle className="tw-sr-only">Navigation Menu</SheetTitle>
        <nav className="tw-flex tw-flex-col tw-gap-4 tw-pt-4">
          <span className="tw-text-lg tw-font-bold">{brand}</span>
          {links.map((link) => (
            <a
              key={link.href}
              href={link.href}
              className="tw-text-sm tw-font-medium tw-text-muted-foreground hover:tw-text-foreground"
              onClick={() => setOpen(false)}
            >
              {link.label}
            </a>
          ))}
        </nav>
      </SheetContent>
    </Sheet>
  )
}

export default function(data) {
  const root = createRoot(this.element)
  root.render(
    <header className="tw-sticky tw-top-0 tw-z-50 tw-w-full tw-border-b tw-bg-background/95 tw-backdrop-blur supports-[backdrop-filter]:tw-bg-background/60">
      <div className="tw-container tw-flex tw-h-14 tw-items-center tw-px-4 md:tw-px-6">
        <MobileNav links={data.links} brand={data.brand} />
        <a href="/" className="tw-mr-6 tw-flex tw-items-center tw-space-x-2 tw-font-bold">
          {data.brand}
        </a>
        <nav className="tw-hidden lg:tw-flex tw-items-center tw-gap-6">
          {data.links.map((link) => (
            <NavLink key={link.href} href={link.href}>
              {link.label}
            </NavLink>
          ))}
        </nav>
      </div>
    </header>
  )
}
