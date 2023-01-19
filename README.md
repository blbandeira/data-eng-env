# data-eng-env
## Objective


Personal project to study deployment, terraform and data engineering;  

inspired by @josephmachado blog

## Requirements:
- AWS CLI
- Terraform
- Docker, Docker Compose

## Step by Step

### Run on local computer
 - clone repo
 - access repo by terminal
 - run make up
 
 
 ### Deploy on AWS
 - clone repo
 - It is possible to edit "my_ip" variable default value to personal computer ipv4 or range of ips (Optional)
 - run make infra-up
 - Access dns instance on port 8080 for airflow, 3000 for metabase.
 - run infra-down to destroy infra.
 
 
 ## Next Steps
 - Add spark service
 - Automate load of variables and connections on airflow
 - Add S3 resource on terraform
 - add tests
 - add CI/CD pipeline on github actions
 
