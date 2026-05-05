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
