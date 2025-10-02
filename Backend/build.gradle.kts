plugins {
	java
	id("org.springframework.boot") version "3.5.6"
	id("io.spring.dependency-management") version "1.1.7"
}

group = "com.sayhi"
version = "0.0.1-SNAPSHOT"
description = "Demo project for Spring Boot"

java {
	toolchain {
		languageVersion = JavaLanguageVersion.of(25)
	}
}

repositories {
	mavenCentral()
}

dependencies {
	implementation("org.springframework.boot:spring-boot-starter-web")
	testImplementation("org.springframework.boot:spring-boot-starter-test")
	testRuntimeOnly("org.junit.platform:junit-platform-launcher")
    implementation("org.springframework.boot:spring-boot-starter-web")
    // Lombok dependencies for Kotlin DSL
    annotationProcessor("org.projectlombok:lombok") 
    compileOnly("org.projectlombok:lombok") 
    testImplementation("org.springframework.boot:spring-boot-starter-test")
    // Actuator dependency for production-ready features
    implementation("org.springframework.boot:spring-boot-starter-actuator")
}

tasks.withType<Test> {
	useJUnitPlatform()
}
