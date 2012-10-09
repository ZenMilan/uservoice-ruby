require "uservoice/version"
require 'uservoice/collection'
require 'uservoice/client'
require 'rubygems'
require 'ezcrypto'
require 'json'
require 'cgi'
require 'base64'
require 'oauth'

module UserVoice
  EMAIL_FORMAT = %r{^(\w[-+.\w!\#\$%&'\*\+\-/=\?\^_`\{\|\}~]*@([-\w]*\.)+[a-zA-Z]{2,9})$}
  DEFAULT_HEADERS = { 'Content-Type'=> 'application/json', 'Accept'=> 'application/json' }

  class APIError < RuntimeError
  end
  Unauthorized = Class.new(APIError)
  NotFound = Class.new(APIError)
  ApplicationError = Class.new(APIError)
 
  def self.generate_sso_token(subdomain_key, sso_key, user_hash, valid_for = 5 * 60)
    user_hash[:expires] ||= (Time.now.utc + valid_for).to_s unless valid_for.nil?
    unless user_hash[:email].to_s.match(EMAIL_FORMAT)
      raise Unauthorized.new("'#{user_hash[:email]}' is not a valid email address")
    end
    unless sso_key.to_s.length > 1
      raise Unauthorized.new("Please specify your SSO key")
    end

    key = EzCrypto::Key.with_password(subdomain_key, sso_key)
    encrypted = key.encrypt(user_hash.to_json)
    encoded = Base64.encode64(encrypted).gsub(/\n/,'')

    return CGI.escape(encoded)
  end
end
