package com.digitalforensics.service;

import com.digitalforensics.model.EvidenceFile;
import java.nio.file.*;
import java.nio.file.attribute.BasicFileAttributes;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;

public class FileScanner {
    private final HashGenerator hashGenerator = new HashGenerator();
    private final FileTypeDetector typeDetector = new FileTypeDetector();
    private final SuspiciousIndicatorDetector indicatorDetector = new SuspiciousIndicatorDetector();

    public List<EvidenceFile> scan(Path root) throws Exception {
        if (root == null || !Files.exists(root)) throw new IllegalArgumentException("Evidence path does not exist");
        List<EvidenceFile> results = new ArrayList<>();
        try (var stream = Files.walk(root)) {
            stream.filter(Files::isRegularFile).forEach(path -> {
                try { results.add(analyze(path, results.size() + 1)); }
                catch (Exception ignored) { /* individual unreadable files do not stop the scan */ }
            });
        }
        return results;
    }

    private EvidenceFile analyze(Path path, int number) throws Exception {
        EvidenceFile e = new EvidenceFile();
        e.setEvidenceId(String.format("EV-%04d", number));
        e.setFileName(path.getFileName().toString());
        e.setFilePath(path.toAbsolutePath().toString());
        e.setFileType(typeDetector.detect(path));
        e.setFileSize(Files.size(path));
        BasicFileAttributes attributes = Files.readAttributes(path, BasicFileAttributes.class);
        e.setCreatedAt(toDateTime(attributes.creationTime().toInstant()));
        e.setModifiedAt(toDateTime(Files.getLastModifiedTime(path).toInstant()));
        e.setAccessedAt(toDateTime(attributes.lastAccessTime().toInstant()));
        e.setMd5(hashGenerator.md5(path));
        e.setSha256(hashGenerator.sha256(path));
        e.setSuspicious(!indicatorDetector.detect(path).isEmpty());
        return e;
    }

    private LocalDateTime toDateTime(Instant instant) {
        return LocalDateTime.ofInstant(instant, ZoneId.systemDefault());
    }
}
