---
name: mail-cli-usage
description: >
  How to build and run the mail CLI tool during development. Use this skill when:
  (1) you need to build the CLI,
  (2) you need to run a CLI command (auth, accounts, emails, sync, threads),
  (3) you need to test CLI changes,
  (4) someone asks how to run or invoke the mail CLI.
license: MIT
compatibility: Rust 1.70+, Cargo
metadata:
  author: internal
  version: "1.0.0"
allowed-tools: Bash(cargo:*) Read Glob Grep
---

# Running the Mail CLI

The CLI workspace lives at `services/cli/` relative to the repo root. There is no top-level `Cargo.toml`, so you must either `cd` into the directory or use `--manifest-path`.

## Building

```bash
# From anywhere in the repo
cargo build --manifest-path services/cli/Cargo.toml

# Or from inside the workspace
cd services/cli && cargo build
```

## Binary Targets

| Binary | Crate | Description |
|--------|-------|-------------|
| `mail-cli` | `cli/` | CLI-only binary |
| `mail-app` | `app/` | Combined CLI + TUI binary |

## Running Commands

Always pass `--manifest-path` when not inside `services/cli/`:

```bash
cargo run --manifest-path services/cli/Cargo.toml --bin mail-cli -- <args>
```

Or from within `services/cli/`:

```bash
cargo run --bin mail-cli -- <args>
```

## Global Flags

These flags go **before** the subcommand:

| Flag | Env Var | Description |
|------|---------|-------------|
| `--server <url>` | `MAIL_SERVER` | gRPC backend address |
| `--format <table\|json>` | — | Output format (default: table) |
| `--auth-backend <auto\|keyring\|file>` | `MAIL_AUTH_BACKEND` | Token storage backend |
| `-v, --verbose` | — | Enable debug logging |

## Subcommands

### Auth
```bash
cargo run --bin mail-cli -- auth login      # OAuth device flow login
cargo run --bin mail-cli -- auth status     # Show auth state + backend
cargo run --bin mail-cli -- auth logout     # Clear stored tokens
```

### Accounts
```bash
cargo run --bin mail-cli -- accounts list
cargo run --bin mail-cli -- accounts get --provider <google|outlook>
cargo run --bin mail-cli -- accounts delete --provider <google|outlook>
```

### Emails
```bash
cargo run --bin mail-cli -- emails folders --provider <p> --email <e>
cargo run --bin mail-cli -- emails list --provider <p> --email <e> --folder INBOX
cargo run --bin mail-cli -- emails read --provider <p> --email <e> --folder INBOX --uid <n>
cargo run --bin mail-cli -- emails body --provider <p> --email <e> --folder INBOX --uid <n>
```

### Sync
```bash
cargo run --bin mail-cli -- sync status --account-id <id>
cargo run --bin mail-cli -- sync trigger --account-id <id>
cargo run --bin mail-cli -- sync history --account-id <id>
```

### Threads
```bash
cargo run --bin mail-cli -- threads list --account-id <id>
cargo run --bin mail-cli -- threads get --thread-id <id> --account-id <id>
```

## Testing Auth Backends

```bash
# Auto-detect (default) — tries keyring, falls back to file
cargo run --bin mail-cli -- auth status

# Force file-based storage
cargo run --bin mail-cli -- --auth-backend file auth status

# Force keyring (errors if unavailable)
cargo run --bin mail-cli -- --auth-backend keyring auth status

# Verbose to see backend selection
cargo run --bin mail-cli -- -v auth status
```

## Common Issues

- **`could not find Cargo.toml`** — You're not in `services/cli/`. Use `--manifest-path services/cli/Cargo.toml`.
- **`Keyring write failed: locked collection`** — GNOME Keyring is locked. Use `--auth-backend file` or unlock your keyring.
- **`Could not open browser`** — Headless/SSH session. Copy the printed URL manually.
