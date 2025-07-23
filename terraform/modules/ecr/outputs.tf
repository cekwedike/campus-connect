output "repository_urls" {
  description = "ECR repository URLs"
  value = {
    for repo in var.repositories : repo => aws_ecr_repository.repositories[repo].repository_url
  }
}

output "repository_arns" {
  description = "ECR repository ARNs"
  value = {
    for repo in var.repositories : repo => aws_ecr_repository.repositories[repo].arn
  }
} 