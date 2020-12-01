# Infrastructure

Uploading the main template should create an infrastructure that looks like this:

![diagram](https://raw.githubusercontent.com/zzenonn/CloudformationTemplates/master/infrastructure/__assets/diagram.png)

**Note:** This template is parameterized, so the final output is completely dependent on how you configure the template. It will also launch in the **Singapore** region. It also looks for a secure SSM parameter called **dbPassword** for the RDS password.
