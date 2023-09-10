FROM gradle:7.6.1-jdk17 as Builder
WORKDIR /src
ADD . /src

RUN chmod +x gradelew
RUN chmod u+x gradlew
RUN ./gradlew build --exclude-task test


FROM eclipse-temurin:17-jdk

EXPOSE 25565
WORKDIR /opt/paper
ADD https://api.papermc.io/v2/projects/paper/versions/1.20.1/builds/169/downloads/paper-1.20.1-169.jar paper.jar
RUN echo "eula=true" > eula.txt
COPY --from=Builder /build/libs/lbwl-flash-all-*.jar plugins/flash.jar

#using optimised Garbage Collector Flags for Minecraft (https://aikar.co/2018/07/02/tuning-the-jvm-g1gc-garbage-collector-flags-for-minecraft/)
CMD java -Xms6G -Xmx6G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar paper.jar --nogui
