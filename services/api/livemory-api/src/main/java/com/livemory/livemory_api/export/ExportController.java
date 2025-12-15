package com.livemory.livemory_api.export;

import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/export")
public class ExportController {

    private final BudgetExportService budgetExportService;

    public ExportController(BudgetExportService budgetExportService) {
        this.budgetExportService = budgetExportService;
    }

    @GetMapping("/budget/{eventId}")
    public ResponseEntity<byte[]> exportBudget(
            @PathVariable Long eventId,
            @RequestParam(defaultValue = "CSV") ExportFormat format) {

        byte[] data = budgetExportService.exportBudget(eventId, format);

        String filename = "budget_event_" + eventId;
        String contentType;
        String extension;

        switch (format) {
            case CSV:
                contentType = "text/csv";
                extension = ".csv";
                break;
            case EXCEL:
                contentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
                extension = ".xlsx";
                break;
            case PDF:
                contentType = "application/pdf";
                extension = ".pdf";
                break;
            default:
                throw new IllegalArgumentException("Unsupported format");
        }

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + filename + extension)
                .contentType(MediaType.parseMediaType(contentType))
                .body(data);
    }
}
