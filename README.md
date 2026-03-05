# Infra Sample
## Resource Summary
**ec2.t2.micro**
vCPU: 1
RAM: 1 GiB
Price: $0.0116/hr * 24 hr * 30 days = $8.352
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

**public ip address**
Price: $0.005/hr * 24 hr * 30 days = $3.60
- [Public IPv4 Addresses](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-ip-addressing.html#vpc-public-ipv4-addresses)

## TODO
- Ansible 
    - dynamic inventory from terraform
        https://github.com/theurbanpenguin/ansible_terraform_inventory/blob/main/inventory.py

    - install podman on aws
    - uninstall podman
- store application image on dockerhub
- create quadlet files that use dockerhub image and deploy systemd container
- makefile 
    - invokes ansible to deploy application
        - Applies to vm
            - ansible podman role
                - deploy
                - destroy
            - application role
                - deploy
                - destroy

    3. make i-t-azure-deploy
    4. run playbook that applies roles
    5. run playbook that removes roles
    6. make i-t-azure-destroy
    7. make s-image-dockerhub-remove

- github actions linter
- implement aws budget to track costs

This application:

- Github actions runs yaml and terraform linter, does not merge into main if it fails
- Uses Terraform to create a Linux VM on Azure
- Uses Ansible to deploy onto the Azure VM a VueJS frontend, ExpressJS backend
   application running as a Podman Quadlet.

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

### Notes
ami query is not generalized. unpredicatable. it is
better to just provide the id. cite os version management
when it comes to applications. Such as podman quadlets
not being available in rhel7, but available in rhel 8.
