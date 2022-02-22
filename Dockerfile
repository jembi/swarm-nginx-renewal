FROM docker:20.10.12

ADD renew.sh .

ENTRYPOINT ["sh","-c","./renew.sh"]
