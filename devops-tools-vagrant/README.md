# DevOps Tools Environment using Vagrant

This repository provisions a multi-VM setup using **Vagrant** and **VirtualBox** to automatically install and configure popular DevOps tools:
- Jenkins
- MongoDB
- Nexus Repository Manager
- SonarQube

Each tool runs in a separate Ubuntu 22.04 (Jammy) virtual machine.

---

## 🧰 Prerequisites

Make sure the following are installed on your system:
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [Vagrant](https://developer.hashicorp.com/vagrant/downloads)
- [vagrant-hostmanager](https://github.com/devopsgroup-io/vagrant-hostmanager) plugin:
  
```bash
  vagrant plugin install vagrant-hostmanager
````

---

## ⚙️ Setup Instructions

1. **Clone this Repository**:

   ```bash
   git clone https://github.com/shreyash99ramtekkar/devops_project_infra.git
   cd devops-tools-vagrant
   ```

2. **Start All VMs**:

   ```bash
   vagrant up
   ```

   This will spin up 4 VMs with the following tools installed:

   | Tool      | Hostname    | IP Address      | Port(s)              |
   | --------- | ----------- | --------------- | -------------------- |
   | MongoDB   | `mongo`     | `192.168.57.10` | 27017                |
   | Jenkins   | `jenkins`   | `192.168.57.11` | 8080                 |
   | SonarQube | `sonarqube` | `192.168.57.12` | 9000 (via NGINX: 80) |
   | Nexus     | `nexus`     | `192.168.57.13` | 8081                 |

3. **Access the Web Interfaces**:

   * Jenkins: [http://192.168.57.11:8080](http://192.168.57.11:8080)
   * MongoDB: Use a client like Compass or `mongosh`
   * Nexus: [http://192.168.57.13:8081](http://192.168.57.13:8081)
   * SonarQube: [http://192.168.57.12](http://192.168.57.12)

---

## 🔧 Tool-specific Details

### 📦 Jenkins

* Installs Jenkins LTS with Java 21.
* Starts and enables Jenkins as a systemd service.
* For initial admin password:

  ```bash
  sudo cat /var/lib/jenkins/secrets/initialAdminPassword
  ```

📖 Reference: [https://www.jenkins.io/doc/book/installing/](https://www.jenkins.io/doc/book/installing/)

---

### 🍃 MongoDB

* Installs MongoDB 8.0 Community Edition.
* Starts the `mongod` service.
* Installs `mongosh` shell for MongoDB interaction.

📖 Reference: [https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/](https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/)

---

### 📦 Nexus Repository Manager

* Installs Nexus 3.81.1 OSS.
* Runs Nexus as a systemd service under a dedicated user.
* Accessible via: [http://192.168.57.13:8081](http://192.168.57.13:8081)

📖 Reference: [https://help.sonatype.com/repomanager3](https://help.sonatype.com/repomanager3)

---

### 🔍 SonarQube

* Installs SonarQube 9.9.8 LTS and PostgreSQL 14.
* Configures DB user/password, and necessary kernel tuning.
* Reverse proxy via NGINX on port 80.

🔑 Credentials:

* DB User: `sonar`
* DB Password: `admin123`

📖 Reference:

* [https://docs.sonarqube.org/latest/setup/install-server/](https://docs.sonarqube.org/latest/setup/install-server/)
* [https://docs.sonarqube.org/latest/requirements/requirements/](https://docs.sonarqube.org/latest/requirements/requirements/)

---

## 🛠 Maintenance Commands

* **SSH into a VM**:

  ```bash
  vagrant ssh <vm-name>
  ```

* **Start a specific VM**:

  ```bash
  vagrant up <vm-name>
  ```

* **Destroy all VMs**:

  ```bash
  vagrant destroy -f
  ```

---

## 📁 Directory Structure

```
devops-tools-vagrant/
├── .vagrant/                 # Vagrant metadata
├── jenkins.sh                # Jenkins provisioning script
├── mongodb.sh                # MongoDB provisioning script
├── nexus.sh                  # Nexus provisioning script
├── sonarqube.sh              # SonarQube provisioning script
├── Vagrantfile               # Main Vagrant configuration
└── README.md                 # You're here!
```

---

## 📌 Notes

* The setup assumes a host-only network with IP range `192.168.57.x`.
* Ensure no port conflicts on your system before running.
* After `vagrant up`, wait a few minutes for all services to fully initialize.

---
