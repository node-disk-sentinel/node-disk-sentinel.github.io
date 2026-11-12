# node-disk-sentinel.github.io

Source repository for the static website hosted at [https://node-disk-sentinel.org/](https://node-disk-sentinel.org/).

## Local Development

You can build and test the site locally using `make`.

Docker (or Podman) is the only requirement: Hugo and htmltest run in pinned container images, so nothing has to be installed. `HUGO_VERSION`, `HTMLTEST_VER` and `PORT` can be overridden, `DOCKER=podman` switches the container engine, and `HUGO=hugo` / `HTMLTEST=htmltest` use local binaries instead.

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
