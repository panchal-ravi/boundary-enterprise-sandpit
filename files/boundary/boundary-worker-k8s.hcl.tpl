apiVersion: apps/v1
kind: Deployment
metadata:
  name: boundary-worker-k8s
  labels:
    app: boundary
    component: worker
    env: k8s
spec:
  replicas: 1
  selector:
    matchLabels:
      app: boundary
      component: worker
      env: k8s
  template:
    metadata:
      labels:
        app: boundary
        component: worker
        env: k8s
    spec:
      containers:
      - name: boundary-worker
        image: hashicorp/boundary-worker-hcp:0.12.2-hcp
        command: [ "boundary-worker", "server", "-config", "/etc/boundary/boundary-worker.hcl" ]
        ports:
        - containerPort: 9202
        volumeMounts:
        - mountPath: /etc/boundary
          name: boundary-config
        securityContext:
          privileged: true
      volumes:
      - name: boundary-config
        configMap:
          name: boundary-k8s-worker-config
---
apiVersion: v1
kind: Service
metadata:
  name: boundary-k8s-worker-svc
  annotations:
    "service.beta.kubernetes.io/aws-load-balancer-type": "nlb"
spec:
  type: LoadBalancer
  selector:
    app: boundary
    component: worker
    env: k8s
  ports:
  - port: 9202
    targetPort: 9202
    name: "data"
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: boundary-k8s-worker-config
data:
  boundary-worker.hcl: |
    // hcp_boundary_cluster_id = "${boundary_cluster_id}"
    disable_mlock = true
    listener "tcp" {
      purpose = "proxy"
      address = "0.0.0.0:9202"
    }

    listener "tcp" {
      purpose = "proxy"
      address = "0.0.0.0:9203"
    }

    worker {
      public_addr = "${eip_public_ip}"
      auth_storage_path = "/home/boundary/worker1"
      tags {
        type = "eks"
      }
    }