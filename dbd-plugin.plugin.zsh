# DBD (Directory Banner Display)
# Shows a figlet banner and a colored directory listing whenever you cd.
# Works as an oh-my-zsh plugin or sourced directly from ~/.zshrc.

# ---------------------------------------------------------------- setup ----
DBD_PLUGIN_DIR="${${(%):-%x}:A:h}"
DBD_CONFIG_FILE="$DBD_PLUGIN_DIR/dbd-config.zsh"
DBD_USER_FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/dbd/fonts"
DBD_SETTINGS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/dbd/settings.zsh"

# Saved settings (from `dbd-config set`) win over defaults.
[[ -r "$DBD_SETTINGS_FILE" ]] && source "$DBD_SETTINGS_FILE"
source "$DBD_CONFIG_FILE"

# ------------------------------------------------------------- helpers ----
_dbd_err() { print -u2 -r -- "dbd: $*"; }

# Prints the directories fonts are searched in, highest priority first.
_dbd_font_dirs() {
    local sys
    sys=$(figlet -I2 2>/dev/null)
    print -rl -- "$DBD_USER_FONT_DIR" "$DBD_FONT_DIR" "$sys" | while IFS= read -r d; do
        [[ -n "$d" && -d "$d" ]] && print -r -- "$d"
    done
}

# Sets REPLY to the directory holding font $1 (without .flf).
_dbd_find_font() {
    local d
    for d in ${(f)"$(_dbd_font_dirs)"}; do
        [[ -f "$d/$1.flf" ]] && { REPLY="$d"; return 0; }
    done
    return 1
}

# Prints every installed font name once, sorted.
_dbd_all_fonts() {
    local d f
    for d in ${(f)"$(_dbd_font_dirs)"}; do
        for f in "$d"/*.flf(N); do print -r -- "${f:t:r}"; done
    done | sort -u
}

# Sets REPLY to the ANSI escape for color name $1 (empty for none/unknown).
_dbd_color_code() {
    case "$1" in
        red)    REPLY=$'\e[31m' ;;
        green)  REPLY=$'\e[32m' ;;
        yellow) REPLY=$'\e[33m' ;;
        blue)   REPLY=$'\e[34m' ;;
        purple) REPLY=$'\e[35m' ;;
        cyan)   REPLY=$'\e[36m' ;;
        orange) REPLY=$'\e[38;5;208m' ;;
        *)      REPLY="" ;;
    esac
}

# Writes VAR=value to the saved-settings file (replacing any earlier line).
_dbd_persist() {
    local var="$1" val="$2" tmp
    mkdir -p "${DBD_SETTINGS_FILE:h}" || return 1
    tmp="$DBD_SETTINGS_FILE.$$"
    { [[ -f "$DBD_SETTINGS_FILE" ]] && grep -v "^export $var=" "$DBD_SETTINGS_FILE"
      print -r -- "export $var=${(q)val}"; } > "$tmp" && mv "$tmp" "$DBD_SETTINGS_FILE"
    export "$var=$val"
}

# -------------------------------------------------------------- banner ----
print_dbd_banner() {
    [[ "$DBD_ENABLED" == true ]] || return 0
    if ! (( $+commands[figlet] )); then
        _dbd_err "figlet is not installed (e.g. 'sudo apt install figlet')"
        return 1
    fi

    local font="$DBD_FONT" color="$DBD_COLOR" width="$DBD_WIDTH" fonts dir name
    if [[ "$DBD_RANDOM_FONT" == true ]]; then
        fonts=(${(f)"$(_dbd_all_fonts)"})
        (( $#fonts )) && font="${fonts[RANDOM % $#fonts + 1]}"
    fi
    if [[ "$DBD_RANDOM_COLOR" == true ]]; then
        fonts=(red green yellow blue purple cyan orange lolcat)
        color="${fonts[RANDOM % $#fonts + 1]}"
    fi
    _dbd_find_font "$font" || { font=standard; _dbd_find_font "$font"; } || return 1
    dir="$REPLY"

    [[ "$width" == <-> ]] || width="${COLUMNS:-80}"
    name="${PWD:t}"
    [[ "$PWD" == "$HOME" ]] && name="~"
    [[ -z "$name" ]] && name="/"

    [[ "$DBD_CLEAR" == true ]] && clear
    local i
    for ((i = 0; i < ${DBD_PADDING:-0}; i++)); do print; done

    local art
    art=$(figlet -d "$dir" -f "$font" -w "$width" -- "$name") || return 1
    if [[ "$color" == lolcat ]] && (( $+commands[lolcat] )); then
        print -r -- "$art" | lolcat
    else
        _dbd_color_code "$color"
        if [[ -n "$REPLY" ]]; then print -r -- "${REPLY}${art}"$'\e[0m'; else print -r -- "$art"; fi
    fi

    for ((i = 0; i < ${DBD_PADDING:-0}; i++)); do print; done
}

# ------------------------------------------------------------- listing ----
show_directory_contents() {
    local flags=() header="📂 $PWD"
    [[ "$1" == --all ]] && flags=(-A)

    print_dbd_banner

    if [[ "$DBD_COLOR" == lolcat ]] && (( $+commands[lolcat] )); then
        print -r -- "$header" | lolcat
    else
        _dbd_color_code "$DBD_COLOR"
        print -r -- $'\e[1m'"${REPLY}${header}"$'\e[0m'
    fi

    print
    if command ls --color=always -d . >/dev/null 2>&1; then
        flags+=(--color=always)         # GNU ls
    else
        flags+=(-G); export CLICOLOR_FORCE=1   # BSD/macOS ls
    fi
    if (( $+commands[column] )); then
        command ls "${flags[@]}" | column
    else
        command ls "${flags[@]}"
    fi
}

dbs() { show_directory_contents; }
dba() { show_directory_contents --all; }
dbd-show() { print_dbd_banner; }

# --------------------------------------------------------------- fonts ----
dbd-list-fonts() {
    _dbd_all_fonts | column
}

# dbd-font [name]  - set the banner font (interactive menu without an argument)
dbd-font() {
    local -a fonts=(${(f)"$(_dbd_all_fonts)"})
    local choice="$1"
    (( $#fonts )) || { _dbd_err "no fonts found (is figlet installed?)"; return 1; }

    if [[ -z "$choice" ]]; then
        local i
        print "\nAvailable fonts:\n"
        for ((i = 1; i <= $#fonts; i++)); do
            printf "[%3d] %-22s" "$i" "${fonts[i]}"
            (( i % 3 == 0 )) && print
        done
        print "\n[  0] Cancel"
        read "choice?Select a font by number or name: " || return 1
        [[ -z "$choice" || "$choice" == 0 ]] && { print "Cancelled."; return 1; }
        [[ "$choice" == <-> ]] && choice="${fonts[choice]}"
    fi
    (( ${fonts[(Ie)$choice]} )) || { _dbd_err "unknown font: $choice"; return 1; }
    _dbd_persist DBD_FONT "$choice" && print "Font set to: $choice"
}

# dbd-ff <url>  - fetch a .flf file or a git repo of .flf fonts into the user font dir
dbd-ff() {
    local url="$1" tmp f name first=""
    [[ -n "$url" ]] || { _dbd_err "usage: dbd-ff <url-to-.flf | repo.git>"; return 1; }
    mkdir -p "$DBD_USER_FONT_DIR" || return 1

    if [[ "$url" == *.git ]]; then
        (( $+commands[git] )) || { _dbd_err "git is required"; return 1; }
        tmp=$(mktemp -d) || return 1
        if ! git clone --depth=1 --quiet "$url" "$tmp" 2>/dev/null; then
            _dbd_err "failed to clone $url"; rm -rf "$tmp"; return 1
        fi
        for f in "$tmp"/**/*.flf(.N); do
            head -c5 "$f" | grep -q '^flf2a' || continue
            cp "$f" "$DBD_USER_FONT_DIR/" && [[ -z "$first" ]] && first="${f:t:r}"
        done
        rm -rf "$tmp"
        [[ -n "$first" ]] || { _dbd_err "no .flf fonts found in $url"; return 1; }
    else
        # github.com/u/r/blob/b/f.flf -> raw.githubusercontent.com/u/r/b/f.flf
        if [[ "$url" =~ '^https://github\.com/([^/]+)/([^/]+)/blob/(.+)$' ]]; then
            url="https://raw.githubusercontent.com/${match[1]}/${match[2]}/${match[3]}"
        fi
        name="${${url:t}%%[?#]*}"
        [[ "$name" == *.flf ]] || { _dbd_err "not a .flf font: $name"; return 1; }
        tmp=$(mktemp) || return 1
        local fetched=1
        if (( $+commands[curl] )); then curl -fsSL -o "$tmp" -- "$url" && fetched=0
        elif (( $+commands[wget] )); then wget -q -O "$tmp" -- "$url" && fetched=0
        else _dbd_err "curl or wget is required"; rm -f "$tmp"; return 1; fi
        if (( fetched )) || ! head -c5 "$tmp" | grep -q '^flf2a'; then
            _dbd_err "download failed or not a figlet font: $url"; rm -f "$tmp"; return 1
        fi
        mv "$tmp" "$DBD_USER_FONT_DIR/$name" && first="${name:r}"
    fi

    print "Installed into $DBD_USER_FONT_DIR"
    _dbd_persist DBD_FONT "$first" && print "Font set to: $first"
}

# ------------------------------------------------------------- config ----
_dbd_config_show() {
    local v
    for v in ENABLED FONT COLOR RANDOM_FONT RANDOM_COLOR PADDING WIDTH CLEAR FONT_DIR; do
        printf "%-14s %s\n" "DBD_$v" "${(P)${:-DBD_$v}}"
    done
    print "\nsaved settings: $DBD_SETTINGS_FILE"
}

dbd-config() {
    local cmd="${1:-show}" key val
    case "$cmd" in
        show) _dbd_config_show ;;
        edit) ${EDITOR:-nano} "$DBD_SETTINGS_FILE"; source "$DBD_SETTINGS_FILE" ;;
        reset) rm -f "$DBD_SETTINGS_FILE"; print "Saved settings removed; open a new shell for defaults." ;;
        set)
            key="${(L)2}" val="$3"
            [[ -n "$key" && -n "$val" ]] || { _dbd_err "usage: dbd-config set <key> <value>"; return 1; }
            case "$key" in
                font)   dbd-font "$val" ;;
                color)
                    [[ "$val" == (red|green|yellow|blue|purple|cyan|orange|lolcat|none) ]] \
                        || { _dbd_err "color must be red|green|yellow|blue|purple|cyan|orange|lolcat|none"; return 1; }
                    _dbd_persist DBD_COLOR "$val" ;;
                random)
                    [[ "$val" == (on|off|true|false) ]] || { _dbd_err "random must be on|off"; return 1; }
                    [[ "$val" == (on|true) ]] && val=true || val=false
                    _dbd_persist DBD_RANDOM_FONT "$val" && _dbd_persist DBD_RANDOM_COLOR "$val" ;;
                random-font|random-color|enabled|clear)
                    [[ "$val" == (on|off|true|false) ]] || { _dbd_err "$key must be on|off"; return 1; }
                    [[ "$val" == (on|true) ]] && val=true || val=false
                    _dbd_persist "DBD_${${(U)key}//-/_}" "$val" ;;
                padding)
                    [[ "$val" == <-> ]] || { _dbd_err "padding must be a number"; return 1; }
                    _dbd_persist DBD_PADDING "$val" ;;
                width)
                    [[ "$val" == (auto|<->) ]] || { _dbd_err "width must be 'auto' or a number"; return 1; }
                    _dbd_persist DBD_WIDTH "$val" ;;
                *) _dbd_err "unknown key: $key (font color random random-font random-color padding width enabled clear)"; return 1 ;;
            esac ;;
        *) print "usage: dbd-config [show | set <key> <value> | edit | reset]" ; return 1 ;;
    esac
}

# --------------------------------------------------------------- hooks ----
_dbd_on_chpwd() {
    [[ "$DBD_ENABLED" == true && -o interactive && -t 1 ]] || return 0
    dbs
}

# Show the banner once for the initial directory, then stop listening.
_dbd_initial_banner() {
    add-zsh-hook -d precmd _dbd_initial_banner
    [[ "$DBD_ENABLED" == true && -t 1 ]] && dbs
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _dbd_on_chpwd
add-zsh-hook precmd _dbd_initial_banner
