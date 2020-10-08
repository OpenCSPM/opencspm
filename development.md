TODO: enable `rails` without `bundle exec`

initial development setup
- cd docker
- docker-compose build

core/api setup
- docker-compose run core bundle install
- docker-compose run core bundle exec rails db:setup

web ui setup
- docker-compose run ui yarn

finish setup (clean up orphaned containers used during setup)
- docker-compose down --remove-orphans

bring up full environment
- docker-compose up

rails console
- docker-compose core bundle exec rails c

restart a container
- docker-compose restart core
- docker-compose restart ui
- docker-compose restart jobs

run tests
- docker-compose run core rspec -e RAILS_ENV=test

cleanup

remove docker volumes
- docker-compose down --remove
- docker volume prune
