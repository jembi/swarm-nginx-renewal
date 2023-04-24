FROM docker:20.10.12

RUN apk add --update coreutils && rm -rf /var/cache/apk/*

ADD renew.sh .

ENTRYPOINT ["sh","-c","./renew.sh"]
