# Active-Active RE Deployment in AWS for Search Workshop Lab6
This Terraform script will deploy Active-Active CRDB databases between two Redis Enterprise Clusters in different regions for the workshop participants to run active active json/search exercises in lab6

*********

### Prerequisites

* aws-cli with aws access key and secret key
* Terraform installed on local machine
* Ansible installed on local machine
* Visual Studio Code
* R53 DNS_hosted_zone_id *(if you do not have one already, go get a domain name on Route53)*
* **AWS generated** SSH keys for **each region** where you are creating a cluster
    - To create new keys: ([link](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html))
        - MUST INCLUDE REGION PARAM
    - EXAMPLE:
    - REGION A SSH KEY
    ```
    aws ec2 create-key-pair \
    --key-name my-key-pair-west \
    --key-type rsa \
    --key-format pem \
    --query “KeyMaterial” \
    --region “us-west-2" \
    --output text > my-key-pair-west.pem
    ```
    - REGION B SSH KEY
    ```
    aws ec2 create-key-pair \
    --key-name my-key-pair-east \
    --key-type rsa \
    --key-format pem \
    --query “KeyMaterial” \
    --region “us-east-1" \
    --output text > my-key-pair-east.pem
    ```
    - **you must chmod 400 the key before use**
* Redis Enterprise License File input in the `re-license` folder
    - Free Trial License found here ([link](https://redis.com/redis-enterprise-software/pricing/))
* install `requirements.txt` file
    - `pip3 install -r requirements.txt`

#### Detailed instructions
1.  Install `aws-cli` on your local machine and run `aws configure` ([link](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)) to set your access and secret key.
    - If using an aws-cli profile other than `default`, `main.tf` may need to edited under the `provider "aws"` block to reflect the correct `aws-cli` profile.
2.  Download the `terraform` binary for your operating system ([link](https://www.terraform.io/downloads.html)), and make sure the binary is in your `PATH` environment variable.
    - MacOSX users:
        - (if you see an error saying something about security settings follow these instructions), ([link](https://github.com/hashicorp/terraform/issues/23033))
        - Just control click the terraform unix executable and click open. 
    - *you can also follow these instructions to install terraform* ([link](https://learn.hashicorp.com/tutorials/terraform/install-cli))
 3.  Install `ansible` via `pip3 install ansible` to your local machine.
     - A terraform local-exec provisioner is used to invoke a local executable and run the ansible playbooks, so ansible must be installed on your local machine and the path needs to be updated.
     - example steps:

    ```
    # create virtual environment
    python3 -m venv ./venv
    # Check if you have pip
    python3 -m pip -V
    # Install ansible and check if it is in path
    python3 -m pip install --user ansible
    # check if ansible is installed:
    ansible --version
    # If it tells you the path needs to be updated, update it
    echo $PATH
    export PATH=$PATH:/path/to/directory
    # example: export PATH=$PATH:/Users/username/Library/Python/3.8/bin
    # (*make sure you choose the correct python version you are using*)
    # you can check if its in the path of your directory by typing "ansible-playbook" and seeing if the command exists

    # To run crdb python script and ansible please install requirements.txt file
    pip3 install -r requirements.txt
    ```

***************

### Instructions for Use:
1. Open repo in VS code
2. Update `terraform.tfvars` variable inputs with your own inputs
    - Some require user input, some will will use a default value if none is given
3. Input Redis Enterprise License file in the `re-license` folder
    - change the `re-license.txt.example` to simply `re-license.txt` then enter in your license file.
    - Free Trial License found here ([link](https://redis.com/redis-enterprise-software/pricing/))
4. Edit `crdbs.tf` and change variable `crdbs` to configure a crdb for each workshop participant 
    - example config: 
    ```
    default = ["crdb1","crdb2","crdb3","crdb4","crdb5","crdb6","crdb7","crdb8","crdb9","crdb10"]
    ```
5. Now you are ready to go!
    * Open a terminal in VS Code:
    ```bash
    # create virtual environment
    python3 -m venv ./venv
    # install requirements.txt file
    pip3 install -r requirements.txt
    # ensure ansible is in path (you should see an output showing ansible is there)
    # if you see nothing refer back to the prerequisites section for installing ansible.
    ansible --version
    # run terraform commands
    terraform init
    terraform plan
    terraform apply
    # Enter a value: yes
    # can take around 10 minutes to provision cluster
    # then will print outputs of cluster FQDN and Ansible cmds
    # for running the memtier data loading & benchmark cmds per cluster
    ```

6. After a successful run you will have a list of all crdb endpoints created on both cluster
 - example output:
```
outputs:

crdb_endpoint_cluster1 = [
  "redis-12000.yuan-workshop-us-east-1-cluster.redisdemo.com",
  "redis-12001.yuan-workshop-us-east-1-cluster.redisdemo.com",
  "redis-12002.yuan-workshop-us-east-1-cluster.redisdemo.com",
  "redis-12003.yuan-workshop-us-east-1-cluster.redisdemo.com",
  "redis-12004.yuan-workshop-us-east-1-cluster.redisdemo.com",
  "redis-12005.yuan-workshop-us-east-1-cluster.redisdemo.com",
  "redis-12006.yuan-workshop-us-east-1-cluster.redisdemo.com",
  "redis-12007.yuan-workshop-us-east-1-cluster.redisdemo.com",
  "redis-12008.yuan-workshop-us-east-1-cluster.redisdemo.com",
  "redis-12009.yuan-workshop-us-east-1-cluster.redisdemo.com",
]
crdb_endpoint_cluster2 = [
  "redis-12000.yuan-workshop-us-west-2-cluster.redisdemo.com",
  "redis-12001.yuan-workshop-us-west-2-cluster.redisdemo.com",
  "redis-12002.yuan-workshop-us-west-2-cluster.redisdemo.com",
  "redis-12003.yuan-workshop-us-west-2-cluster.redisdemo.com",
  "redis-12004.yuan-workshop-us-west-2-cluster.redisdemo.com",
  "redis-12005.yuan-workshop-us-west-2-cluster.redisdemo.com",
  "redis-12006.yuan-workshop-us-west-2-cluster.redisdemo.com",
  "redis-12007.yuan-workshop-us-west-2-cluster.redisdemo.com",
  "redis-12008.yuan-workshop-us-west-2-cluster.redisdemo.com",
  "redis-12009.yuan-workshop-us-west-2-cluster.redisdemo.com",
]
```

#### Accessing the Clusters
* Output name: `re-cluster-url` & `re-cluster-url2`
    * go to chrome browser, enter in the output https address, accept the privacy button, log in with credentials configure in `re-cluster-username` & `re-cluster-password`

## Cleanup

Remove the resources that were created.

```bash
  terraform destroy
  # Enter a value: yes
```