FROM alpine:3.5

COPY ./scripts/ ./scripts/

# Declare environment variables (assign defaults as required)
ENV CLEAN_FREQUENCY=${CLEAN_FREQUENCY:-3600}
ENV CONTAINERS_T0_CLEAN=${CONTAINERS_T0_CLEAN:-ALL}
ENV INCLUDE_SELF=${INCLUDE_SELF:-TRUE}
ENV SELF_NAME=${SELF_NAME:-log-cleaner}

RUN \
    apk update && \
    apk --no-cache add bash s6 docker tree && \
    chmod a+x ./scripts/*

CMD ["/bin/bash", "/scripts/entrypoint.sh"]