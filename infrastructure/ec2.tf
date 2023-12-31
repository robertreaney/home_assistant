resource "aws_key_pair" "deployer" {
  key_name   = "helper-deployer-key"
  public_key = file("~/.ssh/id_rsa.pub") # Path to your public key
}

resource "aws_security_group" "helpful_ai_sg" {
  name        = "helpful_ai_sg"
  description = "Allow only ssh connections."

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # You might want to limit the CIDR blocks for better security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Helpful AI SG"
  }
}

resource "aws_instance" "helpful_ai" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t3a.nano"
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.helpful_ai_sg.id]

  user_data = data.template_file.ec2-startup.rendered

  tags = {
    Name = "HelpfulAIServer"
  }
}

# create elastic ip address for ec2 instance
resource "aws_eip" "helpful_ai_server" {
  instance = aws_instance.helpful_ai.id

  tags = {
    Name = "helpful-ai-eip"
  }
}

resource "aws_s3_bucket" "helpfulai_bucket" {
  bucket = "reaney-helpfulai"

  tags = {
    Name = "Helpful AI Bucket"
  }
}