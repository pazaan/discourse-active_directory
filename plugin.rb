# name: Active Directory
# about: Authenticate on Discourse with your Active Directory.
# version: 0.1.0
# author: Chris Wells <cwells@thegdl.org>

gem 'omniauth-ldap', '1.0.4'

class ADAuthenticator < ::Auth::Authenticator

	DC = Discourse.PluginSettings[:active_directory].authad_domain_controller
	BASE_DN = Discourse.PluginSettings[:active_directory].authad_base_dn
	BIND_DN = Discourse.PluginSettings[:active_directory].authad_bind_dn
	BIND_PASS = Discourse.PluginSettings[:active_directory].authad_bind_pass
	
	def name
		'active_directory'
	end
	
	def after_authenticate(auth_token)
		result = Auth::Result.new
		
		authad_uid = auth_token[:uid]
		data = auth_token[:info]
		result.email = email = data[:email]
		result.name = name = data[:name]

		result.extra_data = {
			uid: authad_uid,
			provider: auth_token[:provider],
			name: name,
			email: email,
		}
		
		
	end
	
	def after_create_account(user, auth)
		data = auth[:extra_data]
	end
	
	def register_middleware(omniauth)
		omniauth.provider :ldap,
						  :host => DC,
						  :port => 389,
						  :method => :plain,
						  :base => BASE_DN,
						  :uid => 'sAMAccountName',
						  :bind_dn => BIND_DN,
						  :password => BIND_PASS
	end
end

auth_provider :title => 'with Active Directory',
	:message => 'Log in with Active Directory',
	:frame_width => 920,
	:frame_height => 800,
	:authenticator => ADAuthenticator.new
	
register_css <<CSS

.btn-social.windows {
	background: #0052A4;
}

.btn-social.windows:before {
	content: "N";
}

CSS