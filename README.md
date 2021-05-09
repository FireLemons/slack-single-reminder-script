# Slack Single Seminder Script
Every time a reminder message is sent the previous reminder message is deleted.

# Setup
install ruby if not already installed  
`bundle install` to install gems  

### Bot Account Setup
1. Register for a developer account on slack over at https://api.slack.com/apps
2. Enable bots on the developer account.  
![account features screenshot](https://raw.githubusercontent.com/FireLemons/DocumentationMaterials/main/img/app-features.png)
3. Enable `channels:read` and `chat:write` on the app's scopes  
![account scopes screenshot](https://raw.githubusercontent.com/FireLemons/DocumentationMaterials/main/img/app-permissions.png)
4. Add the app to a workspace and `/invite` the bot to the channel where messages will be posted  
![invite bot screenshot](https://raw.githubusercontent.com/FireLemons/DocumentationMaterials/main/img/invite-bot.png)
  
### Configuration
#### `config.json`
Create a file called `config.json` in the same directory containing the repo root  

    dir/
      config.json
      slack-single-reminder-script/

It contains keys  
 - channel: the id of the channel to post messages to. This can be found at the end of the channel url. For example https://app.slack.com/client/T01HPM3CFJA/C01HTBZ264V would have an id of C01HTBZ264V  
 - messages: an object where each key contains the message of a different reminder you would like to send  
 - token: the oauth token for the slack app  

Example:  
  
    {
      "channel": "your channel id",
      "messages": {
        "main": "test",
        "emoji": ":eyes:"
      },
      "token": "xoxb-..."
    }

`remind.rb` will send the message for each message name passed to it and delete the previous message of the same name passed to it 
For example `ruby remind.rb emoji` will send the message `:eyes:` to the channel  
running the command a second time will delete the first `:eyes:` and post `:eyes:` again  

At this point it's a good idea to test your config by running remind.rb manually  

#### `config/schedule.rb`  
This file determines when the reminder script will be run.  
More information about configuring this file can be found at https://github.com/javan/whenever  
An example is found in this repo
