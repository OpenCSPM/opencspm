# opencspm
Open Cloud Security Posture Management Engine

./docker - docker compose and docker files for Rails backend/core, sidekiq, redis/redisgraph, postgresql
./terraform - tf modules to build collector, GCS bucket, and service accounts

initial setup
- cd docker
- docker-compose build
- docker-compose run core bundle install
- docker-compose run core bundle exec rails db:setup

