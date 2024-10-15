# Getting Started

This is a sample code using Actor components deployed into a local Kubernetes cluster. The setup instructions is based on *docker for windows*

## Setup Kubernetes (k8s)

On Docker Desktop for windows, enable kubernetes from the settings

## Install Dapr CLI

Install the Dapr CLI

`powershell -Command "iwr -useb https://raw.githubusercontent.com/dapr/cli/master/install/install.ps1 | iex"`

## Initialise dapr in the kubernetes cluster

This will setup all the dapr services in the k8s environment
`dapr init -k`

[https://docs.dapr.io/operations/hosting/kubernetes/kubernetes-deploy/](https://docs.dapr.io/operations/hosting/kubernetes/kubernetes-deploy/)

Once this is setup, check all the services are running using

`dapr status -k`

After they are all running, you can check the dapr dashboard by running

`dapr dashboard -k`

## Install HELM package manager for k8s

`winget install Helm.Helm`

other methods of installing are located here [https://helm.sh/docs/intro/install/](https://helm.sh/docs/intro/install/)

## Install Redis store on the k8s cluster

```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install redis bitnami/redis
```

After installing you can verify by `kubectl get pods`

### Get the Redis password

Run `kubectl get secret --namespace default redis -o jsonpath="{.data.redis-password}" > encoded.b64`, which creates a file with your encoded password. Next, run 
`certutil -decode encoded.b64 password.txt`, which will put your redis password in a text file called password.txt. 

Copy the password and delete the two files.

Add this password as the redisPassword value in your `.deploy\redis-state.yaml` file. For example:

    metadata:
    - name: redisPassword
      value: lhDOkwTlp0

### Setup redis state store in k8s

goto the `.deploy` folder
`kubectl apply -f redis-state.yaml`

## Install a local docker registry for images

`docker run -d -p 5000:5000 --restart=always --name registry registry:2`

If you run into issues accessing the registry locally, you may need to configure this in docker for windows settings


1. Open Docker Desktop settings
2. Go to "Docker Engine"

Add the following to the JSON configuration:

```
{
  "insecure-registries": ["localhost:5000"]
}
```

Apply and restart Docker

## Deploying the sample app

This will build the service and the client application and have them deployed to the kubernetes cluster

```
cd .deploy
build.bat
```

You can then check it is all working with

`dapr dashboard -k`

Check the service is running and the logs to ensure they are getting triggered. The client should be making calls to instantiate the actors

# Setting up Dapr in AWS EKS cluster

We are going to assume an initial AWS EKS cluster is setup. Use the AWS Documents on creating your first EKS cluster. If you have an existing dapr already installed on the EKS cluster, you have to remove it `dapr uninstall -k`

## Setting up storage 

Dapr requires persistent storage. We will need to setup persistent storage on EKS.

1. Ensure to install the EBS CSI driver addon to your cluster from the AWS EKS management console
2. Setup a `StorageClass` based on this document [https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)
3. Your EKS role needs to have the permissions to create EBS Volumes. You can add the AWS Managed permission `AmazonEBSCSIDriverPolicy` to the role that is running your EKS Cluster

If you followed the above example, your StorageClass name is `ebs-sc`

## Initialising dapr

You can now initialise dapr in your EKS cluster and ensuring the storageclass property is set on initialise. Do the following assuming the storage class name is `ebs-sc` as per previous section.

`dapr init -k --set dapr_scheduler.cluster.storageClassName=ebs-sc`

This may take a while but eventually all the services should be running which you can check from

`dapr status -k`

## Additional useful commands for EKS

*Setup aws kubeconfig*

`aws eks update-kubeconfig --region <your-region> --name <cluster-name>`

*Run Commands with kubectl against that profile*

`kubectl get nodes`

*Get all the kubernetes contexts (incase you have multiple, e.g. one locally on docker desktop and one in aws)*

`kubectl config get-contexts`

*Use Kube Context*

`kubectl config use-context <your-cluster-context-name>`

Once you do this, you can interact with your kubernetes cluster as if it was local. Dapr CLI will also interact with the current k8s cluster which is in context.
e.g. `dapr status -k` will retrieve the dapr status from the k8s cluster you have in context.