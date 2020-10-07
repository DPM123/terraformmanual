


provider "datadog" {
  #api_key = "${var.datadog_api_key}"
  #app_key = "${var.datadog_app_key}"
}

#module "module_monitor_apmservice_cassandra_maersk_prod2" {
#      source = "./modules/moduleA"
#      datadogservice = "cassandra"
#      datadogservice_alert_threshold = 0.75
#      datadogservice_warning_threshold = 0.5
#      datadogservice_alert_recover_threshold = 0.51
#      datadogservice_warning_recover_threshold = 0.4
#      datadogservice_time_period = "1m"
#      datadogservice_env = "prod"
#      datadogservice_cluster = "aop-prod-amer"
#      datadogservice_tenant = "maersk"
#      datadogservice_region = "amer"
#      datadogservice_tenant_region = "maersk_amer"
#      datadogservice_mode = "count"
#}
