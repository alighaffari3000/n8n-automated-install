# Automated n8n Installation Script for Ubuntu

This bash script automates the installation of n8n (Workflow Automation) on Ubuntu alongside with automatic Nginx Proxy Manager deployment

**Disclaimer:** This script automates many steps but requires manual configuration of Nginx Proxy Manager and DNS records for full functionality. Please review the script and ensure you understand each step before execution.

## Prerequisites

*   An Ubuntu-based virtual server (VPS).
*   SSH access to the server with a user with sudo privileges.
*   Basic knowledge of server administration and networking.

## Installation

1.  **Run the automated installation script:**

    Execute the following command to download the script, make it executable, and run it. 

    ```bash
    wget https://raw.githubusercontent.com/alighaffari3000/n8n-automated-install/main/install_n8n.sh && chmod +x install_n8n.sh && sudo ./install_n8n.sh
    ```
When prompted, enter the domain name you want to use for your n8n instance (e.g., `n8n.example.com`).


## Manual Configuration Steps

After the script completes, some manual configuration is still required:

1.  **Access Nginx Proxy Manager:** Open your server IP address in a web browser, adding port `81` to access the Nginx Proxy Manager interface (e.g., `http://YOUR_SERVER_IP:81`).

2.  **Add a Proxy Host:**

    *   Log in to Nginx Proxy Manager with the default credentials:
        *   Email: `admin@example.com`
        *   Password: `changeme`
    *   Create a new Proxy Host.
    *   Enter your domain name.
    *   Set the "Forward Hostname / IP" to `n8n`.
    *   Set the "Forward Port" to `5678`.

3.  **Obtain and Apply an SSL Certificate:**
    *    Go to SSL Certificate
    *    Setup a new certification with lets encrypt and configure for the proper domain

4.  **DNS Record Configuration**
    *    In Your DNS record add a DNS entry on the aizoome.ir address so that your server can run to your server IP address (check that it was done right by running ```ping n8n.aizoome.ir```

## Important Notes
*   This script assumes you have not run n8n before to generate an error that will mess up the set up. If you think you might have already setup Nginx, Please run this command to delete any pre existing images ```docker stop n8n; docker rm n8n```
*   The script is intended to install both Nginx Proxy Manager AND n8n on the server.

    After it's done set up is required. If it isn't correctly installed please review and modify the ports in the install and docker-compose steps.
    It's intended that `hostname -I` works by default please make sure that it does.

## Contributing

Feel free to contribute to this project by submitting pull requests with improvements or bug fixes.

## License

[Choose a license and replace this line with the appropriate badge and information.  Common options are Apache 2.0, MIT, etc.]
