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

#### Downloading OpenCSPM

Create a new local folder to hold all the required git repositories.  For example, `opencspm-demo`:

```console
$ mkdir opencspm-demo
$ cd opencspm-demo
```

In `opencspm-demo`, create a subdirectory explicitly named `opencspm-controls`:

```console
$ mkdir opencspm-controls
$ cd opencspm-controls
```

Inside the `opencspm-demo/opencspm-controls` directory, this is where the control pack repositories are to reside.  The community control pack is free and great for getting started:

```console
$ git clone https://github.com/OpenCSPM/opencspm-darkbit-community-controls.git
```

Now, go back up one level to the `opencspm-demo` directory.  This is where the `opencspm` repo should reside:

```console
$ cd ..
$ git clone https://github.com/OpenCSPM/opencspm.git
```

Verify that the directory structure is correct from inside the `opencspm-demo` directory:

```console
$ find . -type d -maxdepth 2 -name "*"
.
./opencspm-controls
./opencspm-controls/opencspm-darkbit-community-controls
./opencspm
./opencspm/collection
./opencspm/docker
./opencspm/load_dir
./opencspm/config
./opencspm/site
./opencspm/.git
./opencspm/assets
```

#### Running OpenCSPM Locally

Enter the `opencspm-demo/opencspm/docker` directory:

```console
$ cd opencspm/docker
```

Run `docker-compose up`:

```console
$ docker-compose up
```

The initial run will take 1-2 minutes.

```console
Creating network "opencspm_default" with the default driver
Creating volume "opencspm_core" with default driver
Creating volume "opencspm_postgres" with default driver
Creating volume "opencspm_redis" with default driver
Creating opencspm_db_1    ... done
Creating opencspm_redis_1 ... done
Creating opencspm_core_1  ... done
Creating opencspm_worker_1 ... done
Attaching to opencspm_redis_1, opencspm_db_1, opencspm_core_1, opencspm_worker_1

...snip...

worker_1  | Cleaning up stale resources and relationships
worker_1  | ..
worker_1  | I, [2020-11-10T16:32:35.478054 #1]  INFO -- : [ActiveJob] [RunnerJob] [27cb2777-0db3-4110-b06f-1f92beb01d28] f0404c7a-14fe-531c-b975-9b605e1f00d6 Loader job finished
worker_1  | I, [2020-11-10T16:32:35.486103 #1]  INFO -- : [ActiveJob] [RunnerJob] [27cb2777-0db3-4110-b06f-1f92beb01d28] f0404c7a-14fe-531c-b975-9b605e1f00d6 Analysis job started
worker_1  | I, [2020-11-10T16:32:36.050652 #1]  INFO -- : [ActiveJob] [RunnerJob] [27cb2777-0db3-4110-b06f-1f92beb01d28] f0404c7a-14fe-531c-b975-9b605e1f00d6 Analysis job finished
worker_1  | I, [2020-11-10T16:32:37.905127 #1]  INFO -- : [ActiveJob] [RunnerJob] [27cb2777-0db3-4110-b06f-1f92beb01d28] f0404c7a-14fe-531c-b975-9b605e1f00d6 Runner job finished
worker_1  | I, [2020-11-10T16:32:37.906126 #1]  INFO -- : [ActiveJob] [RunnerJob] [27cb2777-0db3-4110-b06f-1f92beb01d28] Performed RunnerJob (Job ID: 27cb2777-0db3-4110-b06f-1f92beb01d28) from Sidekiq(default) in 3064.65ms
worker_1  | 2020-11-10T16:32:37.908Z pid=1 tid=gscybnebh class=RunnerJob jid=618dd8bd0a171e5bf53c13ad elapsed=3.07 INFO: done
```

When you see the `RunnerJob` completed, the controls and sample data has been loaded, and the first analysis run over the loaded data has completed.  The Web UI should now be available.

#### Accessing OpenCSPM

* Web UI: [http://localhost:5000](http://localhost:5000)

#### Collecting Live Data

Refer to [data collection](data_collection.md) for obtaining data from your own environment.

#### Shut Down

To stop the containers, hit `Ctrl-c`.  If you ran `docker-compose up -d` to daemonize the containers in the background, run `docker-compose down` from inside the `opencspm-demo/opencspm/docker` directory.  This will stop the containers but leave the volumes intact so that a `docker-compose up` performed later picks up where you left off.

To stop the containers and remove the volumes so that a `docker-compose up` performed later starts from a clean slate:

```console
$ docker-compose down --remove
$ docker volume prune
```

### Dedicated Mode

Refer to [https://github.com/OpenCSPM/opencspm-terraform-gcp](https://github.com/OpenCSPM/opencspm-terraform-gcp) for instructions and a [Terraform](https://terraform.io) module to deploy an OpenCSPM instance inside your GCP organization. AWS based deployments are planned for the future.

## Development

Refer to the [development guide](development.md) for more information about accessing the internals and developing custom control packs.
