


provider "pagerduty" {
  #api_key = "${var.datadog_api_key}"
  #app_key = "${var.datadog_app_key}"
  token = var.pagerduty_token
}
data "pagerduty_team" "aop_akamai_sre"  {
  name = "AOP Akamai SRE Team"
}


data "pagerduty_ruleset" "ao_apmservice_ruleset"  {
    name = "AO APM Services"
}


#module "module_eventmonitor_apmservice_davetests_maersk_prod" {
#        source = "./modules/moduleA"
#        pagerduty_service = "DAVETESTS"
#        pagerduty_techservice = "api-global_bizhrs-maersk-prod-apm"
#        pagerduty_type = "api"
#        pagerduty_category = "apm"
#        pagerduty_env = "prod"
#        pagerduty_tenant = "maersk"
#        pagerduty_ruleset = data.pagerduty_ruleset.ao_apmservice_ruleset.id
#        pagerduty_pause = false 
#        pagerduty_pause_seconds = 10
#}
