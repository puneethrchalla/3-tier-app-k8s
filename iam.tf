 resource "aws_iam_policy" "aws-alb-ingress" {
   policy = file("iam-policy.json")
 }

 module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "2.14.0"
  create_role                   = true
  role_name                     = "aws-alb-ingress-role"
  provider_url                  = replace(module.demo-cluster.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.aws-alb-ingress.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:alb-ingress-controller"]
}