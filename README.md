# Sample App
This repository showcases several strategies to deploy a "sample app" NodeJs
web application to the cloud. Presently, the primary showcase, as seen in
`infra/vm_podman_quadlet`, deploys the web application as a [Podman
Quadlet](https://docs.podman.io/en/latest/markdown/podman-quadlet.1.html)
container via Ansible, operating with a dynamic inventory, to an AWS EC2
instance spun up with OpenTofu (Terraform). The value of this strategy is that
it serves as a low cost, relatively simple method to deploy a containerized
application to the cloud, as compared to using Kubernetes. This strategy is
perfect for custom support apps with low traffic.

## Requirements
- `./`
    - [GNU Make](https://www.gnu.org/software/make/#download)
- `server/`
    - [NodeJs](https://nodejs.org/en/download)
    - [Dockerhub Account](https://hub.docker.com)
    - [Podman](https://podman.io/docs/installation)
- `frontend/`
    - [NodeJs](https://nodejs.org/en/download)
- `infra/vm_podman_quadlet/ansible`
    - [uv, a Python package manager](https://docs.astral.sh/uv/getting-started/installation/)
- `infra/vm_podman_quadlet/terraform`
    - [OpenTofu](https://opentofu.org/docs/intro/install/)

## Running the Application
1. Install system requirements, detailed above
2. Set environment variables
```
export DOCKERHUB_ACCOUNT=<docker hub account>
export DOCKERHUB_PASSWORD=<docker hub password>
```

3. Configure variables in `infra/vm_podman_quadlet/terraform/aws/dev.tfvars`
```
environment    = "dev"
region         = "us-east-1"
aws_access_key = "<aws_access_key>"
aws_secret_key = "<aws_secret_key>"
instance_type  = "t2.micro"

# https://www.centos.org/download/aws-images/
ami_id = "ami-0e2065a877604f106"

instance_name = "aws_sampleApp"
ssh_key_name  = "aws-sample-app-ssh-key"
ssh_user = "ec2-user" 
```

4. `make cloud-dev-deploy`
5. `make cloud-dev-destroy`

## Resource Summary
**ec2.t2.micro** \
vCPU: 1 \
RAM: 1 GiB \
Price: $0.0116/hr * 24 hr * 30 days = $8.352 \
- [EC2 T2 Pricing](https://aws.amazon.com/ec2/instance-types/t2/)
- [Choosing The Right EC2](https://aws.amazon.com/blogs/aws/choosing-the-right-ec2-instance-type-for-your-application/)
- [EC2 On Demand](https://aws.amazon.com/ec2/pricing/on-demand/)

**vpc**
free
- [AWS VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)

**internet gateway**
free
- [AWS Internet Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html)

**subnet**
free
- [Terraform cidrsubnet Function](https://kitemetric.com/blogs/mastering-terraform-s-cidrsubnet-function-a-comprehensive-guide)

**public ip address** \
Price: $0.005/hr * 24 hr * 30 days = $3.60
- [Public IPv4 Addresses](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-ip-addressing.html#vpc-public-ipv4-addresses)

## Future Considerations
Ideally, one ssh key is created for each cloud environment. Ansible will scan
the terraform dir, create a group for each sub dir (aws, gcp, azure), and then
add the hosts generated for those cloud providers in their respective groups,
with the `ansible_ssh_private_key_file` variable set for each group set to
`../terraform/<group-name>/<group-name>.pem`


One cannot pass a custom parameter to a dynamic inventory script when calling
it via ansible. Possible solutions are:

- defining the parameter as a system environment variable
- hard coding it in the inventory script


## Appendix
### Bibliography
- [AWS 2 Ec2s running in a vpc](https://medium.com/@akilblanchard09/creating-aws-ec2-instances-with-ssh-access-using-terraform-f9c3c2996cbd)
- [Podman Quadlet Tutorial](https://giacomo.coletto.io/blog/podman-quadlets/)
- [Podman Quadlet Docs](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)

### Notes
ami query is not generalized. unpredicatable. it is
better to just provide the id. cite os version management
when it comes to applications. Such as podman quadlets
not being available in rhel7, but available in rhel 8.
