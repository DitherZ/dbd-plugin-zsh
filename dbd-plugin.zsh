# ═══════════════════════════════════════════════════════════════════════════════
# ◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤ [ DBD System Plugin — Main ] ◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤
# ═══════════════════════════════════════════════════════════════════════════════
# Author : DitherZ/Blackflame
# Version: 2.0.0
# File   : dbd-plugin.zsh
# ───────────────────────────────────────────────────────────────────────────────

# ═══ PLUGIN PATHS ════════════════════════════════════════════════════════════ #

# ── Core Paths ── #
typeset -g DBD_ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
typeset -g DBD_PLUGIN_ROOT="$DBD_ZSH_CUSTOM/plugins/dbd-plugin"
typeset -g DBD_CONFIG_FILE="$DBD_PLUGIN_ROOT/dbd-config.zsh"

# ── Load Configuration ── #
if [[ -f "$DBD_CONFIG_FILE" ]]; then
    source "$DBD_CONFIG_FILE"
else
    print -P "%F{yellow}⚠️  DBD: Missing config — %f$DBD_CONFIG_FILE"
fi

# ═══ TEXT STYLING ════════════════════════════════════════════════════════════ #
BOLD="\e[1m"  ;  ITL="\e[3m"  ;  DIM="\e[2m"  ;  SHDW="\e[1:2m"
RC="\e[0m"    ; RCFG="\e[39m" ; RCBG="\e[49m" ;  RCFX="\e[22m"

# ═══ ANSI 256 COLORS (FG) ════════════════════════════════════════════════════ #
WHT="\e[38;5;231m"  ;  RED="\e[38;5;196m"  ;  GRN="\e[38;5;46m"
YLW="\e[38;5;226m"  ;  BLU="\e[38;5;21m"   ;  MAG="\e[38;5;201m"
CYN="\e[38;5;45m"   ;  PNK="\e[38;5;219m"  ;  GRY="\e[38;5;234m"

# ── Reset-prefix variants ── #
_WHT="\e[0;38;5;231m" ; _RED="\e[0;38;5;196m" ; _GRN="\e[0;38;5;46m"
_YLW="\e[0;38;5;226m" ; _BLU="\e[0;38;5;21m"  ; _MAG="\e[0;38;5;201m"
_CYN="\e[0;38;5;45m"  ; _PNK="\e[0;38;5;219m" ; _GRY="\e[0;38;5;234m"

# ═══ PILL SHELL COMPONENTS ═══════════════════════════════════════════════════ #
_L1="\e[1;38;5;234m◢"           ; _L2="\e[1;38;5;234;48;5;234m◤"
_R1="\e[23;39;38;5;0m"          ; _R2="\e[1;38;5;234;48;5;234m◢"
_R3="\e[0;1;38;5;234m◤"         ; _LBG="\e[22;3;48;5;234m"

# ═══ PRINT ABSTRACTIONS ══════════════════════════════════════════════════════ #
print_info() { printf "%b\n" "${_L1}${_L2}${_LBG}${CYN}INFO${_R1}${_R2}${_R3} ${_CYN} $1${RC}"; }
print_task() { printf "%b\n" "\n${_L1}${_L2}${_LBG}${MAG}TASK${_R1}${_R2}${_R3} ${_MAG} $1${RC}"; }
print_done() { printf "%b\n" "${_L1}${_L2}${_LBG}${GRN}DONE${_R1}${_R2}${_R3} ${_GRN} $1${RC}"; }
print_fail() { printf "%b\n" "\n${_L1}${_L2}${_LBG}${RED}FAIL${_R1}${_R2}${_R3} ${_RED} $1${RC}"; }
print_warn() { printf "%b\n" "${_L1}${_L2}${_LBG}${YLW}WARN${_R1}${_R2}${_R3} ${_YLW} $1${RC}"; }
user_input() { printf "%b\n" "${_L1}${_L2}${_LBG}${WHT}OPTION${_R1}${_R2}${_R3} ${_YLW}> ${RC}$1"; }
print_path() { printf  "%b"  "${ITL}$1${RC}"; }

# ═══ GRADIENT PRESETS ════════════════════════════════════════════════════════ #
typeset -ga DBD_GRADIENT_PRESETS=(
  "255;0;128:0;255;255"       "0;255;180:128;0;255"       "255;0;255:0;128;255"
  "0;255;128:255;0;200"       "255;80;0:255;220;0"        "255;0;0:255;140;0"
  "255;40;0:255;255;0"        "0;120;255:0;255;255"       "0;200;255:180;255;255"
  "0;80;255:120;0;255"        "0;255;0:0;255;150"         "0;255;100:0;150;0"
  "80;255;0:0;255;120"        "120;0;255:255;0;200"       "80;0;180:255;120;0"
  "180;0;255:0;180;255"       "255;94;0:255;0;150"        "255;0;120:255;200;0"
  "255;128;0:255;0;255"       "200;200;200:255;255;255"   "150;150;150:0;255;255"
)

# ═══ BANNER RENDER ═══════════════════════════════════════════════════════════ #

# ── _dbd_gradient_render: renders text with horizontal RGB gradient ── #
_dbd_gradient_render() {
    local text="$1"
    local font="${2:-$DBD_FONT}"
    local font_path="$DBD_FONT_DIR/${font}.flf"

    # ── Fallback font resolution ── #
    if [[ ! -f "$font_path" ]]; then
        font_path="/usr/share/figlet/${font}.flf"
    fi
    if [[ ! -f "$font_path" ]]; then
        font_path="$DBD_FONT_DIR/standard.flf"
    fi
    if [[ ! -f "$font_path" ]]; then
        print_warn "Font '${font}' not found — printing plain text"
        printf "%b\n" "${_CYN}${text}${RC}"
        return 0
    fi

    # ── Pick random gradient ── #
    local idx=$(( RANDOM % ${#DBD_GRADIENT_PRESETS[@]} + 1 ))
    local preset="${DBD_GRADIENT_PRESETS[$idx]}"

    local START_RGB END_RGB
    START_RGB="${preset%%:*}"
    END_RGB="${preset##*:}"

    local R1 G1 B1 R2 G2 B2
    IFS=";" read -r R1 G1 B1 <<< "$START_RGB"
    IFS=";" read -r R2 G2 B2 <<< "$END_RGB"

    # ── Generate figlet output ── #
    local FIGLET_OUTPUT
    FIGLET_OUTPUT="$(figlet -f "$font_path" -s -w "$DBD_WIDTH" "$text" 2>/dev/null)"

    if [[ -z "$FIGLET_OUTPUT" ]]; then
        printf "%b\n" "${_CYN}${text}${RC}"
        return 0
    fi

    # ── Measure max line width (pure ZSH) ── #
    local width=0
    while IFS= read -r line; do
        (( ${#line} > width )) && width=${#line}
    done <<< "$FIGLET_OUTPUT"
    (( width == 0 )) && width=1

    local denom=$(( width > 1 ? width - 1 : 1 ))
    local delta_r=$(( R2 - R1 ))
    local delta_g=$(( G2 - G1 ))
    local delta_b=$(( B2 - B1 ))
    local half=$(( denom / 2 ))

    # ── Render per-character gradient ── #
    local char r g b i

    while IFS= read -r line; do
        local line_len=${#line}
        for (( i=0; i<line_len; i++ )); do
            char="${line:$i:1}"
            if [[ "$char" == " " ]]; then
                printf " "
                continue
            fi
            r=$(( R1 + (delta_r * i + half) / denom ))
            g=$(( G1 + (delta_g * i + half) / denom ))
            b=$(( B1 + (delta_b * i + half) / denom ))
            printf "\e[38;2;%d;%d;%dm%s" "$r" "$g" "$b" "$char"
        done
        printf "\e[0m\n"
    done <<< "$FIGLET_OUTPUT"
}

# ── _dbd_plain_render: renders figlet text in a flat ANSI color ── #
_dbd_plain_render() {
    local text="$1"
    local color_code="$2"
    local font_path="$DBD_FONT_DIR/${DBD_FONT}.flf"

    [[ ! -f "$font_path" ]] && font_path="/usr/share/figlet/${DBD_FONT}.flf"
    [[ ! -f "$font_path" ]] && font_path="$DBD_FONT_DIR/standard.flf"
    [[ ! -f "$font_path" ]] && { printf "%b\n" "${color_code}${text}\e[0m"; return; }

    printf "%b" "${color_code}"
    figlet -f "$font_path" -s -w "$DBD_WIDTH" "$text" 2>/dev/null
    printf "\e[0m"
}

# ── _dbd_resolve_color: maps $DBD_COLOR to an ANSI code ── #
_dbd_resolve_color() {
    case "$DBD_COLOR" in
        red)    printf "\e[38;5;196m" ;;
        green)  printf "\e[38;5;46m"  ;;
        yellow) printf "\e[38;5;226m" ;;
        blue)   printf "\e[38;5;21m"  ;;
        purple) printf "\e[38;5;201m" ;;
        cyan)   printf "\e[38;5;45m"  ;;
        orange) printf "\e[38;5;208m" ;;
        *)      printf "\e[38;5;231m" ;;
    esac
}

# ═══ CORE BANNER PRINTER ═════════════════════════════════════════════════════ #
print_dbd_banner() {
    [[ "$DBD_ENABLED" != "true" ]] && return
    [[ -n "$_DBD_PRINTED" ]]       && return

    typeset -g _DBD_PRINTED=1

    # ── Optional clear ── #
    [[ "$DBD_CLEAR" == "true" ]] && clear

    # ── Padding above ── #
    local i
    (( DBD_PADDING > 0 )) && for (( i=0; i<DBD_PADDING; i++ )); do echo; done

    local current_dir
    current_dir="$(basename "$PWD")"

    # ── Random mode overrides ── #
    local active_font="$DBD_FONT"
    local active_color="$DBD_COLOR"

    if [[ "$DBD_RANDOM_FONT" == "true" ]]; then
        local -a all_fonts
        all_fonts=( "$DBD_FONT_DIR"/*.flf(N:t:r) )
        (( ${#all_fonts[@]} > 0 )) && active_font="${all_fonts[$(( RANDOM % ${#all_fonts[@]} + 1 ))]}"
    fi

    if [[ "$DBD_RANDOM_COLOR" == "true" ]]; then
        local -a color_opts=( gradient lolcat red green yellow blue purple cyan orange )
        active_color="${color_opts[$(( RANDOM % ${#color_opts[@]} + 1 ))]}"
    fi

    # ── Render banner ── #
    if [[ "$active_color" == "gradient" ]]; then
        _dbd_gradient_render "$current_dir" "$active_font"
    elif [[ "$active_color" == "lolcat" ]] && command -v lolcat >/dev/null 2>&1; then
        local font_path="$DBD_FONT_DIR/${active_font}.flf"
        [[ ! -f "$font_path" ]] && font_path="/usr/share/figlet/${active_font}.flf"
        figlet -f "$font_path" -s -w "$DBD_WIDTH" "$current_dir" 2>/dev/null | lolcat
    elif [[ "$active_color" == "lolcat" ]]; then
        # lolcat requested but not installed — fall through to gradient
        _dbd_gradient_render "$current_dir" "$active_font"
    else
        _dbd_plain_render "$current_dir" "$(_dbd_resolve_color)"
    fi

    # ── Padding below ── #
    (( DBD_PADDING > 0 )) && for (( i=0; i<DBD_PADDING; i++ )); do echo; done
}

# ═══ DIRECTORY LISTING ═══════════════════════════════════════════════════════ #
show_directory_contents() {
    unset _DBD_PRINTED

    local show_hidden=false
    [[ "$1" == "--all" ]] && show_hidden=true

    print_dbd_banner

    # ── Colored path header ── #
    printf "%b\n" "${_CYN}📂 ${PWD}${RC}"
    echo

    # ── Listing ── #
    if $show_hidden; then
        ls --color=always -A | column
    else
        ls --color=always | column
    fi
}

# ── Public shortcuts ── #
dbs() { show_directory_contents; }
dba() { show_directory_contents --all; }
dbd-show() { unset _DBD_PRINTED; print_dbd_banner; }

# ═══ FONT MANAGEMENT ═════════════════════════════════════════════════════════ #

# ── dbd-list-fonts: list all available fonts ── #
dbd-list-fonts() {
    local -a fonts
    fonts=( "$DBD_FONT_DIR"/*.flf(N:t:r) /usr/share/figlet/*.flf(N:t:r) )

    if (( ${#fonts[@]} == 0 )); then
        print_fail "No fonts found in $DBD_FONT_DIR or /usr/share/figlet"
        return 1
    fi

    print_info "Available fonts (${#fonts[@]} total):"
    echo

    local cols=4 total=${#fonts[@]}
    for (( i=1; i<=total; i++ )); do
        printf "%b[%02d]%b %-22s" "${_CYN}" "$i" "${RC}" "${fonts[$i]}"
        (( i % cols == 0 )) && echo
    done
    (( total % cols != 0 )) && echo
    echo
    print_info "Current font: $(print_path "$DBD_FONT")"
}

# ── dbd-font: interactive font selector ── #
dbd-font() {
    local -a fonts
    fonts=( "$DBD_FONT_DIR"/*.flf(N:t:r) /usr/share/figlet/*.flf(N:t:r) )

    if (( ${#fonts[@]} == 0 )); then
        print_fail "No fonts found."
        return 1
    fi

    dbd-list-fonts

    local cols=4 total=${#fonts[@]}
    printf "\n[00] Cancel\n\n"
    user_input "Select font by number:"
    local selection
    read -r selection

    if [[ "$selection" == "00" || -z "$selection" ]]; then
        print_warn "Font selection cancelled."
        return 0
    fi

    if ! [[ "$selection" =~ ^[0-9]+$ ]] || (( selection < 1 || selection > total )); then
        print_fail "Invalid selection: $selection"
        return 1
    fi

    local selected="${fonts[$selection]}"
    sed -i "s|^export DBD_FONT=.*|export DBD_FONT=\"$selected\"|" "$DBD_CONFIG_FILE"
    source "$DBD_CONFIG_FILE"
    print_done "Font set to: $(print_path "$selected")"

    # ── Preview ── #
    echo
    _dbd_gradient_render "$(basename "$PWD")" "$selected"
}

# ── dbd-ff: fetch a font from URL or git repo ── #
dbd-ff() {
    local url="$1"

    if [[ -z "$url" ]]; then
        print_fail "Usage: dbd-ff <url|git-repo.git>"
        return 1
    fi

    mkdir -p "$DBD_FONT_DIR"

    # ── Convert GitHub blob links to raw ── #
    [[ "$url" == *"github.com"*"blob"* ]] && url="${url/blob/raw}"

    # ── Case 1: Git repository ── #
    if [[ "$url" =~ \.git$ ]]; then
        local temp_dir
        temp_dir="$(mktemp -d)"
        print_task "Cloning font repository..."

        if ! git clone --depth=1 "$url" "$temp_dir" >/dev/null 2>&1; then
            print_fail "Failed to clone: $url"
            rm -rf "$temp_dir"
            return 1
        fi

        # ── Recurse into subdirectories for fonts ── #
        local first_font=""
        local count=0
        while IFS= read -r font_file; do
            local font_name
            font_name="$(basename "$font_file")"
            cp "$font_file" "$DBD_FONT_DIR/$font_name"
            [[ -z "$first_font" ]] && first_font="${font_name%.*}"
            (( count++ ))
        done < <(find "$temp_dir" -type f \( -name "*.flf" -o -name "*.fig" -o -name "*.tlf" \) 2>/dev/null)

        rm -rf "$temp_dir"

        if [[ -z "$first_font" ]]; then
            print_fail "No valid font files found in repository."
            return 1
        fi

        print_done "Installed $count font(s). Setting active font to: $(print_path "$first_font")"
        sed -i "s|^export DBD_FONT=.*|export DBD_FONT=\"$first_font\"|" "$DBD_CONFIG_FILE"
        source "$DBD_CONFIG_FILE"
        return 0
    fi

    # ── Case 2: Direct file download ── #
    local font_name
    font_name="$(basename "$url")"
    local font_ext="${font_name##*.}"

    if ! [[ "$font_ext" =~ ^(flf|fig|tlf)$ ]]; then
        print_fail "Unsupported extension: .$font_ext (expected .flf, .fig, or .tlf)"
        return 1
    fi

    print_task "Downloading $(print_path "$font_name")..."

    if wget -q -O "$DBD_FONT_DIR/$font_name" "$url"; then
        local base="${font_name%.*}"
        sed -i "s|^export DBD_FONT=.*|export DBD_FONT=\"$base\"|" "$DBD_CONFIG_FILE"
        source "$DBD_CONFIG_FILE"
        print_done "Font saved to $(print_path "$DBD_FONT_DIR/$font_name") and set as active."
    else
        print_fail "Download failed: $url"
        rm -f "$DBD_FONT_DIR/$font_name"
        return 1
    fi
}

# ═══ CONFIGURATION MANAGER ═══════════════════════════════════════════════════ #

# ── dbd-config: subcommand dispatcher ── #
dbd-config() {
    local subcmd="$1"
    local key="$2"
    local val="$3"

    case "$subcmd" in

        # ── dbd-config set <key> <value> ── #
        set)
            if [[ -z "$key" || -z "$val" ]]; then
                print_fail "Usage: dbd-config set <key> <value>"
                print_info "Keys: font | color | padding | random | clear | enabled | width"
                return 1
            fi

            local config_key=""
            case "$key" in
                font)    config_key="DBD_FONT" ;;
                color)   config_key="DBD_COLOR" ;;
                padding) config_key="DBD_PADDING" ;;
                random)
                    # 'random' sets both font and color random modes
                    sed -i "s|^export DBD_RANDOM_FONT=.*|export DBD_RANDOM_FONT=\"$val\"|" "$DBD_CONFIG_FILE"
                    sed -i "s|^export DBD_RANDOM_COLOR=.*|export DBD_RANDOM_COLOR=\"$val\"|" "$DBD_CONFIG_FILE"
                    source "$DBD_CONFIG_FILE"
                    print_done "Random mode set to: $val"
                    return 0
                    ;;
                random-font)  config_key="DBD_RANDOM_FONT" ;;
                random-color) config_key="DBD_RANDOM_COLOR" ;;
                clear)        config_key="DBD_CLEAR" ;;
                enabled)      config_key="DBD_ENABLED" ;;
                width)        config_key="DBD_WIDTH" ;;
                *)
                    print_fail "Unknown key: $key"
                    print_info "Valid keys: font | color | padding | random | random-font | random-color | clear | enabled | width"
                    return 1
                    ;;
            esac

            sed -i "s|^export ${config_key}=.*|export ${config_key}=\"${val}\"|" "$DBD_CONFIG_FILE"
            source "$DBD_CONFIG_FILE"
            print_done "Set ${config_key} = $val"
            ;;

        # ── dbd-config show ── #
        show)
            print_info "Current DBD Configuration:"
            echo
            printf "  %b%-16s%b %s\n" "${_CYN}" "Font"         "${RC}" "$DBD_FONT"
            printf "  %b%-16s%b %s\n" "${_CYN}" "Color"        "${RC}" "$DBD_COLOR"
            printf "  %b%-16s%b %s\n" "${_CYN}" "Padding"      "${RC}" "$DBD_PADDING"
            printf "  %b%-16s%b %s\n" "${_CYN}" "Width"        "${RC}" "$DBD_WIDTH"
            printf "  %b%-16s%b %s\n" "${_CYN}" "Random Font"  "${RC}" "$DBD_RANDOM_FONT"
            printf "  %b%-16s%b %s\n" "${_CYN}" "Random Color" "${RC}" "$DBD_RANDOM_COLOR"
            printf "  %b%-16s%b %s\n" "${_CYN}" "Clear on cd"  "${RC}" "$DBD_CLEAR"
            printf "  %b%-16s%b %s\n" "${_CYN}" "Enabled"      "${RC}" "$DBD_ENABLED"
            printf "  %b%-16s%b %s\n" "${_CYN}" "Font Dir"     "${RC}" "$DBD_FONT_DIR"
            echo
            ;;

        # ── dbd-config reset ── #
        reset)
            user_input "Reset all DBD settings to defaults? [y/N]"
            local confirm
            read -r confirm
            if [[ "${confirm:l}" == "y" ]]; then
                sed -i \
                    -e 's|^export DBD_FONT=.*|export DBD_FONT="lowerb"|' \
                    -e 's|^export DBD_COLOR=.*|export DBD_COLOR="gradient"|' \
                    -e 's|^export DBD_PADDING=.*|export DBD_PADDING="0"|' \
                    -e 's|^export DBD_RANDOM_FONT=.*|export DBD_RANDOM_FONT="false"|' \
                    -e 's|^export DBD_RANDOM_COLOR=.*|export DBD_RANDOM_COLOR="false"|' \
                    -e 's|^export DBD_CLEAR=.*|export DBD_CLEAR="false"|' \
                    -e 's|^export DBD_ENABLED=.*|export DBD_ENABLED="true"|' \
                    -e 's|^export DBD_WIDTH=.*|export DBD_WIDTH="200"|' \
                    "$DBD_CONFIG_FILE"
                source "$DBD_CONFIG_FILE"
                print_done "Configuration reset to defaults."
            else
                print_warn "Reset cancelled."
            fi
            ;;

        # ── dbd-config help or no args ── #
        help|"")
            print_info "DBD Config — Usage:"
            echo
            printf "  %bdbd-config show%b           — show current settings\n"        "${_CYN}" "${RC}"
            printf "  %bdbd-config set <key> <val>%b — update a setting\n"            "${_CYN}" "${RC}"
            printf "  %bdbd-config reset%b           — restore all defaults\n"        "${_CYN}" "${RC}"
            printf "  %bdbd-config edit%b            — open config in \$EDITOR\n"     "${_CYN}" "${RC}"
            echo
            printf "  %bKeys:%b font | color | padding | width | random | random-font | random-color | clear | enabled\n" "${_YLW}" "${RC}"
            printf "  %bColors:%b gradient | lolcat | red | green | yellow | blue | purple | cyan | orange\n" "${_YLW}" "${RC}"
            echo
            ;;

        # ── dbd-config edit ── #
        edit)
            ${EDITOR:-nano} "$DBD_CONFIG_FILE"
            source "$DBD_CONFIG_FILE"
            print_done "Config reloaded."
            ;;

        # ── Unknown subcommand ── #
        *)
            print_fail "Unknown subcommand: $subcmd"
            dbd-config help
            return 1
            ;;
    esac
}

# ═══ ZSH HOOKS & TRIGGERS ════════════════════════════════════════════════════ #

# ── Track directory changes (chpwd hook) ── #
typeset -g _DBD_OLD_PWD="$PWD"

_dbd_chpwd() {
    if [[ "$_DBD_OLD_PWD" != "$PWD" ]]; then
        _DBD_OLD_PWD="$PWD"
        if [[ "$DBD_ENABLED" == "true" ]]; then
            dbs
        fi
    fi
}

# ── Initial banner — fires once on first prompt, not on every redraw ── #
typeset -g _DBD_INIT_DONE="false"

_dbd_precmd() {
    if [[ "$_DBD_INIT_DONE" == "false" ]]; then
        _DBD_INIT_DONE="true"
        _DBD_OLD_PWD="$PWD"
        [[ "$DBD_ENABLED" == "true" ]] && dbs
    fi
}

# ── Register hooks ── #
autoload -U add-zsh-hook
add-zsh-hook chpwd  _dbd_chpwd
add-zsh-hook precmd _dbd_precmd

# ═══════════════════════════════════════════════════════════════════════════════
