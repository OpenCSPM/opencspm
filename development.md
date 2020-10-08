TODO: enable `rails` without `bundle exec`

create RVM gemset (option to enable IDE integration with Solargraph and Rubocop)
- rvm use 2.6.6@opencspm --create --ruby-version
- gem install bundler:2.0.2
- bundle
- code . (e.g. to start VS Code with access to local gemset)

bring up full environment
- docker-compose up

development setup
- cd docker
- docker-compose build

bash shell
- docker-compose exec shell bash

rails console
- docker-compose exec core bundle exec rails c

sidekiq web ui
- http://localhost:5000/sidekiq

redis insight web ui
- http://localhost:8001

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
