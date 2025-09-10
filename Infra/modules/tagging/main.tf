data "aws_region" "current" {}

locals {
  # Default tags áp dụng cho tất cả resource
  default_tags = {
    Region        = data.aws_region.current.name
    Environment   = var.environment
    Owner         = var.owner
    Project       = var.project
    ProvisionedBy = var.provisioned_by
  }

  # Lọc bỏ tag có giá trị null
  default_tags_map = {
    for k, v in local.default_tags : k => v if v != null
  }

  # Hợp nhất default + custom tags
  tags = merge(
    local.default_tags_map,
    var.extra_tags
  )
}
