resource "aws_security_group" "eks-control-sg" {
  name        = "${var.prefix}-control-sg"
  description = "Communication between the control plane and worker nodegroups"
  vpc_id      = aws_vpc.eks-cluster.id

  tags = {
    Owner       = var.prefix
    Environment = "Dev"
  }
}

resource "aws_security_group_rule" "eks-control-rule-in" {
  description              = "Allow control plane to receive API requests from worker nodes"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks-nodegroup-sg.id
  security_group_id        = aws_security_group.eks-control-sg.id
}

resource "aws_security_group_rule" "eks-control-rule-out-1" {
  description              = "workloads using HTTPS port"
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks-nodegroup-sg.id
  security_group_id        = aws_security_group.eks-control-sg.id
}

resource "aws_security_group_rule" "eks-control-rule-out-2" {
  description              = "kubelet and workload TCP ports"
  type                     = "egress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks-nodegroup-sg.id
  security_group_id        = aws_security_group.eks-control-sg.id
}

resource "aws_security_group" "eks-nodegroup-sg" {
  name        = "${var.prefix}-nodegroup-sg"
  description = "Communication between the control plane and worker nodes"
  vpc_id      = aws_vpc.eks-cluster.id

  tags = {
    Owner       = var.prefix
    Environment = "Dev"
  }
}

resource "aws_security_group_rule" "eks-nodegroup-rule-in-1" {
  description              = "workloads using HTTPS port"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks-control-sg.id
  security_group_id        = aws_security_group.eks-nodegroup-sg.id
}

resource "aws_security_group_rule" "eks-nodegroup-rule-in-2" {
  description              = "kubelet and workload TCP ports"
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks-control-sg.id
  security_group_id        = aws_security_group.eks-nodegroup-sg.id
}

resource "aws_security_group_rule" "eks-nodegroup-rule-in-3" {
  description              = "Allow node to communicate with each other"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  self                     = true
  security_group_id        = aws_security_group.eks-nodegroup-sg.id
}

resource "aws_security_group_rule" "eks-nodegroup-rule-out" {
  description       = "workloads using HTTPS port"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks-nodegroup-sg.id
}
