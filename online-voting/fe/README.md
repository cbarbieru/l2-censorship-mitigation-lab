# Online Voting - Frontend

## Intro
The frontend is a modern React-based web application built with Vite and Material UI (MUI). It provides a user-friendly dashboard for voters to participate in elections, view real-time statistics via ApexCharts, and manage their profiles. It communicates with the Node.js backend to perform secure voting operations using a commit-reveal scheme.

## Deploy
To build and push the Docker image for the frontend with a Linux architecture:

```bash
# Build the image for linux/amd64
docker build --platform linux/amd64 -t <your-registry>/online-voting-fe:latest .

# Push the image to your registry
docker push <your-registry>/online-voting-fe:latest
```
