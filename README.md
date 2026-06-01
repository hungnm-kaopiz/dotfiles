# dotfiles

Ubuntu developer dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Quick start

On a fresh Ubuntu machine:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply hungnm-kaopiz/dotfiles
```

This will:

1. Install chezmoi
2. Clone this repo to `~/.local/share/chezmoi`
3. Install apt packages
4. Install dev tools (Docker, mise, starship, lazygit, lazydocker, Ghostty, etc.)
5. Build and install fcitx5-lotus (Vietnamese input method)
6. Install Monaspace NerdFonts
7. Apply all configs to `$HOME`

**First shell launch**: Zinit (plugin manager) auto-clones on first `zsh` launch. Subsequent launches use the cached version.

## What's included

### Shell (zsh + Zinit)

| File                                  | Purpose                                 |
| ------------------------------------- | --------------------------------------- |
| `~/.zshenv`                           | XDG dirs + `ZDOTDIR`                    |
| `~/.config/zsh/.zshrc`                | Main entry - Zinit, plugins, compinit   |
| `~/.config/zsh/01-env.zsh`            | `$PATH`, `$EDITOR`                      |
| `~/.config/zsh/02-options.zsh`        | ZSH options                             |
| `~/.config/zsh/03-history.zsh`        | History settings                        |
| `~/.config/zsh/05-aliases.zsh`        | Shell aliases                           |
| `~/.config/zsh/06-tools.zsh`          | Tool init (mise, fzf, zoxide, starship) |
| `~/.config/environment.d/fcitx5.conf` | fcitx5 IM env vars (GDM login)          |
| `~/.config/zsh/local.zsh`             | Machine-specific (not in repo)          |

### Plugins (via Zinit)

| Plugin                       | Purpose                            |
| ---------------------------- | ---------------------------------- |
| **OMZ directories**          | `..`, `...`, `take`                |
| **OMZ theme-and-appearance** | Terminal title, ls colors          |
| **OMZ eza**                  | ls replacement (icons, git status) |
| **zsh-syntax-highlighting**  | Command highlighting               |
| **zsh-autosuggestions**      | Ghost text suggestions             |
| **fzf-tab**                  | Fuzzy tab completion               |

### Dev tools

| Tool           | Purpose                                 | Install method  |
| -------------- | --------------------------------------- | --------------- |
| **mise**       | Version manager (Node, Python, Go...)   | `mise.run`      |
| **@antfu/ni**  | Unified package manager (npm/yarn/pnpm) | via mise        |
| **Bun**        | JavaScript runtime & toolkit            | Official script |
| **starship**   | Prompt                                  | Official script |
| **lazygit**    | Git TUI                                 | apt             |
| **lazydocker** | Docker TUI                              | Official script |
| **atuin**      | Shell history sync                      | Official script |
| **Docker**     | Containers                              | Docker repo     |
| **Ghostty**    | Terminal                                | apt / PPA       |
| **Zed**        | Code editor (preview)                   | Official script |
| **Cursor**     | AI code editor                          | Official script |
| **Chrome**     | Web browser                             | Google repo     |
| **OpenVPN 3**  | VPN client                              | OpenVPN repo    |

### Apps

| App              | Purpose                                     |
| ---------------- | ------------------------------------------- |
| **fcitx5-lotus** | Vietnamese input method (build from source) |
| **Pano**         | Clipboard manager (GNOME extension)         |

### CLI packages (apt)

**Core**: `build-essential`, `curl`, `fzf`, `git`, `git-delta`, `procps`, `ripgrep`, `unzip`, `wget`, `tree`, `htop`, `jq`, `zsh`, `zoxide`

**Modern replacements**: `bat`, `eza`, `fd-find`, `trash-cli`

### Configs

| File                           | Purpose                                |
| ------------------------------ | -------------------------------------- |
| `~/.config/starship.toml`      | Starship prompt (Catppuccin Macchiato) |
| `~/.config/lazygit/config.yml` | Lazygit theme + delta integration      |
| `~/.config/ghostty/config`     | Ghostty terminal (Monaspace font)      |
| `~/.gitconfig`                 | Git config (delta, templates)          |

## Daily use

```bash
# Chezmoi
chezmoi update          # pull latest and apply
chezmoi diff            # show pending changes
chezmoi apply           # apply local source changes
chezmoi edit ~/.config/zsh/.zshrc   # edit a managed file

# Version management (via mise)
mise use node@20        # set project node version
mise use --global python@3.12  # set global python version
mise install            # install all tools from .mise.toml

# Package management (via ni)
ni                      # install deps (auto-detect npm/yarn/pnpm)
ni vite                 # add package
ni -D typescript        # add devDependency
ni -g eslint            # global install
```

## Customize

- **Personal data**: edit `.chezmoi.toml.tmpl`
- **Shell**: edit files in [`dot_config/zsh/`](dot_config/zsh/)
- **Machine-specific**: create `~/.config/zsh/local.zsh` (not in repo)
- **Default tools**: edit mise section in `run_onchange_install-packages.sh.tmpl`

## Layout

```
dotfiles/
├── .chezmoi.toml.tmpl                     # Template data (name, email, github_user)
├── dot_zshenv                             # → ~/.zshenv (XDG + ZDOTDIR)
├── dot_gitconfig.tmpl                     # → ~/.gitconfig
├── dot_config/
│   ├── zsh/
│   │   ├── .zshrc                         # → Main entry (Zinit + plugins)
│   │   ├── 01-env.zsh                     # → PATH, EDITOR
│   │   ├── 02-options.zsh                 # → setopt
│   │   ├── 03-history.zsh                 # → History
│   │   ├── 05-aliases.zsh                 # → Aliases
│   │   ├── 06-tools.zsh                   # → Tool init
│   │   └── _fzf-tab.zsh                   # → fzf-tab config
│   ├── starship.toml                      # → Starship prompt
│   ├── lazygit/config.yml                 # → Lazygit
│   ├── ghostty/
│   │   ├── config                         # → Ghostty terminal
│   │   └── shaders/                       # → Custom GLSL shaders
│   ├── environment.d/fcitx5.conf            # → fcitx5 session env
│           ├── bloom.glsl
│           └── cursor-matrix.glsl
├── packages/ubuntu.txt                    # Apt packages list
├── run_onchange_install-packages.sh.tmpl  # First-run installer
├── install.sh                             # Bootstrap script
└── README.md
```

docker
