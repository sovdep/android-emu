FROM openjdk:18-jdk-slim

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /
#=============================
# Install Dependenices
#=============================
SHELL ["/bin/bash", "-c"]

RUN apt update && apt install -y curl sudo wget unzip bzip2 libdrm-dev libxkbcommon-dev libgbm-dev libasound-dev libnss3 libxcursor1 libpulse-dev libxshmfence-dev xauth xvfb x11vnc fluxbox wmctrl libdbus-glib-1-2

#==============================
# Android SDK ARGS
#==============================
ARG ARCH="x86_64"
ARG TARGET="google_apis_playstore"
ARG API_LEVEL="33"
ARG BUILD_TOOLS="34.0.0"
ARG ANDROID_ARCH=${ANDROID_ARCH_DEFAULT}
ARG ANDROID_API_LEVEL="android-${API_LEVEL}"
ARG ANDROID_APIS="${TARGET};${ARCH}"
ARG EMULATOR_PACKAGE="system-images;${ANDROID_API_LEVEL};${ANDROID_APIS}"
ARG PLATFORM_VERSION="platforms;${ANDROID_API_LEVEL}"
ARG BUILD_TOOL="build-tools;${BUILD_TOOLS}"
ARG ANDROID_CMD="commandlinetools-linux-11076708_latest.zip"
ARG ANDROID_SDK_PACKAGES="${EMULATOR_PACKAGE} ${PLATFORM_VERSION} ${BUILD_TOOL} platform-tools"

#==============================
# Set JAVA_HOME - SDK
#==============================
ENV ANDROID_HOME=/opt/android
ENV PATH "$PATH:$ANDROID_HOME/cmdline-tools/tools:$ANDROID_HOME/cmdline-tools/tools/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/${BUILD_TOOLS}"
ENV DOCKER="true"

#============================================
# Install required Android CMD-line tools
#============================================
RUN wget https://dl.google.com/android/repository/${ANDROID_CMD} -P /tmp && \
              unzip -d $ANDROID_HOME /tmp/$ANDROID_CMD && \
              mkdir -p $ANDROID_HOME/cmdline-tools/tools && cd $ANDROID_HOME/cmdline-tools &&  mv NOTICE.txt source.properties bin lib tools/  && \
              cd $ANDROID_HOME/cmdline-tools/tools && ls

#============================================
# Install required package using SDK manager
#============================================
RUN yes Y | sdkmanager --licenses
RUN yes Y | sdkmanager --verbose --no_https ${ANDROID_SDK_PACKAGES}

#============================================
# Create required emulator
#============================================
ARG EMULATOR_NAME="nexus"
ARG EMULATOR_DEVICE="Nexus 6"
ENV EMULATOR_NAME=$EMULATOR_NAME
ENV DEVICE_NAME=$EMULATOR_DEVICE
RUN echo "no" | avdmanager --verbose create avd --force --name "${EMULATOR_NAME}" --device "${EMULATOR_DEVICE}" --package "${EMULATOR_PACKAGE}"

#====================================
# Install latest nodejs, npm & appium
#====================================
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash && \
    apt-get -qqy install nodejs && \
    npm install -g npm && \
    npm i -g appium --unsafe-perm=true --allow-root && \
    npm i -g appium-doctor && \
    appium driver install uiautomator2 && \
    appium plugin install --source=npm appium-device-farm && \
    appium plugin install --source=npm appium-dashboard && \
    exit 0 && \
    npm cache clean && \
    apt-get remove --purge -y npm && \
    apt-get autoremove --purge -y && \
    apt-get clean && \
    rm -Rf /tmp/* && rm -Rf /var/lib/apt/lists/*


#===================
# Alias
#===================
ENV EMU=./start_emu.sh
ENV EMU_HEADLESS=./start_emu_headless.sh
ENV APPIUM=./start_appium.sh


#===================
# Ports
#===================
ENV APPIUM_PORT=4723

#=========================
# Copying Scripts to root
#=========================
COPY . /

#=========================
# Copying configs to root
#=========================
COPY ./configs/* /

RUN chmod a+x start_emu.sh && \
    chmod a+x start_appium.sh && \
    chmod a+x start_emu_headless.sh

EXPOSE 4723
#=======================
# framework entry point
#=======================
CMD [ "/bin/bash" ]
