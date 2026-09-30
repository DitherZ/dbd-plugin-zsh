# ═══ DBD SYSTEM PLUGIN — CONFIGURATION ══════════════════════════════════════ #
# ── dbd-config.zsh ── #
# Author : DitherZ/Blackflame
# Version: 2.0.0
# ─────────────────────────────────────────────────────────────────────────────

# ── Plugin Root ── #
export DBD_PLUGIN_DIR="$HOME/.oh-my-zsh/custom/plugins/dbd-plugin"

# ── Font Storage Directory ── #
export DBD_FONT_DIR="/usr/local/share/figlet"

# ── Default Font (must match a valid .flf in $DBD_FONT_DIR) ── #
export DBD_FONT="lowerb"

# ── Banner Color Mode ── #
# Options: gradient | lolcat | red | green | yellow | blue | purple | cyan | orange
export DBD_COLOR="gradient"

# ── Padding: blank lines above/below banner ── #
export DBD_PADDING="0"

# ── Random Font Mode: picks a random font on each cd ── #
export DBD_RANDOM_FONT="false"

# ── Random Color Mode: picks a random color on each cd ── #
export DBD_RANDOM_COLOR="false"

# ── Master Switch: false = plugin does nothing ── #
export DBD_ENABLED="true"

# ── Banner Width: passed to figlet -w ── #
export DBD_WIDTH="200"

# ── Clear Terminal on cd: true = runs clear before banner ── #
export DBD_CLEAR="false"

# ─────────────────────────────────────────────────────────────────────────────
