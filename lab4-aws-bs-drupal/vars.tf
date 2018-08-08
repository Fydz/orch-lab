# ---------------------------------------------------------------------------
variable "env" {
    type = "string"
    default = "dev"
}

variable "app" {
    type = "string"
    default = "mmh-extranet"
}

variable "customer" {
    type = "string"
    default = "mmh"
}

# ---------------------------------------------------------------------------
data "aws_availability_zones" "available" {}

# avail ${random_id.r.dec}
resource "random_id" "r" {
  byte_length = 4
}

# ---------------------------------------------------------------------------
# avail ${random_id.salt.b64_std} drupal HASH_SALT
resource "random_id" "salt" {
  byte_length = 64
}

# avail ${random_id.config_dir.b64_url} drupal SYNC_DIR
resource "random_id" "config_dir" {
  byte_length = 64
}
