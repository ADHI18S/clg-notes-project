### **1. GitHub Actions**

**GitHub Actions** is a CI/CD tool integrated into GitHub that allows you to automate workflows directly within your GitHub repository. Workflows are defined in YAML files located in the `.github/workflows` directory.

- **Workflow**: The entire process defined in a `.yml` file that specifies the automation steps.
- **Job**: A group of steps executed on the same runner.
- **Step**: A single task within a job.

### **2. Docker**

**Docker** is a platform that allows you to develop, ship, and run applications inside containers. Containers are lightweight, portable, and ensure consistent environments across different stages of development and deployment.

- **Docker Image**: A read-only template that contains the application code, runtime, libraries, and dependencies.
- **Docker Container**: A runnable instance of a Docker image.

**Commands**:
- `docker build -t your-image:latest .`: Builds a Docker image from a Dockerfile in the current directory.
- `docker push your-image:latest`: Pushes the built image to Docker Hub.
- `docker pull your-image:latest`: Pulls the image from Docker Hub.
- `docker run -d -p 80:80 your-image:latest`: Runs the image in a new container, mapping port 80 on the host to port 80 on the container.

### **3. Docker Hub**

**Docker Hub** is a cloud-based repository where you can store and share Docker images. 

**Credentials**:
- **DOCKER_USERNAME**: Your Docker Hub username.
- **DOCKER_PASSWORD**: Your Docker Hub password.

### **4. SSH (Secure Shell)**

**SSH** is a protocol used to securely log into remote machines and execute commands. It's commonly used for managing servers.

**Components**:
- **SSH Key**: A pair of cryptographic keys (private and public) used for authentication. The private key is kept secret, while the public key is shared.

### **5. EC2 (Elastic Compute Cloud)**

**Amazon EC2** is a web service that provides resizable compute capacity in the cloud. It is designed to make web-scale cloud computing easier for developers.

**Components**:
- **Instance**: A virtual server running on AWS.
- **Elastic IP**: A static, public IPv4 address designed for dynamic cloud computing.

### **6. GitHub Secrets**

**GitHub Secrets** are encrypted environment variables that you create in a repository and can use in your GitHub Actions workflows.

### **Step-by-Step Explanation**

#### **Step 1: Trigger Workflow on Push to Main Branch**

```yaml
on:
  push:
    branches:
      - main
```
- This sets up the workflow to run whenever there is a push to the `main` branch of the repository.

#### **Step 2: Define Deployment Job**

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
```
- Defines a job named `deploy` that runs on the latest version of Ubuntu.

#### **Step 3: Checkout Code**

```yaml
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
```
- Uses the `actions/checkout` action to check out the repository code so that it can be used in the workflow.

#### **Step 4: Set Up Node.js (Optional)**

```yaml
    - name: Set up Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '16'
```
- Optionally sets up Node.js if your project requires it.

#### **Step 5: Build and Push Docker Image**

```yaml
    - name: Build and push Docker image
      env:
        DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
        DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
      run: |
        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
        docker build -t your-dockerhub-username/your-image-name:latest .
        docker push your-dockerhub-username/your-image-name:latest
```
- Logs into Docker Hub using credentials stored in GitHub Secrets.
- Builds a Docker image from the codebase.
- Pushes the Docker image to Docker Hub.

#### **Step 6: Deploy to EC2**

```yaml
    - name: Deploy to EC2
      uses: appleboy/ssh-action@v0.1.2
      with:
        host: ${{ secrets.EC2_HOST }}
        username: ubuntu
        key: ${{ secrets.EC2_SSH_KEY }}
        envs: |
          DOCKER_IMAGE=your-dockerhub-username/your-image-name:latest
        script: |
          docker pull $DOCKER_IMAGE
          docker stop $(docker ps -q --filter ancestor=$DOCKER_IMAGE || true)
          docker rm $(docker ps -a -q --filter ancestor=$DOCKER_IMAGE || true)
          docker run -d -p 80:80 $DOCKER_IMAGE
```
- Uses the `appleboy/ssh-action` to SSH into the EC2 instance using the host, username, and private key stored in GitHub Secrets.
- Pulls the latest Docker image.
- Stops and removes any running containers from the previous image.
- Runs a new container from the pulled image.

### **Configuring GitHub Secrets**

1. **Navigate to Repository Settings**:
   - Go to your repository on GitHub.
   - Click on `Settings` -> `Secrets and variables` -> `Actions`.

2. **Add a New Secret**:
   - Click `New repository secret`.
   - **Name**: Enter a name for the secret (e.g., `DOCKER_USERNAME`, `DOCKER_PASSWORD`, `EC2_HOST`, `EC2_SSH_KEY`).
   - **Value**: Paste the value of the secret (e.g., your Docker Hub username, password, EC2 instance IP, and private SSH key).

By following this step-by-step explanation, you should have a good understanding of the tools and services used in the GitHub Actions workflow for deploying a Dockerized application to an EC2 instance.
