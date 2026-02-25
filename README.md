# Paw Mail

Pre-built binaries and Claude Code skills for the Paw Mail email client.

## Installation

### Nix

```bash
# Install the unified binary
nix profile install github:pawpair/paw-mail-cli#mail

# Or install individual tools
nix profile install github:pawpair/paw-mail-cli#mail-cli
nix profile install github:pawpair/paw-mail-cli#mail-tui

# Run without installing
nix run github:pawpair/paw-mail-cli#mail -- --help
```

### Homebrew (macOS / Linux)

```bash
brew tap pawpair/paw-mail-cli
brew install mail

# Or install individual tools
brew install mail-cli
brew install mail-tui
```

### Arch Linux (AUR)

```bash
# Using an AUR helper (e.g., yay, paru)
yay -S mail-bin

# Or individual packages
yay -S mail-cli-bin
yay -S mail-tui-bin

# Or manually
git clone https://aur.archlinux.org/mail-bin.git
cd mail-bin && makepkg -si
```

### Debian / Ubuntu

Download `.deb` packages from the [latest release](https://github.com/pawpair/paw-mail-cli/releases/latest):

```bash
# Download and install (example for amd64)
curl -fSLO https://github.com/pawpair/paw-mail-cli/releases/latest/download/mail_0.1.0_amd64.deb
sudo dpkg -i mail_0.1.0_amd64.deb
```

### Manual

Download the tarball for your platform from [releases](https://github.com/pawpair/paw-mail-cli/releases/latest), extract, and place the binary on your `PATH`:

```bash
tar xzf mail-x86_64-linux.tar.gz
sudo mv mail /usr/local/bin/
```

## Binaries

| Binary     | Description                          |
|------------|--------------------------------------|
| `mail`     | Unified CLI + TUI (recommended)      |
| `mail-cli` | Command-line interface only           |
| `mail-tui` | Terminal user interface only          |

## Platforms

| Platform         | Architecture | Build     |
|------------------|-------------|-----------|
| Linux            | x86_64      | musl static |
| Linux            | aarch64     | musl static |
| macOS            | x86_64      | standard  |
| macOS            | aarch64     | standard  |

## Claude Code Skills

This repo also hosts reusable [Claude Code skills](https://skills.sh) for software development.

### Install skills into your project

```bash
# Clone this repo and run the install script
git clone https://github.com/pawpair/paw-mail-cli.git
./mail-cli/scripts/install-skills.sh

# Or add as a submodule
git submodule add https://github.com/pawpair/paw-mail-cli.git skills-public
./skills-public/scripts/install-skills.sh
```

### Available skills

| Skill | Description |
|-------|-------------|
| `clean-ddd-hexagonal` | Clean Architecture + DDD + Hexagonal patterns |
| `code-quality` | Code correctness and quality rules |
| `deploy-services` | Service deployment automation |
| `grpc-service-development` | gRPC microservice patterns |
| `kubernetes-deployment` | Kubernetes deployment and orchestration |
| `run-cli` | Paw Mail CLI development and testing |
| `rust-async-patterns` | Async Rust with Tokio |
| `rust-best-practices` | Idiomatic Rust (Apollo handbook) |
| `rust-testing` | Comprehensive Rust testing (42 rules) |
| `security-best-practices` | Language-agnostic security reviews |
| `sveltekit-data-flow` | SvelteKit load/action patterns |
| `sveltekit-structure` | SvelteKit routing and layouts |
| `ticketing-management` | Ticket/issue management integration |
| `typescript-best-practices` | Type-first TypeScript development |
| `worktree` | Git worktree management |

## How releases work

1. A new version is tagged in the private build repo
2. CI cross-compiles for all 4 targets (musl static for Linux, standard for macOS)
3. Binaries are uploaded as a GitHub Release on **this repo**
4. A `repository_dispatch` triggers the update workflow
5. The update workflow computes SHA-256 hashes and regenerates all package definitions (Nix, AUR, Homebrew, Debian)
6. `.deb` packages are built and attached to the release
7. AUR PKGBUILDs are published

## License

MIT
