package com.digitalforensics.service;

import com.digitalforensics.model.EvidenceFile;

import java.nio.file.attribute.BasicFileAttributes;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;

public class FileScanner {

    private final HashGenerator hashGenerator = new HashGenerator();
    private final FileTypeDetector typeDetector = new FileTypeDetector();
    private final SuspiciousIndicatorDetector indicatorDetector =
            new SuspiciousIndicatorDetector();

    public List<EvidenceFile> scan(Path root) throws Exception {

        if (root == null || !Files.exists(root)) {
            throw new IllegalArgumentException(
                    "Evidence path does not exist"
            );
        }

        List<EvidenceFile> results = new ArrayList<>();

        try (var stream = Files.walk(root)) {

            stream.filter(Files::isRegularFile)
                    .forEach(path -> {

                        try {
                            results.add(
                                    analyze(path, results.size() + 1)
                            );
                        } catch (Exception ignored) {
                            /*
                             * Individual unreadable files should not
                             * stop the complete evidence scan.
                             */
                        }

                    });
        }

        return results;
    }

    private EvidenceFile analyze(Path path, int number) throws Exception {

        EvidenceFile evidence = new EvidenceFile();

        // Basic evidence information
        evidence.setEvidenceId(
                String.format("EV-%04d", number)
        );

        evidence.setFileName(
                path.getFileName().toString()
        );

        evidence.setFilePath(
                path.toAbsolutePath().toString()
        );

        // File type
        evidence.setFileType(
                typeDetector.detect(path)
        );

        // File size
        evidence.setFileSize(
                Files.size(path)
        );

        // File timestamps
        BasicFileAttributes attributes =
                Files.readAttributes(
                        path,
                        BasicFileAttributes.class
                );

        evidence.setCreatedAt(
                toDateTime(
                        attributes.creationTime().toInstant()
                )
        );

        evidence.setModifiedAt(
                toDateTime(
                        attributes.lastModifiedTime().toInstant()
                )
        );

        evidence.setAccessedAt(
                toDateTime(
                        attributes.lastAccessTime().toInstant()
                )
        );

        // Cryptographic hashes
        evidence.setMd5(
                hashGenerator.md5(path)
        );

        evidence.setSha256(
                hashGenerator.sha256(path)
        );

        // Suspicious technical indicators
        evidence.setSuspicious(
                !indicatorDetector.detect(path).isEmpty()
        );

        return evidence;
    }

    private LocalDateTime toDateTime(Instant instant) {

        return LocalDateTime.ofInstant(
                instant,
                ZoneId.systemDefault()
        );
    }
}