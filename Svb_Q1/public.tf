resource "aws_instance" "v1" {
    ami = "${lookup(var.amis, var.aws_region)}"
    availability_zone = "eu-west-1a"
    instance_type = "m1.small"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.web.id}"]
    subnet_id = "${aws_subnet.eu-west-1a-public.id}"
    associate_public_ip_address = true
    source_dest_check = false


    tags {
        Name = "v1"
    }
}
resource "aws_instance" "v2" {
    ami = "${lookup(var.amis, var.aws_region)}"
    availability_zone = "eu-west-1a"
    instance_type = "m1.small"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.web.id}"]
    subnet_id = "${aws_subnet.eu-west-1a-public.id}"
    associate_public_ip_address = true
    source_dest_check = false


    tags {
        Name = "v2"
    }
}

resource "aws_eip" "web-1" {
    instance = "${aws_instance.web-1.id}"
    vpc = true
}
resource "aws_eip" "web-2" {
    instance = "${aws_instance.web-2.id}"
    vpc = true
}


resource "aws_s3_bucket" "s3" {
  bucket = "svbsamplecode"
}

resource "aws_vpc_endpoint" "frontend_s3" {
  vpc_id = "034591dac1doe9fc3"
  service_name = "com.amazonaws.ap-eu-west-1a.s3"
 tags = {
    Environment = "svb-vpc_endpoint"
  }
}
