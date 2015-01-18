PicoBlog
========

Decentralized, subscription based, microblogging. Its Twitter without a central server or any central control.

## Whats the Point?
### The Problem
Many nerds are upset about how Social Media networks work right now. Twitter, Facebook and Google all control a central system where you give them your data and they display and sell your to advertisers. 

### An Attempted Solution
App.net tried to solve this by charging for a social network. By charging, the users could be the customers instead of advertisers. While they didn’t sell user information to advertisers, they replicated the technology of the traditional networks. A central system that collects and displays user data. The problem with this system is it costs money to run all the central servers and maintain the software.

### PicoBlog: A Different Solution
Pico Blog will take a cue from the old world of the internet. The technology model is closer to that of a self hosted website/blog and a subscription service like an RSS aggregator. To use the network, you host a file that contains all of your “tweets” wherever you want. For someone to “follow” you, they put the URL to this file in PicoBlog. PicoBlog downloads and displays all the subscriptions in a twitter like UI.

## Story Backlog
### MVP Stories
  1. ~~The hosted files must conform to a standard plain text format (i.e. JSON, RSS, XML, etc). A format must be chosen and clear key, value pairs chosen for what a message needs to contain. (username, message, date, picture link?, etc)~~
  1. ~~The user needs be able to subscribe to multiple other users feeds. They are files hosted on any HTTP / HTTPS server.~~
  1. ~~The user needs be able to see all the messages from all of the subscribed URL's in date order in a table view.~~
  1. The user needs to post new messages by using the Transmit extension to upload a file with the new message via FTP/SFTP to their server.
 
### Remaining Stories
  1. The user needs to be able to upload / associate photos with messages.
  2. The user needs to see those photos in the tableview.
  3. The user needs to be able to upload new messages via SFTP/FTP without Trasnmit extension
  4. The user needs to be able to upload new messages via Dropbox
  5. The user needs to be able to subscribe to files hosted on other user's dropbox accounts.
  6. The user needs to be able to reply to a specific message

## Why is this on Github?
- I want this to be free and open to everyone. Not only the background logic that subscribes to files, downloads them and parses them. I also want the UI to be open, so anyone can change it to the desires.
- It goes without saying that everything this app does is relatively simple. Everyone should feel free to make their own clients or do whatever they want with the idea. 
- I would prefer to have people using something like this, rather than trying to make money off of it. 
- Lastly, I’m totally new to programming and my code is guaranteed to be messy and terrible. I welcome all pull requests to refactor and clean things up.
