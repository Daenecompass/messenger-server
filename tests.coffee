{buttons_prep, formatter} = require './FBMessenger/df_to_messenger_formatter'
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


console.log JSON.stringify (formatter fake_df_messages), null, 2
