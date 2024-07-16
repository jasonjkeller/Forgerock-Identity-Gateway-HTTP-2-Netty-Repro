# Forgerock Identity Gateway HTTP/2 Netty Repro

This project configures Forgerock Identity Gateway to repro an issue where the New Relic Java agent's Netty 4.1.16 instrumentation isn't starting transactions for HTTP/2 requests.

## resources
https://backstage.forgerock.com/docs/ig/2024.6  
https://backstage.forgerock.com/docs/ig/2024.6/installation-guide/start-stop.html  
https://backstage.forgerock.com/docs/ig/2024.6/installation-guide/securing-connections.html  
https://backstage.forgerock.com/docs/ig/2024.6/getting-started/single-page.html  

## Java agent branch
WIP can be found on this branch: https://github.com/newrelic/newrelic-java-agent/tree/http2-netty-debug

## update etc/hosts
Add the following to `/etc/hosts`:
```
127.0.0.1  localhost ig.example.com app.example.com am.example.com
```

## secure connections
You might need to setup up the certs on your machine as described here: https://backstage.forgerock.com/docs/ig/2024.6/installation-guide/securing-connections.html

## frig server
Update frig server script to include java agent in `forgerock-ping-gateway/identity-gateway-2024.6.0/bin/start.sh`:
```
JAVA_OPTS="$JAVA_OPTS -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=localhost:5005 -javaagent:/path/to/newrelic/newrelic.jar -Dnewrelic.config.log_file_name=frig-server.log -Dnewrelic.config.app_name=frig-server-3 -Dnewrelic.debug=true -Dnewrelic.token_debug=true -Dnewrelic.config.token_timeout=10 -Dnewrelic.config.segment_timeout=20"
```

Start frig server from `forgerock-ping-gateway/identity-gateway-2024.6.0/bin`:
```
./start.sh
```

## copy frig server config files
Once you've started the frig server it should create a config directory at `/Users/<USER>/.openig/config/`. Copy the files in `.openig/config/` in this repo over to `/Users/<USER>/.openig/config/`.
You will need to update the admin.json file to enter the correct directory value, which should point to the `forgerock-ping-gateway/tls` directory in this repo. 
You will need to update the client-side-https.json to enter the correct directory for the `reverseproxy-truststore.p12`, which should also point to the one in this repo.

## PingGateway sample application
Start the sample app `forgerock-ping-gateway/PingGateway-sample-application-2024.6.0.jar` (attaching the Java agent isn't required for repro):
```
java -javaagent:/path/to/newrelic/newrelic.jar -Dnewrelic.config.log_file_name=ping-gateway-sample-application.log -Dnewrelic.config.app_name=ping-gateway-sample-application -Dnewrelic.config.log_level=info -jar PingGateway-sample-application-2024.6.0.jar
```

## endpoints to hit
Below are the endpoints for reproing the issue. They can be exercised using the k6 load tester tool (see details below) or just in the browser.

### HTTP/1
http://ig.example.com:8080/openig/ping  
http://ig.example.com:8080/openig/api/info  
http://ig.example.com:8080/static  
http://ig.example.com:8080/home/client-side-https  

### HTTP/2
https://ig.example.com:8443/openig/ping  
https://ig.example.com:8443/openig/api/info  
https://ig.example.com:8443/static  
https://ig.example.com:8443/home/client-side-https  

## k6 load test
From `k6/` execute the following script:
```
k6 run --insecure-skip-tls-verify load-test.js
```

The script can be modified to change the duration of the load test as well as the endpoints being hit.