package com.shopsphere.service;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.logging.Level;
import java.util.logging.Logger;

public class EmailService {
    private static final Logger LOGGER = Logger.getLogger(EmailService.class.getName());
    private static final ExecutorService ASYNC_EXECUTOR = Executors.newFixedThreadPool(3);

    private static final String SMTP_HOST = System.getenv().getOrDefault("SMTP_HOST", "smtp.gmail.com");
    private static final String SMTP_PORT = System.getenv().getOrDefault("SMTP_PORT", "587");
    private static final String SMTP_USER = System.getenv().getOrDefault("SMTP_USER", "");
    private static final String SMTP_PASS = System.getenv().getOrDefault("SMTP_PASS", "");
    private static final String FROM_EMAIL = System.getenv().getOrDefault("FROM_EMAIL", "noreply@trendify.com");

    public static void sendOrderReceiptAsync(String recipientEmail, String userName, int orderId, double totalAmount) {
        sendOrderReceiptAsync(recipientEmail, userName, orderId, totalAmount, "COD", "Saved Address", null);
    }

    public static void sendOrderReceiptAsync(String recipientEmail, String userName, int orderId, double totalAmount, String paymentMethod, String shippingAddress, List<Map<String, Object>> items) {
        ASYNC_EXECUTOR.submit(() -> {
            try {
                String subject = "Order Invoice #" + orderId + " — Trendify";
                String htmlContent = buildOrderInvoiceHtml(userName, orderId, totalAmount, paymentMethod, shippingAddress, items);
                sendEmail(recipientEmail, subject, htmlContent);
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Failed to dispatch order receipt to " + recipientEmail, e);
            }
        });
    }

    public static void sendOrderStatusUpdateAsync(String recipientEmail, String userName, int orderId, String status, double totalAmount) {
        ASYNC_EXECUTOR.submit(() -> {
            try {
                String subject = "Order #" + orderId + " Status Update: " + status + " — Trendify";
                String htmlContent = buildOrderStatusUpdateHtml(userName, orderId, status, totalAmount);
                sendEmail(recipientEmail, subject, htmlContent);
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Failed to dispatch order status update to " + recipientEmail, e);
            }
        });
    }

    public static void sendWelcomeEmailAsync(String recipientEmail, String userName) {
        ASYNC_EXECUTOR.submit(() -> {
            try {
                String subject = "Welcome to Trendify — Curated Lifestyle Boutique";
                String htmlContent = buildWelcomeHtml(userName);
                sendEmail(recipientEmail, subject, htmlContent);
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Failed to dispatch welcome email to " + recipientEmail, e);
            }
        });
    }

    public static void sendPasswordResetOtpAsync(String recipientEmail, String otp) {
        ASYNC_EXECUTOR.submit(() -> {
            try {
                String subject = "Password Reset Security Code — Trendify";
                String htmlContent = buildOtpHtml(recipientEmail, otp);
                sendEmail(recipientEmail, subject, htmlContent);
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Failed to dispatch OTP email to " + recipientEmail, e);
            }
        });
    }

    private static void sendEmail(String recipientEmail, String subject, String htmlContent) throws Exception {
        if (recipientEmail == null || recipientEmail.isBlank()) {
            return;
        }

        if (SMTP_USER.isBlank() || SMTP_PASS.isBlank()) {
            LOGGER.info(String.format(
                "[SMTP SIMULATED EMAIL] To: %s | Subject: %s | App: Trendify Boutique",
                recipientEmail, subject
            ));
            return;
        }

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_USER, SMTP_PASS);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(FROM_EMAIL, "Trendify Boutique"));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
        message.setSubject(subject);
        message.setContent(htmlContent, "text/html; charset=utf-8");

        Transport.send(message);
        LOGGER.info("[LIVE EMAIL SENT] To: " + recipientEmail + " | Subject: " + subject);
    }

    private static String buildOrderInvoiceHtml(String userName, int orderId, double totalAmount, String paymentMethod, String shippingAddress, List<Map<String, Object>> items) {
        StringBuilder itemsTable = new StringBuilder();
        if (items != null && !items.isEmpty()) {
            for (Map<String, Object> item : items) {
                String pName = String.valueOf(item.get("name"));
                int qty = Integer.parseInt(String.valueOf(item.get("quantity")));
                double price = Double.parseDouble(String.valueOf(item.get("price")));
                double sub = price * qty;
                itemsTable.append("<tr style='border-bottom: 1px solid #ECE3D7;'>")
                          .append("<td style='padding: 12px 0; color: #1E1A17; font-weight: 500;'>").append(pName).append("</td>")
                          .append("<td style='padding: 12px 0; color: #7D756C; text-align: center;'>").append(qty).append("</td>")
                          .append("<td style='padding: 12px 0; color: #7D756C; text-align: right;'>₹").append(String.format("%.2f", price)).append("</td>")
                          .append("<td style='padding: 12px 0; color: #9E7D52; text-align: right; font-weight: 600;'>₹").append(String.format("%.2f", sub)).append("</td>")
                          .append("</tr>");
            }
        }

        return "<html><body style='font-family: Arial, sans-serif; background: #FAF7F2; color: #1E1A17; padding: 24px; margin: 0;'>"
             + "<div style='max-width: 600px; margin: 0 auto; background: #FFFFFF; border: 1px solid #E8E0D5; border-radius: 14px; padding: 34px; box-shadow: 0 8px 30px rgba(30,26,23,0.06);'>"
             
             // Header Branding
             + "<div style='border-bottom: 1px solid #E8E0D5; padding-bottom: 20px; margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center;'>"
             + "  <div>"
             + "    <h1 style='font-family: Georgia, serif; letter-spacing: 4px; font-size: 26px; color: #1E1A17; margin: 0; text-transform: uppercase;'>TRENDIFY</h1>"
             + "    <span style='font-size: 11px; color: #9E7D52; text-transform: uppercase; letter-spacing: 2px; font-weight: 600;'>Curated Lifestyle Boutique • Official Tax Invoice</span>"
             + "  </div>"
             + "</div>"

             // Greeting & Status
             + "<p style='font-size: 15px; color: #1E1A17; margin-bottom: 8px;'>Hello <strong>" + (userName != null ? userName : "Valued Member") + "</strong>,</p>"
             + "<p style='color: #7D756C; font-size: 13px; line-height: 1.6; margin-top: 0;'>Thank you for your order with Trendify. Your order <strong>#" + orderId + "</strong> has been confirmed and is being hand-packed for dispatch.</p>"

             // Order Meta Card
             + "<div style='background: #FAF7F2; border: 1px solid #E8E0D5; border-radius: 10px; padding: 18px; margin: 20px 0; font-size: 13px;'>"
             + "  <div style='margin-bottom: 8px; color: #7D756C;'><strong style='color: #1E1A17;'>Order Reference:</strong> #" + orderId + "</div>"
             + "  <div style='margin-bottom: 8px; color: #7D756C;'><strong style='color: #1E1A17;'>Payment Method:</strong> " + (paymentMethod != null ? paymentMethod : "COD") + "</div>"
             + "  <div style='color: #7D756C;'><strong style='color: #1E1A17;'>Shipping Address:</strong> " + (shippingAddress != null ? shippingAddress : "Saved Address") + "</div>"
             + "</div>"

             // Items Breakdown Table
             + (itemsTable.length() > 0 ?
                "<table style='width: 100%; border-collapse: collapse; margin: 20px 0; font-size: 13px;'>"
              + "<thead style='border-bottom: 1px solid #D6CBC0; color: #9E7D52; text-transform: uppercase; font-size: 11px; letter-spacing: 1px;'>"
              + "<tr><th style='text-align: left; padding-bottom: 8px;'>Curated Item</th><th style='text-align: center; padding-bottom: 8px;'>Qty</th><th style='text-align: right; padding-bottom: 8px;'>Unit Price</th><th style='text-align: right; padding-bottom: 8px;'>Subtotal</th></tr>"
              + "</thead>"
              + "<tbody>" + itemsTable.toString() + "</tbody>"
              + "</table>" : "")

             // Total Summary Box
             + "<div style='background: #FAF7F2; border: 1px solid #C5A880; border-radius: 10px; padding: 18px; margin: 20px 0; text-align: right;'>"
             + "  <span style='font-size: 12px; color: #7D756C; text-transform: uppercase; letter-spacing: 1.5px;'>Total Billed Amount:</span>"
             + "  <div style='font-size: 26px; font-weight: bold; color: #9E7D52; margin-top: 4px;'>₹" + String.format("%.2f", totalAmount) + "</div>"
             + "</div>"

             // Footer
             + "<div style='border-top: 1px solid #E8E0D5; margin-top: 30px; padding-top: 18px; text-align: center; font-size: 11px; color: #857B72;'>"
             + "  <p style='margin: 0;'>© 2026 Trendify Boutique Ltd. All rights reserved.</p>"
             + "  <p style='margin: 4px 0 0;'>Bespoke Lifestyle & Effortless Fashion</p>"
             + "</div>"

             + "</div></body></html>";
    }

    private static String buildOrderStatusUpdateHtml(String userName, int orderId, String status, double totalAmount) {
        String badgeColor = "#9E7D52";
        String statusIcon = "📦";
        String statusDesc = "Your order status has been updated.";

        if ("SHIPPED".equalsIgnoreCase(status)) {
            badgeColor = "#3B82F6";
            statusIcon = "🚚";
            statusDesc = "Good news! Your curated order has been shipped and is on its way to your address.";
        } else if ("DELIVERED".equalsIgnoreCase(status)) {
            badgeColor = "#4A7A59";
            statusIcon = "🎉";
            statusDesc = "Your package has been successfully delivered! Thank you for choosing Trendify.";
        } else if ("PROCESSING".equalsIgnoreCase(status)) {
            badgeColor = "#C5A880";
            statusIcon = "⚙️";
            statusDesc = "Our boutique team is preparing your items with bespoke care.";
        } else if ("CANCELLED".equalsIgnoreCase(status)) {
            badgeColor = "#C04E44";
            statusIcon = "❌";
            statusDesc = "Your order status has been updated to CANCELLED. Please contact our concierge for assistance.";
        }

        return "<html><body style='font-family: Arial, sans-serif; background: #FAF7F2; color: #1E1A17; padding: 24px; margin: 0;'>"
             + "<div style='max-width: 550px; margin: 0 auto; background: #FFFFFF; border: 1px solid #E8E0D5; border-radius: 14px; padding: 34px; box-shadow: 0 8px 30px rgba(30,26,23,0.06);'>"
             + "<h1 style='font-family: Georgia, serif; letter-spacing: 4px; font-size: 24px; color: #1E1A17; margin: 0 0 15px; text-transform: uppercase;'>TRENDIFY</h1>"
             + "<div style='background: #FAF7F2; border: 1px solid " + badgeColor + "; border-radius: 10px; padding: 18px; margin-bottom: 20px; text-align: center;'>"
             + "  <div style='font-size: 36px; margin-bottom: 6px;'>" + statusIcon + "</div>"
             + "  <span style='font-size: 11px; text-transform: uppercase; letter-spacing: 2px; color: #7D756C;'>Delivery Status Update</span>"
             + "  <h2 style='color: " + badgeColor + "; margin: 6px 0 0; text-transform: uppercase; font-size: 20px;'>ORDER #" + orderId + " IS " + status + "</h2>"
             + "</div>"
             + "<p style='font-size: 14px; color: #1E1A17;'>Hi <strong>" + (userName != null ? userName : "Valued Member") + "</strong>,</p>"
             + "<p style='color: #7D756C; font-size: 13px; line-height: 1.6;'>" + statusDesc + "</p>"
             + "<div style='background: #FAF7F2; border: 1px solid #E8E0D5; padding: 14px; border-radius: 8px; margin: 20px 0; font-size: 13px; color: #7D756C; display: flex; justify-content: space-between;'>"
             + "  <span>Total Order Amount:</span>"
             + "  <strong style='color: #9E7D52;'>₹" + String.format("%.2f", totalAmount) + "</strong>"
             + "</div>"
             + "<p style='color: #857B72; font-size: 11px; text-align: center; margin-top: 30px;'>© 2026 Trendify Boutique. All rights reserved.</p>"
             + "</div></body></html>";
    }

    private static String buildOtpHtml(String recipientEmail, String otp) {
        return "<html><body style='font-family: Arial, sans-serif; background: #FAF7F2; color: #1E1A17; padding: 30px; margin: 0;'>"
             + "<div style='max-width: 500px; margin: 0 auto; background: #FFFFFF; border: 1px solid #E8E0D5; padding: 34px; border-radius: 14px; text-align: center; box-shadow: 0 8px 30px rgba(30,26,23,0.06);'>"
             + "<h2 style='font-family: Georgia, serif; letter-spacing: 3px; text-transform: uppercase; color: #1E1A17; margin-top: 0;'>TRENDIFY</h2>"
             + "<h3 style='color: #9E7D52; font-weight: 500;'>Password Reset Security Code</h3>"
             + "<p style='color: #7D756C;'>Use the verification code below to reset your Trendify account password:</p>"
             + "<div style='font-size: 32px; font-weight: bold; letter-spacing: 6px; color: #9E7D52; background: #FAF7F2; padding: 16px; margin: 20px 0; border: 1px dashed #C5A880; border-radius: 8px;'>" + otp + "</div>"
             + "<p style='color: #857B72; font-size: 11px;'>If you did not request a password reset, please ignore this security email.</p>"
             + "</div></body></html>";
    }

    private static String buildWelcomeHtml(String userName) {
        return "<html><body style='font-family: Arial, sans-serif; background: #FAF7F2; color: #1E1A17; padding: 30px; margin: 0;'>"
             + "<div style='max-width: 550px; margin: 0 auto; background: #FFFFFF; border: 1px solid #E8E0D5; border-radius: 14px; padding: 34px; box-shadow: 0 8px 30px rgba(30,26,23,0.06); text-align: center;'>"
             + "<h1 style='font-family: Georgia, serif; letter-spacing: 4px; font-size: 26px; color: #1E1A17; margin: 0 0 15px; text-transform: uppercase;'>TRENDIFY</h1>"
             + "<div style='font-size: 40px; margin: 15px 0;'>✨</div>"
             + "<h2 style='color: #1E1A17; margin: 0 0 10px; font-family: Georgia, serif;'>Welcome to Trendify Boutique</h2>"
             + "<p style='font-size: 14px; color: #7D756C; line-height: 1.6; margin-bottom: 25px;'>Hello <strong>" + (userName != null && !userName.isBlank() ? userName : "Valued Member") + "</strong>, thank you for joining Trendify. Explore our curated collections of modern lifestyle, curated fashion, and thoughtful essentials.</p>"
             + "<p style='color: #857B72; font-size: 11px; text-align: center; margin-top: 30px;'>© 2026 Trendify Boutique. All rights reserved.</p>"
             + "</div></body></html>";
    }
}
