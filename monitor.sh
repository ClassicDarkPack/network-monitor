#!/bin/bash

# --- تنظیمات رنگ ---
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
PINK='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'

trap "tput cnorm; clear; exit" INT
tput civis
clear # فقط یک بار در شروع صفحه را پاک می‌کند

while true; do
    # بردن نشانگر به خط اول و ستون اول بدون پاک کردن صفحه
    tput cup 0 0

    echo -e "${YELLOW}--- Active Ports with Connections (Top 5) ---${NC}"
    # نمایش پورت‌های فعال
    ss -nt state established | grep -v "Local Address" | awk '{print $4}' | awk -F: '{print $NF}' | sort | uniq -c | sort -rn | head -n 5 | while read count port; do
        printf "Port %-10s : ${GREEN}%-5s connections${NC}      \n" "$port" "$count"
    done
    
    # پاک کردن خط‌های احتمالی باقی‌مانده از قبل (اگر تعداد پورت‌ها کم شد)
    tput el

    echo -e "\n${YELLOW}--- Network Traffic (All Interfaces) ---${NC}"
    printf "%-10s | %-12s | %-12s | %-10s\n" "Interface" "Download" "Upload" "Total GB"
    echo "------------------------------------------------------------"

    for IFACE in $(ls /sys/class/net | grep -v lo); do
        # خوانی آمار اول
        R1=$(cat "/sys/class/net/$IFACE/statistics/rx_bytes")
        T1=$(cat "/sys/class/net/$IFACE/statistics/tx_bytes")
        
        sleep 0.5 # زمان ثابت برای محاسبه دقیق‌تر
        
        # خوانی آمار دوم
        R2=$(cat "/sys/class/net/$IFACE/statistics/rx_bytes")
        T2=$(cat "/sys/class/net/$IFACE/statistics/tx_bytes")

        # محاسبات (تقسیم بر 0.5 چون نیم ثانیه صبر کردیم)
        DL_SPEED=$(awk "BEGIN {printf \"%.2f\", (($R2-$R1)/1024/1024)/0.5}")
        UL_SPEED=$(awk "BEGIN {printf \"%.2f\", (($T2-$T1)/1024/1024)/0.5}")
        TOTAL_GB=$(awk "BEGIN {printf \"%.2f\", ($R2+$T2)/1024/1024/1024}")

        printf "${CYAN}%-10s${NC} | ${GREEN}%-7s MB/s${NC} | ${PINK}%-7s MB/s${NC} | %-7s GB   \n" "$IFACE" "$DL_SPEED" "$UL_SPEED" "$TOTAL_GB"
    done

    # پاک کردن انتهای صفحه برای تمیز ماندن
    echo -e "\n${NC}Refreshing every second... Press [Ctrl+C] to stop"
    tput ed 
done
