# Rentbot
An experimental chatbot that answers questions about New Zealand tenancy problems.
Try it live at https://m.me/rentbotnz (you'll need a Facebook account).

For more details, get in touch with matthew@citizenai.nz / +64 27 211 3455

---

This app connects [Dialogflow](https://dialogflow.com) and [Facebook Messenger](https://www.messenger.com).
It processes some custom syntax in Dialogflow responses to handle images, buttons,
follow-up questions, too-long-for-Messenger text, etc.

---

## Running locally

* You will need

  * A [Dialogflow agent](https://dialogflow.com) to connect to. Rentbot presently uses Dialogflow's V1 api (while we wait for some middleware to be updated to use V2).

  * `node` and `npm` installed

* Clone this repository into a folder on your computer

* Enter the folder and run `npm install`

* Create a `.env` file and populate it with these environment variables:

  * dialogflow_client_token=*Get this from the `767180d905d647bdb4d148d7766feaed` field in Dialogflow agent's settings page*

  * mongoatlas_user=

  * mongoatlas_password=

  * mongoatlas_db_string=

  * fb_page_token=

  * fb_verify_token=

  * fb_app_secret=
