<!--
  Copyright 2020 ForgeRock AS. All Rights Reserved

  Use of this code requires a commercial software license with ForgeRock AS.
  or with one of its affiliates. All use shall be exclusively subject
  to such license between the licensee and ForgeRock AS.
-->
# ForgeRock Identity Gateway - Build your own Docker Image

## Build the Docker image from the Dockerfile
- Go to the identity-gateway directory
- Run `$ docker build . -f docker/Dockerfile -t com.acme/ig`

### Run the Docker image:
- Run `$ docker images` to see the list of available images:
```
REPOSITORY                     TAG                              IMAGE ID            CREATED             SIZE
com.acme/ig                   latest                           d8114f9491a5        5 seconds ago       249MB
```
- Run the image with specific port number:
`$ docker run -p <host port number>:8080 com.acme/ig`
- Run the image in [interactive mode with forgerock user and sh shell](https://docs.docker.com/engine/reference/commandline/run/):
`$ docker run -it --user 11111 com.acme/ig sh`<br> or `docker exec -it <CONTAINER_ID> /bin/sh`


### Stop a running container
- Run `$ docker container list`
- Then `$ docker container stop <container id>`

### Content of IG dockerfile
- IG binaries are installed in `/opt/ig`.
- $IG_INSTANCE_DIR points to `/var/ig`.
- The `forgerock` user (uid:11111) runs the IG process and owns the configuration files.

### Loading local instance files
Run the following command to mount your local instance directory when running the Docker image:
`docker run -v <local_ig_instance_dir_path>:/var/ig/ com.acme/ig`

### Custom configuration

#### TLS for IG
- Run your Docker image in interactive mode.
- Create a keystore holding a self-signed certificate:
    ~~~
    keytool -genkey \
            -alias ig \
            -keyalg RSA \
            -keystore /var/ig/keystore \
            -storepass password \
            -keypass password \
            -dname "CN=openig.example.com,O=Example Corp,C=FR"
    ~~~
- Edit the `/var/ig/config/admin.json` file and add the following connector definition:
    ```
    {
      "port": 8443,
      "tls": {
        "type": "ServerTlsOptions",
        "config": {
          "keyManager": {
            "type": "SecretsKeyManager",
            "config": {
              "signingSecretId": "key.manager.secret.id",
              "secretsProvider": {
                "type": "KeyStoreSecretStore",
                "config": {
                  "file": "/var/ig/keystore",
                  "storePassword": "keystore.pass",
                  "storeType": "JKS",
                  "secretsProvider": {
                    "type": "Base64EncodedSecretStore",
                    "config": {
                      "secrets": {
                        "keystore.pass": "cGFzc3dvcmQ="
                      }
                    }
                  },
                  "mappings": [
                    {
                      "secretId": "key.manager.secret.id",
                      "aliases": ["ig"]
                    }
                  ]
                }
              }
            }
          }
        }
      }
    }
    ```
- Restart the container.
- Navigate to `https://localhost:8443` or `curl -v -k https://localhost:8443` from the Docker
host to see IG welcome page.

#### External links
- [Docker Documentation](https://docs.docker.com/)
