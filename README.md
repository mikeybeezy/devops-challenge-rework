[![README Header][logo]][website]

# Humn.AI Site Reliability Engineer Challenge

Welcome to the Humn.AI SRE coding challenge! Please, read over the whole document before proceeding with coding.

The goals of the challenge are:
1. For you, to showcase your skills in designing and implementing the following:
 -  Kubernetes Objects
 -  Monitoring artifacts, specifically with Prometheus & Grafana
 -  (Optional) AWS infrastructure using Terraform
2. For us, to check if your logic, knowledge, and adaptability match the technical expectations we have for our SRE team members

We recommended not spending more than **two hours** to accomplish as much of the requirements below. We want to highlight that the Terraform challenge is OPTIONAL. However, it is a large part of our tech stack, and candidates who achieve this challenge are preferred.

Let us know if you have any clarifying questions or get stuck on the way - we would be happy to help!

## What should you do?

Read through the various challenge sceanarios and complete the manifests as neccessary.

To solve these challenges, you should have the practical experience with the following:
 - Core Kubernetes objects
 - Core AWS compenents & services
 - Provisioning cloud infrastructure with Terraform
 - Artifacts of monitoring; metrics & observability

## Challanges

### References:
- https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.19/
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

### Kubernetes
#### Challenge 1:

**Scenario:**
We have a backend postgresSQL database workload that maintains the state of an application

**Assumptions:**
- Assume that a StorageClass named `gp2` exists within the cluster.

**Requirements:**
Complete a K8's manifest file by adding/modifying Objects so it contains the correct configuration to fulfill the following criteria:

1. Allow the nginx service to load balancer any taffic to backend postgres workload.
2. Scale postgres with at least `3` replicas in a master/slave configuration, each pod will require it's own identity, network ID to ensure data consistency.
3. Ensure that the state of the DB is consistent to the Pod ID
4. Ensure that that storage class is used with a size of `100GiB`
5. Mount the volume to `/var/lib/postgresql/data`
6. Ensure the pod is accessible within the cluster on port `5432`
7. All objects need to be in the namespace `backend`


#### Challenge 2:

**Scenario:**
We have a test environment that we use our own front-end web service deployed on-premises.

**Assumptions:**
- Networking connectivity and routing is establisheed between the cluster & the on-premises web service

**Requirements:**
Complete a K8's manifest file by adding/modifying Objects so it contains the correct configuration to fulfill thefollowing criteria:

1. A k8's service that points to our test environment on IP `10.15.1.18/29`.
2. Service targetPort is to be configured as `8081`
3. All objects need to be in the namespace `frontend`


#### Challenge 3:
**Scenario:**
We have a front-end web service that requires an Cloud Controller configured Service Type: `LoadBalancer`. We want to conigure an ELB that we can put SSL over our rest API using our certificate configured in our AWS Route53 HostedZone.

**Assumptions:**
- The AWS SSL Certificate exists and it registered against the Route53 HostedZone
- K8s Service Type `LoadBalancer` has been configured with the Cloud Provider: AWS
- Our hosted-zone has been configured with the following Certificate ARN: `arn:aws:acm:eu-west-1:12345678910:certificate/5x74ftt7-575y-1256-8280-7dcd7761267z`

**Requirements:**
Complete a K8's manifest file by adding/modifying Objects so it contains the correct configuration to fulfill the following criteria:
1. We need three ports exposed, they're to be named: `rest-api`(port & targetPort = `7070`),`http`(port & targetPort = `80`),`https`(port & targetPort = `443`).
2. We want SSL to be configured over the `rest-api`, and `https` ports.
3. The name of the service must be `challenge-3`, and pods must have the correct labels & selectors: `key=app`, `value=challenge-3`
4. All objects need to be in the namespace `frontend`


#### Challenge 4:
**Scenario:**

We have a simple hello-world application, we want to inject sensitive values into the pod's environment variables and want to want to provide an a specific app config file that needs to override the default config file.

**Assumptions:**
- The image is not relevant for the application, we're just testing configuration of sensitive and non-sensitve data.

**Requirements:**
Complete a K8's manifest file by adding/modifying Objects so it contains the correct configuration to fulfill the following criteria:
1. The pods need to be deployed onto nodes labelled: `key=role`, `value=microservices`
2. The pods need to be configured with the following resource limits: `0.5` CPU & `1000MiB` Memory
3. The config map needs to be mounted to the following path within the container: `/etc/test_app/app.properties`
4. A sensitive base64 endcoded secret needs to be injected into the containers environment variables with the following configuration: `key=API_KEY`, `value=FJN2fj29fh2$@`
5. All objects need to be in the namespace `frontend`

### Monitoring
#### Challenge 1:

**Scenario:**
We have deployed the Kube Prometheus Stack into our Kubernetes cluster for metrics collection.

**Assumptions:**
- The prometheus stack is deployed into the "monitoring" k8s namespace

**Requirements:**
Update the frontend k8s manifest file and m8g helm chart values file by adding/modifying Objects 
so they contain the correct configuration to fulfill the following criteria:

1. Add a port to expose metrics on the frontend service k8s manifest.
2. Add a ServiceMonitor resource to scrape metrics from the frontend service.
3. Deploy the default Grafana dashboards priveded by the helm chart

#### Challenge 2:

**Scenario:**
We have deployed the Kube Prometheus Stack into our Kubernetes cluster for metrics collection.

**Assumptions:**
- The prometheus stack (see Refs above) is deployed into the "monitoring" k8s namespace of the k8s cluster
- The following metrics are available in Prometheus
 1. kube
     - kube\_pod\_container\_status\_running
     - kube\_pod\_container\_status\_terminated\_reason
 2. node
     - node\_namespace\_pod\_container:container\_cpu\_usage\_seconds\_total
     - node\_namespace\_pod\_container:container\_memory\_rss
 3. frontend
     - num\_requests\_received\_total
     - num\_records\_inserted\_total
     - num\_request\_failures\_total
     - num\_request\_decode\_errors\_total
     - num\_sql\_errors\_total

**Requirements:**
Update the provided Grafana dashboard with the following

1. update panel queries to use data from the correct metric from those available (replace <ENTER_METRIC_HERE> with your choice)


### (Optional) - IAC / Terraform
**Please note:** Deploying this infrastructure into your own personal AWS account is NOT required, simply provide us a successful plan to show the desired-state configuration.
#### Challenge 1:

**Scenario:** 
We want to design a simple multi-AZ networking architecutre that is seprated by public/private logically isolated zones.

**Assumptions:**
- You have a free AWS account and have configured your device with programmatic access to AWS
- You have Terraform `0.13` or higher installed

**Requirements:**
Review the existing terraform resources, Complete a Terraform manifest file by adding/modifying resources so it contains the correct configuration to fulfill the following criteria:
1. Includes the maximum about of subnets as there are available zones within the region specified
2. The private subnets allows eggress via a NAT gateway
3. Defined outputs that provides a list of public & private subnet ids, the vpc ID, & both security group IDs
4. Declare another security group that has the following ingress rules attached: cidr_blocks=[`0.0.0.0/0`], to/from ports-[`22`, `80`, `8080`, `443`], protocol=`TCP`.
5. If you & I wanted to work together on the same TF_STATE, please include the mechanism that allows this.
6. (Optional) - Provide variable configuration over fixed values.  

## Feedback

We would be happy to receive your feedback on this coding challenge!

[![README Footer][logo]][website]

  [logo]: https://humnai-web-assests.s3-eu-west-1.amazonaws.com/humn-logo.png
  [website]: https://https://humn.ai/
  [github]: https://github.com/humn-ai/tf-humn-iac-live
  [slack]: humncloud.slack.com

