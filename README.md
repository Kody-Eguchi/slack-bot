## Dependancies

### Core Framework & Backend

- `rails` ~> 7.2.2, >= 7.2.2.1
- `pg` ~> 1.3
- `activerecord` 7.2.2.1

### Slack Integration

- `slack-ruby-client`
- `slack-ruby-bot`

### Environment & Configuration

- `dotenv-rails`

### CORS

- `rack-cors`

### Frontend Styling

- `tailwindcss-rails` ~> 4.2

### Web Server

- `puma` >= 5.0

### Caching / Realtime

- `redis` ~> 4.0

- [Deployed App](https://slack-bot-evrb.onrender.com/incidents)
- [Install Slack App](https://slack.com/oauth/v2/authorize?client_id=5146735051126.8677850953682&scope=channels:manage,channels:read,channels:write.invites,chat:write,commands,groups:write,im:write,mpim:write,team:read,users:read,users:read.email,channels:join&user_scope=channels:read,channels:write,channels:write.invites,chat:write,groups:write,im:write,mpim:write,users:read,users:read.email)

###### slow initial loading time due to free plan on Render
