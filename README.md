# React + Python Development Environment

This Docker setup provides a complete development environment for both React and Python applications.

## Features

- **Node.js 18** for React development
- **Python 3.12** with virtual environment
- **Pre-installed packages**:
  - React: create-react-app, Vite
  - Python: Flask, Django, FastAPI, Jupyter, NumPy, Pandas, and more
- **Multiple port exposures** for different services
- **Volume mounting** for live code editing

## Quick Start

### Environment Configuration

1. **Copy the environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Edit the `.env` file** to customize ports and settings as needed:
   ```bash
   nano .env  # or use your preferred editor
   ```

### Using Docker Compose (Recommended)

1. **Build and run the container:**
   ```bash
   docker-compose up -d
   ```

2. **Access the container:**
   ```bash
   docker-compose exec dev-environment bash
   ```

3. **SSH into the container:**
   ```bash
   ssh developer@localhost -p 2222
   # Password: devpassword
   
   # Or as root:
   ssh root@localhost -p 2222
   # Password: password
   ```

### Using Docker directly

1. **Build the image:**
   ```bash
   docker build -t react-python-dev .
   ```

2. **Run the container:**
   ```bash
   docker run -it -p 3000:3000 -p 5000:5000 -p 8000:8000 -p 8888:8888 -v $(pwd):/app react-python-dev
   ```

## Usage Examples

### React Development

1. **Create a new React app:**
   ```bash
   cd /app/react-apps
   npx create-react-app my-app
   cd my-app
   npm start
   ```

2. **Create a Vite React app:**
   ```bash
   cd /app/react-apps
   npm create vite@latest my-vite-app --template react
   cd my-vite-app
   npm install
   npm run dev
   ```

### Python Development

1. **Create a Flask app:**
   ```bash
   cd /app/python-apps
   
   # Create app.py
   cat > app.py << EOF
   from flask import Flask
   app = Flask(__name__)
   
   @app.route('/')
   def hello():
       return 'Hello from Flask!'
   
   if __name__ == '__main__':
       app.run(host='0.0.0.0', port=5000, debug=True)
   EOF
   
   python app.py
   ```

2. **Create a FastAPI app:**
   ```bash
   cd /app/python-apps
   
   # Create main.py
   cat > main.py << EOF
   from fastapi import FastAPI
   app = FastAPI()
   
   @app.get("/")
   def read_root():
       return {"Hello": "World"}
   EOF
   
   uvicorn main:app --host 0.0.0.0 --port 8000 --reload
   ```

3. **Start Jupyter Notebook:**
   ```bash
   cd /app/python-apps
   jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root
   ```

### Database Administration

1. **Access pgAdmin:**
   - Open `http://localhost:5050` in your browser
   - Login with:
     - **Email**: `admin@example.com`
     - **Password**: `devpassword`

2. **Connect to PostgreSQL databases:**
   - Click "Add New Server"
   - **Name**: Your database name
   - **Host**: `host.docker.internal` (for host databases) or container name
   - **Port**: Database port (e.g., 5432 for PostgreSQL)
   - **Username/Password**: Your database credentials

## Environment Configuration

The development environment uses environment variables for flexible configuration. All settings are defined in the `.env` file.

### Port Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `SSH_PORT` | 2222 | SSH server port mapping |
| `REACT_PORT` | 3000 | React development server |
| `FLASK_PORT` | 5000 | Flask applications |
| `DJANGO_PORT` | 8000 | Django/FastAPI applications |
| `WEB_PORT` | 8080 | Alternative web server |
| `JUPYTER_PORT` | 8888 | Jupyter Notebook interface |
| `PGADMIN_PORT` | 5050 | pgAdmin web interface |

### Setup Steps

1. **Copy environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Customize your settings** (optional):
   ```bash
   # Edit ports if you have conflicts
   nano .env
   ```

3. **View current configuration:**
   ```bash
   cat .env
   ```

### Common Customizations

- **Change SSH port** if 2222 is already in use:
  ```env
  SSH_PORT=2223
  ```

- **Use different React port** for multiple projects:
  ```env
  REACT_PORT=3001
  ```

- **Add API keys** for external services:
  ```env
  OPENAI_API_KEY=your_key_here
  ```

## Port Mappings

The following ports are configurable via environment variables:

- **SSH_PORT** (default 2222): SSH server access
- **REACT_PORT** (default 3000): React development server
- **FLASK_PORT** (default 5000): Flask applications
- **DJANGO_PORT** (default 8000): Django/FastAPI applications
- **WEB_PORT** (default 8080): Alternative web server
- **JUPYTER_PORT** (default 8888): Jupyter Notebook interface
- **PGADMIN_PORT** (default 5050): pgAdmin web interface

Access your services at:
- SSH: `ssh developer@localhost -p ${SSH_PORT}`
- React: `http://localhost:${REACT_PORT}`
- Flask: `http://localhost:${FLASK_PORT}`
- Django/FastAPI: `http://localhost:${DJANGO_PORT}`
- Jupyter: `http://localhost:${JUPYTER_PORT}`
- pgAdmin: `http://localhost:${PGADMIN_PORT}`

## Directory Structure

```
/app/
├── react-apps/     # Place your React projects here
├── python-apps/    # Place your Python projects here
├── package.json    # Node.js dependencies
└── requirements.txt # Python dependencies
```

## Adding Dependencies

### Python Dependencies
Add packages to `requirements.txt` and rebuild the container, or install directly:
```bash
pip install package-name
```

### Node.js Dependencies
Navigate to your React project and install:
```bash
cd /app/react-apps/my-app
npm install package-name
```

## Stopping the Environment

```bash
docker-compose down
```

## SSH Access

The container includes an SSH server for remote development access.

### Default Credentials
- **User**: `developer` / **Password**: `devpassword` (recommended)
- **User**: `root` / **Password**: `password` (admin access)

### SSH Connection
```bash
# Connect as developer user
ssh developer@localhost -p 2222

# Connect as root
ssh root@localhost -p 2222
```

### Security Note
**Important**: Change the default passwords in production environments. You can modify the passwords by rebuilding the container with updated credentials in the Dockerfile.

### SSH Key Authentication (Recommended)
For better security, set up SSH key authentication:

1. Generate SSH key pair on your host:
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/docker_dev_key
   ```

2. Copy public key to container:
   ```bash
   ssh-copy-id -i ~/.ssh/docker_dev_key.pub -p 2222 developer@localhost
   ```

3. Connect using key:
   ```bash
   ssh -i ~/.ssh/docker_dev_key -p 2222 developer@localhost
   ```

## Customization

You can modify the `Dockerfile` to add more tools or change versions according to your needs.
