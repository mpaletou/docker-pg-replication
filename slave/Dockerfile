FROM postgres:12.8-bullseye

ENV GOSU_VERSION 1.10

ADD ./gosu /usr/bin/
RUN chmod +x /usr/bin/gosu

RUN apt update \
	&& apt install -y --no-install-recommends iputils-ping \
	&& rm -rf /var/lib/apt/lists/*

COPY ./docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

#CMD ["gosu", "postgres", "tail", "-f", "/dev/null"]
CMD ["gosu", "postgres", "postgres"]
