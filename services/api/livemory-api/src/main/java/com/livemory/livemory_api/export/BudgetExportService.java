package com.livemory.livemory_api.export;

import com.livemory.livemory_api.budget.Budget;
import com.livemory.livemory_api.budget.BudgetRepository;
import com.livemory.livemory_api.event.Event;
import com.livemory.livemory_api.event.EventRepository;
import com.livemory.livemory_api.payment.Payment;
import com.livemory.livemory_api.payment.PaymentRepository;
import com.opencsv.CSVWriter;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.math.BigDecimal;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
@Transactional(readOnly = true)
public class BudgetExportService {

    private final EventRepository eventRepository;
    private final BudgetRepository budgetRepository;
    private final PaymentRepository paymentRepository;

    public BudgetExportService(EventRepository eventRepository,
            BudgetRepository budgetRepository,
            PaymentRepository paymentRepository) {
        this.eventRepository = eventRepository;
        this.budgetRepository = budgetRepository;
        this.paymentRepository = paymentRepository;
    }

    public byte[] exportBudget(Long eventId, ExportFormat format) {
        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new IllegalArgumentException("Event not found"));

        Budget budget = budgetRepository.findByEventId(eventId)
                .orElseThrow(() -> new IllegalArgumentException("Budget not found for this event"));

        List<Payment> payments = paymentRepository.findByEventId(eventId);

        return switch (format) {
            case CSV -> exportToCSV(event, budget, payments);
            case EXCEL -> exportToExcel(event, budget, payments);
            case PDF -> throw new UnsupportedOperationException("PDF export not yet implemented");
        };
    }

    private byte[] exportToCSV(Event event, Budget budget, List<Payment> payments) {
        try (ByteArrayOutputStream baos = new ByteArrayOutputStream();
                OutputStreamWriter osw = new OutputStreamWriter(baos);
                CSVWriter writer = new CSVWriter(osw)) {

            // Header
            writer.writeNext(new String[] { "Budget Export - " + event.getTitle() });
            writer.writeNext(new String[] {});

            // Budget summary
            writer.writeNext(new String[] { "Budget Total", budget.getTotalAmount().toString() });
            writer.writeNext(new String[] { "Total Dépensé", budget.getSpentAmount().toString() });
            writer.writeNext(
                    new String[] { "Reste", budget.getTotalAmount().subtract(budget.getSpentAmount()).toString() });
            writer.writeNext(new String[] {});

            // Payments header
            writer.writeNext(new String[] { "Date", "Payeur", "Montant", "Catégorie", "Description" });

            // Payments data
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
            for (Payment payment : payments) {
                String paidByName = payment.getPaidBy().getFirstName() + " " + payment.getPaidBy().getLastName();
                writer.writeNext(new String[] {
                        payment.getPaymentDate().format(formatter),
                        paidByName,
                        payment.getAmount().toString(),
                        payment.getCategory() != null ? payment.getCategory().name() : "",
                        payment.getDescription() != null ? payment.getDescription() : ""
                });
            }

            writer.flush();
            return baos.toByteArray();
        } catch (IOException e) {
            throw new RuntimeException("Failed to export to CSV", e);
        }
    }

    private byte[] exportToExcel(Event event, Budget budget, List<Payment> payments) {
        try (Workbook workbook = new XSSFWorkbook();
                ByteArrayOutputStream baos = new ByteArrayOutputStream()) {

            Sheet sheet = workbook.createSheet("Budget " + event.getTitle());

            // Styles
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            CellStyle currencyStyle = workbook.createCellStyle();
            currencyStyle.setDataFormat(workbook.createDataFormat().getFormat("#,##0.00 €"));

            int rowNum = 0;

            // Title
            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("Budget Export - " + event.getTitle());
            titleCell.setCellStyle(headerStyle);

            rowNum++; // Empty row

            // Budget summary
            createRow(sheet, rowNum++, "Budget Total:", budget.getTotalBudget(), currencyStyle);
            createRow(sheet, rowNum++, "Total Dépensé:", budget.getTotalSpent(), currencyStyle);
            createRow(sheet, rowNum++, "Reste:", budget.getTotalBudget().subtract(budget.getTotalSpent()), currencyStyle);
                    currencyStyle);

            rowNum++; // Empty row

            // Payments header
            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = { "Date", "Payeur", "Montant", "Catégorie", "Description" };
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            // Payments data
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
            for (Payment payment : payments) {
                Row row = sheet.createRow(rowNum++);
                String paidByName = payment.getPaidBy().getFirstName() + " " + payment.getPaidBy().getLastName();
                row.createCell(0).setCellValue(payment.getPaymentDate().format(formatter));
                row.createCell(1).setCellValue(paidByName);
                Cell amountCell = row.createCell(2);
                amountCell.setCellValue(payment.getAmount().doubleValue());
                amountCell.setCellStyle(currencyStyle);
                row.createCell(3).setCellValue(payment.getCategory() != null ? payment.getCategory().name() : "");
                row.createCell(4).setCellValue(payment.getDescription() != null ? payment.getDescription() : "");
            }

            // Auto-size columns
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
            }

            workbook.write(baos);
            return baos.toByteArray();
        } catch (IOException e) {
            throw new RuntimeException("Failed to export to Excel", e);
        }
    }

    private void createRow(Sheet sheet, int rowNum, String label, BigDecimal value, CellStyle style) {
        Row row = sheet.createRow(rowNum);
        row.createCell(0).setCellValue(label);
        Cell valueCell = row.createCell(1);
        valueCell.setCellValue(value.doubleValue());
        valueCell.setCellStyle(style);
    }
}
