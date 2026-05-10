# SDLC notes

When doing local development, run the db through docker and the application on the host:
```sh
mise -E dev x -- docker compose up -d
mise -E dev x -- iex -S mix phx.server
```

To run a containerized version of the application locally, simulating a prod environment, with local environment variables:
```sh
mise -E dev x -- docker compose -f compose-production.yaml up -d

# Running in this manner may encounter caching issues
# Set the --build flag to explicitly rebuild the application
```

When deploying to production, use the `-production` compose file and plant sensitive environment variables. Refer to `mise.dev.toml` for a list of variables to set.