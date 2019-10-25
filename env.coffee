require('dotenv').load()
envalid = require 'envalid'
{ str, url, json } = envalid
envalid.cleanEnv process.env,
  mongo_conn_string: url(desc: 'Mongo DB cloud (or similar) connection string, including username and password')
  fb_page_token: str(desc: 'Facebook Page Access Token')
  fb_verify_token: str(desc: '')
  fb_app_secret: str(desc: '')
  google_creds: json({ desc: 'The contents of a Google Cloud json keyfile for a Dialogflow agent, with line breaks removed' })
