

# Linux Commands

# Change Host Name

```bash
sudo vim /etc/hostname
sudo vim /etc/hosts
```

List all Services
```bash
systemctl list-units --type=service
```

View logs of a service
```bash
journalctl -u <service.name> --no-pager
```

Kill a process
```bash
kill 9 <PID> 
```
