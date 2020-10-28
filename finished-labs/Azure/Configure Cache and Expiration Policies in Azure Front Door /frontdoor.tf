resource "random_uuid" "uuid" { }

resource "azurerm_frontdoor" "my_frontdoor" {
  name                                         = "fd-${random_uuid.uuid.result}"
  resource_group_name                          = var.resource_group_name
  enforce_backend_pools_certificate_name_check = false

  routing_rule {
    name               = "MyRoutingRule1"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["MyFrontendEndpoint1"]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "MyBackendPluralsight"
    }
  }

  backend_pool_load_balancing {
    name = "MyLoadBalancingSettings1"
  }

  backend_pool_health_probe {
    name = "MyHealthProbeSetting1"
  }

  backend_pool {
    name = "MyBackendPluralsight"
    backend {
      host_header = "www.pluralsight.com"
      address     = "www.pluralsight.com"
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "MyLoadBalancingSettings1"
    health_probe_name   = "MyHealthProbeSetting1"
  }

  frontend_endpoint {
    name                              = "MyFrontendEndpoint1"
    host_name                         = "fd-${random_uuid.uuid.result}.azurefd.net"
  }
}
