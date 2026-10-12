# dotfiles

Ubuntu / Fedora developer dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Quick start

On a fresh Ubuntu or Fedora machine (Ubuntu desktop may need `sudo apt install curl` first):

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --source "$HOME/dotfiles" hungnm-kaopiz/dotfiles
```

This will:

1. Install chezmoi and clone this repo to `~/dotfiles`
2. Apply all configs to `$HOME`
3. Run the install scripts, in order:
   1. `10-install-apt` / `10-install-dnf`: system packages, eza, locale, zsh as login shell
   2. `20-install-tools`: Docker, atuin, starship, lazygit, lazydocker, Claude Code, Cursor Agent, herdr, omp, Monaspace NerdFonts, mise (node, bun), pi
   3. `30-install-apps`: fcitx5-lotus, Ghostty, Flameshot, VS Code, GNOME extras, Zed, Cursor, Orca, Chrome, DBeaver

Each script is a `run_onchange_` script: it runs again only when its rendered content changes. A failed step
prints a warning and the script carries on.

**After the first run**: log out and back in so the `docker` group, fcitx5 and the Copyous GNOME extension
take effect.

**First shell launch**: Zinit (plugin manager) auto-clones on first `zsh` launch. Subsequent launches use the cached version.

## What's included

### Shell (zsh + Zinit)

| File                                  | Purpose                                 |
| ------------------------------------- | --------------------------------------- |
| `~/.zshenv`                           | XDG dirs + `ZDOTDIR`                    |
| `~/.config/zsh/.zshrc`                | Main entry - sources `NN-*.zsh` in order |
| `~/.config/zsh/00-plugins.zsh`        | Zinit + plugins (OMZ libs, eza, ...)    |
| `~/.config/zsh/01-env.zsh`            | `$PATH`, `$EDITOR`                      |
| `~/.config/zsh/02-options.zsh`        | ZSH options                             |
| `~/.config/zsh/03-history.zsh`        | History settings                        |
| `~/.config/zsh/04-completion.zsh`     | compinit + fzf-tab                      |
| `~/.config/zsh/05-aliases.zsh`        | Shell aliases                           |
| `~/.config/zsh/06-functions.zsh`      | Shell functions (`lg`)                  |
| `~/.config/zsh/07-tools.zsh`          | Tool init (mise, fzf, zoxide, starship) |
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

| Tool           | Purpose                                 | Install method                     |
| -------------- | --------------------------------------- | ---------------------------------- |
| **mise**       | Version manager (Node, Python, Go...)   | `mise.run`                         |
| **Node LTS**   | JavaScript runtime                      | via mise                           |
| **Bun**        | JavaScript runtime & toolkit            | via mise                           |
| **starship**   | Prompt                                  | Official script                    |
| **Claude Code**| AI coding agent (latest channel)        | Official script (`claude.ai/install.sh`) |
| **Cursor Agent**| Cursor CLI agent (`agent`)             | Official script (`cursor.com/install`)   |
| **herdr**     | Agent/terminal workspace manager (`hd`) | Official script (`herdr.dev/install.sh`) |
| **omp**       | Coding agent harness (`omp`)            | Official script (`omp.sh/install --binary`) |
| **pi**        | Minimal agent harness (`pi`)            | Official script (`pi.dev/install.sh`, via mise node) |
| **atuin**      | Shell history sync                      | Official script                    |
| **lazygit**    | Git TUI                                 | GitHub release                     |
| **lazydocker** | Docker TUI                              | GitHub release                     |
| **Docker**     | Containers                              | Docker repo (apt / dnf)            |

### Apps

| App                   | Purpose                             | Ubuntu                 | Fedora                       |
| --------------------- | ----------------------------------- | ---------------------- | ---------------------------- |
| **fcitx5-lotus**      | Vietnamese input method             | Lotus apt repo         | Lotus rpm repo               |
| **Ghostty**           | Terminal                            | apt / PPA              | dnf / `scottames/ghostty` COPR |
| **Flameshot**         | Screenshot tool                     | apt                    | dnf                          |
| **VS Code**           | Code editor                         | Microsoft apt repo     | Microsoft yum repo           |
| **Zed**               | Code editor (preview)               | Official script        | Official script              |
| **Cursor**            | AI code editor                      | Cursor apt repo        | Cursor yum repo              |
| **Orca**              | Agent IDE (`orca-ide`)              | GitHub release `.deb`  | GitHub release `.rpm`        |
| **Chrome**            | Web browser                         | `.deb`                 | `.rpm`                       |
| **DBeaver CE**        | Database GUI                        | DBeaver apt repo       | `.rpm`                       |
| **Postman**           | API client                          | snap                   | Official tarball (`~/.local/opt`) |
| **Extension Manager** | GNOME extensions                    | snap                   | `gnome-extensions-app` (dnf) |
| **Copyous**           | Clipboard manager (GNOME extension) | extensions.gnome.org   | extensions.gnome.org         |

GNOME apps are only installed when `gnome-extensions` is present. Fedora uses no snap or Flathub.

### CLI packages (apt / dnf)

Lists live in [`packages/ubuntu.txt`](packages/ubuntu.txt) and [`packages/fedora.txt`](packages/fedora.txt).

**Core**: build tools (`build-essential` / `gcc gcc-c++ make`), `curl`, `fzf`, `gh`, `git`, `git-delta`, `htop`, `jq`, `ncdu`, `procps`, `ripgrep`, `unzip`, `zoxide`, `zsh`

**Modern replacements**: `bat`, `eza`, `fd-find`, `trash-cli`

On Ubuntu, `bat` is installed as `batcat` and `fd` as `fdfind`; the setup links `~/.local/bin/bat` and aliases `fd`.

### Configs

| File                                  | Purpose                                |
| ------------------------------------- | -------------------------------------- |
| `~/.config/starship.toml`             | Starship prompt (Catppuccin Macchiato) |
| `~/.config/lazygit/config.yml`        | Lazygit theme + delta integration      |
| `~/.config/ghostty/config`            | Ghostty terminal (Monaspace font)      |
| `~/.config/zed/`                      | Zed settings + keymap                  |
| `~/.config/herdr/config.toml`         | herdr                                  |
| `~/.config/inshellisense/rc.toml`     | inshellisense                          |
| `~/.config/ccstatusline/settings.json`| Claude Code status line                |
| `~/.gitconfig`                        | Git config (delta, templates)          |

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
```

## Customize

- **Personal data**: edit `.chezmoi.toml.tmpl`
- **Shell**: edit files in [`dot_config/zsh/`](dot_config/zsh/)
- **Machine-specific**: create `~/.config/zsh/local.zsh` (not in repo)
- **Default tools**: edit mise section in `run_onchange_20-install-tools.sh.tmpl`

## Layout

```
dotfiles/
├── .chezmoi.toml.tmpl                     # Template data (name, email, github_user)
├── .chezmoiignore                         # Repo-only files (README, packages/, scripts/)
├── dot_zshenv                             # → ~/.zshenv (XDG + ZDOTDIR)
├── dot_gitconfig.tmpl                     # → ~/.gitconfig
├── dot_config/
│   ├── zsh/
│   │   ├── dot_zshrc                      # → Main entry (sources NN-*.zsh)
│   │   ├── 00-plugins.zsh                 # → Zinit + plugins
│   │   ├── 01-env.zsh                     # → PATH, EDITOR
│   │   ├── 02-options.zsh                 # → setopt
│   │   ├── 03-history.zsh                 # → History
│   │   ├── 04-completion.zsh              # → compinit + fzf-tab
│   │   ├── 05-aliases.zsh                 # → Aliases
│   │   ├── 06-functions.zsh               # → Functions
│   │   └── 07-tools.zsh                   # → Tool init
│   ├── environment.d/fcitx5.conf          # → fcitx5 session env
│   ├── ghostty/
│   │   ├── config                         # → Ghostty terminal
│   │   └── shaders/                       # → Custom GLSL shaders
│   ├── lazygit/config.yml                 # → Lazygit
│   ├── starship.toml                      # → Starship prompt
│   ├── zed/                               # → Zed
│   ├── herdr/ inshellisense/ ccstatusline/
├── packages/
│   ├── ubuntu.txt                         # Apt packages list
│   └── fedora.txt                         # Dnf packages list
├── run_onchange_10-install-apt.sh.tmpl    # System packages (Ubuntu)
├── run_onchange_10-install-dnf.sh.tmpl    # System packages (Fedora)
├── run_onchange_20-install-tools.sh.tmpl  # Dev tools (Docker, mise, fonts...)
├── run_onchange_30-install-apps.sh.tmpl   # Desktop apps
├── scripts/install-common.sh              # Shared install helpers
└── README.md
```
