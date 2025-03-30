# Slack Bot Challenge - Summary

###### Development Duration: 10 - 12 hours

[Deployed App](https://slack-bot-evrb.onrender.com/incidents)

###### slow initial loading time due to free plan on Render

## Development Process

### 1. Environmental Setup

- **Version Check**: Ensured compatibility between Ruby, Rails, PostgreSQL, Bundler, and the Slack API.
- **New Project Setup**: Initialized a new Rails project using `rails new` to create the backend environment.
- **Install Dependencies**: Installed necessary gems, including `slack-ruby-bot`, `pg`, and others for Slack API interaction and PostgreSQL support.
- **Database Setup**: Set up PostgreSQL as the database, configured the `database.yml`, and ran migrations to create initial tables.

### 2. API Integration

- **Slack API Documentation**: Studied the Slack API documentation to understand how to interact with Slack, register slash commands, and utilize Slack events.
- **Register and Install Slack App**: Created a new Slack App, generating the necessary credentials (API token, signing secret) for secure communication with Slack.
- **Enable Slack API and Slash Commands**: Enabled and configured Slack Slash commands to interact with the bot within Slack channels.

### 3. Database and Models

- **Database Design**: Designed the RDB schema
- **Generate Migrations**: Created migration files for the incident model and other necessary entities.
- **Database Connection**: Established a connection to PostgreSQL, ran migrations to create tables, and verified the connection to ensure smooth data interaction.

### 4. Backend Development

- **Logic for Slack API Interaction**: Built out the logic to listen to Slack commands and interact with the API to fetch incident data, update statuses, and perform other Slack bot operations.
- **Set up Routes**: Defined backend routes for Slack events, ensuring communication between the bot and the backend was seamless.
- **Webhook Integration**: Integrated webhooks to listen for Slack events and respond accordingly to commands issued within Slack channels.

### 5. Frontend Development

- **Incident List UI**: Built a simple, clean UI using Turbo to display incidents fetched from the database.
- **Real-time Updates**: Ensured the frontend could update in real-time when changes to incidents occurred, reflecting those changes back in the Slack interface as well.

### 6. Deployment

- **Containerization with Docker**: Dockerized the app by writing a custom `Dockerfile` to containerize the backend, ensuring consistency between local and production environments.
- **Render Setup**: Set up the production database on Render, configured the Rails app for production, and deployed the full stack application on Render.

### 7. UI/UX

- **Minimal UI for Incident Management**: Focused on building an intuitive and simple UI using Turbo for efficient incident management. The design aimed at providing clear visibility of incident statuses and updates.
- **Slack Integration**: Ensured the UI reflected changes triggered from Slack, giving users a seamless experience between the web app and Slack.

## Implementation

The core functionality of the Slack bot includes:

- **Incident Management**: Users can manage incident statuses directly from Slack by sending slash commands, with updates being reflected in both Slack and the web app.
- **Incident Dashboard**: A real-time, interactive list of incidents fetched from PostgreSQL, displaying key incident information like status, title, and description.

## Challenges

- **Dockerization**: During the Dockerization process, I initially ran into issues with the default `Dockerfile`. I had to delete the default file and regenerate a new one to meet the specific needs of my app. This involved fine-tuning the file to ensure proper dependencies were installed and that the production environment could run the app effectively.
- **Slack API Interaction**: A significant challenge was ensuring smooth interaction with the Slack API, especially in setting up webhooks and slash commands. This involved learning how to manage OAuth tokens securely and handle user events in real-time.
- **Real-time Data Sync**: Ensuring the frontend reflected real-time data from Slack was challenging but rewarding. I leveraged Turbo for efficient updates and ensured incident statuses were updated seamlessly across the app and Slack.

## Future Implementation

- **Testing**: Plan to implement unit and integration tests to ensure robustness, especially around interactions with the Slack API and PostgreSQL database.
- **Incident Management Enhancements**: Improve the incident management features by allowing users to add comments, attach files, and track incident history directly through the web UI and Slack.
- **Slack Notifications**: Implement more advanced Slack notifications for critical incidents, alerts, and status updates, ensuring teams are notified in real-time without leaving Slack.
- **Authentication & Authorization**: Add user authentication to the app to manage permissions and ensure only authorized users can update or view certain incident details.
