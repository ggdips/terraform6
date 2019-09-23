# Rebrain Terraform 6

This is Terraform learning project

### Prerequisites

Download go
```
https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz
cd ~ && curl -O https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.12.7.linux-amd64.tar.gz
```

Make skelet
```
mkdir -p $HOME/terraform6
```

Configure env
```
echo "export GOPATH=$HOME/terraform6" >> ~/.bash_profile
echo "export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin" >> ~/.bash_profile
source .bash_profile
```

Install Go
```
mkdir -p $GOPATH/src/github.com/terraform-providers; cd $GOPATH/src/github.com/terraform-providers
git clone https://github.com/burkostya/terraform-provider-vscale.git terraform-provider-vscale
```
Enter the provider directory and build the provider
```
cd terraform-provider-vscale
go get ./...
go build
```
Add plugin to terraform

```
mkdir -p ~/.terraform.d/plugins/linux_amd64/
mv terraform-provider-vscale ~/.terraform.d/plugins/linux_amd64/
```
### Running
Copy vars.tf.example to vars.tf
```
cp vars.tf.example vars.tf
```
Customize vars.tf
```
variable "vs_token" {
  default  = "Put your token here"
}

variable "aws_acckey" {
  default  = "Put your AWS access key here"
}

variable "aws_skey" {
  default  = "Put your AWS secret key here"
}

variable "srvs" {
  type    = "list"
  default = [
    "Put your hostname-1",
    "Put your hostname-2",
    ...
  ]
}

```
```
terraform init
terraform apply
```

### Testing
Check connection
```
ssh root@`tail -n1 devs.txt | awk '{print $2}'` -i .ssh/id_rsa
```
