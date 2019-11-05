"aws_launch_configuration" "this" {
	  count = var.create_lc ? 1 : 0
	

	  name_prefix                 = "${coalesce(var.lc_name, var.name)}-"
	  image_id                    = var.image_id
	  instance_type               = var.instance_type
	  iam_instance_profile        = var.iam_instance_profile
	  key_name                    = var.key_name
	  security_groups             = var.security_groups
	  associate_public_ip_address = var.associate_public_ip_address
	  user_data                   = var.user_data
	  enable_monitoring           = var.enable_monitoring
	  spot_price                  = var.spot_price
	  placement_tenancy           = var.spot_price == "" ? var.placement_tenancy : ""
	  ebs_optimized               = var.ebs_optimized
	

	  dynamic "ebs_block_device" {
	    for_each = var.ebs_block_device
	    content {
	      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
	      device_name           = ebs_block_device.value.device_name
	      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
	      iops                  = lookup(ebs_block_device.value, "iops", null)
	      no_device             = lookup(ebs_block_device.value, "no_device", null)
	      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
	      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
	      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
	    }
	  }
	

	  dynamic "ephemeral_block_device" {
	    for_each = var.ephemeral_block_device
	    content {
	      device_name  = ephemeral_block_device.value.device_name
	      virtual_name = ephemeral_block_device.value.virtual_name
	    }
	  }
	

	  dynamic "root_block_device" {
	    for_each = var.root_block_device
	    content {
	      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
	      iops                  = lookup(root_block_device.value, "iops", null)
	      volume_size           = lookup(root_block_device.value, "volume_size", null)
	      volume_type           = lookup(root_block_device.value, "volume_type", null)
	    }
	  }
	

	  lifecycle {
	    create_before_destroy = true
	  }
	}
	

	resource "aws_autoscaling_group" "this" {
	  count = var.create_asg && false == var.create_asg_with_initial_lifecycle_hook ? 1 : 0
	

	  name_prefix = "${join(
	    "-",
	    compact(
	      [
	        coalesce(var.asg_name, var.name),
	        var.recreate_asg_when_lc_changes ? element(concat(random_pet.asg_name.*.id, [""]), 0) : "",
	      ],
	    ),
	  )}-"
	  launch_configuration = var.create_lc ? element(concat(aws_launch_configuration.this.*.name, [""]), 0) : var.launch_configuration
	  vpc_zone_identifier  = var.vpc_zone_identifier
	  max_size             = var.max_size
	  min_size             = var.min_size
	  desired_capacity     = var.desired_capacity
	

	  load_balancers            = var.load_balancers
	  health_check_grace_period = var.health_check_grace_period
	  health_check_type         = var.health_check_type
	

	  min_elb_capacity          = var.min_elb_capacity
	  wait_for_elb_capacity     = var.wait_for_elb_capacity
	  target_group_arns         = var.target_group_arns
	  default_cooldown          = var.default_cooldown
	  force_delete              = var.force_delete
	  termination_policies      = var.termination_policies
	  suspended_processes       = var.suspended_processes
	  placement_group           = var.placement_group
	  enabled_metrics           = var.enabled_metrics
	  metrics_granularity       = var.metrics_granularity
	  wait_for_capacity_timeout = var.wait_for_capacity_timeout
	  protect_from_scale_in     = var.protect_from_scale_in
	

	  tags = concat(
	    [
	      {
	        "key"                 = "Name"
	        "value"               = var.name
	        "propagate_at_launch" = true
	      },
	    ],
	    var.tags,
	    local.tags_asg_format,
	  )
	

	  lifecycle {
	    create_before_destroy = true
	  }
	}
	
	resource "aws_autoscaling_group" "this_with_initial_lifecycle_hook" {
	  count = var.create_asg && var.create_asg_with_initial_lifecycle_hook ? 1 : 0
	

	  name_prefix = "${join(
	    "-",
	    compact(
	      [
	        coalesce(var.asg_name, var.name),
	        var.recreate_asg_when_lc_changes ? element(concat(random_pet.asg_name.*.id, [""]), 0) : "",
	      ],
	    ),
	  )}-"
	  launch_configuration = var.create_lc ? element(aws_launch_configuration.this.*.name, 0) : var.launch_configuration
	  vpc_zone_identifier  = var.vpc_zone_identifier
	  max_size             = var.max_size
	  min_size             = var.min_size
	  desired_capacity     = var.desired_capacity
	

	  load_balancers            = var.load_balancers
	  health_check_grace_period = var.health_check_grace_period
	  health_check_type         = var.health_check_type
	

	  min_elb_capacity          = var.min_elb_capacity
	  wait_for_elb_capacity     = var.wait_for_elb_capacity
	  target_group_arns         = var.target_group_arns
	  default_cooldown          = var.default_cooldown
	  force_delete              = var.force_delete
	  termination_policies      = var.termination_policies
	  suspended_processes       = var.suspended_processes
	  placement_group           = var.placement_group
	  enabled_metrics           = var.enabled_metrics
	  metrics_granularity       = var.metrics_granularity
	  wait_for_capacity_timeout = var.wait_for_capacity_timeout
	  protect_from_scale_in     = var.protect_from_scale_in
	

	  initial_lifecycle_hook {
	    name                    = var.initial_lifecycle_hook_name
	    lifecycle_transition    = var.initial_lifecycle_hook_lifecycle_transition
	    notification_metadata   = var.initial_lifecycle_hook_notification_metadata
	    heartbeat_timeout       = var.initial_lifecycle_hook_heartbeat_timeout
	    notification_target_arn = var.initial_lifecycle_hook_notification_target_arn
	    role_arn                = var.initial_lifecycle_hook_role_arn
	    default_result          = var.initial_lifecycle_hook_default_result
	  }
	

	  tags = concat(
	    [
	      {
	        "key"                 = "Name"
	        "value"               = var.name
	        "propagate_at_launch" = true
	      },
	    ],
	    var.tags,
	    local.tags_asg_format,
	  )
	

	  lifecycle {
	    create_before_destroy = true
	  }
	}
	

	resource "random_pet" "asg_name" {
	  count = var.recreate_asg_when_lc_changes ? 1 : 0
	

	  separator = "-"
	  length    = 2
	

	  keepers = {
	    # Generate a new pet name each time we switch launch configuration
	    lc_name = var.create_lc ? element(concat(aws_launch_configuration.this.*.name, [""]), 0) : var.launch_configuration
	  }
	}

resource "aws_volume_attachment" "this_ec2" {
 	  count = var.instances_number

 	 device_name = "/dev/sdh"
 	 volume_id   = ${ssm:/myapp/${self:provider.stage}/infra/ebs_id}
 	 instance_id = module.ec2.id[count.index]
}

Resource "aws_ebs_volume" "this" {
  	count = var.instances_number

  	availability_zone = module.ec2.availability_zone[count.index]
  	size              = 1
}
resource "aws_ssm_parameter" "ebs_id" {
  	  name  = "/myapp/${terraform.workspace}/infra/ebs_id"
 	 type  = "String"
 	 value = "${join(",", ${ this})}"
}

resource "aws_route53_record" "www-dev" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "www"
  type    = "CNAME"
  ttl     = "5"

  weighted_routing_policy {
    weight = 10
  }

  set_identifier = "dev"
  records        = ["dev.example.com"]
}

resource "aws_route53_record" "www-live" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "www"
  type    = "CNAME"
  ttl     = "5"

  weighted_routing_policy {
    weight = 90
  }

  set_identifier = "live"
  records        = ["live.example.com"]
}
