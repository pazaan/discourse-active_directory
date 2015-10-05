# name: Active Directory
# about: Authenticate on Discourse with your Active Directory.
# version: 0.1.0
# author: Chris Wells <cwells@thegdl.org>

require 'omniauth-ldap'
#gem 'pyu-ruby-sasl', '0.0.3.1'
#gem 'rubyntlm', '0.1.1'
#gem 'net-ldap', '0.3.1'
#gem 'omniauth-ldap', '1.0.4'

class ADAuthenticator < ::Auth::Authenticator

	def name
		'active_directory'
	end
	
	def after_authenticate(auth_token)
		result = Auth::Result.new
		
		ad_uid = auth_token[:uid]
		data = auth_token[:info]
		result.email = email = data[:email]
		result.name = name = data[:sAMAccountName]
		result.email_valid = true

		result.extra_data = {
			uid: ad_uid,
			provider: auth_token[:provider],
			name: name,
			email: email,
		}
		
		user_info = User.find_by_email(email)

		if user_info
			result.user = user_info
		end

		result
	end
	
	def after_create_account(user, auth)
		data = auth[:extra_data]
	end
	
	def register_middleware(omniauth)
		omniauth.provider :ldap,
						:title => "Active Directory Login",
						:name => name,
						:require => "omniauth-ldap",
						:setup => lambda { |env|
						  	strategy = env["omniauth.strategy"]
						  	strategy.options[:host] = SiteSetting.ad_domain_controller
						  	strategy.options[:port] = SiteSetting.ad_domain_controller_port
							strategy.options[:base] = SiteSetting.ad_base_dn
							strategy.options[:bind_dn] = SiteSetting.ad_bind_dn
							strategy.options[:password] = SiteSetting.ad_bind_pass
							strategy.options[:method] = :plain
							strategy.options[:uid] = SiteSetting.ad_login_attribute
							strategy.options[:name_proc] = Proc.new {|name| name.gsub(/@.*$/,'')}
						}
	end
end

auth_provider :title => 'with Active Directory',
	:message => 'Log in with Active Directory',
	:frame_width => 600,
	:frame_height => 350,
	:authenticator => ADAuthenticator.new
	
register_css <<CSS

.btn-social.active_directory {
	background: #0052A4;
}

.btn-social.active_directory:before {
	content: "\\F17A";
}

CSS
