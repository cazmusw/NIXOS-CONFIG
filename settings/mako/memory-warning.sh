state="${XDG_RUNTIME_DIR:?}/mosaic-memory-warning.state"
status=$(awk '
    $1 == "MemTotal:" { total = $2 }
    $1 == "MemAvailable:" { available = $2 }
    $1 == "SwapTotal:" { swap_total = $2 }
    $1 == "SwapFree:" { swap_free = $2 }
    END {
        if (total <= 0 || available == "") exit 1
        percent = 100 * available / total
        level = percent <= 10 ? "low" : (percent >= 15 ? "recovered" : "hold")
        printf "%s %d %.1f %.1f\n", level, percent, swap_free / 1048576, swap_total / 1048576
    }
' "${1:-/proc/meminfo}") || exit 1
read -r level available swap_free swap_total <<< "$status"

case "$level" in
    recovered)
        rm -f -- "$state"
        ;;
    low)
        if [[ ! -e "$state" ]]; then
            notify-send --app-name="VibeShell" --urgency=critical \
                "Мало оперативной памяти" \
                "Доступно ${available}% ОЗУ. Свободно ${swap_free} из ${swap_total} ГиБ swap." &&
                : > "$state"
        fi
        ;;
esac
