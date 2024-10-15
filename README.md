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