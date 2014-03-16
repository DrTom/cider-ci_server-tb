# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
CiderCI::Application.config.secret_key_base = '2b052ccfd01cf0d0dab0ad5031fb6aa5bd150cffb995de0d5a100ebf8e4c49020ac6791cf2517984eff53dd828d50b07a7945ab1b4ce518a61f0f33908383695'
