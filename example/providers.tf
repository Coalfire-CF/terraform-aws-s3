provider "aws" {
  region            = var.aws_region
  profile           = var.profile
  use_fips_endpoint = true
  default_tags {
    tags = {
      Application = "management_plane"
      Owner       = "Coalfire"
      Team        = "Build"
      Environment = "dev"
    }
  }
  ignore_tags {
    keys = ["map-migrated"]
  }
}