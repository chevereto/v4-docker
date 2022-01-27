target "docker-metadata-action" {}

target "build" {
  inherits = ["docker-metadata-action"]
  context = "./php/8.1"
  dockerfile = "Dockerfile"
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
}
