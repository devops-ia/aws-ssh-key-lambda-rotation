# Null Resource
## Build layer
resource "null_resource" "build_lambda_layers" {
  provisioner "local-exec" {
    command = <<CMD
    virtualenv -p ${element(var.lambda_layer.default.compatible_runtimes, 2)} src/venv;
    src/venv/bin/pip install -r src/requirements.txt --target src/venv/python;
    cd src/venv;
    zip -r ../../libs.zip python/*;
CMD

    interpreter = ["bash", "-c"]
  }
}
