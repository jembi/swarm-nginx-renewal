#!/bin/sh

renewalEmail=${RENEWAL_EMAIL}
staging=${STAGING:-"false"}
domainName=${DOMAIN_NAME}
subdomainNames=${SUBDOMAINS}
timestamp="$(date "+%Y%m%d%H%M%S")"
domainArgs=""

if [ ! -z "$subdomainNames" ]; then
  domainArgs="-d $domainName,$subdomainNames"
else
  domainArgs="-d $domainName"
fi

if [ "$staging" = "true" ]; then
  stagingArgs="--staging"
fi

docker run --rm \
    -p 8083:80 \
    -p 8443:443 \
    --name certbot \
    --network cert-renewal-network \
    -v "data-certbot-conf:/etc/letsencrypt/archive/$domainName" \
    certbot/certbot:v1.23.0 certonly -n \
    --standalone \
    $stagingArgs \
    -m "$renewalEmail" \
    "$domainArgs" \
    --agree-tos 

docker run --rm --network host --name certbot-helper -w /temp -v data-certbot-conf:/temp-certificates -v renew-certbot-conf:/temp busybox sh -c "rm -rf certificates; mkdir certificates; cp -r /temp-certificates/* /temp/certificates"
docker volume rm data-certbot-conf

docker secret create --label name=nginx "$timestamp-fullchain.pem" "/instant/certificates/fullchain1.pem"
docker secret create --label name=nginx "$timestamp-privkey.pem" "/instant/certificates/privkey1.pem"

currentFullchainName=$(docker service inspect instant_reverse-proxy-nginx --format "{{(index .Spec.TaskTemplate.ContainerSpec.Secrets 0).SecretName}}")
currentPrivkeyName=$(docker service inspect instant_reverse-proxy-nginx --format "{{(index .Spec.TaskTemplate.ContainerSpec.Secrets 1).SecretName}}")

docker service update \
    --secret-rm "$currentFullchainName" \
    --secret-rm "$currentPrivkeyName" \
    --secret-add source="$timestamp-fullchain.pem",target=/run/secrets/fullchain.pem \
    --secret-add source="$timestamp-privkey.pem",target=/run/secrets/privkey.pem \
    instant_reverse-proxy-nginx
