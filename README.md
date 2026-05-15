# jigsaw-engine

## Setup

This repo contains the `jigsaw_engine` gem located in `./engines/jigsaw-engine`.
The root directory of this project is itself a **complete working example** of `jigsaw_engine` that can be run locally or deployed.

### Engine only

```
bundle add jigsaw_engine
bin/rails jigsaw_engine:install:migrations
bin/rails db:migrate
```

### Standalone app

```
git clone https://github.com/general-intelligence-systems/jigsaw-engine
cd jigsaw-engine
bin/setup
```

## Rake Tasks

### Install seed templates

Copies the engine's JavaScript seed files (slot template configs, data, and render sources) into `app/javascript/seeds/`. Existing files are skipped.

```bash
bin/rails jigsaw:install:seeds
```

### Install shadcn/ui components

Downloads shadcn/ui components, compiles TSX to ESM JavaScript, and installs them into the engine at `app/javascript/jigsaw/components/ui/` with importmap pins auto-added.

```bash
bin/rails jigsaw:shadcn:install[button,dropdown-menu,sheet]
```

After installation, replace Tailwind classes with Fomantic-UI classes and add any missing Radix importmap pins to `config/importmap.rb`.

## Testing

Docker Compose provides a PostgreSQL test database (port 6432).

```bash
# Start docker services (if not already running)
docker compose up -d

# Run engine tests from within the engine directory
cd engines/jigsaw-engine
RAILS_ENV=test bin/rails db:create db:migrate   # first time only
RAILS_ENV=test bin/rails test
```
