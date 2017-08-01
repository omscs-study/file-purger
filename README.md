File Purger
===========

![Logo](logo.png)

## General

This script purges all shared files in Slack older than a certain time interval.
It's meant to be used with [Heroku Scheduler][heroku-scheduler], but can be
easily adapted into other schedulers, e.g. `cron`.

## Deployment

One-button deployment to [Heroku](https://heroku.com):

[![Deploy][deploy-button]](https://heroku.com/deploy)

Or, host on your own server. You'll need [Ruby](https://www.ruby-lang.org) along
with the dependencies listed in the `Gemfile`, _i.e. run_ `bundle install`

Once deployed, configure your scheduler (at your desired interval, _e.g. daily_)
to run the command, `bundle exec ruby purge.rb`.

## Configuration with Environment Variables

| Variable          | Description                                              |
|-------------------|----------------------------------------------------------|
| `SLACK_TOKEN`     | *Required*: [Slack (legacy) API token][legacy-tokens]    |
| `DAYS_TO_KEEP`    | Threshold days to keep files, _default: 10_              |
| `ADMIN_CHANNEL`   | Channel to notify if there are any errors                |
| `GENERAL_CHANNEL` | Channel to notify when the script is run                 |

[deploy-button]: https://www.herokucdn.com/deploy/button.svg
[heroku-scheduler]: https://elements.heroku.com/addons/scheduler
[legacy-tokens]: https://api.slack.com/custom-integrations/legacy-tokens
