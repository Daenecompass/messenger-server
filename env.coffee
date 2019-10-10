require('dotenv').load()
envalid = require 'envalid'
{str} = envalid
envalid.cleanEnv process.env,
  mongo_conn_string: str()
  fb_page_token: str()
  fb_verify_token: str()
  fb_app_secret: str()
  google_creds: str()
  google_project_id: str()
