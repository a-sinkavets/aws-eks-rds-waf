resource "aws_eks_cluster" "eks-cluster" {
  name      = "${var.prefix}-cluster"
  role_arn  = aws_iam_role.eks-cluster-role.arn
  version   = var.eks_version

  vpc_config {
    security_group_ids = [ aws_security_group.eks-control-sg.id, aws_security_group.eks-nodegroup-sg.id ]
    subnet_ids         = [ aws_subnet.eks-private[0].id, aws_subnet.eks-private[1].id, aws_subnet.eks-private[2].id ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy,
  ]
}


resource "aws_eks_node_group" "eks-nodes-ec2" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "${var.prefix}-node-group"
  node_role_arn   = aws_iam_role.eks-nodegroup-role.arn
  subnet_ids      = [ aws_subnet.eks-private[0].id, aws_subnet.eks-private[1].id, aws_subnet.eks-private[2].id ]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  ami_type       = "AL2_x86_64"
  instance_types = ["t3.micro"]
  capacity_type  = "ON_DEMAND"
  disk_size      = 20

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKS_CNI_Policy
  ]
}
