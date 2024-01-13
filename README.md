# k8s-kubeone-vagrant

This project provides an example setup for a Kubernetes cluster with KubeOne. The nodes for the cluster can be provisioned with Vagrant.

# Prerequisits

Kubeone requires a proper ssh setup for a non root user. Password protected ssh keys are not supported by kubeone. 

The user requires passwordless sudo permissions. This is already done for the VMs in this example.

## Tools

- VM setup (only for local VM setup)
    - VirtualBox
    - Vagrant
- Cluster setup
    - [Kubeone CLI](https://docs.kubermatic.com/kubeone/v1.7/getting-kubeone/)

## Local VM setup

This is only required if you want to test the setup on your local machine. 

1. Adjust [Vagrantfile](vagrant/Vagrantfile)
    1. Add your public ssh key to SSH_KEY (passwordless required)
    2. (optional) You can change CPUS, MEMORY, USER_NAME, PASSWORD and KEYMAP
2. Run [run.sh](vagrant/run.sh)
3. (optional) SSH config on host
    1. Open `~/.ssh/config` (you might need to create it first)
    2. Add this lines:

```
host node-1
    HostName 192.168.56.11
host node-2
    HostName 192.168.56.12
host node-3
    HostName 192.168.56.13
host node-4
    HostName 192.168.56.14
host node-5
    HostName 192.168.56.15
host node-6
    HostName 192.168.56.16
host node-*
    User kubeone
```

# Cluster setup

This section is written for a setup with five nodes (node-1 to node-5):

TODO: PICTURE

## Load Balancer

You will need these files:
- [Dockerfile](haproxy/Dockerfile)
- [haproxy.cfg](haproxy/haproxy.cfg)

Perform these steps on node-1 `ssh node-1`:


```
mkdir ~/haproxy
cd ~/haproxy
vi Dockerfile
# Copy the content of haproxy/Dockerfile
vi haproxy.cfg
# Copy the content of haproxy.cfg
sudo docker build . -t kubeone-haproxy:2.8.4-bullseye
sudo docker run -p 6443:6443 -d --restart always --name haproxy kubeone-haproxy:2.8.4-bullseye
```

The load balancer is now configured to send traffic to the two control planes wlith the given IP.

## OIDC
Perform these steps on node-1 `ssh node-1`:

```
mkdir ~/keycloak
cd ~/keycloak
sudo docker run -p 9090:8080 -d --restart always --name keycloak -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin quay.io/keycloak/keycloak:23.0.4-0 start-dev
```

This will start an Keycloak instance in development mode. You can access the instance in the browser here http://192.168.56.11:9090/

## Cluster

1. run "kubeone config print --full >> kubeone.yaml"
2. Open [kubeone.yaml](kubeone.yaml)
    1. set kubernetes version
    2. set cloudProvider to `none: {}` (none for not supported providers)
    3. set machineController to `deploy: false` (false for not supported providers)
    4. set values for controlPlane (ssh setup for non root user)
    5. set values for staticWorkers (ssh setup for non root user)
    6. set values for apiEndpoint (loadbalancer IP + port from node-1)
3. run "kubeone apply -m kubeone.yaml"
