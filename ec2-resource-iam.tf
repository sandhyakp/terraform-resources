resource "aws_iam_user" "iam_users" {
  count = length(var.iamusers)
  name  = var.iamusers[count.index]

}
