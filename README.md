# SINCON2024 Modern Red Teaming workshop

This is the Git repository for the `Modern Red Teaming` workshop given at SINCON2024.

It is initially based on the [Multi-Stage-Mythic](https://github.com/kyleavery/Multi-Stage-Mythic) project from Kyle Avery, but with significant additions, upgrades and modifications:
* Cloudfront geo-restriction to cut noise from mass scanners and defeat some security solutions hosted in other countries
* Use of Cloudfront prefix list in the security group of the load balancer to prevent direct access
* ALB instead of ELB for content-based routing and WebSockets support
* ALB access logging for debugging / compliance purposes
* Use of SSM Session Manager instead of open SSH to avoid exposing the SSH port or setting up a bastion host. The instance is in a private subnet, with no public IP address assigned
* Use of EC2 `user-data` instead of Terraform's `remote-exec` provider as there's no native SSM support for the latter
* The `http` C2 profile now uses Docker volumes, so this project uses the new path to copy the `config.json` file
* Works with the new Mythic v3 (tested with v3.2.20-rc7)
* Dynamic Ubuntu AMI via aws_ami data source, to get the latest AMI and no hardcoded, region-dependent AMI ID
* Use of S3 as a Terraform state backend
* Use of `t4g.small` ARM64 EC2 instances as they're free for 750 hours / month until end 2024 :)
* Creation of a phishing server with pre-built `Evilginx2` and `Muraena` binaries
* No scripted payload generation, no Azure CDN to make things simpler during the workshop