# Steps to run

1. ```bash
    ssh-keygen -b 4096
    ```

2. Copy ~/.ssh/id_rsa.pub and paste it to `public_key` value of `aws_key_pair` resource in `instance_extras.tf` file.
3. ```bash
    terraform init
    ```
3. ```bash
    terraform apply -auto-approve
    ```