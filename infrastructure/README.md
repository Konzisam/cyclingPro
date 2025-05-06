## Snowflake Setup with Terraform
>[!NOTE]
>The project can be run using the free trial.

* The best practise when working with snowflake and tools such as Terraform is to create a role , granting only the permissions it needs. 

### Steps
1. Generate key pair for use
2. Create a  role and add the necessary permissions in snowflake
3. Configure Snowflake provider in Terraform with key-based authentication  
4. Create Snowflake warehouse, databases, and if necessary users and assign them roles; Granting privileges on databases and warehouse to the appropriate roles. 
5. Apply Terraform to provision resources  

#### Generating a private key and public key.

```
# Generate a private key
openssl genrsa -out snowflake_key.pem 2048

# Generate a public key from the private key
openssl rsa -in snowflake_key.pem -pubout -out snowflake_key.pub
```
#### Creating role and adding permissions
The RSA_PUBLIC_KEY is the content of the public key, base64-encoded and without the -----BEGIN PUBLIC KEY----- headers.


In snowflake console, we create the roles and grant the necessary permissions.
```
-- Use a high-privilege role to create and assign
USE ROLE ACCOUNTADMIN;

-- 1. Create the Terraform role
CREATE ROLE TERRAFORM_ADMIN;

-- 2. Grant essential privileges
-- Allow creation of objects
GRANT CREATE DATABASE ON ACCOUNT TO ROLE TERRAFORM_ADMIN;
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE TERRAFORM_ADMIN;
GRANT CREATE ROLE ON ACCOUNT TO ROLE TERRAFORM_ADMIN;

-- 3. Allow managing integration & file formats
GRANT CREATE FILE FORMAT ON ACCOUNT TO ROLE TERRAFORM_ADMIN;
GRANT CREATE STAGE ON ACCOUNT TO ROLE TERRAFORM_ADMIN;

-- 4. Create User 
CREATE USER TERRAFORM_USER
  DEFAULT_ROLE = TERRAFORM_ADMIN
  MUST_CHANGE_PASSWORD = FALSE
  RSA_PUBLIC_KEY = '<your_public_key>'
  COMMENT = 'Terraform automation user';

-- 5. Assign the role to your Terraform user
GRANT ROLE TERRAFORM_ADMIN TO USER TERRAFORM_USER;

-- view users
SHOW USERS;
```
>[!NOTE]
>Note: If we want to .
ALTER WAREHOUSE cycling_pro_wh RESUME;

#### Step 3 Configure Snowflake Provider in Terraform
* Ensure the variables and the `.env` is properly configured with the Snowflake credentials and region details. Here is a sample template.
```
TF_VAR_SNOWFLAKE_ORGANIZATION=""
TF_VAR_SNOWFLAKE_ACCOUNT=""
TF_VAR_SNOWFLAKE_USER=""
TF_VAR_SNOWFLAKE_PRIVATE_KEY_PATH="
TF_VAR_DATABASE=""
```

#### Step 4 & 5 Provision Resources with Terraform
```
terraform init
terraform apply
```
This will create the Snowflake warehouse, databases, and user roles, as well as other necessary resources based on the provided Terraform configurations.

With that the snowflake infrastructure is ready and the workflows can be deployed to prod.
