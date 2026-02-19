#!/bin/bash

# --- تشخیص خودکار رابط شبکه ---
INTERFACE=$(ip route get 8.8.8.8 | awk '{print $5; exit}')

# --- رنگ‌ها ---
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
PINK='\033[1;35m'
NC='\033[0m'

trap "tput cnorm; exit" INT
tput civis

while true; do
    # آمار لحظه اول
    R1=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
    T1=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
    
    sleep 1
    
    # آمار لحظه دوم
    R2=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
    T2=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

    # محاسبات سرعت و حجم
    DL_SPEED=$(awk "BEGIN {printf \"%.2f\", ($R2-$R1)/1024/1024}")
    UL_SPEED=$(awk "BEGIN {printf \"%.2f\", ($T2-$T1)/1024/1024}")
    DL_TOTAL=$(awk "BEGIN {printf \"%.2f\", $R2/1024/1024/1024}")
    UL_TOTAL=$(awk "BEGIN {printf \"%.2f\", $T2/1024/1024/1024}")

    # شمارش کانکشن‌ها
    HTTPS_1=$(ss -nt state established '( sport = :443 )' | grep -v Recv-Q | wc -l)
    HTTPS_2=$(ss -nt state established '( sport = :2053 )' | grep -v Recv-Q | wc -l)
    HTTP_1=$(ss -nt state established '( sport = :80 )' | grep -v Recv-Q | wc -l)

    clear
    echo -e "${YELLOW}--- Active Frontend Connections (ESTABLISHED) ---${NC}"
    printf "HTTPS (Port 443 ) : ${GREEN}%-5s connections${NC}\n" "$HTTPS_1"
    printf "HTTPS (Port 2053) : ${GREEN}%-5s connections${NC}\n" "$HTTPS_2"
    printf "HTTP  (Port 80  ) : ${GREEN}%-5s connections${NC}\n" "$HTTP_1"
    
    echo ""
    # اینجا اسم اینترفیس به صورت خودکار نمایش داده می‌شود
    echo -e "${YELLOW}--- Network Traffic ($INTERFACE) ---${NC}"
    printf "Current Speed : DL ${GREEN}%-7s MB/s${NC} |  UL ${GREEN}%-7s MB/s${NC}\n" "$DL_SPEED" "$UL_SPEED"
    printf "Total Usage   : DL ${PINK}%-7s GB${NC}   |  UL ${PINK}%-7s GB${NC}\n" "$DL_TOTAL" "$UL_TOTAL"
    
    echo -e "\n${NC}Interface detected: $INTERFACE | Press [Ctrl+C] to stop"
done
