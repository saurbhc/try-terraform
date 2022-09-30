# Steps to run

1. ```bash
    terraform init
    ```
2. ```bash
    terraform apply -auto-approve
    ```
3. ```bash
    terraform output kubeconfig > ~/.kube/config
    ```
4. Install [kubectl](https://kubernetes.io/docs/tasks/tools/)
5. Install [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html) on your machine.
5. ```bash
    aws-iam-authenticator version
    ```
6. ```bash
    kubectl cluster-info
    ```

# Play with the cluster

1. kubectl version --client --short
2. kubectl run nginx --image nginx
3. kubectl get all
4. kubectl delete pod nginx
5. kubectl get all
