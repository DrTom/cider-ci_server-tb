# Be sure to restart your server when you modify this file.

CiderCI::Application.config.session_store :cookie_store, key: '_CiderCI_session'

Rails.application.config.action_dispatch.cookies_serializer = :hybrid
