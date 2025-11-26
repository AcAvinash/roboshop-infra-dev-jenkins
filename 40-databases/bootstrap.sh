!/bin/bash

component=$1
environment=$2

dnf install ansible -y

ansible-pull \
  -U https://github.com/AcAvinash/ansible-roboshop-roles-tf.git \
  -e "component=$component env=$environment" \
  main.yaml
