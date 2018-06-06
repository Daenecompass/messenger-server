{buttons_prep, format} = require './FBMessenger/df_to_messenger_formatter'
#
# console.log buttons_prep 'Notice template https://www.tenancy.govt.nz/assets/Uploads/Tenancy/T141-14-day-Notice-to-remedy-landlord-breach-handwritten-letter-template.pdf'

fake_df_messages = [
  "type": 0,
  "platform": "facebook",
  "speech": 'A tenancy agreement clause requiring carpets to be professionally cleaned is likely to be seen as in conflict with the Residential Tenancies Act and therefore unenforceable.
  [FU: Want to know more about fair wear and tear?: What counts as fair wear and tear?]
  [Tenacy Serivces 0800 123 123; Tenancy Serves http://asite.com/doop.pdf]'
,
  "type": 0,
  "speech": 'A tenancy agreement clause requiring carpets to be professionally cleaned is likely to be seen as in conflict with the Residential Tenancies Act and therefore unenforceable.
  [FU: Want to know more about fair wear and tear?: What counts as fair wear and tear?]
  [Tenacy Serivces 0800 123 123; Tenancy Serves http://asite.com/doop.pdf]'
,
  "type": 2,
  "platform": "facebook",
  "title": "Want to do something?",
  "replies": [
    "Yes",
    "No"
  ]
]


console.log JSON.stringify (format fake_df_messages), null, 2
