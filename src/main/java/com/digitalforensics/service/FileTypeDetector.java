package com.digitalforensics.service;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Locale;

public class FileTypeDetector {
    public String detect(Path file) {
        try {
            String detected = Files.probeContentType(file);
            if (detected != null) return detected;
        } catch (Exception ignored) {}
        String name = file.getFileName().toString().toLowerCase(Locale.ROOT);
        int dot = name.lastIndexOf('.');
        if (dot < 0) return "unknown";
        return switch (name.substring(dot + 1)) {
            case "jpg", "jpeg", "png", "gif" -> "image";
            case "pdf", "doc", "docx", "txt" -> "document";
            case "mp4", "avi", "mkv" -> "video";
            case "mp3", "wav" -> "audio";
            case "zip", "rar", "7z" -> "archive";
            case "exe", "msi", "bat", "cmd" -> "executable";
            default -> "unknown";
        };
    }
}
