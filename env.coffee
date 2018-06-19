require('dotenv').load()
envalid = require 'envalid'
{str} = envalid
envalid.cleanEnv process.env,
  dialogflow_client_token: str()
  mongoatlas_user: str()
  mongoatlas_password: str()
  mongoatlas_db_string: str()
  fb_page_token: str()
  fb_verify_token: str()
  fb_app_secret: str()
