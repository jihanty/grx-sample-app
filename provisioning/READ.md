1. Install terraform if not already done so 

 On Mac OS 
        Install homebrew first.
                ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
        Install terraform.
                brew install terraform
 On Windows 
        https://www.vasos-koupparis.com/terraform-getting-started-install/
 On Linux 
        Install unzip

        sudo apt-get install unzip
        Confirm the latest version number on the terraform website:

        https://www.terraform.io/downloads.html
        Download latest version of the terraform (substituting newer version number if needed)

        wget https://releases.hashicorp.com/terraform/0.12.7/terraform_0.12.7_linux_amd64.zip
        Extract the downloaded file archive

        unzip terraform_0.12.7_linux_amd64.zip
        Move the executable into a directory searched for executables

        sudo mv terraform /usr/local/bin/
        Run it

        terraform --version 
2. Clone github project 
        git clone https://github.com/jihanty/grx-sample-app.git

3. configure your aws key and secrets in your ~/.aws directory. You should have been given the key and scret by your administrator for this task

4. run the following command from "provisiong" subdirectory 
    cd grx-sample-app/provisioning
    terraform init -backend-config=infrastructure-prod.config

5. run terraform plan command to chek the provisioning plan (optional)
    terraform plan -var-file=production.tfvars -out=output.run

6. run terraform apply to create the infrastructure . Please enter your computer public ip to run the terraform script by typing "what is my ip" in google search box. The scipt will spit out an dns name of the external load balancer in the form elb_dns_name = my-elb-XXXXXXX.us-west-2.elb.amazonaws.com
    
    terraform apply  -var-file=production.tfvars --auto-approve 

7. To run the tests  we need to get the classic loadbalancer  DNS name which will be the output of the step 6 above.  

curl -X POST http://<<elb_dns_name>>/builds --data  @data.txt -H "Content-Type: application/json"

8. To destroy the above infrastructure run - 

    terraform destroy  -var-file=production.tfvars --auto-approve 




