FROM eclipse-temurin:21-jdk-jammy AS builder

WORKDIR /app

COPY build.gradle.kts settings.gradle.kts gradlew ./

COPY gradle gradle

RUN ./gradlew dependencies || true

COPY src src

RUN ./gradlew clean build -x test -x ktlintKotlinScriptCheck -x ktlintTestSourceSetCheck -x ktlintMainSourceSetCheck

FROM eclipse-temurin:21-jre-jammy

RUN useradd --system --create-home --uid 5050 user
WORKDIR /app

COPY --chown=user:user --from=builder /app/build/libs/*-SNAPSHOT.jar app.jar

RUN chown -R user:user /app

USER user

ENTRYPOINT ["java", "-jar", "app.jar"]
