FROM postgres:16-alpine

COPY init.sh /init.sh
COPY init.sql /init.sql

ENTRYPOINT ["sh", "/init.sh"]