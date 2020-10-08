

### Development Environment Setup

#### IDE integration (optional)

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



#### Launch Full Environment

To just run the full environment locally, run `docker-compose up` from within the `docker` directory. The initial run will take several minutes - at roughly 1 minute to build the Docker image, roughly 2 more minutes to install all Ruby gems (`core` container) and JavaScript packages (`ui` container).

Most of the console output won't be visible while the initial build is happening, though you can view status in the Docker Desktop dashboard or with `docker-compose logs`. 

```console
$ cd docker
$ docker-compose up
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



#### Application URLs & Endpoints

Web UI: http://localhost:8000

Rails API: http://localhost:5000

Sidekiq console: http://localhost:5000/sidekiq

Redis Insight UI: http://localhost:8001



### Development Environment Details

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

#### Restarting Containers

Frontend UI (HTML/JavaScript) and Rails changes are reflected in their respective containers in real-time. However, certain changes will require a container restart. For example:

```console
$ docker-compose restart core
```



#### Running Rails Rspec Tests

Run tests in a dedicated container (with the correct environment set) and remove it afterwards:

```console
$ docker-compose run core bundle exec rspec -e RAILS_ENV=test
```

#### Clean up

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

