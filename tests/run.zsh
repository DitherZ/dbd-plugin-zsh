#!/usr/bin/env zsh
# Test suite: runs the plugin in isolated shells with a throwaway $HOME.
# Usage: zsh tests/run.zsh   (needs zsh + figlet)

emulate -L zsh
ROOT="${${(%):-%x}:A:h:h}"
PLUGIN="$ROOT/dbd-plugin.plugin.zsh"
pass=0 fail=0

ok()   { (( pass++ )); print "  ok   $1"; }
bad()  { (( fail++ )); print "  FAIL $1"; [[ -n "$2" ]] && print -r -- "       $2"; }
check() { # check <name> <command...>; passes when the command succeeds
    local name="$1"; shift
    if out=$("$@" 2>&1); then ok "$name"; else bad "$name" "$out"; fi
}

# run <zsh code>: fresh interactive-ish shell, isolated HOME, plugin sourced
run() {
    local home; home=$(mktemp -d)
    HOME="$home" XDG_CONFIG_HOME= XDG_DATA_HOME= COLUMNS=100 \
        zsh -f -c "source ${(q)PLUGIN}; $1" 2>&1
    local rc=$?; rm -rf "$home"; return $rc
}

print "syntax"
check "plugin parses"  zsh -n "$PLUGIN"
check "config parses"  zsh -n "$ROOT/dbd-config.zsh"
[[ -f "$ROOT/dbd-plugin.plugin.zsh" ]] && ok "named for the oh-my-zsh loader" || bad "loader filename"

print "loading"
out=$(run 'print -r -- $DBD_FONT/$DBD_COLOR/$DBD_WIDTH')
[[ "$out" == "lowerb/lolcat/auto" ]] && ok "defaults applied" || bad "defaults applied" "$out"
out=$(HOME=$(mktemp -d) DBD_COLOR=red zsh -f -c "source ${(q)PLUGIN}; print \$DBD_COLOR")
[[ "$out" == red ]] && ok "env overrides defaults" || bad "env overrides defaults" "$out"
out=$(cd /tmp && run 'print -r -- $DBD_PLUGIN_DIR')
[[ "$out" == "$ROOT" ]] && ok "plugin dir detected from any cwd" || bad "plugin dir" "$out"

print "banner"
out=$(run 'DBD_COLOR=none DBD_CLEAR=false; cd /tmp; print_dbd_banner' | grep -c '[_|]')
(( out > 0 )) && ok "renders figlet art (fell back from missing font)" || bad "renders art"
out=$(run 'DBD_COLOR=red DBD_CLEAR=false DBD_FONT=standard; print_dbd_banner' | head -c 4 | od -An -c | tr -d ' ')
[[ "$out" == *"033"* ]] && ok "color escape emitted" || bad "color escape" "$out"
out=$(run 'DBD_ENABLED=false; print_dbd_banner')
[[ -z "$out" ]] && ok "disabled prints nothing" || bad "disabled prints nothing" "$out"
out=$(run 'DBD_COLOR=none DBD_CLEAR=false DBD_PADDING=2 DBD_FONT=standard; print_dbd_banner' | head -2 | tr -d '\n')
[[ -z "$out" ]] && ok "padding adds blank lines" || bad "padding" "$out"
out=$(run 'DBD_COLOR=none DBD_CLEAR=false DBD_RANDOM_FONT=true DBD_RANDOM_COLOR=true; for i in 1 2 3 4 5; do print_dbd_banner >/dev/null || exit 1; done; print fine')
[[ "$out" == fine ]] && ok "random font/color mode" || bad "random mode" "$out"
out=$(run 'DBD_COLOR=none DBD_CLEAR=false; cd /; print_dbd_banner' | grep -c .)
(( out > 0 )) && ok "works in / (empty basename)" || bad "root dir"

print "listing"
d=$(mktemp -d); touch "$d/alpha" "$d/.hidden"
out=$(run "DBD_COLOR=cyan DBD_CLEAR=false; cd ${(q)d}; dbs")
[[ "$out" == *alpha* && "$out" != *.hidden* ]] && ok "dbs lists visible files" || bad "dbs" "$out"
out=$(run "DBD_COLOR=cyan DBD_CLEAR=false; cd ${(q)d}; dba")
[[ "$out" == *.hidden* ]] && ok "dba lists hidden files" || bad "dba" "$out"
rm -rf "$d"

print "hooks"
d=$(mktemp -d)
out=$(run "DBD_COLOR=none DBD_CLEAR=false; _dbd_on_chpwd() { print HOOK }; add-zsh-hook -d chpwd _dbd_on_chpwd; add-zsh-hook chpwd _dbd_on_chpwd; cd ${(q)d}")
[[ "$out" == *HOOK* ]] && ok "chpwd hook registered/fires" || bad "chpwd hook" "$out"
out=$(run 'print -r -- ${chpwd_functions} ${precmd_functions}')
[[ "$out" == *_dbd_on_chpwd* && "$out" == *_dbd_initial_banner* ]] && ok "hooks installed" || bad "hooks installed" "$out"
out=$(run 'DBD_COLOR=none DBD_CLEAR=false; _dbd_initial_banner </dev/null; print -r -- $precmd_functions')
[[ "$out" != *_dbd_initial_banner* ]] && ok "initial-banner hook removes itself" || bad "self-removal" "$out"
rm -rf "$d"

print "dbd-config"
out=$(run 'dbd-config set color red && dbd-config set random on && dbd-config set padding 2 && dbd-config set width 90 && dbd-config set clear off; print $DBD_COLOR $DBD_RANDOM_FONT $DBD_PADDING $DBD_WIDTH $DBD_CLEAR')
[[ "$out" == *"red true 2 90 false"* ]] && ok "set applies immediately" || bad "set applies" "$out"
home=$(mktemp -d)
HOME=$home zsh -f -c "source ${(q)PLUGIN}; dbd-config set color green" >/dev/null 2>&1
out=$(HOME=$home zsh -f -c "source ${(q)PLUGIN}; print \$DBD_COLOR")
[[ "$out" == green ]] && ok "set persists across shells" || bad "persistence" "$out"
out=$(HOME=$home zsh -f -c "source ${(q)PLUGIN}; dbd-config reset >/dev/null; dbd-config show" | grep -c DBD_)
(( out >= 8 )) && ok "show lists settings" || bad "show" "$out"
rm -rf "$home"
run 'dbd-config set color mauve' >/dev/null && bad "rejects bad color" || ok "rejects bad color"
run 'dbd-config set width abc' >/dev/null && bad "rejects bad width" || ok "rejects bad width"
run 'dbd-config set nonsense 1' >/dev/null && bad "rejects unknown key" || ok "rejects unknown key"
out=$(run 'dbd-config set font standard; print $DBD_FONT')
[[ "$out" == *standard ]] && ok "set font" || bad "set font" "$out"
run 'dbd-font no-such-font' >/dev/null && bad "rejects unknown font" || ok "rejects unknown font"

print "fonts"
out=$(run 'dbd-list-fonts' | grep -c standard)
(( out > 0 )) && ok "dbd-list-fonts lists installed fonts" || bad "dbd-list-fonts"
out=$(run 'print 3 | dbd-font >/dev/null; print $DBD_FONT')
[[ -n "$out" && "$out" != lowerb ]] && ok "interactive dbd-font selection" || bad "interactive font" "$out"
d=$(mktemp -d); cp "$(figlet -I2)/standard.flf" "$d/mycustom.flf"
home=$(mktemp -d)
out=$(HOME=$home zsh -f -c "source ${(q)PLUGIN}; dbd-ff file://$d/mycustom.flf; print_dbd_banner" 2>&1 | tail -3)
[[ -f "$home/.local/share/dbd/fonts/mycustom.flf" ]] && ok "dbd-ff installs font into user dir" || bad "dbd-ff" "$out"
out=$(HOME=$home zsh -f -c "source ${(q)PLUGIN}; print \$DBD_FONT")
[[ "$out" == mycustom ]] && ok "dbd-ff activates the font" || bad "dbd-ff activate" "$out"
echo "not a font" > "$d/bad.flf"
HOME=$home zsh -f -c "source ${(q)PLUGIN}; dbd-ff file://$d/bad.flf" >/dev/null 2>&1 && bad "dbd-ff rejects non-font" || ok "dbd-ff rejects non-font"
(cd "$d" && git init -q fonts && cd fonts && mkdir sub && cp ../mycustom.flf sub/nested.flf && git add . && git -c user.email=t@t -c user.name=t commit -qm x)
mv "$d/fonts" "$d/fonts.git"
HOME=$home zsh -f -c "source ${(q)PLUGIN}; dbd-ff $d/fonts.git" >/dev/null 2>&1
[[ -f "$home/.local/share/dbd/fonts/nested.flf" ]] && ok "dbd-ff clones repos (recursive)" || bad "dbd-ff repo"
rm -rf "$d" "$home"

print "zoxide"
if (( $+commands[zoxide] && $+commands[script] )); then
    # zt <zshrc-lines> <shell-commands> [lines-before-plugin]: real interactive zsh on a pty; prints the banner header lines seen
    zt() {
        local h; h=$(mktemp -d); mkdir -p "$h/work/alpha-project" "$h/work/beta"
        print -r -- "$3
source ${(q)PLUGIN}
DBD_CLEAR=false DBD_COLOR=none DBD_FONT=standard
$1" > "$h/.zshrc"
        printf '%s\nexit\n' "$2" | HOME="$h" TERM=xterm COLUMNS=80 script -qec "zsh -i" /dev/null 2>&1 \
            | sed 's/\x1b\[[0-9;?]*[a-zA-Z]//g' | tr -d '\r' | grep -E '^📂'
        rm -rf "$h"
    }
    out=$(zt 'eval "$(zoxide init zsh)"' $'cd ~/work/alpha-project\ncd ~\nz alpha')
    [[ "${${(f)out}[-1]}" == *alpha-project ]] && ok "z triggers the banner" || bad "z" "$out"
    out=$(zt 'eval "$(zoxide init zsh)"' $'cd ~/work/alpha-project\ncd ~\nz alpha\nz -')
    [[ "${${(f)out}[-1]}" != *alpha-project ]] && (( ${#${(f)out}} == 5 )) && ok "z - triggers the banner" || bad "z -" "$out"
    out=$(zt 'eval "$(zoxide init zsh --cmd cd)"' $'cd ~/work/beta\ncd ~\ncd bet')
    [[ "${${(f)out}[-1]}" == *beta ]] && ok "zoxide --cmd cd replacement triggers the banner" || bad "--cmd cd" "$out"
    out=$(zt 'export _ZO_FZF_OPTS="--select-1 --exit-0"; eval "$(zoxide init zsh)"' $'cd ~/work/alpha-project\ncd ~\nzi alpha')
    [[ "${${(f)out}[-1]}" == *alpha-project ]] && ok "zi triggers the banner" || bad "zi" "$out"
    out=$(zt 'eval "$(zoxide init zsh)"' $'cd ~/work/alpha-project\ncd ~\nz nonexistent-xyz')
    (( ${#${(f)out}} == 3 )) && ok "failed z prints no banner" || bad "failed z" "$out"
    out=$(zt '' $'cd ~/work/alpha-project\ncd ~\nz alpha' 'eval "$(zoxide init zsh)"')
    [[ "${${(f)out}[-1]}" == *alpha-project ]] && ok "works when zoxide is initialised before the plugin" || bad "init order" "$out"
else
    print "  skip (needs zoxide and script)"
fi

print "\n$pass passed, $fail failed"
(( fail == 0 ))
