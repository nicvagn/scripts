#!/usr/bin/env bash
# cpu_monitor.sh — live CPU temp & frequency monitor for Guix Linux
# Reads directly from /sys (no lm-sensors needed)
# Usage: bash cpu_monitor.sh [interval_seconds]

INTERVAL="${1:-3}"

# ANSI colors
RED='\033[0;31m'
YEL='\033[0;33m'
GRN='\033[0;32m'
CYN='\033[0;36m'
BLU='\033[0;34m'
BLD='\033[1m'
RST='\033[0m'

# Find CPU temperature source (works across Intel, AMD, and most ARM)
find_temp_source() {
    # Prefer coretemp / k10temp / zenpower; fall back to any hwmon with temp1_input
    for hwmon in /sys/class/hwmon/hwmon*; do
        name_file="$hwmon/name"
        [[ -f "$name_file" ]] || continue
        name=$(cat "$name_file" 2>/dev/null)
        case "$name" in
            coretemp|k10temp|zenpower|cpu_thermal|soc_thermal)
                echo "$hwmon"
                return
                ;;
        esac
    done
    # Generic fallback: first hwmon with a temp1_input
    for hwmon in /sys/class/hwmon/hwmon*; do
        [[ -f "$hwmon/temp1_input" ]] && echo "$hwmon" && return
    done
    echo ""
}

# Collect all temperature labels + paths from a hwmon dir
collect_temps() {
    local hwmon="$1"
    local -n out_labels=$2
    local -n out_paths=$3
    out_labels=()
    out_paths=()
    for f in "$hwmon"/temp*_input; do
        [[ -f "$f" ]] || continue
        base="${f%_input}"
        num="${base##*temp}"
        label_file="${base}_label"
        if [[ -f "$label_file" ]]; then
            label=$(cat "$label_file" 2>/dev/null)
        else
            label="Sensor $num"
        fi
        out_labels+=("$label")
        out_paths+=("$f")
    done
}

# Read one temperature in C (sysfs gives millidegrees)
read_temp_c() {
    local path="$1"
    local raw
    raw=$(cat "$path" 2>/dev/null) || { echo "N/A"; return; }
    awk "BEGIN { printf \"%.1f\", $raw / 1000 }"
}

# Color-code temperature
temp_color() {
    local t="$1"
    local n
    n=$(awk "BEGIN { printf \"%d\", $t + 0 }")
    if   (( n >= 85 )); then echo -n "${RED}"
    elif (( n >= 70 )); then echo -n "${YEL}"
    else                     echo -n "${GRN}"
    fi
}

# Read CPU frequency for each core (kHz -> GHz)
read_freqs() {
    local -n out_freqs=$1
    out_freqs=()
    local i=0
    for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq; do
        [[ -f "$f" ]] || continue
        khz=$(cat "$f" 2>/dev/null)
        ghz=$(awk "BEGIN { printf \"%.2f\", $khz / 1000000 }")
        out_freqs+=("$ghz")
        (( i++ ))
        # Cap at 16 cores for display sanity
        (( i >= 16 )) && break
    done
}

# Simple horizontal bar (0–100 scale, 20 chars wide)
bar() {
    local val="$1"   # numeric, 0–100
    local max="${2:-100}"
    local width=20
    local filled
    filled=$(awk "BEGIN { printf \"%d\", ($val / $max) * $width }")
    (( filled > width )) && filled=$width
    local empty=$(( width - filled ))
    printf '['
    printf '%0.s█' $(seq 1 $filled 2>/dev/null) 2>/dev/null
    # fallback if seq is slow
    local s=""; for ((j=0;j<filled;j++)); do s+='█'; done; printf '%s' "$s"
    local e=""; for ((j=0;j<empty;j++));  do e+='░'; done; printf '%s' "$e"
    printf ']'
}

# ── Setup ──────────────────────────────────────────────────────────────────

HWMON=$(find_temp_source)
if [[ -z "$HWMON" ]]; then
    echo -e "${RED}Error:${RST} No hwmon temperature source found under /sys/class/hwmon."
    echo "You may need to load the appropriate kernel module, e.g.:"
    echo "  modprobe coretemp    # Intel"
    echo "  modprobe k10temp     # AMD"
    exit 1
fi

HWMON_NAME=$(cat "$HWMON/name" 2>/dev/null || echo "unknown")

# Get max/crit temp for bar scaling (optional)
TEMP_MAX=100
[[ -f "$HWMON/temp1_crit" ]] && TEMP_MAX=$(awk "BEGIN { printf \"%d\", $(cat "$HWMON/temp1_crit") / 1000 }")

# ── Main loop ──────────────────────────────────────────────────────────────

trap 'tput cnorm; echo; exit 0' INT TERM
tput civis   # hide cursor

while true; do
    declare -a T_LABELS T_PATHS FREQS
    collect_temps "$HWMON" T_LABELS T_PATHS
    read_freqs FREQS

    # Move cursor to top-left; clear screen on first pass
    tput cup 0 0

    echo -e "${BLD}${CYN}╔════════════════════════════════════════════════════════════════════════${RST}"
    printf "${BLD}${CYN}║${RST}  ${BLD}CPU Monitor${RST}  ·  source: %-26s${BLD}${CYN}${RST}\n" "$HWMON_NAME"
    printf "${BLD}${CYN}║${RST}  Refresh: ${INTERVAL}s  ·  %s%-35s${BLD}${CYN}${RST}\n" "" "$(date '+%H:%M:%S')"
    echo -e "${BLD}${CYN}╠════════════════════════════════════════════════════════════════════════${RST}"

    # ── Temperatures ──────────────────────────────────────────────────────
    echo -e "${BLD}${CYN}║${RST}  ${BLD}Temperatures${RST}"
    for i in "${!T_LABELS[@]}"; do
        tc=$(read_temp_c "${T_PATHS[$i]}")
        if [[ "$tc" == "N/A" ]]; then
            printf "${BLD}${CYN}║${RST}  %-16s  N/A${RST}\n" "${T_LABELS[$i]}"
        else
            col=$(temp_color "$tc")
            pct=$(awk "BEGIN { printf \"%d\", ($tc / $TEMP_MAX) * 100 }")
            (( pct > 100 )) && pct=100
            printf "${BLD}${CYN}║${RST}  ${BLD}%-16s${RST}  ${col}%5s°C${RST}  " "${T_LABELS[$i]}" "$tc"
            printf '%s' "$(bar "$pct")"
            printf "  ${RST}\n"
        fi
    done

    # ── Frequencies ───────────────────────────────────────────────────────
    if [[ ${#FREQS[@]} -gt 0 ]]; then
        MAX_GHZ=6.0   # adjust if you have a faster CPU

        echo -e "${BLD}${CYN}╠════════════════════════════════════════════════════════════════════════${RST}"
        echo -e "${BLD}${CYN}║      ${RST}  ${BLD}Core Frequencies (GHz)${RST}"

        cols=2
        total=${#FREQS[@]}
        for (( i=0; i<total; i+=cols )); do
            line="║  "
            for (( j=0; j<cols && i+j<total; j++ )); do
                idx=$(( i + j ))
                ghz="${FREQS[$idx]}"
                pct=$(awk "BEGIN { printf \"%d\", ($ghz / $MAX_GHZ) * 100 }")
                (( pct > 100 )) && pct=100
                freq_col="${BLU}"
                (( $(awk "BEGIN{printf \"%d\",$ghz >= $MAX_GHZ * 0.85}") )) && freq_col="${YEL}"
                line+=$(printf "${BLD}Core%-2d${RST} ${freq_col}%4s GHz${RST} " "$idx" "$ghz")
            done
            # Pad to fixed width
            printf "${BLD}${CYN}║${RST}  %-50s${BLD}${CYN}${RST}\n" \
                "$(printf "${BLD}Core%-2d${RST} ${BLU}%4s GHz${RST}  " "${i}" "${FREQS[$i]}")$(
                    j2=$((i+1))
                    [[ $j2 -lt $total ]] && printf "${BLD}Core%-2d${RST} ${BLU}%4s GHz${RST}" "$j2" "${FREQS[$j2]}"
                )"
        done
    fi

    echo -e "${BLD}${CYN}╠════════════════════════════════════════════════════════════════════════${RST}"
    echo -e "${BLD}${CYN}║      ${RST}  ${GRN}≤69°C OK${RST}  ${YEL}70–84°C Warm${RST}  ${RED}≥85°C Hot${RST}"
    echo -e "${BLD}${CYN}╚════════════════════════════════════════════════════════════════════════${RST}"
    echo -e "  Press ${BLD}Ctrl+C${RST} to exit"

    sleep "$INTERVAL"
    tput clear 2>/dev/null || clear
done
