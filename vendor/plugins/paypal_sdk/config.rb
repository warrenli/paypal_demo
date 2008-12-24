puts "*** Loading paypal config"

PAYPAL_EC_URL="https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token="

DEV_CENTRAL_URL="https://developer.paypal.com"

PP_credentials =  {"USER" => "<API Username>", "PWD" => "<API Password>", "SIGNATURE" => "<API Signature>" }

PP_endpoints = {"SERVER" => "api-3t.sandbox.paypal.com", "SERVICE" => "/nvp/"}

PP_proxy_info = {"USE_PROXY" => false, "ADDRESS" => nil, "PORT" => nil, "USER" => nil, "PASSWORD" => nil }

PP_client_info = { "VERSION" => "55.0", "SOURCE" => "PayPalRubySDKV1.2.0"}

PP_pdt_endpoints = {"SERVER" => "www.sandbox.paypal.com", "SERVICE" => "/cgi-bin/webscr"}
PAYPAL_WPS_URL = "https://#{PP_pdt_endpoints['SERVER']}#{PP_pdt_endpoints['SERVICE']}"

CREDENTIALS_PATH_ROOT = RAILS_ROOT+"/credentials"

PAYPAL_CERT_PATH      = "#{CREDENTIALS_PATH_ROOT}/paypal_cert_pem.txt"

MY_BUSINESS_EMAIL_ADDRESS   = "<Email of Seller PayPal Account>"

MY_BUSINESS_EWP_CERT_ID     = "<Cert ID>"

MY_BUSINESS_EWP_CERT_PATH   = "#{CREDENTIALS_PATH_ROOT}/my-pubcert.pem"

MY_BUSINESS_EWP_KEY_PATH    = "#{CREDENTIALS_PATH_ROOT}/my-prvkey.pem"

MY_BUSINESS_PRIVATE_KEY_PWD = ''

BUTTON_IMAGE                = "https://www.paypal.com/en_US/i/btn/btn_buynow_LG.gif"

MY_BUSINESS_IDENTITY_TOKEN = "<PDT identity token>"

