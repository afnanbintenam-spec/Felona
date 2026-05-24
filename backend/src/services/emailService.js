const nodemailer = require('nodemailer');

// For development: use Ethereal (fake SMTP) or Gmail
// For production: use SendGrid, Mailgun, or AWS SES
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.SMTP_EMAIL || 'felona.app.otp@gmail.com',
    pass: process.env.SMTP_PASSWORD || 'your_app_password_here',
  },
});

// Fallback: If Gmail isn't configured, log OTP to console (dev mode)
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
    await transporter.sendMail({
      from: '"FeloNa" <felona.app.otp@gmail.com>',
      to: email,
      subject,
      html,
    });
    console.log(`📧 OTP sent to ${email}`);
    return true;
  } catch (error) {
    // In development, just log the OTP
    console.log(`\n📧 ═══════════════════════════════════════`);
    console.log(`   EMAIL: ${email}`);
    console.log(`   OTP: ${otp}`);
    console.log(`   PURPOSE: ${purpose}`);
    console.log(`   (Email sending failed — using console fallback)`);
    console.log(`═══════════════════════════════════════════\n`);
    return true; // Still return true so the flow continues
  }
};

module.exports = { sendOtpEmail };
