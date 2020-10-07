# Create a new Datadog monitor 5xx error rate monitor

# Create a new Pagerduty techservices
terraform {
  experiments = [variable_validation]
}

variable "datadogservice" {
  type        = string
  description = "The datadog service to monitor."
}
variable "datadogservice_alert_threshold" {
  type        = number
  description = "The datadog service critical threshold to monitor."
}
variable "datadogservice_warning_threshold" {
  type        = number
  description = "The datadog service warning threshold to monitor."
}
variable "datadogservice_alert_recover_threshold" {
  type        = number
  description = "The datadog service critical recovery threshold to monitor."
}
variable "datadogservice_warning_recover_threshold" {
  type        = number
  description = "The datadog service warning recovery threshold to monitor."
}
variable "datadogservice_time_period" {
  type        = string
  description = "The time period of which to assess the threshold."
  default = "30m"
  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^(1m|5m|10m|15m|30m|1h|2h|4h|1d|2d)$", var.datadogservice_time_period))
    error_message = "Allowed values for aggregated time period are \"<1m|5m|10m|15m|30m|1h|2h|4h|1d|2d>\"."
  }
}
variable "datadogservice_env" {
  type        = string
  description = "The environment associated with the Service."
}
variable "datadogservice_tenant" {
  type        = string
  description = "datadogservice_tenant."
  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^(maersk|apmt)$", var.datadogservice_tenant))
    error_message = "The type should be \"<maersk|apmt>\"."
  }
}
variable "datadogservice_region" {
  type        = string
  description = "datadogservice_region."
  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^(emea|apac|amer)$", var.datadogservice_region))
    error_message = "The type should be \"<emea|apac|amer>\"."
  }
}
variable "datadogservice_tenant_region" {
  type        = string
  description = "datadogservice_tenant_region."
  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^(maersk|apmt)_(emea|apac|amer)$", var.datadogservice_tenant_region))
    error_message = "The type should be \"<maersk|apmt>_<emea|apac|amer>\"."
  }
}
variable "datadogservice_cluster" {
  type        = string
  description = "datadogservice_cluster."
  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^(aop|apmt)-(prod|preprod|cdt)-(emea|apac|amer)$", var.datadogservice_cluster))
    error_message = "The type should be \"<aop|apmt>-<prod|preprod|cdt>-<emea|apac|amer>\"."
  }
}
variable "datadogservice_mode" {
  type        = string
  description = "datadogservice_mode."
  default = "rate"
  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^(rate|count)$", var.datadogservice_mode))
    error_message = "The mode should be \"<rate|count>\"."
  }
}

locals {
  thr_dd_srv_warn = var.datadogservice_warning_threshold
  thr_dd_srv_alert = var.datadogservice_alert_threshold
  thr_dd_srv_alert_recover= var.datadogservice_alert_recover_threshold
  thr_dd_srv_warn_recover = var.datadogservice_warning_recover_threshold
  ddog_env = var.datadogservice_env
  ddog_tenant = var.datadogservice_tenant
  ddog_region = var.datadogservice_region
  ddog_tenant_region = var.datadogservice_tenant_region
  ddog_cluster = var.datadogservice_cluster
  ddog_mode = var.datadogservice_mode
  query_rate = <<EOT
  avg(last_${var.datadogservice_time_period}):default_zero((default_zero(sum:trace.cassandra.query.errors{service:${var.datadogservice},env:${local.ddog_env},tenant_region:${local.ddog_tenant_region}}.as_rate()) /
  sum:trace.cassandra.query.hits{service:${var.datadogservice},env:${local.ddog_env},tenant_region:${local.ddog_tenant_region}}.as_rate())) > ${local.thr_dd_srv_alert}
  EOT
  query_count = <<EOT
  sum(last_${var.datadogservice_time_period}):default_zero((default_zero(sum:trace.cassandra.query.errors{service:${var.datadogservice},env:${local.ddog_env},tenant_region:${local.ddog_tenant_region}}.as_count()) /
  sum:trace.cassandra.query.hits{service:${var.datadogservice},env:${local.ddog_env},tenant_region:${local.ddog_tenant_region}}.as_count())) > ${local.thr_dd_srv_alert}
  EOT
  query_eval = {
    rate   = local.query_rate
    count  = local.query_count
  }  
}



resource "datadog_monitor" "Monitor_apm_service_error_rate_cassandra" {
  name               = "APM Service ${local.ddog_env} ${var.datadogservice} has a high error rate cassandra 500x on tenant_region:${local.ddog_tenant_region}"
  type               = "query alert"
  message            = <<EOT
  {{#is_alert}}
   AO - APM Service ${local.ddog_env} ${var.datadogservice} has a high error rate cassandra 500x on tenant_region:${local.ddog_tenant_region} (alert) @pagerduty-ao_apm
   See API Product Team dependencies : https://confluence.maerskdev.net/pages/viewpage.action?spaceKey=CoP&title=AO+API+Catalogue
  {{/is_alert}}

  {{#is_warning}}
   AO - APM Service ${local.ddog_env} ${var.datadogservice} has a high error rate cassandra 500x on tenant_region:${local.ddog_tenant_region} (warn) @pagerduty-ao_apm
   See API Product Team dependencies : https://confluence.maerskdev.net/pages/viewpage.action?spaceKey=CoP&title=AO+API+Catalogue
  {{/is_warning}}

  {{#is_recovery}}
  @pagerduty-ao_apm
  {{/is_recovery}}
  EOT
  escalation_message = ""
#need to change the query for cluster instead of env
  query = local.query_eval["${local.ddog_mode}"]
  thresholds = {
    warning           = local.thr_dd_srv_warn
    critical          = local.thr_dd_srv_alert
    critical_recovery = local.thr_dd_srv_alert_recover
    warning_recovery  = local.thr_dd_srv_warn_recover
  }

  notify_no_data    = false
  renotify_interval = 0
  notify_audit = false
  timeout_h    = 0
  include_tags = true
  require_full_window = false

  # ignore any changes in silenced value; using silenced is deprecated in favor of downtimes
  lifecycle {
    ignore_changes = [silenced]
  }

  tags = ["env:${local.ddog_env}", "service:${var.datadogservice}", "category:apm", "type:api", "origin:ddagent", "tenant:${local.ddog_tenant}", "tenant_region:${local.ddog_tenant_region}", "region:${local.ddog_region}", "cluster:${local.ddog_cluster}", "callout:false"]
}
