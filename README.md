[![Code Climate](https://codeclimate.com/github/passcod/caskbot.png)](https://codeclimate.com/github/passcod/caskbot)

Caskbot
=======

IRC bot for the [Homebrew Cask](http://caskroom.io) project.

Main features:

- Runs on Heroku with one dyno.
- Incorporates a web server so it can receive and process web hooks.
- Written in Ruby to match the rest of the project.
- Uses Octokit for Github requests as well as webhook.
- Pulls all configuration from ENV.

## Configuration

These are all required, except for PORT= and RACK_ENV=:

- GITHUB_TOKEN= Personal token to be used by the bot. Permissions used:
  gist, public_repo, read:org, repo:status.

- IRC_CHANNELS= Space-delimited list of channels the bot should connect
  to. The first one will be "mainchan", to which messages that aren't
  replies to commands or patterns (such as responses from webhooks)
  will be sent.

- IRC_NICK=

- IRC_PORT=

- IRC_REALNAME=

- IRC_SERVER=

- IRC_SSL= `0` for no encryption, `1` for SSL without verification,
  `2` for verified SSL.

- PORT= Port the web server runs on. This shouldn't be set on Heroku, but
  is useful for development.

- RACK_ENV= Currently only used for Bundler loading. Defaults to `production`.

## Installation & Development

To run locally:

1. Clone this repo,
2. Create a `.env` file with the configuration above in the form `KEY="value"`,
3. Install the dependencies: `bundle`,
4. If using rbenv, run `rbenv rehash`,
5. Start the bot: `bundle exec foreman start`.

The bot needs to be restarted at every change.

## Automated testing

Nothing yet!

## Functions of the Bot

### Issue parsing
Parse issue numbers from within messages e.g. `#123` and display information.

### Events handling
When subscribed to a repo, display some events as they come in: new issues and PRs, releases.

### SHA2 hashing
Streamload URLs and compute their SHA256 checksum.

### Audit checking
Fetch results from cask tastings.

## Community

Created by @passcod for @caskroom, Public Domain.

