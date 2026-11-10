
FROM cm2network/steamcmd:root

RUN apt-get update && apt-get install -y --no-install-recommends \
    lib32gcc-s1 \
    lib32stdc++6 \
    ca-certificates \
    curl \
    unzip \
    python3 \
    && rm -rf /var/lib/apt/lists/*

COPY --chmod=755 entrypoint.sh /entrypoint.sh

RUN sed -i '1s/^\xEF\xBB\xBF//' /entrypoint.sh \
    && sed -i 's/\r$//' /entrypoint.sh \
    && chmod +x /entrypoint.sh

USER steam
WORKDIR /home/steam

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
