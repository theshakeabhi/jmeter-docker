# Build a reproducible JMeter image
FROM eclipse-temurin:11-jre as jre

ARG JMETER_VERSION=5.6.3
ENV JMETER_HOME=/opt/apache-jmeter-${JMETER_VERSION}
ENV JMETER_BIN=${JMETER_HOME}/bin
ENV PATH="${JMETER_BIN}:${PATH}"

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl unzip ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Download and install Apache JMeter
RUN curl -fsSL https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz \
    -o /tmp/jmeter.tgz \
 && mkdir -p /opt \
 && tar -xzf /tmp/jmeter.tgz -C /opt \
 && rm -f /tmp/jmeter.tgz

# Work directories (mounted as volumes at runtime)
RUN mkdir -p /testplan /config /results /reports

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Default JVM heap for JMeter (overridable)
ENV JMETER_HEAP="-Xms512m -Xmx2048m"

WORKDIR /work
ENTRYPOINT ["/entrypoint.sh"]
