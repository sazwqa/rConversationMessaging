# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_conversation_session',
  :secret      => '44d08098bbdef4aad2adb0852fba140a12c6185f9fc67a86725832781f3a293217bf53ef142aa5ef598f0f1a9dd03ea813a1df0db3a5c28b5b033e6904f8e521'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
