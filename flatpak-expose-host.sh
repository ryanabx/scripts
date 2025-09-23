#!/bin/sh

flatpak run --filesystem=host --env=PATH=/app/bin:/usr/bin:/run/host/bin --env=LD_LIBRARY_PATH=/app/lib:/run/host/lib "$@"