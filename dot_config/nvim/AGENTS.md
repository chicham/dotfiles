# Repository Guidelines

## Project Structure & Module Organization
This is a Neovim configuration repo. The entry point is `init.lua`, which wires up plugins, LSP, and UI behavior. Core configuration lives under `lua/`, with base Kickstart-style modules in `lua/kickstart/` and local customizations in `lua/custom/` (notably `lua/custom/plugins/`). Tree-sitter query overrides are stored in `after/queries/`, and custom spelling additions are in `spell/`. Plugin pinning is tracked in `lazy-lock.json`.

## Build, Test, and Development Commands
There is no build step. Common workflows are run inside Neovim:
- `nvim` to launch using this config.
- `:Lazy sync` to install/update plugins defined in `init.lua` and `lua/custom/plugins/`.
- `:Mason` to manage LSP servers and external tools configured in `init.lua`.
- `:checkhealth` to diagnose runtime issues.

## Coding Style & Naming Conventions
Lua is the primary language. Match existing style: tab indentation, single-quoted strings where possible, and small, focused plugin modules. Formatting is handled by `conform.nvim` with `stylua` for Lua and `ruff_format` for Python (see `init.lua`). Linting is set up via `nvim-lint` (see `lua/kickstart/plugins/lint.lua`).

## Testing Guidelines
There is no formal test framework. Lightweight, ad-hoc scripts live at the repo root (e.g., `test_org_api.lua`). You can run them headlessly:
- `nvim --headless -u init.lua -l test_org_api.lua`
Keep test scripts small and focused on one behavior.

## Commit & Pull Request Guidelines
This directory does not include Git history. Follow your team’s standard commit message format and PR checklist. If contributing upstream, include a clear description of changes, affected plugins/modules, and any manual verification performed.

## Agent-Specific Notes
When adding plugins, prefer `lua/custom/plugins/*.lua` and keep each plugin in its own file. Update `lazy-lock.json` only via `:Lazy sync` so pins stay consistent.
