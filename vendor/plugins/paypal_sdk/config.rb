puts "*** Loading paypal config"

PAYPAL_EC_URL="https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token="

DEV_CENTRAL_URL="https://developer.paypal.com"

PP_credentials =  {"USER" => "<API Username>", "PWD" => "<API Password>", "SIGNATURE" => "<API Signature>" }

PP_endpoints = {"SERVER" => "api-3t.sandbox.paypal.com", "SERVICE" => "/nvp/"}

PP_proxy_info = {"USE_PROXY" => false, "ADDRESS" => nil, "PORT" => nil, "USER" => nil, "PASSWORD" => nil }

PP_client_info = { "VERSION" => "55.0", "SOURCE" => "PayPalRubySDKV1.2.0"}

PAYPAL_WPS_URL="https://www.sandbox.paypal.com/cgi-bin/webscr"

