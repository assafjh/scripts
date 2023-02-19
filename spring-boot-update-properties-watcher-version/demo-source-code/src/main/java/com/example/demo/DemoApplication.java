package com.example.demo;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.PropertySource;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
@Slf4j
@PropertySource(value = "file:${user.dir}/config.properties", ignoreResourceNotFound = true)
@PropertySource(value = "file:${user.dir}/database-configuration.properties", ignoreResourceNotFound = true)
@PropertySource(value = "file:/conjur/secrets/database-configuration.properties", ignoreResourceNotFound = true)
public class DemoApplication {

	public static void main(String[] args) {
		Thread.setDefaultUncaughtExceptionHandler((thread, throwable) -> {
			log.error("Unhandled exception in thread " + thread.getName() + ": " + throwable);
			System.exit(1);
		});

		SpringApplication.run(DemoApplication.class, args);
	}

}