package com.example.demo.config;

import com.zaxxer.hikari.HikariDataSource;
import com.zaxxer.hikari.HikariPoolMXBean;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;

@Component
@Slf4j
public class DatabaseConnectionProperties extends PropertyWatcher {

    @Value("${spring.datasource.username}")
    @Getter
    private String datasourceUsername;

    @Value("${spring.datasource.password}")
    @Getter
    private String datasourcePassword;

    private final DataSource dataSource;

    public DatabaseConnectionProperties(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @Override
    protected String getPropertyFileName() {
        return "database-configuration.properties";
    }

    @Override
    protected void actionsAfterReload() {
        updateKeys();
        refreshConnectionPool();
    }

    private void updateKeys() {
        this.datasourceUsername = environment.getProperty("spring.datasource.username");
        this.datasourcePassword = environment.getProperty("spring.datasource.password");
    }

    private void refreshConnectionPool() {
        ((HikariDataSource) dataSource).setUsername(datasourceUsername);
        ((HikariDataSource) dataSource).setPassword(datasourcePassword);
        HikariPoolMXBean hikariPoolMXBean = ((HikariDataSource) dataSource).getHikariPoolMXBean();
        hikariPoolMXBean.softEvictConnections();
        log.info("Refreshed database connection.");
    }

}
