FROM eclipse-temurin:21-jdk

ARG USER_HOME_DIR="/root"
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"
COPY maven/settings.xml /root/.m2/settings.xml

RUN apt-get update && apt-get install -y unzip wget

RUN echo "Install Android SDK"
ARG ANDROID_SDK_VERSION=9123335
ENV ANDROID_HOME /opt/android-sdk
ENV ANDROID_SDK /opt/android-sdk
RUN mkdir -p ${ANDROID_HOME}

RUN wget -O ${ANDROID_HOME}/commandlinetools.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip \
    && unzip ${ANDROID_HOME}/commandlinetools.zip -d ${ANDROID_HOME}/cmdline-tools \
    && rm ${ANDROID_HOME}/commandlinetools.zip

RUN mkdir -p ${ANDROID_HOME}/cmdline-tools/latest \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools/* ${ANDROID_HOME}/cmdline-tools/latest/

RUN yes | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --licenses \
    && yes | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager "platform-tools" \
    && yes | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager \
        "build-tools;30.0.3" \
        "build-tools;31.0.0" \
        "build-tools;32.0.0" \
        "build-tools;33.0.0" \
        "build-tools;34.0.0" \
    && yes | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager \
        "platforms;android-30" \
        "platforms;android-31" \
        "platforms;android-32" \
        "platforms;android-33" \
        "platforms;android-34"

RUN mkdir -p /usr/share/android-ndk \
    && wget -O /tmp/android-ndk.zip https://dl.google.com/android/repository/android-ndk-r21-linux-x86_64.zip \
    && unzip -d /usr/share/android-ndk /tmp/android-ndk.zip \
    && rm -f /tmp/android-ndk.zip
ENV ANDROID_NDK_HOME /usr/share/android-ndk/android-ndk-r21
ENV PATH $PATH:$ANDROID_NDK_HOME

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        libreadline-dev \
        wget \
        unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget -O lua-5.1.5.tar.gz https://www.lua.org/ftp/lua-5.1.5.tar.gz && \
    tar zxf lua-5.1.5.tar.gz && \
    cd lua-5.1.5 && \
    make linux test && \
    make install && \
    cd .. && \
    rm -rf lua-5.1.5 lua-5.1.5.tar.gz

RUN apt-get -y update \
    && apt-get -y install \
        cmake \
        git \
        build-essential \
        automake \
        libsqlite3-dev \
        g++-multilib \
        gcc-multilib \
        mingw-w64 \
        libz-mingw-w64 \
        libz-mingw-w64-dev \
        libtool \
        zlib1g \
        zlib1g-dev \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get -y install \
        zlib1g:i386 \
        zlib1g-dev:i386 \
        libncurses6 \
    && apt-get -y install --install-recommends wine \
    && wget -qO- https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

COPY kcct.sh /bin/kcct
COPY kcct-spatialite-cow /root/.kcct/
RUN echo "Install KCCT - Kaffa Cross Compiler Tool" && chmod +x /bin/kcct
    
RUN echo "Copying Java Windows Includes"
COPY java-win-includes /opt/java-win-includes/
ENV JAVA_WIN_INCLUDES /opt/java-win-includes/

RUN echo "Install native dependencies" \
    && apt-get -y update \
    && apt-get -y install cmake \
    && apt-get -y install git \
    && apt-get -y install build-essential \
    && apt-get -y install automake  \
    && apt-get -y install libsqlite3-dev \
    && apt-get -y install g++-multilib \
    && apt-get -y install gcc-multilib \
    && apt-get -y install mingw-w64 \
    && apt-get -y install libz-mingw-w64 \
    && apt-get -y install libz-mingw-w64-dev \
    && apt-get -y install libtool \
    && apt-get -y install zlib1g \
    && apt-get -y install zlib1g-dev \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get -y install zlib1g:i386 \
    && apt-get -y install zlib1g-dev:i386 \
    && apt-get -y install libncurses5

RUN apt-get -y update && apt-get -y upgrade

RUN apt-get -y autoremove \
    && apt-get -y autoclean \
    && apt-get -y clean all

CMD [""]
