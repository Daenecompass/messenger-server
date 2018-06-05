{buttons_prep, formatter} = require './FBMessenger/df_to_messenger_formatter'
is_balanced = require 'is-balanced'
#
# console.log buttons_prep 'Notice template https://www.tenancy.govt.nz/assets/Uploads/Tenancy/T141-14-day-Notice-to-remedy-landlord-breach-handwritten-letter-template.pdf'

fake_df_messages = [
  "type": 0,
  "platform": "facebook",
  "speech": 'A tenancy agreement clause requiring carpets to be professionally cleaned is likely to be seen as in conflict with the Residential Tenancies Act and therefore unenforceable.
  [FU: Want to know more about fair wear and tear?: What counts as fair wear and tear?]'
,
  "type": 0,
  "speech": 'A tenancy agreement clause requiring carpets to be professionally cleaned is likely to be seen as in conflict with the Residential Tenancies Act and therefore unenforceable.
  [FU: Want to know more about fair wear and tear?: What counts as fair wear and tear?]'
,
  "type": 2,
  "platform": "facebook",
  "title": "Want to do something?",
  "replies": [
    "Yes",
    "No"
  ]
]


# console.log JSON.stringify (formatter fake_df_messages), null, 2

message = """
If your tenancy agreement prohibits pets, you can’t keep a pet on the property. If your tenancy agreement doesn’t, then you can keep a pet but you’re responsible for any damage it does.
[FU: Want to know about extra fees for pets?: What is a dog bond?]
[Sources: https://www.tenancy.govt.nz/starting-a-tenancy/tenancy-agreements/adding-conditions-to-the-tenancy-agreement/#id_361345-the-tenant-is-responsible-if-their-pet-damages-anything; https://www.tenancy.govt.nz/starting-a-tenancy/tenancy-agreements/adding-conditions-to-the-tenancy-agreement/]
"""
fake_df_response =
  result:
    fulfillment:
      messages: [speech: message]

response_malformed = (df_response) ->
  not df_response.result.fulfillment.messages.every (message) ->
    is_balanced(message.speech, '{[(', ')]}') and not message.speech.match /\[.*more:.*\]/i


console.log response_malformed fake_df_response
