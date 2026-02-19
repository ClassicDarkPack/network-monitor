# 🚀 Real-time Network Monitoring Dashboard
A lightweight, high-performance Bash script to monitor live network traffic and active HTTP/HTTPS connections on Linux servers.

## 📊 Overview
This tool provides a terminal-based dashboard that tracks:
- **Active Connections:** Counts established connections on Port 80, 443, and 2053.
- **Bandwidth Speed:** Live Download (DL) and Upload (UL) speeds in MB/s.
- **Data Consumption:** Total data usage in GB since the last system boot.

## 🛠 Installation & Usage
To get started, clone the repository and run the script:

```bash
curl -L https://raw.githubusercontent.com/ClassicDarkPack/network-monitor/main/monitor.sh -o monitor.sh && chmod +x monitor.sh && ./monitor.sh
