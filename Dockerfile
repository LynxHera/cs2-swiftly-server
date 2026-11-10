FROM cm2network/steamcmd:root
RUN apt-get update && apt-get install -y --no-install-recommends lib32gcc-s1 lib32stdc++6 ca-certificates curl unzip python3 && rm -rf /var/lib/apt/lists/*
COPY --chmod=755 entrypoint.sh /entrypoint.sh
USER steam
WORKDIR /home/steam
ENTRYPOINT ["/entrypoint.sh"]
