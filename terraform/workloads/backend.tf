terraform {
  backend "gcs" {
    bucket = "tfstate-test-kose"
    prefix = "state"
  }
}
