# Citizen AI Messenger bot

For more details, get in touch with matthew@citizenai.nz / +64 27 211 3455

---

This app connects [Dialogflow](https://dialogflow.com) and [Facebook Messenger](https://www.messenger.com).
It processes some custom syntax in Dialogflow responses to handle images, buttons, follow-up questions, too-long-for-Messenger text, etc (see below for details).

---

## Todo

* Add support for environments from workbot/webchat-server
* Flesh out env.coffee with helpful messages
* abstract to be able to use same codebase for Workbot
  * env for privacy policy link
  * env for persistent menu?
* Look up profile on get_started?
* make get started look up and supply context?
* make a models folder?
* Rather than using session_id to figure out whether to refresh context; use has-20-minutes-passed-since-last-interaction-with-DF (https://stackoverflow.com/questions/53717717/what-is-the-lifetime-of-dialog-flow-session)


## Notes

* `npm run set_menu` will set the bot's get_started postback and persistent menu


## Thanks to

* https://github.com/mrbot-ai/botkit-middleware-fbuser/blob/master/src/botkit-middleware-fbuser.js

## Running locally [NOTE THIS NEEDS UPDATING FOR DIALOGFLOW v2]

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
    * Once the cluster is created, click `Connect`, create a new user (remember the username and password for later).
    * Choose `Connect Your Application`, then `Standard connection string`. Copy everything after the `@`, and save it for later.
    * Under Security > IP Whitelist, make sure your computer's IP address is listed, or use 'Allow access from anywhere'

* Clone this repository into a folder on your computer.

* Enter the folder and run `npm install`.

* Create a `.env` file and populate it with these environment variables:

  * dialogflow_client_token=*Get this from the `Client access token` field in Dialogflow agent's settings page*

  * fb_page_token=*Use the Page Access Token generated above.*

  * fb_verify_token=*Choose a random string of characters*

  * fb_app_secret=*Get this from your app page on [developers.facebook.com](https://developers.facebook.com/), under Settings > Basic > App Secret*

  * mongoatlas_user=*The username you chose earlier*

  * mongoatlas_password=*The password you chose or generated earlier*

  * mongoatlas_db_string=*The connection string saved earlier. Will look like `cluster0-shard-00-00-svyyv.mongodb.net:27017,cluster0-shard-00-01-svyyv.mongodb.net:27017,cluster0-shard-00-02-svyyv.mongodb.net:27017/test?ssl=true&replicaSet=Cluster0-shard-0&authSource=admin&retryWrites=true`*

  * ngrok_subdomain=*Optional, only works if you have an ngrok subscription. Use whatever subdomain name you like, e.g. rentbot-local-test*

  * ngrok_authtoken=*Optional, only works if you have an ngrok subscription. Get the token from https://dashboard.ngrok.com/get-started*

  * NODE_ENV=development *(optional, but makes the bot server show more debugging information)*

  * delay_ms=*Optional, reading speed in milliseconds per character. Rentbot delays the second and following of multiple messages so that there's time for users to read them. Defaults to 40*

* Start your bot with `npm start`.

* If you set the two `ngrok-` environment variables, you should shortly see a message like `Your bot is available at https://rentbot-local-test.ngrok.io/facebook/receive`.

* If you don't have an ngrok subscription, open a new terminal window, and run `ngrok http 3000`. You'll see two urls labelled `Fowarding`. Copy the https one (e.g. `https://75d145dd.ngrok.io`).

* **Setup webhooks:**
  * Once the node app is running, visit your Facebook app page on [developers.facebook.com](https://developers.facebook.com/), go to Messenger > Settings, and under Webhooks, and choose Setup Webhooks. * For the `Callback URL`, use the full ngrok url reported by the bot above, or if you don't have an ngrok subscription, the url you copied above, plus `/facebook/receive`, e.g. `https://75d145dd.ngrok.io/facebook/receive`.
  * For `Verify Token`, use the random string of characters you chose above.
  * Select `messages` and `messaging_postbacks`
  * Choose `Verify and Save`
  * Under `Select a page to subscribe your webhook to the page events`, choose the same page you chose under `Token Generation` earlier, and click `Subscribe`.

* Now if you visit https://m.me/ + *your Facebook page ID*, you should be able to chat with your bot.

* Note that while your Facebook App is 'In Development', only you, and other Facebook users that you have added as testers (in Roles > Roles on your Facebook app page at [developers.facebook.com](https://developers.facebook.com/) will be able to interact with your bot.

---

# Rentbot syntax (to be completed)

This app processes responses from Dialogflow like this:

* Responses from Dialogflow are split on newlines, and each 'line' is sent to Facebook Messenger with a delay corresponding to the length of each message (to give people time to read).

* Messages that are too long for Messenger are broken in half, with the first part sent to Messenger along with a 'Tell me more' button with a payload containing the second part.

* The app handles this special syntax:

  * **Follow-up messages**:
    * Syntax: `[FU: Words to show the user: Words to send to Dialogflow]`

  * **Quick replies**:
    * Syntax: `[QU: Message text; Option 1 words to show user: Text to send to Dialogflow; Option 2 words to show user: Words to send to Dialogflow; etc]`

  * **Cards**:
    * Syntax: `[Cards: Card 1 title (Card 1 subtitle): Button label: Text to send to Dialogflow on click; Card 2 title...]`