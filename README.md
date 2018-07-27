# SSH Bastion

## Usage

Some variables will be used here:

* `$JUMPER_PORT` - SSH port which will be used for jumping to another hosts. As port `22` most likely will be busy by system SSH daemon, we will use another port, for example `10022`.
* `$JUMPER_HOST` - host which will be used as bastion, it may be dedicated server or part of your cluster. For examples we will use `localhost`.
* `$JUMPER_USER` - user which will be used to login on this host, something like `developer` or `admin`. By default it is `jumper`.

So, here is defaults:
    
```bash
JUMPER_PORT=10022
JUMPER_HOST=localhost
JUMPER_USER=jumper
```    

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
    
2. Build and run your image:    

    ```bash
    docker build -t mybastion .
    docker run -p $JUMPER_PORT:$JUMPER_PORT -it mybastion
    ```

3. Test it with commands above    
4. Deploy it on your infrastructure   

### Connecting

#### With port forwarding

1. Establish connection to bastion-host and open local port
    ```bash
    ssh -N -L $LP:$TARGET_HOSTNAME:$TARGET_PORT -p $JUMPER_PORT $JUMPER_USER@$JUMPER_HOST
    ```
    
    where:
    * `-N` - not to try to allocate PTY
    * `-L` - local port redirection mode
    * `$LP` - local port to open (`1024+` if you are not root)
    * `$TARGET_HOSTNAME` - target hostname to connect to
    * `$TARGET_PORT` - target port to connect to
    * `$JUMPER_PORT`, `$JUMPER_USER`, `$JUMPER_HOST` - see above
    
    for example:
    
    ```bash
    # connect to another machine over SSH
    ssh -N -L 2022:anotherhost.example.com:22 -p $JUMPER_PORT $JUMPER_USER@$JUMPER_HOST
    # connect to remote MySQL server
    ssh -N -L 13306:anotherhost.example.com:3306 -p $JUMPER_PORT $JUMPER_USER@$JUMPER_HOST
    ```
    
2. Connect via opened local port
    Now you can use any application forwarded in previous step, just use `localhost:$LP` as target. For example for SSH:

    ```bash
    ssh -p $LP $REMOTE_USER@localhost
    ```    
    
    where:
    * `$LP` - locally opened port from previous step
    * `$REMOTE_USER` - user to authenticate on target host
    * `localhost` - your address, where you've started tunnel
    
    for example:
    
    ```bash
    # connect to another machine over SSH
    ssh -p 2022 targetuser@localhost
    # connect to remote MySQL server
    mysql -u root -h localhost -P 13306 
    ```
    
#### With SSH proxy-command

SSH will open tunnel for you automatically with next command:

```bash
ssh -o ProxyCommand="ssh -W %h:%p -p $JUMPER_PORT $JUMPER_USER@$JUMPER_HOST" targetuser@$TARGET_HOSTNAME
```

For example:

```bash
ssh -o ProxyCommand="ssh -W %h:%p -p 10022 jumper@localhost" targetuser@anotherhost.example.com
```
