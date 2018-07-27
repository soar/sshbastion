# SSH Bastion

## Usage

### Quick way

1. Create your own image based on this image with following files:
 
    `Dockerfile`:
    
    ```Dockerfile
    FROM soarname/sshbastion
    
    ```
    
    `homefs/.ssh/authorized_keys`:
    
    ```bash
    ssh-rsa AAAA... your first user rsa key
    ssh-rsa AAAA... your second user rsa key
    ```
    
2. Build your image:    

    ```bash
    docker build -t devgateway .
    docker run -p 2022:22 -it devgateway
    ```
