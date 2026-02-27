# Command-Line Help for `paw-mail-cli`

This document contains the help content for the `paw-mail-cli` command-line program.

**Command Overview:**

* [`paw-mail-cli`↴](#paw-mail-cli)
* [`paw-mail-cli auth`↴](#paw-mail-cli-auth)
* [`paw-mail-cli auth login`↴](#paw-mail-cli-auth-login)
* [`paw-mail-cli auth logout`↴](#paw-mail-cli-auth-logout)
* [`paw-mail-cli auth status`↴](#paw-mail-cli-auth-status)
* [`paw-mail-cli accounts`↴](#paw-mail-cli-accounts)
* [`paw-mail-cli accounts list`↴](#paw-mail-cli-accounts-list)
* [`paw-mail-cli accounts get`↴](#paw-mail-cli-accounts-get)
* [`paw-mail-cli accounts add`↴](#paw-mail-cli-accounts-add)
* [`paw-mail-cli accounts delete`↴](#paw-mail-cli-accounts-delete)
* [`paw-mail-cli accounts activate`↴](#paw-mail-cli-accounts-activate)
* [`paw-mail-cli accounts deactivate`↴](#paw-mail-cli-accounts-deactivate)
* [`paw-mail-cli accounts oauth-clients`↴](#paw-mail-cli-accounts-oauth-clients)
* [`paw-mail-cli emails`↴](#paw-mail-cli-emails)
* [`paw-mail-cli emails folders`↴](#paw-mail-cli-emails-folders)
* [`paw-mail-cli emails list`↴](#paw-mail-cli-emails-list)
* [`paw-mail-cli emails fetch`↴](#paw-mail-cli-emails-fetch)
* [`paw-mail-cli emails body`↴](#paw-mail-cli-emails-body)
* [`paw-mail-cli emails search`↴](#paw-mail-cli-emails-search)
* [`paw-mail-cli emails read`↴](#paw-mail-cli-emails-read)
* [`paw-mail-cli emails unread`↴](#paw-mail-cli-emails-unread)
* [`paw-mail-cli emails flag`↴](#paw-mail-cli-emails-flag)
* [`paw-mail-cli emails move`↴](#paw-mail-cli-emails-move)
* [`paw-mail-cli emails delete`↴](#paw-mail-cli-emails-delete)
* [`paw-mail-cli sync`↴](#paw-mail-cli-sync)
* [`paw-mail-cli sync status`↴](#paw-mail-cli-sync-status)
* [`paw-mail-cli sync trigger`↴](#paw-mail-cli-sync-trigger)
* [`paw-mail-cli sync history`↴](#paw-mail-cli-sync-history)
* [`paw-mail-cli threads`↴](#paw-mail-cli-threads)
* [`paw-mail-cli threads list`↴](#paw-mail-cli-threads-list)
* [`paw-mail-cli threads get`↴](#paw-mail-cli-threads-get)
* [`paw-mail-cli config`↴](#paw-mail-cli-config)
* [`paw-mail-cli config refresh`↴](#paw-mail-cli-config-refresh)
* [`paw-mail-cli config show`↴](#paw-mail-cli-config-show)

## `paw-mail-cli`

Command-line interface for Paw Mail — manage accounts, read and organize email, trigger sync, and browse conversation threads.

**Usage:** `paw-mail-cli [OPTIONS] <COMMAND>`

###### **Subcommands:**

* `auth` — Authentication management
* `accounts` — Account management
* `emails` — Email operations
* `sync` — Sync management
* `threads` — Thread/conversation management
* `config` — Configuration management

###### **Options:**

* `--server <URL>` — Backend server address
* `--format <FORMAT>` — Output format: table or json

  Default value: `table`

  Possible values: `table`, `json`

* `--auth-backend <BACKEND>` — Token storage backend: auto, keyring, or file
* `-v`, `--verbose` — Enable verbose logging



## `paw-mail-cli auth`

Authentication management

**Usage:** `paw-mail-cli auth <COMMAND>`

###### **Subcommands:**

* `login` — Authenticate via OAuth Device Flow
* `logout` — Clear stored authentication tokens
* `status` — Show current authentication status



## `paw-mail-cli auth login`

Authenticate via OAuth Device Flow

**Usage:** `paw-mail-cli auth login`



## `paw-mail-cli auth logout`

Clear stored authentication tokens

**Usage:** `paw-mail-cli auth logout`



## `paw-mail-cli auth status`

Show current authentication status

**Usage:** `paw-mail-cli auth status`



## `paw-mail-cli accounts`

Account management

**Usage:** `paw-mail-cli accounts <COMMAND>`

###### **Subcommands:**

* `list` — List all accounts
* `get` — Get a specific account by provider
* `add` — Link a new email account via OAuth (opens browser)
* `delete` — Delete an account
* `activate` — Activate an account
* `deactivate` — Deactivate an account
* `oauth-clients` — List available OAuth clients



## `paw-mail-cli accounts list`

List all accounts

**Usage:** `paw-mail-cli accounts list`



## `paw-mail-cli accounts get`

Get a specific account by provider

**Usage:** `paw-mail-cli accounts get --provider <PROVIDER>`

###### **Options:**

* `--provider <PROVIDER>` — Email provider: google, microsoft, app-password



## `paw-mail-cli accounts add`

Link a new email account via OAuth (opens browser)

**Usage:** `paw-mail-cli accounts add --email <EMAIL> --provider <PROVIDER>`

###### **Options:**

* `--email <EMAIL>` — Email address to link to your account
* `--provider <PROVIDER>` — Email provider: google, microsoft



## `paw-mail-cli accounts delete`

Delete an account

**Usage:** `paw-mail-cli accounts delete --provider <PROVIDER>`

###### **Options:**

* `--provider <PROVIDER>` — Email provider: google, microsoft, app-password



## `paw-mail-cli accounts activate`

Activate an account

**Usage:** `paw-mail-cli accounts activate --id <ID>`

###### **Options:**

* `--id <ID>` — Account ID (use 'accounts list' to find it)



## `paw-mail-cli accounts deactivate`

Deactivate an account

**Usage:** `paw-mail-cli accounts deactivate --id <ID>`

###### **Options:**

* `--id <ID>` — Account ID (use 'accounts list' to find it)



## `paw-mail-cli accounts oauth-clients`

List available OAuth clients

**Usage:** `paw-mail-cli accounts oauth-clients [OPTIONS]`

###### **Options:**

* `--system` — Show system-level clients instead of user clients



## `paw-mail-cli emails`

Email operations

**Usage:** `paw-mail-cli emails <COMMAND>`

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



## `paw-mail-cli emails folders`

List folders for an account

**Usage:** `paw-mail-cli emails folders --provider <PROVIDER> --email <EMAIL>`

###### **Options:**

* `--provider <PROVIDER>` — Email provider: google, microsoft, app-password
* `--email <EMAIL>` — Account email address



## `paw-mail-cli emails list`

List messages in a folder

**Usage:** `paw-mail-cli emails list [OPTIONS] --provider <PROVIDER> --email <EMAIL> --folder <FOLDER>`

###### **Options:**

* `--provider <PROVIDER>` — Email provider: google, microsoft, app-password
* `--email <EMAIL>` — Account email address
* `--folder <FOLDER>` — Mailbox folder name (e.g. INBOX, Sent, Drafts)
* `--limit <LIMIT>` — Maximum number of messages to return

  Default value: `50`



## `paw-mail-cli emails fetch`

Fetch a specific message

**Usage:** `paw-mail-cli emails fetch --provider <PROVIDER> --email <EMAIL> --folder <FOLDER> --uid <UID>`

###### **Options:**

* `--provider <PROVIDER>` — Email provider: google, microsoft, app-password
* `--email <EMAIL>` — Account email address
* `--folder <FOLDER>` — Mailbox folder name (e.g. INBOX, Sent, Drafts)
* `--uid <UID>` — Message UID (unique identifier within the folder)



## `paw-mail-cli emails body`

Fetch message body

**Usage:** `paw-mail-cli emails body --provider <PROVIDER> --email <EMAIL> --folder <FOLDER> --uid <UID>`

###### **Options:**

* `--provider <PROVIDER>` — Email provider: google, microsoft, app-password
* `--email <EMAIL>` — Account email address
* `--folder <FOLDER>` — Mailbox folder name (e.g. INBOX, Sent, Drafts)
* `--uid <UID>` — Message UID (unique identifier within the folder)



## `paw-mail-cli emails search`

Search messages

**Usage:** `paw-mail-cli emails search --provider <PROVIDER> --email <EMAIL> --folder <FOLDER> --query <QUERY>`

###### **Options:**

* `--provider <PROVIDER>` — Email provider: google, microsoft, app-password
* `--email <EMAIL>` — Account email address
* `--folder <FOLDER>` — Mailbox folder name (e.g. INBOX, Sent, Drafts)
* `--query <QUERY>` — IMAP search query string



## `paw-mail-cli emails read`

Mark message as read

**Usage:** `paw-mail-cli emails read --provider <PROVIDER> --email <EMAIL> --folder <FOLDER> --uid <UID>`

###### **Options:**

* `--provider <PROVIDER>` — Email provider: google, microsoft, app-password
* `--email <EMAIL>` — Account email address
* `--folder <FOLDER>` — Mailbox folder name (e.g. INBOX, Sent, Drafts)
* `--uid <UID>` — Message UID (unique identifier within the folder)



## `paw-mail-cli emails unread`

Mark message as unread

**Usage:** `paw-mail-cli emails unread --provider <PROVIDER> --email <EMAIL> --folder <FOLDER> --uid <UID>`

###### **Options:**

* `--provider <PROVIDER>` — Email provider: google, microsoft, app-password
* `--email <EMAIL>` — Account email address
* `--folder <FOLDER>` — Mailbox folder name (e.g. INBOX, Sent, Drafts)
* `--uid <UID>` — Message UID (unique identifier within the folder)



## `paw-mail-cli emails flag`

Flag/unflag a message

**Usage:** `paw-mail-cli emails flag [OPTIONS] --provider <PROVIDER> --email <EMAIL> --folder <FOLDER> --uid <UID>`

###### **Options:**

* `--provider <PROVIDER>` — Email provider: google, microsoft, app-password
* `--email <EMAIL>` — Account email address
* `--folder <FOLDER>` — Mailbox folder name (e.g. INBOX, Sent, Drafts)
* `--uid <UID>` — Message UID (unique identifier within the folder)
* `--unflag` — Unflag instead of flag



## `paw-mail-cli emails move`

Move a message to another folder

**Usage:** `paw-mail-cli emails move --provider <PROVIDER> --email <EMAIL> --folder <FOLDER> --uid <UID> --destination <DESTINATION>`

###### **Options:**

* `--provider <PROVIDER>` — Email provider: google, microsoft, app-password
* `--email <EMAIL>` — Account email address
* `--folder <FOLDER>` — Mailbox folder name (e.g. INBOX, Sent, Drafts)
* `--uid <UID>` — Message UID (unique identifier within the folder)
* `--destination <DESTINATION>` — Target folder to move the message to



## `paw-mail-cli emails delete`

Delete a message

**Usage:** `paw-mail-cli emails delete --provider <PROVIDER> --email <EMAIL> --folder <FOLDER> --uid <UID>`

###### **Options:**

* `--provider <PROVIDER>` — Email provider: google, microsoft, app-password
* `--email <EMAIL>` — Account email address
* `--folder <FOLDER>` — Mailbox folder name (e.g. INBOX, Sent, Drafts)
* `--uid <UID>` — Message UID (unique identifier within the folder)



## `paw-mail-cli sync`

Sync management

**Usage:** `paw-mail-cli sync <COMMAND>`

###### **Subcommands:**

* `status` — Get current sync status for an account
* `trigger` — Trigger a sync operation
* `history` — List recent sync history



## `paw-mail-cli sync status`

Get current sync status for an account

**Usage:** `paw-mail-cli sync status --account-id <ACCOUNT_ID>`

###### **Options:**

* `--account-id <ACCOUNT_ID>` — Account ID (use 'accounts list' to find it)



## `paw-mail-cli sync trigger`

Trigger a sync operation

**Usage:** `paw-mail-cli sync trigger [OPTIONS] --account-id <ACCOUNT_ID>`

###### **Options:**

* `--account-id <ACCOUNT_ID>` — Account ID (use 'accounts list' to find it)
* `--type <TYPE>` — Sync type: full, incremental, quick

  Default value: `incremental`
* `--folders <FOLDERS>` — Restrict to specific folders (comma-separated)



## `paw-mail-cli sync history`

List recent sync history

**Usage:** `paw-mail-cli sync history [OPTIONS] --account-id <ACCOUNT_ID>`

###### **Options:**

* `--account-id <ACCOUNT_ID>` — Account ID (use 'accounts list' to find it)
* `--limit <LIMIT>` — Maximum number of history entries to return

  Default value: `20`



## `paw-mail-cli threads`

Thread/conversation management

**Usage:** `paw-mail-cli threads <COMMAND>`

###### **Subcommands:**

* `list` — List conversation threads
* `get` — Get a specific thread with its messages



## `paw-mail-cli threads list`

List conversation threads

**Usage:** `paw-mail-cli threads list [OPTIONS] --account-id <ACCOUNT_ID>`

###### **Options:**

* `--account-id <ACCOUNT_ID>` — Account ID (use 'accounts list' to find it)
* `--limit <LIMIT>` — Maximum number of threads to return

  Default value: `50`
* `--offset <OFFSET>` — Number of threads to skip for pagination

  Default value: `0`



## `paw-mail-cli threads get`

Get a specific thread with its messages

**Usage:** `paw-mail-cli threads get --thread-id <THREAD_ID> --account-id <ACCOUNT_ID>`

###### **Options:**

* `--thread-id <THREAD_ID>` — Thread ID
* `--account-id <ACCOUNT_ID>` — Account ID (use 'accounts list' to find it)



## `paw-mail-cli config`

Configuration management

**Usage:** `paw-mail-cli config <COMMAND>`

###### **Subcommands:**

* `refresh` — Fetch config from remote server and cache locally
* `show` — Show current config values



## `paw-mail-cli config refresh`

Fetch config from remote server and cache locally

**Usage:** `paw-mail-cli config refresh`



## `paw-mail-cli config show`

Show current config values

**Usage:** `paw-mail-cli config show`



<hr/>

<small><i>
    This document was generated automatically by
    <a href="https://crates.io/crates/clap-markdown"><code>clap-markdown</code></a>.
</i></small>
