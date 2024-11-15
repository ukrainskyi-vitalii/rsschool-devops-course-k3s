
resource "aws_ecr_repository" "rs-school_app" {
  name                 = "rs-school_app"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_lifecycle_policy" "my_app_policy" {
  repository = aws_ecr_repository.rs-school_app.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep only the last 2 images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 2
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}
