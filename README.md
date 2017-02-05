#### Startup command
```
sudo docker-compose up -d
```

#### More elaborate startup command
```
sudo docker-compose up -d --build --force-recreate && sudo docker-compose logs -f
```

#### Environment variables

- `CLEAN_FREQUENCY` - an integer and represents seconds so 60 = 1 minute, 3600 = 1 hour
- `CONTAINERS_T0_CLEAN` - the ***container_name*** of the containers to have their logs cleaned.
- `INCLUDE_SELF` - whether the current container (`log-cleaner` by default) should also have it's logs cleaned, defaults to `TRUE`
- `SELF_NAME` - name of the current container (defaults to `log_cleaner`)
