# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

config.action_controller.session = {
   :session_key => '_rails_funda_session',
   :secret      => CONFIG[:secret_for_sessions],#'00b09871ac6f25601ec4a6cc5ed28da73d1633a12e3f44a32ab90151c6842bcf46eceb9b37445846ba87c3005b425656c18c8442a53f44b8591f32e1f6db971a'
   :session_domain => ".local.host"
}


# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

config.action_mailer.delivery_method = CONFIG[:delivery_method].to_sym
config.action_mailer.smtp_settings = CONFIG[:smtp_settings].symbolize_keys