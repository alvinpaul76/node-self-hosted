# Multi-stage Dockerfile for React and Python applications
FROM node:18-bookworm-slim

# Install system dependencies and build tools for Python 3.12
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    vim \
    openssh-server \
    sudo \
    wget \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.12 from source
RUN cd /tmp && \
    wget https://www.python.org/ftp/python/3.12.7/Python-3.12.7.tgz && \
    tar xzf Python-3.12.7.tgz && \
    cd Python-3.12.7 && \
    ./configure --enable-optimizations --with-ensurepip=install && \
    make -j 8 && \
    make altinstall && \
    cd / && \
    rm -rf /tmp/Python-3.12.7*

# Create symbolic links for python and pip
RUN ln -sf /usr/local/bin/python3.12 /usr/local/bin/python3 && \
    ln -sf /usr/local/bin/python3.12 /usr/local/bin/python && \
    ln -sf /usr/local/bin/pip3.12 /usr/local/bin/pip3 && \
    ln -sf /usr/local/bin/pip3.12 /usr/local/bin/pip

# Update PATH to prioritize our Python installation
ENV PATH="/usr/local/bin:$PATH"

# Set working directory
WORKDIR /app

# Install global npm packages for React development
RUN npm install -g create-react-app @vitejs/create-app

# Create Python 3.12 virtual environment
RUN python3.12 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Configure SSH
RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Generate SSH host keys
RUN ssh-keygen -A

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

# Note: package.json and requirements.txt will be mounted via volumes
# Dependencies can be installed at runtime or via docker-compose exec commands

# Expose ports for React (3000), Python web apps (8000, 5000), and SSH (22)
EXPOSE 22 3000 5000 8000 8080

# Create startup script to run SSH daemon and keep container running
RUN echo '#!/bin/bash\n\
# Fix SSH host key permissions if they exist\n\
if [ -d "/etc/ssh" ]; then\n\
    chmod 600 /etc/ssh/ssh_host_*_key 2>/dev/null || true\n\
    chmod 644 /etc/ssh/ssh_host_*_key.pub 2>/dev/null || true\n\
fi\n\
\n\
# Generate SSH host keys if they do not exist\n\
if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then\n\
    ssh-keygen -A\n\
fi\n\
\n\
# Start SSH service\n\
service ssh start\n\
\n\
# Execute the command passed to the container\n\
exec "$@"' > /usr/local/bin/docker-entrypoint.sh && \
    chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
# Set default command to bash for interactive development
CMD ["bash"]
