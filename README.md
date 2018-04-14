terraform-kops
===============

Overview
---------
- Using terraform to provision the VPC and RDS instance.
- Using kops to provision the k8s cluster in the same VPC.
- Using helm to deploy the wordpress setup.

Steps
------
- To create the setup, you should provide a Valid DNS name(sub-domain), S3 bucket, Database name, username and password for wordpress.

  `setup.sh <create> <s3-bucket> <dns-name-for-k8s-cluster>
<database-name> <database-username> <database-password>`
- To remove the setup,

  `setup.sh <remove> <s3-bucket> <dns-name-for-k8s-cluster>`

prerequisites
-------------
- It requires AWS_SECRET_ACCESS_KEY and AWS_ACCESS_KEY_ID ENVIRONMENT variables.
- Before run the setup script, please install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/), [kops-v1.8.0](https://github.com/kubernetes/kops/releases/download/1.8.0/kops-linux-amd64), [terraform](https://www.terraform.io/downloads.html) and [helm-v2.2.0](https://kubernetes-helm.storage.googleapis.com/helm-v2.2.0-linux-amd64.tar.gz) binaries.
- By default, kops uses ~/.ssh/id_rsa.pub to create ec2 key pair for k8s nodes.

Notes
------
- For production, we should use private network and custom security groups for k8s nodes, persistent volumes or S3 for wordpress container and remote backend for terraform.
