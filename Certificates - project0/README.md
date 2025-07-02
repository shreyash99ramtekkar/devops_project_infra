# Setup For projects

In this setup project we will setup few things that we will need for the future projects.

## Prerequisites
- [AWS account Free tier](https://aws.amazon.com/free/?trk=ce1f55b8-6da8-4aa2-af36-3f11e9a449ae&sc_channel=ps&ef_id=CjwKCAjw6ZTCBhBOEiwAqfwJd5Iii_1fgY1dpLqz-DjslJJDPFiqVKq0ZCF3aW6A31BA977xaFBiYRoCqY0QAvD_BwE:G:s&s_kwcid=AL!4422!3!433803620870!e!!g!!aws%20free%20tier!9762827897!98496538463&gad_campaignid=9762827897&gbraid=0AAAAADjHtp-hv9TFx2lMpN1_kj3SfdsC5&gclid=CjwKCAjw6ZTCBhBOEiwAqfwJd5Iii_1fgY1dpLqz-DjslJJDPFiqVKq0ZCF3aW6A31BA977xaFBiYRoCqY0QAvD_BwE&all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc&awsf.Free%20Tier%20Types=*all&awsf.Free%20Tier%20Categories=*all)
- [Terraform installed](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Ansible installed](https://docs.ansible.com/ansible/latest/installation_guide/index.html)
- [AWS client](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Basic knowledge of AWS services](https://explore.skillbuilder.aws/learn/courses/134/aws-cloud-practitioner-essentials)
- [Go Daddy Domain](https://www.godaddy.com/en)

## Project Structure
```
├── terraform
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tf
│   └── output.tf 
└── README.md
```

# Step 1: Setup HTTPS Traffic Encryption with ACM and GoDaddy

- ## SSL Certificate with ACM
1. **Clone the repository**:
   ```bash
   git clone https://github.com/shreyash99ramtekkar/devops_project_infra.git
   cd devops_project_infra/Certificates\ -\ project0/terraform
    ```
2. **Configure AWS credentials**:
    Ensure your AWS credentials are configured. You can set them up using the [AWS CLI](https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-files.html#cli-configure-files-methods)
    ```bash
    aws configure
    ```
3. **Initialize Terraform**:
    ```bash
    terraform init
    ```
4. **Plan the Terraform deployment**:
    ```bash
    # Change the variables in the variable.tf file according to need.
    terraform plan
    ```
5. **Apply the Terraform configuration**:
    ```bash
    terraform apply
    ```

- ## Ensure the Domain is Registered and Matches ACM Configuration
    Verify that the domain you used in the ACM request is correctly [registered in GoDaddy]((https://www.godaddy.com/en/domains)), and you have access to manage its DNS records. 

- ## Add Validation Records in GoDaddy DNS 
    Add the CNAME records provided by ACM into your [GoDaddy DNS records](https://docs.aws.amazon.com/amplify/latest/userguide/to-add-a-custom-domain-managed-by-godaddy.html) to validate domain ownership.


- ##  Verify Certificate Status in ACM
    After the DNS records propagate (can take a few minutes), check in ACM. The certificate status should change from Pending validation to Issued.

    AWS Console ---> Certificate Manager ---> Certificate ---> Domains ---> Status 