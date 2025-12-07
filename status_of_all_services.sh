#!/bin/bash

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

for LINGER_PATH in /var/lib/systemd/linger/service_*; do
    USER=$(basename "$LINGER_PATH")

    systemctl --user -M "$USER@" list-units \
        --type=service --no-pager --no-legend --output=json 2>/dev/null \
    | jq -r --arg user "$USER" '
        .[] | [$user, .active, .unit, .description] | @tsv
    ' \
    | while IFS=$'\t' read -r USERNAME ACTIVE UNIT DESC; do
        
        case "$ACTIVE" in
            active)   ICON="${GREEN}●${RESET}" UNIT="${GREEN}${UNIT}${RESET}" ;;
            inactive) ICON="${YELLOW}○${RESET}" UNIT="${YELLOW}${UNIT}${RESET}" ;;
            *)        ICON="${RED}✖${RESET}" UNIT="${RED}${UNIT}${RESET}" ;;
        esac

        printf "%b  %-12b  %-35s  %s\n" \
            "$ICON" "$UNIT (${USERNAME}):" "$DESC"
    done
done
