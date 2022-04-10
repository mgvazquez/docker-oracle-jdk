FROM alpine:3.14.6

ARG BUILD_DATE
ARG BUILD_VCS_REF
ARG BUILD_VERSION

# ------------------------ GLIBC ------------------------

ENV LANG=C.UTF-8
ENV GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download"
ENV GLIBC_VERSION_PKG="2.26-r0"
ENV GLIBC_BASE_PKG="glibc-${GLIBC_VERSION_PKG}.apk"
ENV GLIBC_BIN_PKG="glibc-bin-${GLIBC_VERSION_PKG}.apk"
ENV GLIBC_I18N_PKG="glibc-i18n-${GLIBC_VERSION_PKG}.apk"

ADD ${GLIBC_BASE_URL}/${GLIBC_VERSION_PKG}/${GLIBC_BASE_PKG} /tmp/${GLIBC_BASE_PKG}
ADD ${GLIBC_BASE_URL}/${GLIBC_VERSION_PKG}/${GLIBC_BIN_PKG}  /tmp/${GLIBC_BIN_PKG}
ADD ${GLIBC_BASE_URL}/${GLIBC_VERSION_PKG}/${GLIBC_I18N_PKG} /tmp/${GLIBC_I18N_PKG}
ADD https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub /etc/apk/keys/sgerrand.rsa.pub

WORKDIR /tmp

RUN apk add --no-cache --virtual=.build-dependencies ca-certificates && \
    apk add --no-cache \
        "${GLIBC_BASE_PKG}" \
        "${GLIBC_BIN_PKG}" \
        "${GLIBC_I18N_PKG}" && \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true && \
    echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
    apk del glibc-i18n && \
    apk del .build-dependencies && \
    rm -f /tmp/*

# -------------------------------------------------------

ENV JAVA_VERSION=8 \
    JAVA_UPDATE=151 \
    JAVA_BUILD=12 \
    JAVA_PATH=e758a0de34e24606bca991d704f6dcbf \
    JAVA_HOME="/usr/lib/jvm/default-jvm"

RUN apk add --no-cache --virtual=build-dependencies wget ca-certificates unzip && \
    wget --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
        "http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_BUILD}/${JAVA_PATH}/jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" && \
    tar -xzf "jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" && \
    mkdir -p "/usr/lib/jvm" && \
    mv "/tmp/jdk1.${JAVA_VERSION}.0_${JAVA_UPDATE}" "/usr/lib/jvm/java-${JAVA_VERSION}-oracle" && \
    ln -s "java-${JAVA_VERSION}-oracle" "$JAVA_HOME" && \
    ln -s "$JAVA_HOME/bin/"* "/usr/bin/" && \
    rm -rf "$JAVA_HOME/"*src.zip && \
    rm -rf "$JAVA_HOME/lib/missioncontrol" \
           "$JAVA_HOME/lib/visualvm" \
           "$JAVA_HOME/lib/"*javafx* \
           "$JAVA_HOME/jre/lib/plugin.jar" \
           "$JAVA_HOME/jre/lib/ext/jfxrt.jar" \
           "$JAVA_HOME/jre/bin/javaws" \
           "$JAVA_HOME/jre/lib/javaws.jar" \
           "$JAVA_HOME/jre/lib/desktop" \
           "$JAVA_HOME/jre/plugin" \
           "$JAVA_HOME/jre/lib/"deploy* \
           "$JAVA_HOME/jre/lib/"*javafx* \
           "$JAVA_HOME/jre/lib/"*jfx* \
           "$JAVA_HOME/jre/lib/amd64/libdecora_sse.so" \
           "$JAVA_HOME/jre/lib/amd64/"libprism_*.so \
           "$JAVA_HOME/jre/lib/amd64/libfxplugins.so" \
           "$JAVA_HOME/jre/lib/amd64/libglass.so" \
           "$JAVA_HOME/jre/lib/amd64/libgstreamer-lite.so" \
           "$JAVA_HOME/jre/lib/amd64/"libjavafx*.so \
           "$JAVA_HOME/jre/lib/amd64/"libjfx*.so && \
    rm -rf "$JAVA_HOME/jre/bin/jjs" \
           "$JAVA_HOME/jre/bin/keytool" \
           "$JAVA_HOME/jre/bin/orbd" \
           "$JAVA_HOME/jre/bin/pack200" \
           "$JAVA_HOME/jre/bin/policytool" \
           "$JAVA_HOME/jre/bin/rmid" \
           "$JAVA_HOME/jre/bin/rmiregistry" \
           "$JAVA_HOME/jre/bin/servertool" \
           "$JAVA_HOME/jre/bin/tnameserv" \
           "$JAVA_HOME/jre/bin/unpack200" \
           "$JAVA_HOME/jre/lib/ext/nashorn.jar" \
           "$JAVA_HOME/jre/lib/jfr.jar" \
           "$JAVA_HOME/jre/lib/jfr" \
           "$JAVA_HOME/jre/lib/oblique-fonts" && \
    wget --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
        "http://download.oracle.com/otn-pub/java/jce/${JAVA_VERSION}/jce_policy-${JAVA_VERSION}.zip" && \
    unzip -jo -d "${JAVA_HOME}/jre/lib/security" "jce_policy-${JAVA_VERSION}.zip" && \
    rm "${JAVA_HOME}/jre/lib/security/README.txt" && \
    apk del build-dependencies && \
    rm "/tmp/"*

# ---------------------------------------------------------------------------------------------

ENTRYPOINT ["/bin/sh" ]

################### Don't move ###################
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/mgvazquez/docker-oracle-jdk.git" \
      org.label-schema.vcs-ref=$BUILD_VCS_REF \
      org.label-schema.version=$BUILD_VERSION \
      org.label-schema.maintainer="Manuel Andres Garcia Vazquez <mvazquez@scabb-island.com.ar>" \
      org.label-schema.oracle.jdk.version=$JAVA_VERSION.$JAVA_UPDATE-$JAVA_BUILD \
      com.microscaling.license=GPL-3.0
##################################################