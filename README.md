# cubbit-task
Repository to try execute the task assigned by Cubbit interviewer

## Terraform part
Before run the terraform plan and apply commands, you have to set the following vars to pass account credentials of an iam user preconfigured on aws account target:
export AWS_ACCESS_KEY_ID=your_aws_access_key
export AWS_SECRET_ACCESS_KEY=your_aws_secret_access_key

Next you can run following commands:
- cd aws-vms
- terraform plan -out=./tf_state.tfplan
- terraform apply "./tf_state.tfplan"

With terraform, will be created a single ec2 instance and install these tools with user-data:
- k3s cluster in single node mode
- kubectl
- helm

# Go app part
To build docker image of the go application:
- docker build go-app -t {account-id}.dkr.ecr.eu-central-1.amazonaws.com/go-app:latest
- login to the ecr repository that is created with terraform (see command from aws ecr dashboard)
- docker push {account-id}.dkr.ecr.eu-central-1.amazonaws.com/go-app:latest 

In the same directory, there is a folder named "go-app-chart" where there are stored the helm chart files.
With this templates, will be create k8s manifests of deployment and secret resources. To generate the manifests open the chart folder and run:
helm template go-app-chart .
