# DBD Plugin — Directory Banner Display

A zsh / [Oh My Zsh](https://ohmyz.sh) plugin that shows a [figlet](http://www.figlet.org) banner of the current directory name, plus a colored directory listing, every time you `cd`.

## Features

- Banner and listing on every directory change (`cd`, `pushd`, `auto_cd`, …) and once when the shell starts
- Any figlet `.flf` font, with a font picker and a fetcher for fonts from URLs or git repos
- Colors: red, green, yellow, blue, purple, cyan, orange, or rainbow via `lolcat`
- Random font / random color mode
- Settings changed with `dbd-config set …` are saved and survive new shells

## Requirements

| Tool | Needed | Notes |
|------|--------|-------|
| `zsh` | yes | |
| `figlet` | yes | `sudo apt install figlet` / `brew install figlet` |
| `lolcat` | optional | rainbow color; falls back to plain color without it |
| `column` | optional | multi-column listing (`bsdextrautils` on Debian/Ubuntu) |
| `curl` or `wget`, `git` | optional | only for `dbd-ff` |

## Installation

### Oh My Zsh

```zsh
git clone https://github.com/DitherZ/dpd-plugin \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/dbd-plugin"
```

Add `dbd-plugin` to the `plugins` array in `~/.zshrc`:

```zsh
plugins=(git dbd-plugin)
```

Then `exec zsh`.

### Without Oh My Zsh

```zsh
git clone https://github.com/DitherZ/dpd-plugin ~/.dbd-plugin
echo 'source ~/.dbd-plugin/dbd-plugin.plugin.zsh' >> ~/.zshrc
```

## zoxide

Works with [zoxide](https://github.com/ajeetdsouza/zoxide) out of the box: `z`, `zi`, `z -` and `eval "$(zoxide init zsh --cmd cd)"` all show the banner, whichever order you load them in. A `z` that finds no match doesn't change directory, so no banner is drawn.

## Commands

| Command | What it does |
|---------|--------------|
| `dbd-show` | Draw the banner for the current directory |
| `dbs` / `dba` | Banner + listing (`dba` includes hidden files) |
| `dbd-config show` | Print the current settings |
| `dbd-config set <key> <value>` | Change and save a setting (see below) |
| `dbd-config edit` / `reset` | Edit or delete your saved settings |
| `dbd-font [name]` | Pick a font (interactive menu when no name is given) |
| `dbd-list-fonts` | List every installed font |
| `dbd-ff <url>` | Fetch a `.flf` file or a `*.git` repo of fonts and make it the active font |

### Settings

```zsh
dbd-config set font <name>          # any name from dbd-list-fonts
dbd-config set color <color>        # red green yellow blue purple cyan orange lolcat none
dbd-config set random on|off        # random font and color on every banner
dbd-config set random-font on|off   # ...or just one of them
dbd-config set random-color on|off
dbd-config set padding <n>          # blank lines above and below
dbd-config set width <n|auto>       # figlet width; auto = terminal width
dbd-config set clear on|off         # clear the screen before each banner
dbd-config set enabled on|off       # master switch
```

Saved settings live in `${XDG_CONFIG_HOME:-~/.config}/dbd/settings.zsh`. You can also export any `DBD_*` variable (see [`dbd-config.zsh`](dbd-config.zsh) for the full list and defaults) in `~/.zshrc` *before* the plugin loads.

### Fonts

Fonts are searched in this order: `~/.local/share/dbd/fonts` (where `dbd-ff` installs), `$DBD_FONT_DIR` (optional), then figlet's own font directory. If the configured font is missing, `standard` is used. Only figlet `.flf` fonts are supported.

```zsh
dbd-ff https://github.com/xero/figlet-fonts.git
dbd-ff https://github.com/user/repo/blob/main/Cool.flf
```

## Example

```
 _ __  _ __ ___ (_)
| '_ \| '__/ _ \| |
| |_) | | | (_) | |
| .__/|_|  \___// |
|_|           |__/
📂 /home/me/proj
file1	file2
```

## Development

```zsh
zsh tests/run.zsh      # needs zsh and figlet
```

## Uninstall

Remove `dbd-plugin` from the `plugins=(...)` array in `~/.zshrc` (or the `source` line), then:

```zsh
rm -rf "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/dbd-plugin" ~/.config/dbd ~/.local/share/dbd
```

## License

MIT — see [LICENSE](LICENSE).

## Author

Developed by **BlackFlame444** — [GitHub](https://github.com/BlackFlame444)
