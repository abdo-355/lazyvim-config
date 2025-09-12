# PostgreSQL SQL Support Setup Guide

This guide helps you install the required tools for full PostgreSQL support in LazyVim.

## Required Tools Installation

### 1. SQL Language Server

```bash
npm install -g sql-language-server
```

### 2. SQLFluff (Primary formatter and linter)

```bash
pip install sqlfluff
```

### 3. pg_format (Alternative formatter)

```bash
# Ubuntu/Debian
sudo apt install pgformatter

# macOS
brew install pgformatter

# Or install via Perl CPAN
cpan install SQL::Beautify
```

### 4. sqlc (for code generation)

```bash
go install github.com/kyleconroy/sqlc/cmd/sqlc@latest
```

## Verification

After installing the tools, verify they're available:

```bash
# Check if tools are in PATH
which sql-language-server
which sqlfluff
which pg_format
which sqlc

# Test sqlfluff
echo "select * from users where id = \$1;" | sqlfluff format --dialect=postgres -

# Test pg_format
echo "select * from users where id = \$1;" | pg_format
```

## Configuration Files

The setup creates these configuration files:

- `~/.config/nvim/.sqlfluff` - SQLFluff configuration with PostgreSQL dialect and sqlc placeholder support
- SQL-specific autocmds and keymaps in your LazyVim config

## Usage

### Keybindings (in SQL files)

- `<leader>sf` - Format SQL buffer
- `<leader>sl` - Run SQL linting
- `<leader>se` - Execute SQL (placeholder for your SQL client)

### Features

- **Syntax Highlighting**: Full PostgreSQL syntax via Treesitter
- **Parameter Support**: Recognizes `$1`, `$2`, etc. placeholders used by sqlc
- **Auto-formatting**: Format on save with sqlfluff (PostgreSQL dialect)
- **Linting**: Real-time SQL linting with PostgreSQL-specific rules
- **LSP**: Intelligent completions and diagnostics via sql-language-server
- **File Type Detection**: Automatic detection of `.sql`, `.pgsql`, and `.sqlc` files

## Customization

### Switch to pg_format

To use pg_format instead of sqlfluff, edit `lua/plugins/sql-formatters.lua`:

```lua
opts.formatters_by_ft.sql = { "pg_format" }
opts.formatters_by_ft.pgsql = { "pg_format" }
```

### Database Connection

Update the LSP connection settings in `lua/plugins/sql-support.lua` with your database credentials.

### SQLFluff Rules

Modify `.sqlfluff` to customize formatting rules according to your preferences.
