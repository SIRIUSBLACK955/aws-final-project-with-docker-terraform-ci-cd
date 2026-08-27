resource "aws_vpc" "project_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "project-vpc"
    }
}

resource "aws_subnet" "project_subnet_public_1" {
    vpc_id = aws_vpc.project_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "project-subnet-public-1"
    }
}

resource "aws_subnet" "project_subnet_public_2" {
    vpc_id = aws_vpc.project_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    tags = {
        Name = "project-subnet-public-2"
    }
}

resource "aws_internet_gateway" "project_igw" {
    vpc_id = aws_vpc.project_vpc.id
    tags = {
        Name = "project-igw"
    }
}

resource "aws_route_table" "project_route_table" {
    vpc_id = aws_vpc.project_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.project_igw.id
    }
}

resource "aws_route_table_association" "project_route_table_association_1" {
    subnet_id = aws_subnet.project_subnet_public_1.id
    route_table_id = aws_route_table.project_route_table.id
}

resource "aws_route_table_association" "project_route_table_association_2" {
    subnet_id = aws_subnet.project_subnet_public_2.id
    route_table_id = aws_route_table.project_route_table.id
}

resource "aws_security_group" "project_security_group" {
    name = "project-security-group"
    description = "Security group for project instances"
    vpc_id = aws_vpc.project_vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "project_instance" {
    ami = "ami-000658d93b648929c" # Amazon Linux 2 AMI
    instance_type = "t2.medium"
    subnet_id = aws_subnet.project_subnet_public_1.id
    vpc_security_group_ids = [aws_security_group.project_security_group.id]
    key_name = "project" # Replace with your key pair name
    associate_public_ip_address = true

    tags = {
        Name = "project-instance"
    }
  
}

resource "aws_lb_target_group" "project_target_group" {
    name     = "project-target-group"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.project_vpc.id

    health_check {
        path                = "/"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        matcher             = "200-299"
    }
}

resource "aws_lb" "project_load_balancer" {
    name               = "project-load-balancer"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.project_security_group.id]
    subnets            = [aws_subnet.project_subnet_public_1.id, aws_subnet.project_subnet_public_2.id]

    tags = {
        Name = "project-load-balancer"
    }
}

resource "aws_lb_listener" "project_listener" {
    load_balancer_arn = aws_lb.project_load_balancer.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.project_target_group.arn
    }
}

# resource "aws_autoscaling_group" "project_asg" {
#     desired_capacity     = 2
#     max_size             = 3
#     min_size             = 1
#     vpc_zone_identifier  = [aws_subnet.project_subnet_public_1.id, aws_subnet.project_subnet_public_2.id]
#     target_group_arns    = [aws_lb_target_group.project_target_group.arn]
#     launch_configuration = aws_launch_configuration.project_launch_configuration.id

#     tag {
#         key                 = "Name"
#         value               = "project-asg-instance"
#         propagate_at_launch = true
#     }
# }

# resource "aws_launch_configuration" "project_launch_configuration" {
#     name          = "project-launch-configuration"
#     image_id      = "ami-0c4e355e0cc9c5225" # Amazon Linux 2 AMI
#     instance_type = "t2.medium"
#     security_groups = [aws_security_group.project_security_group.id]
#     key_name      = "project" # Replace with your key pair name

#     lifecycle {
#         create_before_destroy = true
#     }
# }