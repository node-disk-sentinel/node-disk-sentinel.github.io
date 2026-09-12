# node-disk-sentinel.github.io

Source repository for the static website hosted at [https://node-disk-sentinel.org/](https://node-disk-sentinel.org/).

## Local Development

You can build and test the site locally using `make`.

If `hugo` or `htmltest` are not installed on your host, the Makefile automatically downloads pinned binaries into `./bin/`.

```sh
# Build site and run htmltest link & syntax validation
make

# Serve locally with live-reload (http://localhost:1313)
make serve

# Build production bundle explicitly
make build

# Run htmltest link checker
make test

# Clean build artifacts
make clean
```

## Deployment

Pushes to the `main` branch trigger an automated build and deployment to GitHub Pages via GitHub Actions.
