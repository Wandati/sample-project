
## Introduction

This project demonstrates a comprehensive DevOps workflow for a web application, showcasing skills in -:

-   Version control using Git.

-   Containerization with Docker.

-   Cloud infrastructure provisioning using Terraform.

-   Continuous Integration and Continuous Deployment (CI/CD) pipelines using Jenkins.

-   Site Reliability Engineering (SRE) principles for monitoring and alerting.

-   Configuration management using Ansible.

## Project Setup

## Prerequisites

- Docker and Docker Compose installed.

- Terraform installed.

- Jenkins installed and configured.

- AWS credentials with appropriate permissions.

- Ansible installed.

## Repository Structure

├── app/                   # Application source code

├── docker-compose.yml     # Docker Compose configuration

├── Dockerfile             # Docker image definition

├── terraform/             # Terraform IaC scripts

├── ansible/               # Ansible playbooks and templates

├── Jenkinsfile_infra      # Jenkinsfile for infrastructure provisioning

├── Jenkinsfile_app        # Jenkinsfile for application deployment

├── README.md              # Project documentation (this file)

## Task Breakdown

# Task 1: Version Control Integration

# Approach

Initialized a Git repository for the project.

Structured the project with clear folder organization.

Made meaningful commits for each significant change, ensuring a clear commit history.

Pushed the repository to GitHub.

# Challenges

Structuring the repository to integrate Terraform and Ansible configurations while maintaining clarity.

# Task 2: Containerization with Docker

# Approach

Created a multi-stage Dockerfile to build a lightweight production image for the web application.

Used Docker Compose to simulate a multi-container environment with the app and PostgreSQL database.

Configured the application to connect to the database using Docker networking.

# Key Commands

docker-compose up --build

Access the application at http://localhost:8080/courses/.

# Challenges

Configuring the application to communicate seamlessly with the database container.

# Task 3: Infrastructure as Code (IaC)

## Approach

Used Terraform to provision:

A VPC with public subnets.

An EC2 instance with a static IP and a security group allowing HTTP, HTTPS, and SSH traffic.

Modularized the configuration for scalability and reusability.

# Steps to Deploy

terraform -chdir=terraform/ init
terraform -chdir=terraform/ apply -auto-approve

Verification

Check the EC2 instance in the AWS Management Console.

# Challenges

Ensuring compatibility of the AMI used for the EC2 instance in the target AWS region.

# Task 4: CI/CD Pipeline with Cloud Integration

# Approach

Developed two Jenkins pipelines:

Infrastructure Provisioning: Automates Terraform tasks (init, plan, apply).

App Deployment:

Builds and scans Docker images.

Pushes images to AWS ECR.

Deploys the application to the EC2 instance.

Features

Secure handling of AWS credentials using Jenkins credentials store.

Automated ECR login and Docker image tagging.

Integration of Trivy for security scanning.


# Challenges

Automating ECR authentication securely.

Managing environment variables across different pipeline stages.

# Task 5: Site Reliability Engineering (SRE)

# Approach

Deployed Prometheus and Grafana on the EC2 instance.

Configured Prometheus to monitor application metrics.

Set up dashboards and alerting rules in Grafana for key performance indicators.

# Tools Used

Prometheus: For scraping application metrics.

Grafana: For visualizing metrics and configuring alerts.

# Challenges

Fine-tuning alert thresholds to avoid excessive or false alerts.

# Bonus Task: Ansible Configuration Management

# Approach

Wrote an Ansible playbook to:

Create a devops group and configure file permissions.

Install PostgreSQL and Nginx.

Enable and start required services.

Ensured idempotency for repeatable execution.

Usage

ansible-playbook -i inventory ansible/main.yml

# Challenges

Managing SSH access securely for remote execution.



