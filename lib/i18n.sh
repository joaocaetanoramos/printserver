# lib/i18n.sh — Minimal i18n for bash scripts
# Usage: . "$REPO_DIR/lib/i18n.sh" then t MSG_KEY
# PS_LANG env var overrides auto-detection.
# Fallback: English.

if [ -z "${PS_LANG:-}" ]; then
    case "${LANG:-en}" in
        pt*) PS_LANG="pt-BR" ;;
        *)   PS_LANG="en" ;;
    esac
fi

_ps_i18n_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# English first as full base, then locale overrides
[ -f "$_ps_i18n_dir/en.sh" ] && . "$_ps_i18n_dir/en.sh"
case "$PS_LANG" in
    pt-BR) [ -f "$_ps_i18n_dir/pt-BR.sh" ] && . "$_ps_i18n_dir/pt-BR.sh" ;;
esac

t() {
    local _var="MSG_$1"
    printf '%s' "${!_var:-[$1]}"
}

tf() {
    local _var="MSG_$1"
    shift
    printf "${!_var:-[$1]}" "$@"
}