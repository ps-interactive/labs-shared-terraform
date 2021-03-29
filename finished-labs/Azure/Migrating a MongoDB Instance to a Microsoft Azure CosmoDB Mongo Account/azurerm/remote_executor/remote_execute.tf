resource "null_resource" "install-mongo" {

    provisioner "file" {
        source = "./mongo-init.sh"
        destination = "/tmp/mongo-init.sh"
        connection {
            type = "ssh"
            user = var.username
            password = var.password
            host = var.public_ip
            port = 22
        }
    }

    provisioner "file" {
        source = "./mongod.conf"
        destination = "./mongod.conf"
        connection {
            type = "ssh"
            user = var.username
            password = var.password
            host = var.public_ip
            port = 22
        }
    }

    provisioner "remote-exec" {
        inline = [
            "/bin/bash /tmp/mongo-init.sh"
        ]
        connection {
            type = "ssh"
            user = var.username
            password = var.password
            host = var.public_ip
            port = 22
        }
    }
}
