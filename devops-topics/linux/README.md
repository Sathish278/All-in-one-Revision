```markdown
# Linux — interview-ready revision

> Summary: Linux essentials for SREs — filesystems, process management, networking, troubleshooting, and automation.
>
> How to use: practice common admin tasks on a sandbox VM, learn to triage using system logs, and script repetitive tasks with shell or Python.

1) Useful commands
- ps, top/htop, ss/netstat, journalctl, dmesg, df, du, lsof, strace.

2) Networking
- IP routing, iptables/nftables basics, network namespaces, and troubleshooting with tcpdump.

3) Storage
- Filesystem types, mounting, LVM basics, and disk performance troubleshooting.

4) Process & service management
- systemd units, timers, cgroups, resource limits (ulimit), and process supervision.

5) Security
- SELinux/AppArmor basics, user permissions, sudo, SSH hardening, and secure patching practices.

6) Interview Q&A
- Q: How to find a process using most memory? A: `ps aux --sort=-%mem | head` or `top` and inspect with `pmap`.

--

I can add a small troubleshooting checklist and a few one-liner recipes for common incidents (OOM, disk full, high load).
```
