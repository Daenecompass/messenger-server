require '../env'
{ fb_page_token } = process.env

FB = require 'fb'

persistent_menu = require './persistent_menu.json'


console.log 'Attempting to delete and re-set get started postback & persistent menu'
FB.setAccessToken fb_page_token
FB.api '/me/messenger_profile', 'delete', fields: [ 'persistent_menu', 'get_started' ], console.log
FB.api '/me/messenger_profile', 'post', persistent_menu: [ persistent_menu ], get_started: payload: 'GET_STARTED', console.log
