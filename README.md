# Udagram Image Filtering Application

Udagram is a simple cloud application developed alongside the Udacity Cloud Developer Nanodegree. It allows users to register and log into a web client, post photos to the feed, and process photos using an image filtering microservice.

The project is split into two parts:
1. Frontend - Angular web application built with Ionic Framework
2. Backend RESTful API - Node-Express application

## Getting Started
### Prerequisite
1. [AWS CLI](https://aws.amazon.com/cli/)
2. [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
3. [Docker](https://www.docker.com/products/docker-desktop)

#### Environment Script
A file named `set_env.sh` has been prepared as an optional tool to help you configure these variables on your local development environment.
 
We do _not_ want your credentials to be stored in git. After pulling this `starter` project, run the following command to tell git to stop tracking the script in git but keep it stored locally. This way, you can use the script for your convenience and reduce risk of exposing your credentials.
`git rm --cached set_env.sh`

Afterwards, we can prevent the file from being included in your solution by adding the file to our `.gitignore` file.

### 1. Database
Create a PostgreSQL database either locally or on AWS RDS. The database is used to store the application's metadata.

* We will need to use password authentication for this project. This means that a username and password is needed to authenticate and access the database.
* The port number will need to be set as `5432`. This is the typical port that is used by PostgreSQL so it is usually set to this port by default.

Once your database is set up, set the config values for environment variables prefixed with `POSTGRES_` in `set_env.sh`.
* If you set up a local database, your `POSTGRES_HOST` is most likely `localhost`
* If you set up an RDS database, your `POSTGRES_HOST` is most likely in the following format: `***.****.us-west-1.rds.amazonaws.com`. You can find this value in the AWS console's RDS dashboard.


### 2. S3
Create an AWS S3 bucket. The S3 bucket is used to store images that are displayed in Udagram.

Set the config values for environment variables prefixed with `AWS_` in `set_env.sh`.

### 3. Backend API
Launch the backend API locally. The API is the application's interface to S3 and the database.

* To download all the package dependencies, run the command from the directory `udagram-api/`:
    ```bash
    npm install .
    ```
* To run the application locally, run:
    ```bash
    npm run dev
    ```
* You can visit `http://localhost:8080/api/v0/feed` in your web browser to verify that the application is running. You should see a JSON payload. Feel free to play around with Postman to test the API's.

### 4. Frontend App
Launch the frontend app locally.

* To download all the package dependencies, run the command from the directory `udagram-frontend/`:
    ```bash
    npm install .
    ```
* Install Ionic Framework's Command Line tools for us to build and run the application:
    ```bash
    npm install -g ionic
    ```
* Prepare your application by compiling them into static files.
    ```bash
    ionic build
    ```
* Run the application locally using files created from the `ionic build` command.
    ```bash
    ionic serve
    ```
* You can visit `http://localhost:8100` in your web browser to verify that the application is running. You should see a web interface.

## Tips
1. Take a look at `udagram-api` -- does it look like we can divide it into two modules to be deployed as separate microservices?
2. The `.dockerignore` file is included for your convenience to not copy `node_modules`. Copying this over into a Docker container might cause issues if your local environment is a different operating system than the Docker image (ex. Windows or MacOS vs. Linux).
3. It's useful to "lint" your code so that changes in the codebase adhere to a coding standard. This helps alleviate issues when developers use different styles of coding. `eslint` has been set up for TypeScript in the codebase for you. To lint your code, run the following:
    ```bash
    npx eslint --ext .js,.ts src/
    ```
    To have your code fixed automatically, run
    ```bash
    npx eslint --ext .js,.ts src/ --fix
    ```
4. `set_env.sh` is really for your backend application. Frontend applications have a different notion of how to store configurations. Configurations for the application endpoints can be configured inside of the `environments/environment.*ts` files.
5. In `set_env.sh`, environment variables are set with `export $VAR=value`. Setting it this way is not permanent; every time you open a new terminal, you will have to run `set_env.sh` to reconfigure your environment variables. To verify if your environment variable is set, you can check the variable with a command like `echo $POSTGRES_USERNAME`.

## Deploy on local
### Step 1. Set some variables
```
export POSTGRES_USERNAME=postgres
export POSTGRES_PASSWORD=postgres
export POSTGRES_DB=postgres
export POSTGRES_HOST=postgres.c74mggpqpypi.us-east-1.rds.amazonaws.com
export AWS_REGION=us-east-1
export AWS_PROFILE=default
export AWS_BUCKET=arn:aws:s3:::test-user2029395-dev
export JWT_SECRET=hello
```
### Step 2. Start all the services
```
docker-compose up
```

### Step 3. Check services status
```
docker-ps
```
### Step 4. Open the website and use
```http://localhost:8100```

## Deploy on AWS
### Create an EKS Cluster
#### Step 1. Create the EKS Cluster
Follow the instructions provided by AWS on [Creating an Amazon EKS Cluster](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html). Make sure that you are following the steps for AWS Management Console and not eksctl or AWS CLI.

During the creation process, the EKS console will provide dropdown menus for selecting options such as IAM roles and VPCs. If none exist for you, follow the documentation that is linked in the EKS console. Here are some tips for you:

For the Cluster Service Role in the creation process, create an [AWS role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html) for EKS. Make sure you attach the policies for AmazonEKSClusterPolicy, AmazonEC2ContainerServiceFullAccess, and AmazonEKSServicePolicy.
If you don't have a VPC, create one with the IPv4 CIDR block value 10.0.0.0/16. Make sure you select No IPv6 CIDR block.
Your Cluster endpoint access should be set to Public
Your cluster may take ~20 minutes to be created. Once it's ready, it should be marked with an Active status.

#### Step 2. Create the EKS Node Groups
Once your cluster is created, we will need to add Node Groups so that the cluster has EC2 instances to process the workloads.

Follow the instructions provided by AWS on [Creating a Managed Node Group](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html). Similar to before, make sure you're following the steps for AWS Management Console. Here are some tips for you:

For the Node IAM Role in the creation process, create an [AWS role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html) for EKS Node Groups. Make sure you attach the policies for AmazonEKSWorkerNodePolicy, AmazonEC2ContainerRegistryReadOnly, and AmazonEKS_CNI_Policy.
We recommend using m5.large instance types
We recommend setting 2 minimum nodes, 3 maximum nodes

#### Step 3. Connecting kubectl with EKS
Follow the instructions provided by AWS on [Create a kubeconfig for Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html). This will make it such that your kubectl will be running against your newly-created EKS cluster.

Once kubectl is configured to communicate with your EKS cluster, run the following to validate the connection to the cluster

```kubectl get nodes```
This should return information regarding the nodes that were created in your EKS cluster.

### Deployment
In this step, you will deploy the Docker containers for the frontend web application and backend API applications in their respective pods.

Recall that while splitting the monolithic app into microservices, you used the values saved in the environment variables, as well as AWS CLI was configured locally. Similar values are required while instantiating containers from the Dockerhub images.

ConfigMap: Update all the configurations value in the file ```deployment/k8s/env-configmap.yaml```.

Secret: Update the PostgreSQL username and passwords in the ```deployment/k8s/env-secret.yaml``` file.

Secret: Update  AWS login credentials with the Base64 encoded credentialsin the file ```deployment/k8s/aws-secret.yaml```

Deployment configuration: Run these commands to deploy services:
```
kubectl apply -f aws-secret.yaml
kubectl apply -f env-secret.yaml
kubectl apply -f env-configmap.yaml
# Deployments - Double check the Dockerhub image name and version in the deployment files
kubectl apply -f backend-feed-deployment.yaml
kubectl apply -f backend-user-deployment.yaml
kubectl apply -f frontend-deployment.yaml
# Do the same for other three deployment files
# Service
kubectl apply -f backend-feed-service.yaml
kubectl apply -f backend-user-service.yaml
kubectl apply -f frontend-service.yaml
```

Check services: Run these commands to check services status:
```
kubectl get pod
kubectl get service
kubectl get deployment
```