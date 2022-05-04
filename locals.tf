locals {
  defaults = {
    cpu           = 256
    memory        = 512
    desired_count = 2

    deregistration_delay = 30
    network_mode    = "awsvpc"
    compatibilities = ["FARGATE"]
  }
}
