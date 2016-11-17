# Overview
Creates a base NATS server, VPC and security groups.

# Start in the development directory.
Please test in the development directory. Once you're ready for production, you can update the main.tf there in your fork.

# Build your packer AMI
First, you need to build your NATS aws packer [ami](../../package/packer/). 
Using that AMI, update terraform.tfvars with the correct AMIs.

```
# development/main.tf
region = "us-east-1"
ami = {
  # this is a custom AMI built using the nats-aws-ubuntu-16.04.json packer build file
  us-east-1 = "ami-[Your New AMI ID]"
}

```

# Limiting Access 

To prevent instance ssh and admin consoles being accessible from any IP address

Get your local IP Address:

``` bash
export ADMIN_CIDR=`curl http://checkip.amazonaws.com/`
```

Then, use that network to set the admin_cidr var list. Or update with your own management network and appropriate CIDR.


# Plan the terraform
Set key_name to the name of the AWS key pair you want to use to access your AWS instances.

``` bash
terraform plan -var "admin_cidr=[\"$ADMIN_CIDR/1\"]" -var "key_name=aws"

```

# Build the terraform 

Warning: this will create billable AWS resources.
 
``` bash
terraform apply -var "admin_cidr=[\"$ADMIN_CIDR/1\"]" -var "key_name=aws"
```

# Connecting to your instance
Once you terraform completes, you can connect NATS clients to the ELB public  name in the Output  at port 4233. 
```
ELB Public Name = nats-elb-?.us-east-1.elb.amazonaws.com
```

# Failover timing
If an instance fails, the autoscale group will automatically restart the instance. Do *not* run more than 1 instance at a time against the EFS.
