#!/bin/bash

# General settings
# ----------------

# Check for dependencies.  Fail if unmet.
_checkdep() {
    command -v "$1" > /dev/null || { echo "Missing dependency: $1"; exit 1; }
}

_checkdep bspwm
_checkdep lemonbar
_checkdep xdo

# Kill any running lemonbar
pgrep -x lemonbar > /dev/null && pkill -x lemonbar &

# DO NOT EDIT the name of this parameter (checked by other scripts).
melonpanel_height=22

# Colours
# -------
# Taken from my Modus Vivendi (Modus themes for Emacs):
# https://gitlab.com/protesilaos/modus-themes
bg_main="#000000"
bg_alt="#181a20"
fg_main="#ffffff"
fg_alt="#a8a8a8"
red="#ff8059"
green="#58dd13"
yellow="#f0ce43"

# Fonts (upstream lemonbar only supports bitmap fonts)
# ----------------------------------------------------
if [ -n "$(fc-list FiraGO)" ]; then
    fontmain='FiraGO:style=regular:size=11'
    fontbold='FiraGO:style=bold:size=11'
else
    fontmain='-misc-fixed-medium-r-normal--13-120-75-75-c-80-iso10646-1'
    fontbold='-misc-fixed-bold-r-normal--13-120-75-75-c-80-iso10646-1'
fi

# Panel modules
# -------------
#
# NOTE all functions that are meant to pipe their output to the panel
# will echo a majuscule (letter A-Z).  This is done to easily retrieve
# their output from the named pipe.  The letter has to be unique and,
# ideally, use common words that denote the function of the content of
# the command such as e.g. D for Date, N for Network...  Where this
# would lead to conflicts, find a synonym or something close enough.
#
# The various sequences %{..} are part of lemonbar's syntax for styling
# the output.  See `man lemonbar`.



# Battery status.
_battery() {
    command -v acpi > /dev/null || return 1

    local label command status output

    label='B:'
    # Using Bash parameter expansion here.  Just experimenting…
    command="$(acpi -b)"
    status="${command#*: }"    # Delete up the colon and following space
    status="${status:0:1}"     # Use first character
    output="${command#*, }"    # Delete up to first comma
    output="${output%,*}"      # Same but read from the end

    # The $battery_status will tell us if it is (C)harging or
    # (D)ischaging.  If dischange level reaches 0-9, the whole indicator
    # will turn to a bright colour.  Otherwise, discharging will be
    # denoted by a coloured output of the current level followed by the
    # minus sign.
    case "$status" in
        'C')
            echo "%{F$fg_alt}${label}%{F-} %{F$green}${output}+%{F-}"
            ;;
        'D')
            case "${output%?}" in
                [0-9])
                    echo "%{B$yellow}%{F$bg_main} $label ${output}- %{F-}%{B-}"
                    ;;
                *)
                    echo "%{F$fg_alt}${label}%{F-} %{F$yellow}${output}-%{F-}"
                    ;;
            esac
            ;;
        *)
            echo "%{F$fg_alt}${label}%{F-} ${output}"
            ;;
    esac
}

# Core temperature.
_temperature() {
    command -v acpi > /dev/null || return 1

    local label command output

    label='T:'
    # Use Bash parameter expansion again…
    command="$(acpi -t)"
    output="${command#*: }"
    output="${output#*, }"
    output="${output:0:2}"

    # Up to 59 degrees celsius keep text colour same as default.  60-79
    # turn the colour red on normal background.  Else turn the whole
    # indicator red.
    case "$output" in
        [12345][0-9])
            echo "%{F$fg_alt}${label}%{F-} ${output}°C"
            ;;
        [67][0-9])
            echo "%{F$fg_alt}${label}%{F-} %{F$red}${output}°C%{F-}"
            ;;
        *)
            echo "%{F$bg_main}%{B$red} $label ${output}°C %{B-}%{F-}"
            ;;
    esac
}

# Check the sound volume and whether it is muted or not.  Output the
# appropriate indicators.
_volume() {
    command -v amixer > /dev/null || return 1

    local label status output

    label='V:'
    # Could not do this with just parameter expansions…
    status="$(amixer get Master | awk -F'[][]' '/%/{print $2","$4;exit}')"
    output="${status%,*}"

    case "${status#*%}" in
        'off') echo "%{F$fg_alt}${label}%{F-} $output (Muted)" ;;
        *)     echo "%{F$fg_alt}${label}%{F-} $output"         ;;
    esac
}

# Keyboard indicators.
_keyboard() {
    local kd_layout kb_caps

    # Checks if the current layout is set to Greek (adjust accordingly).
    # If yes, the indicator will be displayed, else it is assumed that
    # English is being used.
    if [ "$(setxkbmap -query | sed '/^l/!d ; s,.*:[\ ]*,,g')" = 'gr' ]; then
        kb_layout="%{B$bg_alt}%{U$fg_main}%{+u} EL %{-u}%{U-}%{B-}"
    fi

    # Show an indicator if Caps Lock is on.
    if [ "$(xset -q | awk '/Caps/ { print $4 }')" = 'on' ]; then
        kb_caps="%{B$bg_alt}%{U$fg_main}%{+u} CAPS %{-u}%{U-}%{B-}"
    fi

    # Print the indicators next each other in the given order.
    printf "%s %s" "$kb_layout" "$kb_caps"
}

_datetime() {
    local label output

    label='D:'
    output="$(date +'%a %-d %b %H:%M')"

    echo "%{F$fg_alt}${label}%{F-} $output"
}

# Include all modules in a single infinite loop that iterates every
# second (adjust interval accordingly, as it can be taxing on system
# resources).
_modules() {
    while true; do
        echo "B" "$(_battery)"
        echo "T" "$(_temperature)"
        echo "D" "$(_datetime)"
        echo "K" "$(_keyboard)"
        echo "V" "$(_volume)"
        sleep 1s
    done
}

# Piping and reading the output of the modules
# --------------------------------------------

# The design of this section has been heavily inspired/adapted from the
# examples provided by upstream bspwm.

# set path to named pipe used to store process data for these operations
melonpanel_fifo='/tmp/melonpanel.fifo'

# make sure you delete any existing named pipe
[ -e "$melonpanel_fifo" ] && rm "$melonpanel_fifo"

# create a new named pipe
mkfifo "$melonpanel_fifo"

# pipe the output of the modules to the fifo
_modules > "$melonpanel_fifo" &
bspc subscribe report > "$melonpanel_fifo" &

# Read the content of the fifo file.  We differentiate between modules
# based on the majuscule (letter A-Z) they piped into melonpanel_fifo
# (see modules above).  Here we just add a shorter variable to each
# module, which helps position it on the panel (the last printf).
_melonpanel() {
    while read -r line ; do
        case $line in
            B*)
                # battery status
                bat="${line#?}"
                ;;
            T*)
                # temperature
                therm="${line#?}"
                ;;
            D*)
                # current date and time
                date="${line#?}"
                ;;
            K*)
                # keyboard layout (en or gr)
                key="${line#?}"
                ;;
            V*)
                # volume level
                vol="${line#?}"
                ;;
            W*)
                # bspwm's state
                wm=
                IFS=':'
                set -- ${line#?}
                while [ "$#" -gt 0 ] ; do
                    item="$1"
                    name="${item#?}"
                    case "$item" in
                        [mMfFoOuULG]*)
                            case "$item" in
                                m*)
                                    # monitor
                                    FG="$fg_alt" # needed to avoid invalid colour error
                                    on_focused_monitor=
                                    name=
                                    ;;
                                M*)
                                    # focused monitor
                                    FG="$fg_alt" # needed to avoid invalid colour error
                                    on_focused_monitor=1
                                    name=
                                    ;;
                                # {Free,Occupied,Urgent} focused
                                [FOU]*)
                                    if [ -n "$on_focused_monitor" ]; then
                                        name="%{T2}${name/*/[$name]}%{T-}"
                                        FG="$fg_main"
                                    else
                                        name="${name/*/ $name-}"
                                        FG="$fg_alt"
                                    fi
                                    ;;
                                # {free,occupied,urgent} unfocused
                                f*)
                                    FG="$fg_alt"
                                    name="${name/*/ $name }"
                                    ;;
                                o*)
                                    FG="$fg_alt"
                                    name="${name/*/ $name^}"
                                    ;;
                                u*)
                                    FG="$red"
                                    name="${name/*/ $name\#}"
                                    ;;
                                # desktop layout for monocle and node flags
                                LM|G*?)
                                    FG="$fg_main"
                                    name="${name/*/ $name }"
                                    ;;
                                *)
                                    FG="$fg_alt"
                                    name="${name/*/ * }"
                                    ;;
                            esac
                            wm="${wm}%{F$FG}${name}%{F-}"
                            ;;
                    esac
                    shift
                done
        esac

        _panel_layout() {
            echo "%{l}$wm%{r}$key $bat $therm $vol $date "
        }

        if [ "$(bspc query -M | wc -l)" -gt 1 ]; then
            printf "%s%s\n" "%{Sf}$(_panel_layout)" "%{Sl}$(_panel_layout)"
        else
            printf "%s\n" "%{Sf}$(_panel_layout)"
        fi
    done
}

# Launch the panel with the given parameters
# ------------------------------------------

# NOTE the syntax for the background value.  If you want transparency,
# just replace "ff" with a lower value: "00" means no opacity.  This is
# hexadecimal notation: 0-9, a-f, A-F.
_melonpanel < "$melonpanel_fifo" \
    | lemonbar -b -u 1 -p -g "x${melonpanel_height}" \
               -F "$fg_main" -B "#ff${bg_main:1}" \
               -f "$fontmain" -f "$fontbold" -n "Melonpanel" &

# Hide panel when windows are in full screen mode.  This does not work
# all the time, especially with lower `sleep` values, requiring a
# re-launch of melonpanel (pkill -x melonpanel && melonpanel).  I have
# yet to find a robust solution.
#
# Source of this snippet (with minor adapatations by me):
# https://github.com/baskerville/bspwm/issues/484
until bar_id=$(xdo id -a 'Melonpanel'); do
    sleep 0.1s
done

xdo below -t $(xdo id -n root) $bar_id &
