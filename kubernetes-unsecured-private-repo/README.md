# After deployment

## Enable repo on k3s

### Modify the registries file
```bash
vi /etc/rancher/k3s/registries.yaml
```
### Example
```yaml
  "hostname:5000":
    endpoint:
      - "hostname:5000"
```

## Enable repo on podman (containerd)
### Modify the registries file
```bash
sudo vi /etc/containers/registries.conf.d/myregistry.conf
```
### Example
```properties
[[registry]]
location = "localhost:5000"
insecure = true
```