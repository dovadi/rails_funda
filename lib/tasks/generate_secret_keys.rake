require 'rails_generator/secret_key_generator'
require 'action_controller/cgi_ext/session'

namespace :secret_keys do

  desc "Generate new secret keys for session, cookies and authentication"
  task :generate do
    config_file = "#{RAILS_ROOT}/config/config.yml"
    config_settings = YAML.load_file(config_file)

    config_settings['global']['secret_for_sessions'] = Rails::SecretKeyGenerator.new(config_settings['global']['site_title']).generate_secret
    config_settings['global']['secret_protect_from_forgery'] = CGI::Session.generate_unique_id
    config_settings['global']['rest_auth_site_key'] = CGI::Session.generate_unique_id
  
    config_file = File.open(config_file, 'w')
    config_file.write YAML.dump(config_settings)
    config_file.close 
  end

end