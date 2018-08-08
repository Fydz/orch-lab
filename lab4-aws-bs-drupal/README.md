installation DRUPAL
-------------------
* install infrastructure with terraform (init, plan, apply)
  * this should take around 5 minutes
  * check sites/default/files is a link to the S3 bucket
* create drupal package
  * create a drupal-X directory
  * from the drupal source
  * add .ebextensions directory
  * copy and adapt the startup.config file in .ebextensions (this will be used at boot by beanstalk)
  * add beanstalk-settings.php
  * zip : zip ../drupal-v0.zip -r -u * .[^.]*
* (option) add CNAME in your DNS pointing to the host created and available at beanstalk console and in the eb-cname output
* from the beanstalk console, add the version (drupal-v0.zip)
  * this should take around 2 minutes
* install drupal from the web console
* install modules, themes, ...
* on the server through ssh, from /var/app/current create new drupal-v1.zip
  * zip /tmp/drupal-v1.zip -r -u * .[^.]* -x sites/default\\*
* add .ebextensions directory to the archive
* publish the final version to beanstalk

commands
---------
* terraform init
* terraform plan
* terraform apply --auto-approve


biblio
------
instance profile for environnement
 https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html

S3
 https://github.com/s3fs-fuse/s3fs-fuse/wiki/Fuse-Over-Amazon
 https://cloudkul.com/blog/mounting-s3-bucket-linux-ec2-instance/

EC2 customize:
 https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/customize-containers-ec2.html