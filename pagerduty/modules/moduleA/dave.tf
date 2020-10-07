# Create a new Pagerduty event rules
terraform {
  experiments = [variable_validation]
}


variable "pagerduty_techservice" {
  type        = string
  description = "The technical service in pagerduty to route rules to"

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^(api|ui)-[0-9A-Za-z_.-]+(-maersk|-apmt)-(prod|preprod|cdt)-(aka|emp|iks|dse|ora|mam|syn|rum|iam|sof|apm)$", var.pagerduty_techservice))
    error_message = "The service name should be in the  \"<api|ui>-<service name>-<maersk|apmt>-<environment>-<aka|emp|iks|dse|ora|mam|syn|rum|iam|sof|apm>\"."
  }
}
variable "pagerduty_type" {
  type        = string
  description = "pagerduty_type is either api or ui."
  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^(api|ui)$", var.pagerduty_type))
    error_message = "The type should be \"<api|ui>\"."
  }
}
variable "pagerduty_category" {
  type        = string
  description = "pagerduty_category."
  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^(apm)$", var.pagerduty_category))
    error_message = "The type should be \"<apm>\"."
  }
}
variable "pagerduty_env" {
  type        = string
  description = "pagerduty_env is either prod, preprod or cdt."
  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^(prod|preprod|cdt)$", var.pagerduty_env))
    error_message = "The type should be \"<prod|preprod|cdt>\"."
  }
}
variable "pagerduty_tenant" {
  type        = string
  description = "pagerduty_tenant."
  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^(maersk|apmt)$", var.pagerduty_tenant))
    error_message = "The type should be \"<maersk|apmt>\"."
  }
}
variable "pagerduty_ruleset" {
  type        = string
  description = "pagerduty_ruleset."
}
variable "pagerduty_service" {
  type        = string
  description = "pagerduty_service."
}
variable "pagerduty_pause" {
  type = bool
  default = true
  description = "pagerduty_pause - pause the incident true|false."
}
variable "pagerduty_pause_seconds" {
  type = number
  default = 10
  description = "pagerduty_pause_seconds - time in seconds to pause the incident."
  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^(14400|14[0-3][0-9][0-9]|1[0-3][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9]|[1-9][0-9][0-9]|[1-9][0-9])$", var.pagerduty_pause_seconds))
    error_message = "The type should be \"<10-14440 0>\"."
  }
}

data "pagerduty_service" "technical_service"  {
  name = var.pagerduty_techservice
}

#data "pagerduty_ruleset" "ao_apmservice_ruleset"  {
#  name = "AO APM Services"
#}

resource "pagerduty_ruleset_rule" "ao_apmservice_ruleset_rule_error_pause" {
  count = var.pagerduty_pause ? 1 : 0
  #ruleset = data.pagerduty_ruleset.ao_apmservice_ruleset.id
  ruleset = var.pagerduty_ruleset
  disabled = "false"
  conditions {
    operator = "and"
    subconditions {
      operator = "equals"
      parameter {
        value = "${var.pagerduty_service}"
        path = "payload.source"
      }
    }
    subconditions {
      operator = "contains"
      parameter {
        value = "tenant:${var.pagerduty_tenant}"
        path = "payload.custom_details.tags"
      }
    }
    subconditions {
      operator = "contains"
      parameter {
        value = "env:${var.pagerduty_env}"
        path = "payload.custom_details.tags"
      }
    }
    subconditions {
      operator = "contains"
      parameter {
        value = "category:${var.pagerduty_category}"
        path = "payload.custom_details.tags"
      }
    }
    subconditions {
      operator = "contains"
      parameter {
        value = "type:${var.pagerduty_type}"
        path = "payload.custom_details.tags"
      }
    }
    subconditions {
      operator = "contains"
      parameter {
        value = "callout:false"
        path = "payload.custom_details.tags"
      }
    }
    subconditions {
      operator = "contains"
      parameter {
        value = "error"
        path = "payload.severity"
      }
    }
  }
  actions {
    route {
      value = data.pagerduty_service.technical_service.id
    }
    severity  {
      value = "warning"
    }
    annotate {
      value = "From Terraform"
    }
    priority {
      value = "PGEQMNH"
    }
    #suspend {
    #  value = var.pageduty_pause_seconds
    #}
  }
}

resource "pagerduty_ruleset_rule" "ao_apmservice_ruleset_rule_error" {
  count = var.pagerduty_pause ? 0 : 1
  #ruleset = data.pagerduty_ruleset.ao_apmservice_ruleset.id
  ruleset = var.pagerduty_ruleset
  disabled = "false"
  conditions {
    operator = "and"
    subconditions {
      operator = "equals"
      parameter {
        value = "${var.pagerduty_service}"
        path = "payload.source"
      }
    }
    subconditions {
      operator = "contains"
      parameter {
        value = "tenant:${var.pagerduty_tenant}"
        path = "payload.custom_details.tags"
      }
    }
    subconditions {
      operator = "contains"
      parameter {
        value = "env:${var.pagerduty_env}"
        path = "payload.custom_details.tags"
      }
    }
    subconditions {
      operator = "contains"
      parameter {
        value = "category:${var.pagerduty_category}"
        path = "payload.custom_details.tags"
      }
    }
    subconditions {
      operator = "contains"
      parameter {
        value = "type:${var.pagerduty_type}"
        path = "payload.custom_details.tags"
      }
    }
    subconditions {
      operator = "contains"
      parameter {
        value = "callout:false"
        path = "payload.custom_details.tags"
      }
    }
    subconditions {
      operator = "contains"
      parameter {
        value = "error"
        path = "payload.severity"
      }
    }
  }
  actions {
    route {
      value = data.pagerduty_service.technical_service.id
    }
    severity  {
      value = "warning"
    }
    annotate {
      value = "From Terraform"
    }
    priority {
      value = "PGEQMNH"
    }
  }
}


resource "pagerduty_ruleset_rule" "ao_apmservice_ruleset_rule_warn" {
  #ruleset = data.pagerduty_ruleset.ao_apmservice_ruleset.id
  depends_on = [
    pagerduty_ruleset_rule.ao_apmservice_ruleset_rule_error,
  ]
  ruleset = var.pagerduty_ruleset
  disabled = "false"
  conditions {
    operator = "and"
    subconditions {
      operator = "equals"
      parameter {
        value = "${var.pagerduty_service}"
        path = "payload.source"
      }
    }
    subconditions {
      operator = "contains"
      parameter {
        value = "tenant:${var.pagerduty_tenant}"
        path = "payload.custom_details.tags"
      }
    }
    subconditions {
      operator = "contains"
      parameter {
        value = "env:${var.pagerduty_env}"
        path = "payload.custom_details.tags"
      }
    }
    subconditions {
      operator = "contains"
      parameter {
        value = "category:${var.pagerduty_category}"
        path = "payload.custom_details.tags"
      }
    }
    subconditions {
      operator = "contains"
      parameter {
        value = "type:${var.pagerduty_type}"
        path = "payload.custom_details.tags"
      }
    }
    subconditions {
      operator = "contains"
      parameter {
        value = "callout:false"
        path = "payload.custom_details.tags"
      }
    }
    subconditions {
      operator = "contains"
      parameter {
        value = "warning"
        path = "payload.severity"
      }
    }
  }
  actions {
    route {
      value = data.pagerduty_service.technical_service.id
    }
    severity  {
      value = "warning"
    }
    annotate {
      value = "From Terraform"
    }
    priority {
      value = "PD52LYU"
    }
    suppress {
      value = true
    }
  }
}



resource "pagerduty_ruleset_rule" "ao_apmservice_ruleset_rule_info" {
  #ruleset = data.pagerduty_ruleset.ao_apmservice_ruleset.id
  depends_on = [
    pagerduty_ruleset_rule.ao_apmservice_ruleset_rule_warn,
  ]
  ruleset = var.pagerduty_ruleset
  disabled = "false"
  conditions {
    operator = "and"
    subconditions {
      operator = "equals"
      parameter {
        value = "${var.pagerduty_service}"
        path = "payload.source"
      }
    }
    subconditions {
      operator = "contains"
      parameter {
        value = "tenant:${var.pagerduty_tenant}"
        path = "payload.custom_details.tags"
      }
    }
    subconditions {
      operator = "contains"
      parameter {
        value = "env:${var.pagerduty_env}"
        path = "payload.custom_details.tags"
      }
    }
    subconditions {
      operator = "contains"
      parameter {
        value = "category:${var.pagerduty_category}"
        path = "payload.custom_details.tags"
      }
    }
    subconditions {
      operator = "contains"
      parameter {
        value = "type:${var.pagerduty_type}"
        path = "payload.custom_details.tags"
      }
    }
    subconditions {
      operator = "contains"
      parameter {
        value = "callout:false"
        path = "payload.custom_details.tags"
      }
    }
    subconditions {
      operator = "contains"
      parameter {
        value = "info"
        path = "payload.severity"
      }
    }
  }
  actions {
    route {
      value = data.pagerduty_service.technical_service.id
    }
    suppress {
      value = true
    }
  }
}

