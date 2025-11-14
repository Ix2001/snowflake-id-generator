FROM eclipse-temurin:21-jdk-jammy AS builder


WORKDIR /app

# Копирование файлов сборки Gradle
COPY build.gradle.kts settings.gradle.kts gradlew ./
COPY gradle gradle


RUN ./gradlew dependencies || true


COPY src src


RUN ./gradlew clean bootJar -x test \
    -x ktlintCheck -x ktlintFormat -x ktlintKotlinScriptCheck \
    -x ktlintMainSourceSetCheck -x ktlintTestSourceSetCheck \
    -x runKtlintCheckOverMainSourceSet -x runKtlintCheckOverTestSourceSet \
    -x detekt


RUN find build/libs -name "*.jar" -not -name "*-plain.jar" | head -1

FROM eclipse-temurin:21-jre-jammy


RUN groupadd -r appuser && \
    useradd -r -g appuser appuser


WORKDIR /app


COPY --from=builder /app/build/libs/*.jar app.jar


RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 8080

# Запуск приложения
ENTRYPOINT ["java", "-jar", "app.jar"]

