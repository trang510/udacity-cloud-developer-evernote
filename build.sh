docker --version # print the version for logging
docker build -t api-feed ./api-feed
docker build -t api-user ./api-user
docker build -t frontend ./frontend
docker tag api-feed trangnd/api-feed:v1
docker tag api-user trangnd/api-user:v1
docker tag frontend trangnd/frontend:v2
docker push trangnd/api-feed:v1
docker push trangnd/api-user:v1
docker push trangnd/frontend:v2
