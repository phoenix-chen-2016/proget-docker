FROM mono

EXPOSE 80

ARG PROGET_VERSION=5.3.7

RUN apt-get update && \
    apt-get install -y xz-utils && \
    # Cleanup the Dockerfile
    apt-get clean && \
    rm -rf /var/lib/apt/lists

RUN mkdir -p /usr/local/proget && curl -sSL "https://s3.amazonaws.com/cdn.inedo.com/downloads/proget-linux/ProGet.$PROGET_VERSION.tar.xz" | tar xJC /usr/local/proget

ENV PROGET_DATABASE "Server=proget-postgres; Database=postgres; User Id=postgres; Password=;"
ENV PROGET_DB_TYPE PostgreSQL
ENV PROGET_SVC_MODE both

VOLUME /var/proget/packages
VOLUME /var/proget/extensions
VOLUME /usr/share/Inedo/SharedConfig

CMD ([ -f /usr/share/Inedo/SharedConfig/ProGet.config ] || echo '<?xml version="1.0" encoding="utf-8"?><InedoAppConfig><ConnectionString Type="'"$PROGET_DB_TYPE"'">'"$PROGET_DATABASE"'</ConnectionString><WebServer Enabled="true" Urls="http://*:80/"/></InedoAppConfig>' > /usr/share/Inedo/SharedConfig/ProGet.config) \
&& exec mono /usr/local/proget/service/ProGet.Service.exe run --mode=$PROGET_SVC_MODE --linuxContainer
