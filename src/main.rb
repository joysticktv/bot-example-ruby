require 'dotenv'
Dotenv.load '.env'
require 'oauth2'
require 'json'
require 'base64'
require 'uri'
require 'sinatra'
require_relative 'bot'
require 'action_cable_client'

HOST = ENV['JOYSTICKTV_HOST']
CLIENT_ID = ENV['JOYSTICKTV_CLIENT_ID']
CLIENT_SECRET = ENV['JOYSTICKTV_CLIENT_SECRET']
WS_HOST = ENV['JOYSTICKTV_API_HOST']
ACCESS_TOKEN = Base64.urlsafe_encode64(CLIENT_ID + ":" + CLIENT_SECRET)
GATEWAY_IDENTIFIER = "GatewayChannel"

URL = "#{WS_HOST}?token=#{ACCESS_TOKEN}"

def connect_to_server
  EventMachine.run do
    client = ActionCableClient.new(URL, GATEWAY_IDENTIFIER)

    client.connected { puts 'connection has opened' }

    client.received do |received_message|
      puts "\n\nMESSAGE #{received_message}"

      Bot.handle_message(client, received_message)
    end

    client.pinged do |received_message|
      puts "\n\nMESSAGE #{received_message}"
    end

    client.disconnected do
      puts 'connection has closed'
    end
  end
end

OAUTH_CLIENT = OAuth2::Client.new(
  CLIENT_ID,
  CLIENT_SECRET,
  site: HOST,
  authorize_url: '/api/oauth/authorize',
  token_url: '/api/oauth/token'
)

set :port, 8080

get '/' do
  'Visit <a href="/install">INSTALL</a> to install Bot'
end

get '/install' do
  state = 'abcsinatra123'

  authorize_uri = OAUTH_CLIENT.auth_code.authorize_url(redirect_uri: '/unused', scope: 'bot', state: state)
  redirect(authorize_uri)
end

get '/callback' do
  # STATE should equal `abcsinatra123`
  puts "STATE: #{params['state']}"
  puts "CODE: #{params['code']}"
  
  auth_header = Base64.strict_encode64([CLIENT_ID, CLIENT_SECRET].join(':'))
  data = OAUTH_CLIENT.auth_code.get_token(params['code'], redirect_uri: '/unused', headers: {'Authorization' => "Basic #{auth_header}"})

  # Save to your DB if you need to request user data
  puts data.token
  'Bot has been activated'
end

puts 'listening...'
connect_to_server
