## Live Links

- [Deployed App](https://slack-bot-evrb.onrender.com/incidents)
- [Install Slack App](https://slack.com/oauth/v2/authorize?client_id=5146735051126.8677850953682&scope=channels:manage,channels:read,channels:write.invites,chat:write,commands,groups:write,im:write,mpim:write,team:read,users:read,users:read.email,channels:join&user_scope=channels:read,channels:write,channels:write.invites,chat:write,groups:write,im:write,mpim:write,users:read,users:read.email)

> Initial loading may be slow due to the free Render hosting plan.

---

## Usage

- This Slack bot responds to the `/flag` command with two main actions:
  - `/flag declare title description severity`
    - `title` is **required**
    - `description` and `severity` are optional
    - `severity` must be one of `sev0`, `sev1`, or `sev2`
  - `/flag resolve`
    - Can be run only in the dedicated incident Slack channel
    - Marks the status of the incident as `resolved` and display back to the channel the time it took the team to get to resolution.

---

## Getting Started Locally

### Prerequisites

- Ruby
- PostgreSQL
- Redis/Valkey
- Node.js and Yarn (for Tailwind)
- Slack workspace where you can install the bot

---

## Installation

### Install backend dependencies

`bundle install`

### Install TailwindCSS

`rails tailwindcss:install`

### Set up the database

`rails db:setup`

---

## Running Tests

### Run tests

`bundle exec rspec`

### Generate an HTML report (optional)

`bundle exec rspec --format html --out rspec_report.html`
`open rspec_report.html`
