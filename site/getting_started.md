# Getting Started

## How is OpenCSPM deployed?

There are two primary methods of deployment:

1. Local-mode: Running the platform on a local system with [docker](https://docker.com) and [docker-compose](https://docker/com/compose) to support temporary testing, one-off assessments, and custom policy check development.
2. Dedicated-mode: Running the platform inside the cloud account using dedicated resources managed by infrastructure-as-code ([terraform](https://terraform.io)).

### Local Mode

#### Requirements
1. git
2. bash
3. Docker
4. Docker-Compose 3.x
5. 2CPU Cores, 4GB of RAM

#### Running OpenCSPM Locally

Run `docker-compose up` from within the `docker` directory. The initial run will take several minutes - at roughly 1 minute to build the Docker image, roughly 2 more minutes to install all Ruby gems (`core` container) and JavaScript packages (`ui` container).

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

#### Accessing OpenCSPM

All users:

* Web UI: http://localhost:8000

Development and Custom Check Development:

* Rails API: http://localhost:5000
* Sidekiq console: http://localhost:5000/sidekiq
* Redis Insight UI: http://localhost:8001

#### Clean up

To stop the containers but leave the volumes intact so that a `docker-compose up` performed later picks up where you left off:

```console
$ docker-compose down
```
To stop the containers and remove the volumes so that a `docker-compose up` performed later starts from a clean slate:

```console
$ docker-compose down --remove
$ docker volume prune
```

### Dedicated Mode

Refer to the `/terraform` directory for instructions on deploying OpenCSPM in your environment.