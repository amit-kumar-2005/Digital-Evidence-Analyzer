package com.digitalforensics.service;

import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class SuspiciousIndicatorDetector {
    public List<String> detect(Path file) {
        List<String> indicators = new ArrayList<>();
        String name = file.getFileName().toString().toLowerCase(Locale.ROOT);
        if (name.matches(".*\\.[a-z0-9]{2,5}\\.(exe|scr|bat|cmd|msi)$")) indicators.add("Double extension");
        if (name.endsWith(".exe") || name.endsWith(".scr") || name.endsWith(".bat") || name.endsWith(".cmd")) indicators.add("Executable file");
        if (name.contains("hidden") || name.contains("suspicious") || name.contains("unknown")) indicators.add("Unusual file name");
        return indicators;
    }
}
