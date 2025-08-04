# Multi-stage Dockerfile for React and Python applications
FROM node:18-bullseye-slim

# Install Python, SSH server and system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    curl \
    git \
    vim \
    openssh-server \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create symbolic link for python command
RUN ln -s /usr/bin/python3 /usr/bin/python

# Set working directory
WORKDIR /app

# Install global npm packages for React development
RUN npm install -g create-react-app @vitejs/create-app

# Create Python virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Configure SSH
RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Create a non-root user for SSH access
RUN useradd -m -s /bin/bash developer && \
    echo 'developer:devpassword' | chpasswd && \
    usermod -aG sudo developer

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Upgrade pip and install common Python packages
RUN pip install --upgrade pip setuptools wheel

# Install common Python packages for web development and data science
RUN pip install \
    flask \
    django \
    fastapi \
    uvicorn \
    requests \
    numpy \
    pandas \
    matplotlib \
    jupyter \
    pytest

# Create directories for both React and Python projects
RUN mkdir -p /app/react-apps /app/python-apps

# Create dummy files to ensure COPY doesn't fail if originals don't exist
RUN touch /tmp/dummy-package.json /tmp/dummy-requirements.txt

# Copy package.json if it exists, otherwise copy dummy
COPY package*.json ./react-apps/
COPY requirements.txt ./python-apps/

# Install Node.js dependencies if package.json exists and is not empty
RUN cd /app/react-apps && \
    if [ -f package.json ] && [ -s package.json ]; then \
        npm install; \
    else \
        echo "No package.json found or file is empty"; \
    fi

# Install Python dependencies if requirements.txt exists and is not empty
RUN cd /app/python-apps && \
    if [ -f requirements.txt ] && [ -s requirements.txt ]; then \
        pip install -r requirements.txt; \
    else \
        echo "No requirements.txt found or file is empty"; \
    fi

# Expose ports for React (3000), Python web apps (8000, 5000), and SSH (22)
EXPOSE 22 3000 5000 8000 8080

# Create startup script to run SSH daemon and keep container running
RUN echo '#!/bin/bash\n\
service ssh start\n\
exec "$@"' > /usr/local/bin/docker-entrypoint.sh && \
    chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
# Set default command to bash for interactive development
CMD ["bash"]
