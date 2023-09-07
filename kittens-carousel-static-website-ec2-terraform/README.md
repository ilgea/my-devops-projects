# Creating a Static Website on AWS EC2 using Terraform

In this project, we will create an Amazon Elastic Compute Cloud (EC2) instance and deploy a static website on it using Terraform and a Bash script. The static website files, including an `index.html` file and necessary images, are stored in a folder named `static-web` within the project directory.

## Prerequisites

Before proceeding, ensure that you have the following prerequisites:

1. **Terraform Installed**: Make sure Terraform is installed on your local machine. You can download it from [Terraform's official website](https://www.terraform.io/downloads.html).

2. **AWS Account**: You must have an AWS account with appropriate access credentials. Ensure you have configured your AWS credentials using the AWS CLI or environment variables.

3. **SSH Key Pair**: Create an SSH key pair or choose an existing one. This key pair will be used to connect to the EC2 instance securely.

## Project Structure

- `main.tf`: This Terraform configuration file defines the infrastructure resources required, such as EC2 instance, security group, etc.
- `carusel.sh`: This Bash script is executed on the EC2 instance. It sets up the web server and deploys the static website.

## Terraform Configuration

The `main.tf` file contains the Terraform configuration for creating the EC2 instance and associated resources. The main components include:

- **AWS Provider Configuration**: This section specifies the AWS region where the EC2 instance will be launched.

- **AWS AMI Data Source**: We retrieve the latest Amazon Linux 2 AMI ID for our EC2 instance.

- **Variables**: There are two variables defined:
    - `secgr-dynamic-ports`: A list of ports to open in the security group (default: 22, 80, 443).
    - `instance-type`: The EC2 instance type (default: t2.micro).

- **AWS Instance Resource**: This resource creates the EC2 instance, associates it with the security group, and uses the `carusel.sh` script as user data.

- **Null Resource**: This resource depends on the EC2 instance and is responsible for copying the static website files to the web server and restarting the HTTP service.

- **AWS Security Group**: This resource defines the security group allowing inbound SSH and HTTP traffic.

- **Output**: The public IP address of the EC2 instance is exposed as an output.

## Bash Script (`carusel.sh`)

The `carusel.sh` Bash script is executed on the EC2 instance. It performs the following tasks:

1. Updates the system packages and applies security updates.
2. Sets the hostname to "carusel".
3. Installs the Apache HTTP server (`httpd`).
4. Starts and enables the HTTP server.
5. Sets permissive permissions for the web server directory (`/var/www/html`).

## Usage

1. Clone this repository to your local machine:

``` bash
   git clone <repository-url>
   cd <repository-directory>
```

2. Initialize Terraform:

``` bash
    terraform init
```
   * Review and adjust Terraform variables in main.tf if needed.

3. Deploy the infrastructure:

``` bash
terraform apply
```
4. Once the deployment is complete, Terraform will output the public IP address of the EC2 instance.

5. Access your static website by visiting the public IP address in a web browser.

## Cleanup
To destroy the created resources and clean up, run:

``` bash
terraform destroy
```

## Security Considerations

**SSH Key Pair** : Ensure that you manage your SSH key pair securely, and do not share your private key with unauthorized individuals.

**Security Group**: The provided security group allows inbound SSH and HTTP traffic from any IP address (0.0.0.0/0). In a production environment, consider restricting access to only trusted IP addresses.

* Please ensure you follow AWS best practices for security, cost optimization, and resource management when using this setup in a production environment.
