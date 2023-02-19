package com.example.demo.config;

import lombok.Cleanup;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.MutablePropertySources;
import org.springframework.core.env.PropertiesPropertySource;
import org.springframework.core.env.PropertySource;
import org.springframework.core.env.StandardEnvironment;

import javax.annotation.PostConstruct;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.*;
import java.util.Optional;
import java.util.Properties;
import java.util.stream.StreamSupport;

@Slf4j
public abstract class PropertyWatcher {

    private Path propertiesFilePath = null;
    private PropertySource<?> appConfigPropertySource = null;

    @Autowired
    protected StandardEnvironment environment;

    @PostConstruct
    private void init() {
        propertiesFilePath = locatePropertyFilePath(getPropertyFileName());
        new Thread(() -> watchPropertiesFile(propertiesFilePath)).start();
    }

    private Path locatePropertyFilePath(String filename) {
        MutablePropertySources propertySources = environment.getPropertySources();
        Optional<PropertySource<?>> appConfigPsOp =
                StreamSupport.stream(propertySources.spliterator(), false)
                        .filter(ps -> ps.getName().matches("^.*file.*"+filename+".*$"))
                        .findFirst();
        if (appConfigPsOp.isEmpty())  {
            // this will stop context initialization
            // (i.e. kill the spring boot program before it initializes)
            throw new RuntimeException("Unable to find property Source as file");
        }
        appConfigPropertySource = appConfigPsOp.get();

        String locatedFileName = appConfigPropertySource.getName();
        locatedFileName = locatedFileName
                .replace("URL [file:", "")
                .replaceAll("]$", "");
        return Paths.get(locatedFileName);
    }

    private void watchPropertiesFile(Path propertiesFilePath) {
        try (WatchService watchService = propertiesFilePath.getFileSystem().newWatchService()) {
            Path directory = propertiesFilePath.getParent();
            directory.register(watchService, StandardWatchEventKinds.ENTRY_MODIFY);
            while (!Thread.currentThread().isInterrupted()) {
                WatchKey key;
                try {
                    key = watchService.take();
                } catch (InterruptedException e) {
                    return;
                }
                for (WatchEvent<?> event : key.pollEvents()) {
                    WatchEvent.Kind<?> kind = event.kind();
                    if (kind == StandardWatchEventKinds.OVERFLOW) {
                        continue;
                    }
                    Path changedFile = (Path) event.context();
                    if (changedFile.equals(propertiesFilePath.getFileName())) {
                        log.info("Detected changes in {}", propertiesFilePath);
                        reloadProperties();
                    }
                }
                key.reset();
            }
        } catch (IOException e) {
            log.error("Error watching properties file: {}", e.getMessage(), e);
        }
    }


    private void reloadProperties() {
        try {
            Properties properties = new Properties();
            @Cleanup InputStream inputStream = Files.newInputStream(propertiesFilePath);
            properties.load(inputStream);
            environment.getPropertySources()
                    .replace(
                            appConfigPropertySource.getName(),
                            new PropertiesPropertySource(
                                    appConfigPropertySource.getName(),
                                    properties
                            )
                    );
            log.info("Reloaded property file.");
            actionsAfterReload();
        } catch (IOException ex) {
            log.error("Error reloading properties file: {}", ex.getMessage(), ex);
        }
    }

    protected abstract String getPropertyFileName();

    protected abstract void actionsAfterReload();

}

