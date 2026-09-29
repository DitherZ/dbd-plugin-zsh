# DBD (Directory Banner Display) - default settings
#
# Each value is only a default: anything you export before the plugin loads
# (e.g. in ~/.zshrc) wins, and so does anything saved with `dbd-config set`
# (stored in ${XDG_CONFIG_HOME:-~/.config}/dbd/settings.zsh).

# Master switch: true | false
: ${DBD_ENABLED:=true}

# Figlet font name (without .flf). Falls back to "standard" if not installed.
: ${DBD_FONT:=lowerb}

# Extra font directory to search first for figlet fonts. Empty = auto-detect
# figlet's own font directory. Fonts fetched with `dbd-ff` are stored in
# ${XDG_DATA_HOME:-~/.local/share}/dbd/fonts and always searched.
: ${DBD_FONT_DIR:=}

# Banner color: red green yellow blue purple cyan orange lolcat none
: ${DBD_COLOR:=lolcat}

# Pick a random font / color on every banner: true | false
: ${DBD_RANDOM_FONT:=false}
: ${DBD_RANDOM_COLOR:=false}

# Blank lines above and below the banner
: ${DBD_PADDING:=0}

# Banner width in columns, or "auto" to use the terminal width
: ${DBD_WIDTH:=auto}

# Clear the screen before drawing the banner: true | false
: ${DBD_CLEAR:=true}
