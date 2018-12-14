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

  * `node` and `npm` installed

  * **[`ngrok`](https://ngrok.com/)** installed, to create a tunnel to expose your local server so that your Messenger bot can talk to it. If you purchase an [ngrok subscription](https://ngrok.com/pricing), you can set fixed subdomain for ngrok to use (e.g. rentbot-local-test.ngrok.io), otherwise you'll have to make do with a randomly assigned subdomain that will change with each restart of ngrok.

  * A **[Dialogflow agent](https://dialogflow.com)**. Rentbot presently uses Dialogflow's V1 api (while we wait for some middleware to be updated to use V2).

  * A **[Facebook page](https://www.facebook.com/pages/creation/)** (choose 'Business or brand', and 'App page' for the category).

  * A **Facebook app**:
    * Visit [developers.facebook.com](https://developers.facebook.com/), choose 'My apps', then Add New App.
    * On the Dashboard, under Add a Product, choose Messenger.
    * **Connect your app to your page:** On the Messenger Settings page, under Token Generation, choose the page you created above. Facebook will ask you to authorise the connection to that page. It will then generate a **Page Access Token**. Save this for later.

  * A **MongoDB Atlas cloud database**:
    * Visit https://www.mongodb.com/cloud/atlas and create an account.
    * Create a new project.
    * Create a new cluster, using default, 'free tier' options.


* Clone this repository into a folder on your computer.

* Enter the folder and run `npm install`.

* Create a `.env` file and populate it with these environment variables:

  * ngrok=
  * dialogflow_client_token=*Get this from the `Client access token` field in Dialogflow agent's settings page*
  * fb_page_token=*Use the Page Access Token generated above.*
  * fb_verify_token=*Choose a random string of characters*
  * fb_app_secret=*Get this from your app page on [developers.facebook.com](https://developers.facebook.com/), under Settings > Basic > App Secret*
  * mongoatlas_user=
  * mongoatlas_password=
  * mongoatlas_db_string=

* Start your bot with `npm start`. After starting, you should see a message like `Your bot is available at https://somesubdomain.ngrok.io/facebook/receive`.

* **Setup webhooks:**
  * Once the node app is running, visit your Facebook app page on [developers.facebook.com](https://developers.facebook.com/), go to Messenger > Settings, and under Webhooks, and choose Setup Webhooks. * For the `Callback URL`, use the full ngrok url reported by the bot above.
  * For `Verify Token`, use the random string of characters you chose above.
  * Select `messages` and `messaging_postbacks`
  * Choose `Verify and Save`
