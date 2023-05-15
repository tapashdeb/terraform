#!/bin/bash

      sudo yum update -y
      sudo yum install docker -y
      sudo amazon-linux-extras install java-openjdk11 -y
      sudo wget -O /etc/yum.repos.d/jenkins.repo \https://pkg.jenkins.io/redhat-stable/jenkins.repo
      sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
      sudo yum upgrade
      sudo yum install jenkins -y
      sudo systemctl start jenkins
      sudo systemctl enable jenkins


      
