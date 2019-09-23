provider "vscale" {
  token = "${var.vs_token}"
}

resource "vscale_ssh_key" "root" {
  name = "kornyakovdy root key"
  key  = "${file(".ssh/id_rsa.pub")}"
}

resource "vscale_ssh_key" "rb" {
  name = "rebrain root key"
  key  = "${file(".ssh/rb.pub")}"
}

resource "vscale_scalet" "terraform6" {
  count     = "${var.srvcount}"
  ssh_keys  = ["${vscale_ssh_key.root.id}","vscale_ssh_key.rb.id"]
  make_from = "${var.vscale_centos_7}"
  location  = "${var.vscale_msk}"
  rplan     = "${var.vscale_rplan["s"]}"
  name      = "${var.srvtemplname}${count.index}"

    connection {
      host     = "${self.public_address}"
      type     = "ssh"
      user     = "root"
      private_key = "${file(".ssh/id_rsa")}"
    }

  provisioner "remote-exec" {
    inline = [
      "hostnamectl set-hostname  ${var.srvtemplname}${count.index}"
    ]
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "${var.aws_acckey}"
  secret_key = "${var.aws_skey}"
}


data "aws_route53_zone" "rb" {
  name = "devops.rebrain.srwx.net."
}

resource "aws_route53_record" "kornyakovdy" {
  count   = "${var.srvcount}"
  zone_id = "${data.aws_route53_zone.rb.zone_id}"
  name    = "${var.srvtemplname}${count.index}.${data.aws_route53_zone.rb.name}"
  type    = "A"
  ttl     = "300"
  records = ["${vscale_scalet.terraform6.*.public_address[count.index]}"]
}

data "template_file" "data_json" {
  template = "${file("${path.module}/data.tmpl")}"
  count    = "${var.srvcount}"
  vars = {
    srvname = "${vscale_scalet.terraform6.*.name[count.index]}"
    srvip = "${vscale_scalet.terraform6.*.public_address[count.index]}"
  }
}

output "json" {
  value = "${data.template_file.data_json.*.rendered}"
}

#resource "null_resource" "devstxt" {
#  count   = "${var.srvcount}"
#  provisioner "local-exec" {
#    command = "echo ${var.srvs[count.index]} ${vscale_scalet.terraform6.*.public_address[count.index]} >> ./devs.txt"
#  }
#}
