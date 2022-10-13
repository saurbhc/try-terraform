resource "aws_s3_object_copy" "test" {
  bucket = "gen-zoo-test"
  key    = "config_${timestamp()}.json"
  source = "gen-zoo-test/config.json"
}
