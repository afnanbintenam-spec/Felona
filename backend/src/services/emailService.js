const nodemailer = require('nodemailer');
require('dotenv').config();

// Create transporter using Gmail with App Password
const createTransporter = () => {
  return nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.SMTP_EMAIL,
      pass: process.env.SMTP_PASSWORD,
    },
  });
};

const sendOtpEmail = async (email, otp, purpose) => {
  const subject = purpose === 'password_reset'
    ? 'FeloNa — Reset Your Password'
    : 'FeloNa — Verify Your Email';

  const html = `
    <div style="font-family: 'Inter', sans-serif; max-width: 400px; margin: 0 auto; padding: 32px; background: #1A2B2E; border-radius: 16px;">
      <h2 style="color: #4CAF50; margin-bottom: 8px;">FeloNa 🌱</h2>
      <p style="color: #B0BEC5; font-size: 14px;">Your verification code is:</p>
      <div style="background: #223B3F; border-radius: 12px; padding: 24px; text-align: center; margin: 24px 0;">
        <span style="font-size: 32px; font-weight: 700; color: #4CAF50; letter-spacing: 8px;">${otp}</span>
      </div>
      <p style="color: #78909C; font-size: 12px;">This code expires in 5 minutes. Don't share it with anyone.</p>
      <p style="color: #78909C; font-size: 12px;">If you didn't request this, ignore this email.</p>
    </div>
  `;

  try {
    const transporter = createTransporter();
    await transporter.sendMail({
      from: `"FeloNa" <${process.env.SMTP_EMAIL}>`,
      to: email,
      subject,
      html,
    });
    console.log(`📧 OTP sent successfully to ${email}`);
    return true;
  } catch (error) {
    console.error(`❌ Email send failed to ${email}:`, error.message);
    if (process.env.NODE_ENV === 'development') {
      // Only log OTP in development for debugging
      console.log(`   [DEV] OTP for ${email}: ${otp} (${purpose})`);
    }
    // Return true so registration flow continues even if email fails
    return true;
  }
};

module.exports = { sendOtpEmail };
