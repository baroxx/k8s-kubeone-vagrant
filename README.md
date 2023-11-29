# Prerequisits

This

1. Proper ssh setup for non root user
2. The user requires passwordless sudo permissions

# Load Balancer

Run these commands on node-1:

- Copy [Dockerfile](haproxy/Dockerfile) to node-1
- Copy [haproxy.cfg](haproxy/haproxy.cfg) to node-1

```
docker build . -t kubeone-haproxy:2.8.4-bullseye
docker run -p 6443:6443 -d --restart always --name haproxy kubeone-haproxy:2.8.4-bullseye
```

# OIDC

Run this commands on node-1:

```
docker run -p 9090:8080 -d --restart always --name keycloak -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin quay.io/keycloak/keycloak:22.0.5 start-dev
```



# Cluster setup

1. run "kubeone config print --full >> kubeone.yaml"
2. Open [kubeone.yaml](kubeone.yaml)
    1. set kubernetes version
    2. set cloudProvider to `none: {}` (none for not supported providers)
    3. set machineController to `deploy: false` (false for not supported providers)
    4. set values for controlPlane (ssh setup for non root user)
    5. set values for staticWorkers (ssh setup for non root user)
    6. set values for apiEndpoint (loadbalancer IP + port from node-1)
3. run "kubeone apply -m kubeone.yaml"

# 