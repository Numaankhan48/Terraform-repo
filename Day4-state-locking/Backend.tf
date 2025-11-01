terraform {
  backend "s3" {
    bucket = "terraform-bucket-state-file-storage"
    key    = "terraform.tfstate"
    #use_lockfile = true # to use s3 native locking 1.19 version above
    region = "us-west-2"
    dynamodb_table = "Numaan" # any version we can use dynamodb locking 
    encrypt = true
  }
}
