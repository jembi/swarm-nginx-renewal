FROM jembi/platform:latest

ADD renew.sh .

ENTRYPOINT ["sh","-c","./renew.sh"]
