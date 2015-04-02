# name: Active Directory
# about: Authenticate on Discourse with your Active Directory.
# version: 0.1.0
# author: Chris Wells <cwells@thegdl.org>

gem 'omniauth-ldap', '1.0.4'

class ADAuthenticator < ::Auth::Authenticator

	DC = ''
	BASE_DN = ''
	BIND_DN = ''
	BIND_PASS = ''
	
	def name
		'active_directory'
	end
	
	def after_authenticate(auth_token)
		result = Auth::Result.new
	end
	
	def after_create_account(user, auth)
	
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