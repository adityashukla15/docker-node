# Docker + Docker Compose 

This README explains how to containerize a Node.js application, build a Docker image, publish it to Docker Hub, and use Docker Compose with PostgreSQL and Redis.

---

# 1. What is Docker?

Docker allows us to package an application together with its dependencies and environment into a **container**.

Without Docker:

```text
Developer's Computer
├── Node.js version
├── npm packages
├── PostgreSQL
├── Redis
└── Application
```

This can cause:

> "It works on my machine!"

With Docker:

```text
Docker Container
├── Application
├── Dependencies
└── Required environment
```

The same container can run on another developer's machine.

---

# 2. Important Docker Terms

## Image

An image is a **template/package** used to create containers.

Example:

```text
postgres
redis
ubuntu
node
my-node-app
```

## Container

A container is a **running instance of an image**.

For example:

```text
postgres image
      ↓
postgres container
```

## Dockerfile

A Dockerfile contains instructions for creating a Docker image.

Example:

```dockerfile
FROM ubuntu
RUN apt-get update
...
```

## Docker Hub

Docker Hub is a registry where Docker images can be stored and shared.

Example:

```text
adityashukla1501/my-node-app
```

---

# 3. What is curl?

`curl` is a command-line tool used to transfer data from or to a server.

For example:

```bash
curl https://example.com
```

It can make HTTP requests and download data.

In our Dockerfile, we use:

```dockerfile
RUN apt-get install -y curl
```

to install curl.

Then:

```dockerfile
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -
```

downloads the Node.js 18 setup script and passes it to Bash.

### Meaning of the command

```text
curl
```

Download/read data.

```text
-s
```

Silent mode.

```text
-L
```

Follow redirects.

```text
|
```

Pipe the output of one command into another command.

```text
bash -
```

Execute the downloaded script using Bash.

---

# 4. Project Structure

Our project should look like:

```text
docker-node/
│
├── Dockerfile
├── docker-compose.yml
├── package.json
├── package-lock.json
└── index.js
```

---

# 5. Dockerfile

Create a file named exactly:

```text
Dockerfile
```

Do not use:

```text
Dockerfile.txt
```

Dockerfile:

```dockerfile
# Use Ubuntu as the base image
FROM ubuntu

# Update the package list
RUN apt-get update

# Install curl
RUN apt-get install -y curl

# Set up the Node.js 18 repository
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -

# Upgrade installed packages
RUN apt-get upgrade -y

# Install Node.js
RUN apt-get install -y nodejs

# Copy package.json into the container
COPY package.json package.json

# Copy package-lock.json into the container
COPY package-lock.json package-lock.json

# Copy the application file into the container
COPY index.js index.js

# Install Node.js dependencies
RUN npm install

# Run the Node.js application when the container starts
ENTRYPOINT ["node", "index.js"]
```

---

# 6. Build the Docker Image

Open the terminal inside the project folder.

Check the files:

```powershell
dir
```

You should see:

```text
Dockerfile
package.json
package-lock.json
index.js
```

Build the image:

```powershell
docker build -t my-node-app .
```

### Meaning

```text
docker build
```

Build a Docker image.

```text
-t my-node-app
```

Give the image the name `my-node-app`.

```text
.
```

Use the current directory as the build context.

---

# 7. Check Docker Images

Run:

```powershell
docker images
```

You should see:

```text
my-node-app    latest
```

---

# 8. Run the Docker Container

Run:

```powershell
docker run my-node-app
```

Docker will execute:

```text
node index.js
```

because our Dockerfile contains:

```dockerfile
ENTRYPOINT ["node", "index.js"]
```

---

# 9. Docker Port Mapping

If the Node.js application runs on port `3000`, use:

```powershell
docker run -p 3000:3000 my-node-app
```

The format is:

```text
-p HOST_PORT:CONTAINER_PORT
```

Therefore:

```text
-p 3000:3000
```

means:

```text
Your computer port 3000
        ↓
Container port 3000
```

Then access the application using:

```text
http://localhost:3000
```

---

# 10. EXPOSE

We can add this to the Dockerfile:

```dockerfile
EXPOSE 3000
```

This tells Docker that the application uses port `3000`.

Important:

`EXPOSE` does NOT actually publish the port.

Actual port mapping is done using:

```powershell
docker run -p 3000:3000 my-node-app
```

---

# 11. Publish the Image to Docker Hub

First login:

```powershell
docker login
```

Enter your Docker Hub username and authentication details.

Your Docker Hub username:

```text
adityashukla1501
```

After successful login:

```text
Login Succeeded
```

---

# 12. Tag the Image

Our local image is:

```text
my-node-app
```

Tag it with the Docker Hub username:

```powershell
docker tag my-node-app adityashukla1501/my-node-app:latest
```

The format is:

```text
docker tag LOCAL_IMAGE USERNAME/REPOSITORY:TAG
```

---

# 13. Push the Image to Docker Hub

Run:

```powershell
docker push adityashukla1501/my-node-app:latest
```

The image will be uploaded to Docker Hub.

Repository:

```text
adityashukla1501/my-node-app
```

---

# 14. How Another Developer Uses the Image

Another developer does not need your Dockerfile or Node.js dependencies.

They can pull your image:

```powershell
docker pull adityashukla1501/my-node-app:latest
```

Then run:

```powershell
docker run -p 3000:3000 adityashukla1501/my-node-app:latest
```

Or Docker can automatically pull the image when running:

```powershell
docker run -p 3000:3000 adityashukla1501/my-node-app:latest
```

---

# 15. Docker Compose

## What is Docker Compose?

Docker Compose is used to manage **multiple containers/services together** using one YAML file.

For example, a real application might need:

```text
Node.js
PostgreSQL
Redis
```

Instead of manually starting three containers, Docker Compose allows us to define them in:

```text
docker-compose.yml
```

and start them together.

---

# 16. docker-compose.yml

Create:

```text
docker-compose.yml
```

Example:

```yaml
version: "3.8"

services:

  postgres:
    image: postgres
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: postgres
      POSTGRES_DB: review
      POSTGRES_PASSWORD: password

  redis:
    image: redis
    ports:
      - "6379:6379"
```

---

# 17. Is a New Image Created for PostgreSQL and Redis?

No.

These lines:

```yaml
image: postgres
```

and:

```yaml
image: redis
```

tell Docker to use existing images.

Docker will pull them from Docker Hub if they are not already available locally.

The result is:

```text
Docker Compose
│
├── PostgreSQL container
│      └── postgres image
│
└── Redis container
       └── redis image
```

We are creating containers from existing images.

---

# 18. PostgreSQL Configuration

```yaml
postgres:
  image: postgres
```

Use the PostgreSQL image.

```yaml
ports:
  - "5432:5432"
```

Map:

```text
Host port 5432
      ↓
Container port 5432
```

Environment variables:

```yaml
POSTGRES_USER: postgres
POSTGRES_DB: review
POSTGRES_PASSWORD: password
```

These configure:

```text
Username: postgres
Database: review
Password: password
```

---

# 19. Redis Configuration

```yaml
redis:
  image: redis
```

Use the Redis image.

```yaml
ports:
  - "6379:6379"
```

Map:

```text
Host port 6379
      ↓
Container port 6379
```

---

# 20. Start Docker Compose

Open the terminal in the folder containing:

```text
docker-compose.yml
```

Run:

```powershell
docker compose up
```

Docker Compose will:

```text
1. Read docker-compose.yml
2. Pull postgres image if required
3. Pull redis image if required
4. Create PostgreSQL container
5. Create Redis container
6. Start both containers
```

---

# 21. Run Docker Compose in Background

Instead of keeping the terminal occupied:

```powershell
docker compose up -d
```

`-d` means:

```text
Detached mode
```

The containers keep running in the background.

---

# 22. Check Running Containers

Run:

```powershell
docker ps
```

You should see PostgreSQL and Redis containers.

---

# 23. Stop Docker Compose

Run:

```powershell
docker compose down
```

This stops and removes the containers created by Compose.

---

# 24. Stop Containers Without Removing Them

You can use:

```powershell
docker compose stop
```

Then start them again:

```powershell
docker compose start
```

---

# 25. View Docker Compose Logs

Run:

```powershell
docker compose logs
```

For live logs:

```powershell
docker compose logs -f
```

---

# 26. Useful Docker Commands

Check Docker version:

```powershell
docker --version
```

Check Docker information:

```powershell
docker info
```

List images:

```powershell
docker images
```

List running containers:

```powershell
docker ps
```

List all containers:

```powershell
docker ps -a
```

Stop a container:

```powershell
docker stop CONTAINER_ID
```

Start a stopped container:

```powershell
docker start CONTAINER_ID
```

Remove a container:

```powershell
docker rm CONTAINER_ID
```

Remove an image:

```powershell
docker rmi IMAGE_NAME
```

---

# 27. Complete Docker Workflow

## Step 1 — Create Dockerfile

```text
Dockerfile
```

## Step 2 — Build image

```powershell
docker build -t my-node-app .
```

## Step 3 — Check image

```powershell
docker images
```

## Step 4 — Run locally

```powershell
docker run -p 3000:3000 my-node-app
```

## Step 5 — Login to Docker Hub

```powershell
docker login
```

## Step 6 — Tag image

```powershell
docker tag my-node-app adityashukla1501/my-node-app:latest
```

## Step 7 — Push image

```powershell
docker push adityashukla1501/my-node-app:latest
```

## Step 8 — Another developer pulls it

```powershell
docker pull adityashukla1501/my-node-app:latest
```

## Step 9 — Another developer runs it

```powershell
docker run -p 3000:3000 adityashukla1501/my-node-app:latest
```

---

# 28. Complete Docker Compose Workflow

Create:

```text
docker-compose.yml
```

Then:

```powershell
docker compose up -d
```

Check:

```powershell
docker ps
```

View logs:

```powershell
docker compose logs -f
```

Stop everything:

```powershell
docker compose down
```

---

# 29. Final Architecture

After adding your Node.js application to Compose, a typical application can look like:

```text
                    Docker Compose
                         │
          ┌──────────────┼──────────────┐
          │              │              │
          ▼              ▼              ▼
      Node.js         PostgreSQL       Redis
      Container        Container      Container
          │              │              │
          └──────────────┼──────────────┘
                         │
                    Application
```

Docker Compose allows all these services to be managed together.

---

# 30. Most Important Commands to Remember

```powershell
# Build image
docker build -t my-node-app .

# Run container
docker run my-node-app

# Run with port mapping
docker run -p 3000:3000 my-node-app

# Login to Docker Hub
docker login

# Tag image
docker tag my-node-app adityashukla1501/my-node-app:latest

# Push image
docker push adityashukla1501/my-node-app:latest

# Pull image
docker pull adityashukla1501/my-node-app:latest

# Start Docker Compose
docker compose up

# Start Compose in background
docker compose up -d

# Check running containers
docker ps

# Stop and remove Compose containers
docker compose down
```

# Key Difference

```text
Dockerfile
    ↓
Build ONE application image

Docker Compose
    ↓
Manage MULTIPLE containers/services
```

Example:

```text
Dockerfile
    ↓
my-node-app image
    ↓
Node.js container
```

while:

```text
docker-compose.yml
    ↓
Node.js container
PostgreSQL container
Redis container
```

are managed together.
