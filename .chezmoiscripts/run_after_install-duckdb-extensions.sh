#!/bin/sh
# Install the DuckDB extensions `view` needs to read xlsx and SQLite files, which
# it never downloads itself. Runs on every apply because extensions belong to
# one DuckDB version; installing a present extension needs no network.
# Does nothing without duckdb. A failed install warns and lets apply continue.

set -eu

command -v duckdb > /dev/null 2>&1 || exit 0

duckdb -no-init -c 'INSTALL excel; INSTALL sqlite;' \
  || echo "Warning: DuckDB extensions not installed; view cannot read xlsx or SQLite files" >&2
