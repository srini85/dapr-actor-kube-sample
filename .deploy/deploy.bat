docker build -t localhost:5000/smart-device-actor -f ..\service\Dockerfile ..\
docker push localhost:5000/smart-device-actor

docker build -t localhost:5000/smart-device-client -f ..\client\Dockerfile ..\
docker push localhost:5000/smart-device-client

kubectl rollout restart deployment smart-device-actor
kubectl apply -f smart-device-actor-deployment.yaml
kubectl apply -f smart-device-actor-service.yaml

kubectl rollout restart deployment smart-device-client
kubectl apply -f smart-device-client-deployment.yaml
