---
title: Paw Mail CLI Documentation
---

# Command-Line Help for `paw-mail`

This document contains the help content for the `paw-mail` command-line program.

**Command Overview:**

* [`paw-mail`↴](#paw-mail)
* [`paw-mail tui`↴](#paw-mail-tui)
* [`paw-mail auth`↴](#paw-mail-auth)
* [`paw-mail auth login`↴](#paw-mail-auth-login)
* [`paw-mail auth logout`↴](#paw-mail-auth-logout)
* [`paw-mail auth status`↴](#paw-mail-auth-status)
* [`paw-mail accounts`↴](#paw-mail-accounts)
* [`paw-mail accounts list`↴](#paw-mail-accounts-list)
* [`paw-mail accounts get`↴](#paw-mail-accounts-get)
* [`paw-mail accounts add`↴](#paw-mail-accounts-add)
* [`paw-mail accounts delete`↴](#paw-mail-accounts-delete)
* [`paw-mail accounts activate`↴](#paw-mail-accounts-activate)
* [`paw-mail accounts deactivate`↴](#paw-mail-accounts-deactivate)
* [`paw-mail accounts oauth-clients`↴](#paw-mail-accounts-oauth-clients)
* [`paw-mail emails`↴](#paw-mail-emails)
* [`paw-mail emails folders`↴](#paw-mail-emails-folders)
* [`paw-mail emails list`↴](#paw-mail-emails-list)
* [`paw-mail emails fetch`↴](#paw-mail-emails-fetch)
* [`paw-mail emails body`↴](#paw-mail-emails-body)
* [`paw-mail emails search`↴](#paw-mail-emails-search)
* [`paw-mail emails read`↴](#paw-mail-emails-read)
* [`paw-mail emails unread`↴](#paw-mail-emails-unread)
* [`paw-mail emails flag`↴](#paw-mail-emails-flag)
* [`paw-mail emails move`↴](#paw-mail-emails-move)
* [`paw-mail emails delete`↴](#paw-mail-emails-delete)
* [`paw-mail sync`↴](#paw-mail-sync)
* [`paw-mail sync status`↴](#paw-mail-sync-status)
* [`paw-mail sync trigger`↴](#paw-mail-sync-trigger)
* [`paw-mail sync history`↴](#paw-mail-sync-history)
* [`paw-mail threads`↴](#paw-mail-threads)
* [`paw-mail threads list`↴](#paw-mail-threads-list)
* [`paw-mail threads get`↴](#paw-mail-threads-get)
* [`paw-mail config`↴](#paw-mail-config)
* [`paw-mail config refresh`↴](#paw-mail-config-refresh)
* [`paw-mail config show`↴](#paw-mail-config-show)

## `paw-mail`

Combined mail CLI and TUI — manage accounts, read and organize email, trigger sync, and browse conversation threads. Run a subcommand for CLI mode, or 'paw-mail tui' for interactive TUI mode.

**Usage:** `paw-mail [OPTIONS] <COMMAND>`

###### **Subcommands:**

* `tui` — Launch interactive TUI mode
* `auth` — Authentication management
* `accounts` — Account management
* `emails` — Email operations
* `sync` — Sync management
* `threads` — Thread/conversation management
* `config` — Configuration management

###### **Options:**

* `--server <URL>` — Backend server address
* `--format <FORMAT>` — Output format: table or json (for CLI commands)

  Default value: `table`

  Possible values: `table`, `json`

* `--auth-backend <BACKEND>` — Token storage backend: auto, keyring, or file
* `-v`, `--verbose` — Enable verbose logging



## `paw-mail tui`

Launch interactive TUI mode

**Usage:** `paw-mail tui`



## `paw-mail auth`

Authentication management

**Usage:** `paw-mail auth <COMMAND>`

###### **Subcommands:**

* `login` — Authenticate via OAuth Device Flow
* `logout` — Clear stored authentication tokens
* `status` — Show current authentication status



## `paw-mail auth login`

Authenticate via OAuth Device Flow

**Usage:** `paw-mail auth login`



## `paw-mail auth logout`

Clear stored authentication tokens

**Usage:** `paw-mail auth logout`



## `paw-mail auth status`

Show current authentication status

**Usage:** `paw-mail auth status`



## `paw-mail accounts`

Account management

**Usage:** `paw-mail accounts <COMMAND>`

###### **Subcommands:**

* `list` — List all accounts
* `get` — Get a specific account by provider
* `add` — Link a new email account via OAuth (opens browser)
* `delete` — Delete an account
* `activate` — Activate an account
* `deactivate` — Deactivate an account
* `oauth-clients` — List available OAuth clients



## `paw-mail accounts list`

List all accounts

**Usage:** `paw-mail accounts list`



## `paw-mail accounts get`

Get a specific account by provider

**Usage:** `paw-mail accounts get --provider <PROVIDER>`

###### **Options:**

* `--provider <PROVIDER>` — Email provider: google, microsoft, app-password



## `paw-mail accounts add`

Link a new email account via OAuth (opens browser)

**Usage:** `paw-mail accounts add --email <EMAIL> --provider <PROVIDER>`

###### **Options:**

* `--email <EMAIL>` — Email address to link to your account
* `--provider <PROVIDER>` — Email provider: google, microsoft



## `paw-mail accounts delete`

Delete an account

**Usage:** `paw-mail accounts delete --provider <PROVIDER>`

###### **Options:**

* `--provider <PROVIDER>` — Email provider: google, microsoft, app-password



## `paw-mail accounts activate`

Activate an account

**Usage:** `paw-mail accounts activate --id <ID>`

###### **Options:**

* `--id <ID>` — Account ID (use 'accounts list' to find it)



## `paw-mail accounts deactivate`

Deactivate an account

**Usage:** `paw-mail accounts deactivate --id <ID>`

###### **Options:**

* `--id <ID>` — Account ID (use 'accounts list' to find it)



## `paw-mail accounts oauth-clients`

List available OAuth clients

**Usage:** `paw-mail accounts oauth-clients [OPTIONS]`

###### **Options:**

* `--system` — Show system-level clients instead of user clients



## `paw-mail emails`

Email operations

**Usage:** `paw-mail emails <COMMAND>`

###### **Subcommands:**

* `folders` — List folders for an account
* `list` — List messages in a folder
* `fetch` — Fetch a specific message
* `body` — Fetch message body
* `search` — Search messages
* `read` — Mark message as read
* `unread` — Mark message as unread
* `flag` — Flag/unflag a message
* `move` — Move a message to another folder
* `delete` — Delete a message



## `paw-mail emails folders`

List folders for an account

**Usage:** `paw-mail emails folders --provider <PROVIDER> --email <EMAIL>`

###### **Options:**

* `--provider <PROVIDER>` — Email provider: google, microsoft, app-password
* `--email <EMAIL>` — Account email address



## `paw-mail emails list`

List messages in a folder

**Usage:** `paw-mail emails list [OPTIONS] --provider <PROVIDER> --email <EMAIL> --folder <FOLDER>`

###### **Options:**

* `--provider <PROVIDER>` — Email provider: google, microsoft, app-password
* `--email <EMAIL>` — Account email address
* `--folder <FOLDER>` — Mailbox folder name (e.g. INBOX, Sent, Drafts)
* `--limit <LIMIT>` — Maximum number of messages to return

  Default value: `50`



## `paw-mail emails fetch`

Fetch a specific message

**Usage:** `paw-mail emails fetch --provider <PROVIDER> --email <EMAIL> --folder <FOLDER> --uid <UID>`

###### **Options:**

* `--provider <PROVIDER>` — Email provider: google, microsoft, app-password
* `--email <EMAIL>` — Account email address
* `--folder <FOLDER>` — Mailbox folder name (e.g. INBOX, Sent, Drafts)
* `--uid <UID>` — Message UID (unique identifier within the folder)



## `paw-mail emails body`

Fetch message body

**Usage:** `paw-mail emails body --provider <PROVIDER> --email <EMAIL> --folder <FOLDER> --uid <UID>`

###### **Options:**

* `--provider <PROVIDER>` — Email provider: google, microsoft, app-password
* `--email <EMAIL>` — Account email address
* `--folder <FOLDER>` — Mailbox folder name (e.g. INBOX, Sent, Drafts)
* `--uid <UID>` — Message UID (unique identifier within the folder)



## `paw-mail emails search`

Search messages

**Usage:** `paw-mail emails search --provider <PROVIDER> --email <EMAIL> --folder <FOLDER> --query <QUERY>`

###### **Options:**

* `--provider <PROVIDER>` — Email provider: google, microsoft, app-password
* `--email <EMAIL>` — Account email address
* `--folder <FOLDER>` — Mailbox folder name (e.g. INBOX, Sent, Drafts)
* `--query <QUERY>` — IMAP search query string



## `paw-mail emails read`

Mark message as read

**Usage:** `paw-mail emails read --provider <PROVIDER> --email <EMAIL> --folder <FOLDER> --uid <UID>`

###### **Options:**

* `--provider <PROVIDER>` — Email provider: google, microsoft, app-password
* `--email <EMAIL>` — Account email address
* `--folder <FOLDER>` — Mailbox folder name (e.g. INBOX, Sent, Drafts)
* `--uid <UID>` — Message UID (unique identifier within the folder)



## `paw-mail emails unread`

Mark message as unread

**Usage:** `paw-mail emails unread --provider <PROVIDER> --email <EMAIL> --folder <FOLDER> --uid <UID>`

###### **Options:**

* `--provider <PROVIDER>` — Email provider: google, microsoft, app-password
* `--email <EMAIL>` — Account email address
* `--folder <FOLDER>` — Mailbox folder name (e.g. INBOX, Sent, Drafts)
* `--uid <UID>` — Message UID (unique identifier within the folder)



## `paw-mail emails flag`

Flag/unflag a message

**Usage:** `paw-mail emails flag [OPTIONS] --provider <PROVIDER> --email <EMAIL> --folder <FOLDER> --uid <UID>`

###### **Options:**

* `--provider <PROVIDER>` — Email provider: google, microsoft, app-password
* `--email <EMAIL>` — Account email address
* `--folder <FOLDER>` — Mailbox folder name (e.g. INBOX, Sent, Drafts)
* `--uid <UID>` — Message UID (unique identifier within the folder)
* `--unflag` — Unflag instead of flag



## `paw-mail emails move`

Move a message to another folder

**Usage:** `paw-mail emails move --provider <PROVIDER> --email <EMAIL> --folder <FOLDER> --uid <UID> --destination <DESTINATION>`

###### **Options:**

* `--provider <PROVIDER>` — Email provider: google, microsoft, app-password
* `--email <EMAIL>` — Account email address
* `--folder <FOLDER>` — Mailbox folder name (e.g. INBOX, Sent, Drafts)
* `--uid <UID>` — Message UID (unique identifier within the folder)
* `--destination <DESTINATION>` — Target folder to move the message to



## `paw-mail emails delete`

Delete a message

**Usage:** `paw-mail emails delete --provider <PROVIDER> --email <EMAIL> --folder <FOLDER> --uid <UID>`

###### **Options:**

* `--provider <PROVIDER>` — Email provider: google, microsoft, app-password
* `--email <EMAIL>` — Account email address
* `--folder <FOLDER>` — Mailbox folder name (e.g. INBOX, Sent, Drafts)
* `--uid <UID>` — Message UID (unique identifier within the folder)



## `paw-mail sync`

Sync management

**Usage:** `paw-mail sync <COMMAND>`

###### **Subcommands:**

* `status` — Get current sync status for an account
* `trigger` — Trigger a sync operation
* `history` — List recent sync history



## `paw-mail sync status`

Get current sync status for an account

**Usage:** `paw-mail sync status --account-id <ACCOUNT_ID>`

###### **Options:**

* `--account-id <ACCOUNT_ID>` — Account ID (use 'accounts list' to find it)



## `paw-mail sync trigger`

Trigger a sync operation

**Usage:** `paw-mail sync trigger [OPTIONS] --account-id <ACCOUNT_ID>`

###### **Options:**

* `--account-id <ACCOUNT_ID>` — Account ID (use 'accounts list' to find it)
* `--type <TYPE>` — Sync type: full, incremental, quick

  Default value: `incremental`
* `--folders <FOLDERS>` — Restrict to specific folders (comma-separated)



## `paw-mail sync history`

List recent sync history

**Usage:** `paw-mail sync history [OPTIONS] --account-id <ACCOUNT_ID>`

###### **Options:**

* `--account-id <ACCOUNT_ID>` — Account ID (use 'accounts list' to find it)
* `--limit <LIMIT>` — Maximum number of history entries to return

  Default value: `20`



## `paw-mail threads`

Thread/conversation management

**Usage:** `paw-mail threads <COMMAND>`

###### **Subcommands:**

* `list` — List conversation threads
* `get` — Get a specific thread with its messages



## `paw-mail threads list`

List conversation threads

**Usage:** `paw-mail threads list [OPTIONS] --account-id <ACCOUNT_ID>`

###### **Options:**

* `--account-id <ACCOUNT_ID>` — Account ID (use 'accounts list' to find it)
* `--limit <LIMIT>` — Maximum number of threads to return

  Default value: `50`
* `--offset <OFFSET>` — Number of threads to skip for pagination

  Default value: `0`



## `paw-mail threads get`

Get a specific thread with its messages

**Usage:** `paw-mail threads get --thread-id <THREAD_ID> --account-id <ACCOUNT_ID>`

###### **Options:**

* `--thread-id <THREAD_ID>` — Thread ID
* `--account-id <ACCOUNT_ID>` — Account ID (use 'accounts list' to find it)



## `paw-mail config`

Configuration management

**Usage:** `paw-mail config <COMMAND>`

###### **Subcommands:**

* `refresh` — Fetch config from remote server and cache locally
* `show` — Show current config values



## `paw-mail config refresh`

Fetch config from remote server and cache locally

**Usage:** `paw-mail config refresh`



## `paw-mail config show`

Show current config values

**Usage:** `paw-mail config show`



<hr/>

<small><i>
    This document was generated automatically by
    <a href="https://crates.io/crates/clap-markdown"><code>clap-markdown</code></a>.
</i></small>
