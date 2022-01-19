# Dockerfile for manual deployemnt from local environment
FROM amazon/aws-cli:2.4.11
# https://github.com/aws/aws-cli/blob/2.4.11/docker/Dockerfile

# install terraform for amazonlinux:2
# https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started

RUN yum update -y \
  && yum install -y yum-utils \
  && yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo \
  && yum -y install terraform git jq yq

WORKDIR /terraform
ENTRYPOINT ["/bin/bash", "-c", "echo hello; sleep 1d"]
