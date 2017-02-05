## log-cleaner

### Features

  - A standalone docker container.
  - Designed to clear the log files for a docker container at specified intervals.
  - Can be used for clearing logs in multiple containers.

### Startup commands
```
sudo docker-compose up -d
```

force recreate and show logs
```
sudo docker-compose up -d --build --force-recreate && sudo docker-compose logs -f
```

### Environment variables

- `CLEAN_FREQUENCY` - an integer and represents seconds so 60 = 1 minute, 3600 = 1 hour
- `CONTAINERS_T0_CLEAN` - the ***container_name*** of the containers to have their logs cleaned.
- `INCLUDE_SELF` - whether the current container (`log-cleaner` by default) should also have it's logs cleaned, defaults to `TRUE`
- `SELF_NAME` - name of the current container (defaults to `log_cleaner`)


***Some examples:***

The following `docker-compose.yml` example will clear the logs of containers with names `mongo nginx`
every 3600 seconds (hourly)
```
  environment:
    - CLEAN_FREQUENCY=3600
    - CONTAINERS_T0_CLEAN=mongo nginx
    - INCLUDE_SELF=FALSE
```


The following `docker-compose.yml` example will clear the logs of containers with names `mongo nginx log-cleaner`
every 3600 seconds (hourly)
```
  environment:
    - CLEAN_FREQUENCY=3600
    - CONTAINERS_T0_CLEAN=mongo nginx
    - INCLUDE_SELF=TRUE
```


The following `docker-compose.yml` example will clear the logs of containers with names `mongo nginx my-logger-cleaner`
every 3600 seconds (hourly)
```
version: '2'

services:

  log-cleaner:
    image: log-cleaner:latest
    build:
      context: .
      dockerfile: Dockerfile
    container_name: my-logger-cleaner
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /var/lib/docker/containers/:/var/lib/docker/containers/
    environment:
    - CLEAN_FREQUENCY=3600
    - CONTAINERS_T0_CLEAN=mongo nginx
    - INCLUDE_SELF=TRUE
    - SELF_NAME=my-logger-cleaner
```


### Notes

  - This project is not designed as a replacement for the [docker-compose logging directives](https://docs.docker.com/compose/compose-file/#/logging)
  but rather as an adjunct to the logging directive.
  - If this feature is implemented in `docker` then this project will become defunct and hopefully this will be the case. There
  was an [issue about this](https://github.com/docker/compose/issues/1083) in `docker/compose` in github.

### Licence
[MIT Licence](./LICENCE.md)