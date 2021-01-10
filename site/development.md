# Development Guide

## Docker Components

![Docker Dashboard](/site/img/docker-dashboard.png)


## Development Environment Setup

### IDE integration (optional)

Create an RVM gemset so IDEs (like VS Code) will be able to use Ruby integration with Solargraph and Rubocop for formatting and linting.

```console
$ cd docker
```

```console
~/docker $ rvm use 2.6.6@opencspm --create --ruby-version
```

```console
~/docker $ gem install bundler:2.0.2
```

```console
~/docker $ bundle
```

Launch IDE from within `docker` directory:

```console
~/docker $ code .
```

### Launch Full Environment

To just run the full environment locally, run `docker-compose -f docker-compose-development.yml up` from within the `docker` directory. The initial run will take several minutes - at roughly 1 minute to build the Docker image, roughly 2 more minutes to install all Ruby gems (`core` container) and JavaScript packages (`ui` container).
 

Most of the console output won't be visible while the initial build is happening, though you can view status in the Docker Desktop dashboard or with `docker-compose logs`. 

```console
$ cd docker
$ docker-compose -f docker-compose-development.yml up
Creating network "opencspm_default" with the default driver
Creating volume "opencspm_gems" with default driver
Creating volume "opencspm_postgres" with default driver
Creating volume "opencspm_redis" with default driver
Creating volume "opencspm_bundle" with default driver
Creating volume "opencspm_node_modules" with default driver
Creating volume "opencspm_rails_cache" with default driver
Creating opencspm_db_1       ... done
Creating opencspm_redis_1 ... done
Creating opencspm_redis_ui_1 ... done
Creating opencspm_shell_1    ... done
Creating opencspm_core_1     ... done
Creating opencspm_ui_1       ... done
Creating opencspm_worker_1   ... done
Attaching to opencspm_redis_1, opencspm_db_1, opencspm_redis_ui_1, opencspm_core_1, opencspm_shell_1, opencspm_ui_1, opencspm_worker_1
```

The `worker` container depends on the `core` container being fully built and running, so it will always complete last. When `sidekiq` log messages appear, all containers should be up and running.

```console
worker_1    | 2020-10-08T19:10:01.283Z pid=1 tid=gnzrya5pl INFO: Booted Rails 6.0.3.4 application in development environment
worker_1    | 2020-10-08T19:10:01.284Z pid=1 tid=gnzrya5pl INFO: Running in ruby 2.6.6p146 (2020-03-31 revision 67876) [x86_64-linux]
worker_1    | 2020-10-08T19:10:01.284Z pid=1 tid=gnzrya5pl INFO: See LICENSE and the LGPL-3.0 for licensing details.
worker_1    | 2020-10-08T19:10:01.284Z pid=1 tid=gnzrya5pl INFO: Upgrade to Sidekiq Pro for more features and support: https://sidekiq.org
worker_1    | 2020-10-08T19:10:01.284Z pid=1 tid=gnzrya5pl INFO: Starting processing, hit Ctrl-C to stop
```
As such if there are errors in the `worker` container such as:
```
worker_1    | bundler: command not found: sidekiq
worker_1    | Install missing gem executables with `bundle install`
opencspm_worker_1 exited with code 127
```
Just wait for the `core` container to finish initializing.

### Application URLs & Endpoints

* Web UI: http://localhost:8000
* Rails API: http://localhost:5000
* Sidekiq console: http://localhost:5000/sidekiq
* Redis Insight UI: http://localhost:8001

### Development Environment Details

To re-deploy and re-build the Docker images 
```console
$ cd docker
$ docker-compose -f docker-compose-development.yml up --build
```

To build or re-build the Docker image, use `docker-compose build`.

```console
$ cd docker
$ docker-compose build
```

A local console/shell is available on the `shell` container. To drop into the shell, use `docker-compose exec`. For example, to run a Rails console in this container:

```console
$ docker-compose exec shell bash
app@shell:~$ bundle exec rails c
Running via Spring preloader in process 24
Loading development environment (Rails 6.0.3.4)
irb(main):001:0> 
```

It is also possible to run a Rails console directly from `docker-compose exec`, for example:

```console
$ docker-compose exec shell bundle exec rails c
Running via Spring preloader in process 43
Loading development environment (Rails 6.0.3.4)
irb(main):001:0> 
```

### Restarting Containers

Frontend UI (HTML/JavaScript) and Rails changes are reflected in their respective containers in real-time. However, certain changes will require a container restart. For example:

```console
$ docker-compose restart core
```

### Running Rails Rspec Tests

Run tests in a dedicated container (with the correct environment set) and remove it afterwards:

```console
$ docker-compose run core bundle exec rspec -e RAILS_ENV=test
```

### Clean up

To stop the containers but leave the volumes intact:

```console
$ docker-compose down
```

To stop the contianers and remove the volumes:

```console
$ docker-compose down --remove
$ docker volume prune
```

To re-run a clean "initial" setup, remove the `.init` artifacts after deleting volumes, then re-run `docker-compose up`:

```console
$ rm .init ui/.init
$ docker-compose up
```

## Custom Control Pack Development

OpenCSPM supports the addition and modification of the control metadata and control check logic.  Groups of related controls are distributed as git repositories, and they are expected to be kept as subdirectories of the `opencspm-controls` directory.  For example:

```console
|- opencspm-controls
|  |- opencspm-darkbit-community-controls
|  |- your-custom-control-repo-here
|  '- another-custom-control-repo-here
'- opencspm
```

### Control Pack Required Files

* `config.yaml` - holds the index and metadata for the controls
* `controls_spec.rb` - contains the custom control check logic in [RSpec3](https://rspec.info/) format

### Creating a Custom Control Pack

The recommended way to begin writing custom controls is to modify an existing control pack.  Consider forking [https://github.com/OpenCSPM/opencspm-darkbit-community-controls](https://github.com/OpenCSPM/opencspm-darkbit-community-controls) and modifying the `config.yaml` and `controls_spec.rb` as needed.

Notes:

* In `config.yaml`, the `id:` and `controls > id:` fields must be globally unique across all control packs.  The convention is for the top level `id:` to be the [Kebab case](https://en.wikipedia.org/wiki/Letter_case#Special_case_styles) format of the repository name, and the control IDs to be `<orgname>-<groupingname>-<numberidentifier>`.  e.g. `darkbit-aws-42`.
* Tags have two levels.  The top level is meant for a higher order grouping like a compliance framework, and the nested level is meant for listing out all the applicable tags.  Tags are arbitrary strings, but the convention is to list multiple tags that represent the various levels of a compliance requirement.  For example, the top level tag `nist-csf` is meant to indicate that this control has one or more associations with the NIST Cybersecurity Framework.  As subtags, `nist-csf-pr`, `nist-csf-pr.ac` and `nist-csf.pr.ac-1` indicate that this control is in the `Protect` Function, the `Identity Management and Access Control` Category of the `Protect` Function, and that it maps to the specific ID `1` in that Category.  This allows for tag-based grouping in the UI at any level of depth and specificity.
* Currently, the responsibility is on the user for ensuring the contents of the control pack repos stay in sync with the upstream git repo where they are hosted.

### Querying the Redisgraph Database

* Launch the `docker-compose-development.yaml` to also run the [RedisInsight](https://redislabs.com/redis-enterprise/redis-insight/) container from [RedisLabs](https://redislabs.com).
* Visit [http://localhost:8001](http://localhost:8001)
* Accept the EULA if needed
* Click on Redisgraph on the left, and add a new database.  Supply `redis`, `redis`, and `6379` for the name, hostname, and port, respectively.
* Once inside and your data (or the sample data) has been loaded, you can run [Cypher](https://www.opencypher.org/) queries against the `opencspm` "database".
