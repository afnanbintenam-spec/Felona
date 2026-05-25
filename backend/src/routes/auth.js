const express = require('express');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const { body, validationResult } = require('express-validator');
const { User, EcoActivity, Otp } = require('../models');
const { authenticate } = require('../middleware/auth');
const upload = require('../middleware/upload');
const { sendOtpEmail } = require('../services/emailService');

const router = express.Router();

// Generate JWT
const generateToken = (userId) =>
  jwt.sign({ userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '30d',
  });

// Generate 6-digit OTP
const generateOtp = () => crypto.randomInt(100000, 999999).toString();

// ─── REGISTER ───────────────────────────────────────────────────
// Creates unverified user + sends OTP. Returns NO token until verified.
router.post('/register', [
  body('full_name').trim().isLength({ min: 2, max: 100 }),
  body('email').isEmail().normalizeEmail().custom((value) => {
    if (!value.endsWith('@gmail.com')) {
      throw new Error('Only Gmail addresses are allowed');
    }
    return true;
  }),
  body('password').isLength({ min: 8 }),
  body('role').isIn(['normal_user', 'buyer', 'collector']),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg });
    }

    const { full_name, email, password, role } = req.body;

    // Check if email exists
    const existing = await User.findOne({ where: { email } });
    if (existing) {
      if (!existing.is_email_verified) {
        // Resend OTP for unverified user
        const otp = generateOtp();
        await Otp.create({
          email,
          code: otp,
          purpose: 'email_verification',
          expires_at: new Date(Date.now() + 5 * 60 * 1000),
        });
        await sendOtpEmail(email, otp, 'email_verification');
        return res.status(200).json({
          message: 'Account exists but not verified. New verification code sent.',
          requires_verification: true,
          email,
        });
      }
      return res.status(409).json({ error: 'Email already registered' });
    }

    // Create user (unverified, no token yet)
    const user = await User.create({
      full_name,
      email,
      password,
      role,
      is_email_verified: false,
    });

    // Send verification OTP
    const otp = generateOtp();
    await Otp.create({
      email,
      code: otp,
      purpose: 'email_verification',
      expires_at: new Date(Date.now() + 5 * 60 * 1000),
    });
    await sendOtpEmail(email, otp, 'email_verification');

    res.status(201).json({
      message: 'Account created! Check your email for the 6-digit verification code.',
      requires_verification: true,
      email: user.email,
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ error: 'Registration failed' });
  }
});

// ─── VERIFY EMAIL ───────────────────────────────────────────────
// After user enters OTP — marks email verified + returns auth token
router.post('/verify-email', [
  body('email').isEmail().normalizeEmail(),
  body('code').isLength({ min: 6, max: 6 }),
], async (req, res) => {
  try {
    const { email, code } = req.body;

    const user = await User.findOne({ where: { email } });
    if (!user) return res.status(404).json({ error: 'User not found' });

    if (user.is_email_verified) {
      return res.status(400).json({ error: 'Email already verified. Please login.' });
    }

    const otp = await Otp.findOne({
      where: { email, code, purpose: 'email_verification', is_used: false },
      order: [['created_at', 'DESC']],
    });

    if (!otp) {
      return res.status(400).json({ error: 'Invalid verification code' });
    }

    if (new Date() > otp.expires_at) {
      return res.status(400).json({ error: 'Verification code expired. Request a new one.' });
    }

    // Mark OTP used + verify user
    await otp.update({ is_used: true });
    await user.update({ is_email_verified: true });

    // Award signup bonus now that email is verified
    await EcoActivity.create({
      user_id: user.id,
      type: 'signup_bonus',
      points: 50,
      description: 'Welcome to FeloNa! 🌱',
    });
    await user.increment('eco_points', { by: 50 });
    await user.reload();

    // Issue auth token
    const token = generateToken(user.id);
    res.json({
      message: 'Email verified! Welcome to FeloNa 🌱',
      user: user.toJSON(),
      token,
    });
  } catch (error) {
    console.error('Verify email error:', error);
    res.status(500).json({ error: 'Verification failed' });
  }
});

// ─── RESEND VERIFICATION OTP ────────────────────────────────────
router.post('/resend-verification', [
  body('email').isEmail().normalizeEmail(),
], async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ where: { email } });
    if (!user) return res.status(404).json({ error: 'User not found' });
    if (user.is_email_verified) {
      return res.status(400).json({ error: 'Email already verified' });
    }

    const otp = generateOtp();
    await Otp.create({
      email,
      code: otp,
      purpose: 'email_verification',
      expires_at: new Date(Date.now() + 5 * 60 * 1000),
    });
    await sendOtpEmail(email, otp, 'email_verification');

    res.json({ message: 'Verification code sent to your email' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to resend code' });
  }
});

// ─── LOGIN ──────────────────────────────────────────────────────
// Requires verified email
router.post('/login', [
  body('email').isEmail().normalizeEmail(),
  body('password').notEmpty(),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: 'Please enter a valid email and password' });
    }

    const { email, password } = req.body;

    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // Block login if email not verified — send fresh OTP
    if (!user.is_email_verified) {
      const otp = generateOtp();
      await Otp.create({
        email,
        code: otp,
        purpose: 'email_verification',
        expires_at: new Date(Date.now() + 5 * 60 * 1000),
      });
      await sendOtpEmail(email, otp, 'email_verification');
      return res.status(403).json({
        error: 'Please verify your email first. New code sent.',
        requires_verification: true,
        email,
      });
    }

    const token = generateToken(user.id);
    res.json({ user: user.toJSON(), token });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Login failed' });
  }
});

// ─── FORGOT PASSWORD (send OTP) ─────────────────────────────────
router.post('/forgot-password', [
  body('email').isEmail().normalizeEmail(),
], async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ where: { email } });

    // Always return success message (don't leak if email exists)
    const responseMsg = 'If this email is registered, you will receive a reset code.';

    if (!user) return res.json({ message: responseMsg });

    const otp = generateOtp();
    await Otp.create({
      email,
      code: otp,
      purpose: 'password_reset',
      expires_at: new Date(Date.now() + 5 * 60 * 1000),
    });
    await sendOtpEmail(email, otp, 'password_reset');

    res.json({ message: responseMsg });
  } catch (error) {
    console.error('Forgot password error:', error);
    res.status(500).json({ error: 'Failed to process request' });
  }
});

// ─── VERIFY RESET OTP ───────────────────────────────────────────
router.post('/verify-reset-otp', [
  body('email').isEmail().normalizeEmail(),
  body('code').isLength({ min: 6, max: 6 }),
], async (req, res) => {
  try {
    const { email, code } = req.body;

    const otp = await Otp.findOne({
      where: { email, code, purpose: 'password_reset', is_used: false },
      order: [['created_at', 'DESC']],
    });

    if (!otp) return res.status(400).json({ error: 'Invalid code' });
    if (new Date() > otp.expires_at) {
      return res.status(400).json({ error: 'Code expired. Please request a new one.' });
    }

    await otp.update({ is_used: true });

    const resetToken = jwt.sign(
      { email, purpose: 'reset' },
      process.env.JWT_SECRET,
      { expiresIn: '10m' }
    );

    res.json({ message: 'Code verified', reset_token: resetToken });
  } catch (error) {
    res.status(500).json({ error: 'Verification failed' });
  }
});

// ─── RESEND RESET OTP ───────────────────────────────────────────
router.post('/resend-reset-otp', [
  body('email').isEmail().normalizeEmail(),
], async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.json({ message: 'If this email is registered, you will receive a code.' });
    }

    const otp = generateOtp();
    await Otp.create({
      email,
      code: otp,
      purpose: 'password_reset',
      expires_at: new Date(Date.now() + 5 * 60 * 1000),
    });
    await sendOtpEmail(email, otp, 'password_reset');

    res.json({ message: 'Reset code sent' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to resend code' });
  }
});

// ─── RESET PASSWORD ─────────────────────────────────────────────
router.post('/reset-password', [
  body('reset_token').notEmpty(),
  body('new_password').isLength({ min: 8 }),
], async (req, res) => {
  try {
    const { reset_token, new_password } = req.body;

    const decoded = jwt.verify(reset_token, process.env.JWT_SECRET);
    if (decoded.purpose !== 'reset') {
      return res.status(400).json({ error: 'Invalid reset token' });
    }

    const user = await User.findOne({ where: { email: decoded.email } });
    if (!user) return res.status(404).json({ error: 'User not found' });

    await user.update({ password: new_password });

    res.json({ message: 'Password reset successfully! You can now log in.' });
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(400).json({ error: 'Reset session expired. Please start over.' });
    }
    res.status(500).json({ error: 'Password reset failed' });
  }
});

// ─── CHANGE PASSWORD (authenticated) ────────────────────────────
router.post('/change-password', authenticate, [
  body('current_password').notEmpty(),
  body('new_password').isLength({ min: 8 }),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: 'New password must be at least 8 characters' });
    }

    const { current_password, new_password } = req.body;

    const isMatch = await req.user.comparePassword(current_password);
    if (!isMatch) {
      return res.status(401).json({ error: 'Current password is incorrect' });
    }

    await req.user.update({ password: new_password });
    res.json({ message: 'Password changed successfully!' });
  } catch (error) {
    res.status(500).json({ error: 'Password change failed' });
  }
});

// ─── GET CURRENT USER ───────────────────────────────────────────
router.get('/me', authenticate, async (req, res) => {
  res.json({ user: req.user.toJSON() });
});

// ─── UPDATE PROFILE ─────────────────────────────────────────────
router.put('/profile/:userId', authenticate, [
  body('full_name').optional().trim().isLength({ min: 2, max: 100 }),
  body('phone_number').optional().trim(),
], async (req, res) => {
  try {
    if (req.params.userId !== req.userId) {
      return res.status(403).json({ error: 'Cannot update another user profile' });
    }

    const updates = {};
    if (req.body.full_name) updates.full_name = req.body.full_name;
    if (req.body.phone_number !== undefined) updates.phone_number = req.body.phone_number;

    await req.user.update(updates);
    res.json({ user: req.user.toJSON() });
  } catch (error) {
    res.status(500).json({ error: 'Profile update failed' });
  }
});

// ─── UPLOAD PROFILE PICTURE ─────────────────────────────────────
router.post('/profile/:userId/picture', authenticate, upload.single('profile_picture'), async (req, res) => {
  try {
    if (req.params.userId !== req.userId) {
      return res.status(403).json({ error: 'Cannot update another user profile' });
    }
    if (!req.file) {
      return res.status(400).json({ error: 'No image file provided' });
    }

    const imageUrl = `/uploads/${req.file.filename}`;
    await req.user.update({ profile_picture_url: imageUrl });
    res.json({ profile_picture_url: imageUrl });
  } catch (error) {
    res.status(500).json({ error: 'Upload failed' });
  }
});

module.exports = router;
