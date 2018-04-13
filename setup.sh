#!/bin/bash


GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
YELLOW='\033[0;33m'

if [ $# != 3 ]
  then
    echo -e "${RED}Incorrect Arguments Provided${NC}"
    echo -e "${GREEN}setup.sh <create/remove> <s3-bucket> <dns-name-for-k8s-cluster>${NC}"
    exit 1
fi


#Requires AWS credentials
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]
then
  echo -e "${RED}It requires AWS_SECRET_ACCESS_KEY & \
AWS_ACCESS_KEY_ID ENV variables${NC}"
  exit 1
fi

#Requires AWS CLI, kops and Terraform
kops version >/dev/null 2>&1 && \
terraform version >/dev/null 2>&1 && \
kubectl help >/dev/null 2>&1 && \
which helm >/dev/null
if [ $? != 0  ]
then
  echo -e "${RED}Please install AWS CLI, kops, terraform and helm(just install binary)${NC}"
  exit 1
fi

terraform_apply() {
  cd terraform-templates && terraform init && terraform apply
  if [ $? != 0  ]
  then
    echo -e "${RED}\t--> terraform failed${NC}"
    exit 1
  else
    echo -e "${YELLOW}\t--> terraform completed${NC}"
  fi
}

terraform_destroy() {
  cd terraform-templates && terraform destroy
  if [ $? != 0  ]
  then
    echo -e "${RED}\t--> terraform failed${NC}"
    exit 1
  else
    echo -e "${YELLOW}\t--> terraform destroy completed${NC}"
  fi
}

#By default, kops uses ~/.ssh/id_rsa.pub for ec2 key pair.
kops_create_cluster() {
  kops create cluster \
  --cloud=aws \
  --master-zones=eu-west-1a,eu-west-1b,eu-west-1c \
  --zones=eu-west-1a,eu-west-1b,eu-west-1c \
  --node-count=2 \
  --node-size=t2.micro \
  --master-size=t2.micro \
  --vpc=$(terraform output vpc_id) \
  --name=${dns_k8s_cluster} \
  --state=s3://${s3_bucket} \
  --yes
  if [ $? != 0  ]
  then
    echo -e "${RED}\t--> kops create cluster failed${NC}"
    exit 1
  fi
  #It will take few minutes to create the cluster, until check the state
  kops validate cluster \
  --state=s3://${s3_bucket} >/dev/null 2>&1
  while [ $? -ne 0 ]; do
    sleep 20
    echo "Validating kops cluster"
    kops validate cluster \
    --state=s3://${s3_bucket} >/dev/null 2>&1
  done
  echo -e "${YELLOW}\t--> kops create cluster completed${NC}"
}

kops_remove_cluster() {
  kops delete cluster \
  --name=${dns_k8s_cluster} \
  --state=s3://${s3_bucket} \
  --yes
  if [ $? != 0  ]
  then
    echo -e "${RED}\t--> kops delete cluster failed${NC}"
    exit 1
  fi
  echo -e "${YELLOW}\t--> kops delete cluster completed${NC}"
}

create_setup() {
  s3_bucket=$1
  dns_k8s_cluster=$2
  echo -e "${GREEN}\tCreating K8s Setup\n${NC}"
  echo -e "${GREEN}\t--> Running terraform\n${NC}"
  terraform_apply;
  echo -e "${GREEN}\t--> Running kops\n${NC}"
  kops_create_cluster;
  echo -e "${GREEN}\t--> Installing helm/tiller in k8s cluster${NC}"
  helm init
}

remove_setup() {
  s3_bucket=$1
  dns_k8s_cluster=$2
  echo -e "${GREEN}\tRemoving K8s Setup\n${NC}"
  echo -e "${GREEN}\t--> Running kops\n${NC}"
  kops_remove_cluster;
  echo -e "${GREEN}\t--> Running terraform\n${NC}"
  terraform_destroy;
}

#Create or Remove the whole setup based on input argument
if [ "$1" == "create" ]
then
  create_setup $2 $3;
elif [ "$1" == "remove" ]
then
  remove_setup $2 $3;
else
  echo -e "${RED}Unknown Argument $1: It only support create or remove${NC}"
  exit 1
fi
