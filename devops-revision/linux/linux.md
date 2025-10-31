# Linux - Consolidated Revision

Core commands and topics for system administration and common interview items.

## Topics
- Filesystem, permissions, users/groups, systemd, services
- Networking tools: ip, ss, netstat, ifconfig, iptables
- Logs: /var/log, journalctl
- Disk and filesystem: df -h, du -sh, lsblk, fdisk

## Quick Commands
- Check memory: free -m
- Check disk usage: df -h; du -sh /var/log
- View logs: journalctl -u nginx -f; tail -n 200 /var/log/syslog
- Manage services: systemctl start|stop|status nginx
- Network: ip a; ip route; ss -tuln

## References
- ../../linux/README.md
- ../../Devops/linux.md
