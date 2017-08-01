File Purger
===========

![Logo](logo.png)

## General

This script purges all shared files in Slack older than a certain time interval.
It's meant to be used with [Heroku
Scheduler][heroku-scheduler], but can be easily
adapted into other schedulers, e.g. `cron`.

## Configuration with Environment Variables

| Variable          | Description                                              |
|-------------------|----------------------------------------------------------|
| `SLACK_TOKEN`     | *Required*: [Slack (legacy) API token][legacy-tokens]    |
| `DAYS_TO_KEEP`    | Threshold days to keep files, _default: 10_              |
| `ADMIN_CHANNEL`   | Channel to notify if there are any errors                |
| `GENERAL_CHANNEL` | Channel to notify when the script is run                 |

[heroku-scheduler]: https://elements.heroku.com/addons/scheduler
[legacy-tokens]: https://api.slack.com/custom-integrations/legacy-tokens
