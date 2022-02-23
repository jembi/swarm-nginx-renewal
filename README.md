# Swarm Nginx Renewal
A docker image that will assist in the renewal of certificates when using nginx and certbot with docker swarm.

## Note - staging certificates
The certificate generation and renewal process can be run against the staging servers of letsencrypt to avoid reaching rate limits. This is controlled by the STAGING environment variable.
