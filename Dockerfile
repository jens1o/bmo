FROM mozillabteam/bmo-slim:20180801.2

ARG CI
ARG CIRCLE_SHA1
ARG CIRCLE_BUILD_URL

ENV CI=${CI}
ENV CIRCLE_BUILD_URL=${CIRCLE_BUILD_URL}
ENV CIRCLE_SHA1=${CIRCLE_SHA1}

ENV LOG4PERL_CONFIG_FILE=log4perl-json.conf
ENV HTTPD_StartServers=8
ENV HTTPD_MinSpareServers=5
ENV HTTPD_MaxSpareServers=20
ENV HTTPD_ServerLimit=256
ENV HTTPD_MaxClients=256
ENV HTTPD_MaxRequestsPerChild=4000

ENV PORT=8000

# we run a loopback logging server on this TCP port.
ENV LOGGING_PORT=5880

WORKDIR /app
COPY . .

RUN mv /opt/bmo/local /app && \
    chown -R app:app /app && \
    perl -I/app -I/app/local/lib/perl5 -c -E 'use Bugzilla; BEGIN { Bugzilla->extensions }' && \
    perl -c /app/scripts/entrypoint.pl && \
    setcap 'cap_net_bind_service=+ep' /usr/sbin/httpd

USER app

RUN perl checksetup.pl --no-database --default-localconfig && \
    rm -rf /app/data /app/localconfig && \
    mkdir /app/data

EXPOSE $PORT

ENTRYPOINT ["/app/scripts/entrypoint.pl"]
CMD ["httpd"]
