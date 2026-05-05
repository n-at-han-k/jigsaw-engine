# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

```bash
# Start dev server (starts docker compose + Falcon on localhost:3000)
bin/dev

# Database
bin/rails db:create db:migrate

# Run all engine tests (from engines/jigsaw-engine/)
cd engines/jigsaw-engine
RAILS_ENV=test bin/rails db:create db:migrate   # first time only
RAILS_ENV=test bin/rails test

# Rails console
bin/rails console

# Docker services (PostgreSQL on 5432)
docker compose up -d
```

## Architecture

- **Host app** at project root — Rails 8.1.3, PostgreSQL, Falcon web server, Propshaft asset pipeline, Hotwire (Turbo + Stimulus), importmap-rails
- **Engine** at `engines/jigsaw-engine/` — isolated namespace `Jigsaw`, contains all models, controllers, views, and routes

## Key Gems

- `rails-active-ui` — Fomantic-UI component system. Views use `.html.ruby` files (not ERB). Components are PascalCase method calls (`Header()`, `Table()`, `Button()`, etc.).

## Views (rails-active-ui)

- Views use `.html.ruby` extension, not `.erb`
- Components: `Table()`, `Menu()`, `MenuItem()`, `Header()`, `Button()`, `ButtonTo()`, `Form()`, `Message()`, `LinkTo()`, `BackButton()`, `TurboFrame()`, `Modal()`, etc.
- `ButtonTo` takes keyword args only: `ButtonTo(url:, method:, color:, confirm:) { text "label" }`
- Forms open in modals via `TurboFrame(id: "modal")` + `Modal(turbo: true, blurring: true)` in layout
- Layout at `engines/jigsaw-engine/app/views/layouts/jigsaw/application.html.ruby`
- Fomantic-UI CSS loaded via `StylesheetLink("stylesheets.css")`
- jQuery + Fomantic JS loaded via `fui_javascript_tags` helper
- Stimulus controllers registered via `registerFuiControllers(application)` in `app/javascript/controllers/index.js`

## Engine Setup Notes

The engine (`lib/jigsaw/engine.rb`) has an asset initializer that adds rails-active-ui's `app/assets` to Propshaft paths (the gem's own engine doesn't register this path).

## Routes

Engine mounted at `/jigsaw`.

## Docker Services

`docker-compose.yml` provides:
- `db` — PostgreSQL 16 on port 5432 (development)
- `db_test` — PostgreSQL 16 on port 6432 (test, tmpfs-backed)
