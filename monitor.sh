#!/bin/bash

# --- تنظیمات ---
# نام کارت شبکه خود را اینجا بنویسید (با دستور ip a می توانید ببینید)
INTERFACE="eth0"

# کدهای رنگی برای زیبایی خروجی
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
PINK='\033[0;35m'
NC='\033[0m' # No Color

# برای تمیز ماندن ترمینال هنگام خروج (Ctrl+C)
trap "tput cnorm; exit" INT
tput civis # مخفی کردن نشانگر موس

while true; do
    # --- محاسبه سرعت شبکه ---
    # خواندن مقدار اولیه بایت‌های دریافتی و ارسالی
    R1=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
    T1=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
    
    # وقفه ۱ ثانیه‌ای برای محاسبه نرخ انتقال
    sleep 1
    
    # خواندن مقدار ثانویه
    R2=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
    T2=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

    # محاسبه تفاوت (بایت بر ثانیه) و تبدیل به مگابایت
    DL_SPEED=$(awk "BEGIN {printf \"%.2f\", ($R2-$R1)/1024/1024}")
    UL_SPEED=$(awk "BEGIN {printf \"%.2f\", ($T2-$T1)/1024/1024}")

    # محاسبه حجم کل مصرفی (تبدیل بایت به گیگابایت)
    DL_TOTAL=$(awk "BEGIN {printf \"%.2f\", $R2/1024/1024/1024}")
    UL_TOTAL=$(awk "BEGIN {printf \"%.2f\", $T2/1024/1024/1024}")

    # --- شمارش اتصالات فعال (ESTABLISHED) ---
    # در اینجا پورت‌ها را بر اساس نیاز خود تغییر دهید
    HTTPS_1=$(ss -ant state established '( sport = :443 )' | wc -l)
    HTTPS_2=$(ss -ant state established '( sport = :2053 )' | wc -l) # پورت نمونه
    HTTP_1=$(ss -ant state established '( sport = :80 )' | wc -l)

    # --- نمایش خروجی ---
    clear
    echo -e "${YELLOW}--- Active Frontend Connections (ESTABLISHED) ---${NC}"
    echo -ne "HTTPS (Port 443 ) : ${GREEN}$((HTTPS_1-1)) connections${NC}\n"
    echo -ne "HTTPS (Port 2053) : ${GREEN}$((HTTPS_2-1)) connections${NC}\n"
    echo -ne "HTTP  (Port 80  ) : ${GREEN}$((HTTP_1-1)) connections${NC}\n"
    
    echo ""
    echo -e "${YELLOW}--- Network Traffic ($INTERFACE) ---${NC}"
    echo -ne "Current Speed : DL ${GREEN}$DL_SPEED MB/s${NC}  |  UL ${GREEN}$UL_SPEED MB/s${NC}\n"
    echo -ne "Total Usage   : DL ${PINK}$DL_TOTAL GB${NC}   |  UL ${PINK}$UL_TOTAL GB${NC}\n"
    
    echo -e "\n${NC}Press [Ctrl+C] to stop monitoring..."
done
