Encoding.default_external = "UTF-8"

require "cuba"
require "cuba/contrib"
require "malone"
require "mote"
require "nobi"
require "ohm"
require "ohm/contrib"
require "ost"
require "rack/protection"
require "scrivener"
require "shield"

APP_SECRET = ENV.fetch("APP_SECRET")
MALONE_URL = ENV.fetch("MALONE_URL")
REDIS_URL = ENV.fetch("REDIS_URL")
RESET_URL = ENV.fetch("RESET_URL")
NOBI_SECRET = ENV.fetch("NOBI_SECRET")

Cuba.plugin Cuba::Mote
Cuba.plugin Cuba::TextHelpers
Cuba.plugin Shield::Helpers

# Ohm.connect(url: REDIS_URL)
Ohm.redis = Redic.new(REDIS_URL)
Ost.connect(url: REDIS_URL)
Malone.connect(url: MALONE_URL, tls: false, domain: "teamballots.com")

Dir["./models/**/*.rb"].each  { |rb| require rb }
Dir["./routes/**/*.rb"].each  { |rb| require rb }
Dir["./helpers/**/*.rb"].each { |rb| require rb }
Dir["./filters/**/*.rb"].each { |rb| require rb }
Dir["./lib/**/*.rb"].each     { |rb| require rb }
Dir["./services/**/*.rb"].each     { |rb| require rb }

Cuba.plugin UserHelpers

Cuba.use Rack::Session::Cookie,
  key: "team_ballots",
  secret: APP_SECRET

Cuba.use Rack::Protection, except: :http_origin
Cuba.use Rack::Protection::RemoteReferrer

Cuba.use Rack::Static,
  urls: %w[/js /css /img],
  root: File.expand_path("./public", __dir__)

Cuba.define do
  persist_session!

  on root do
    render("home", title: "Home")
  end

  on authenticated(User) do
    run Users
  end

  on default do
    run Guests
  end
end