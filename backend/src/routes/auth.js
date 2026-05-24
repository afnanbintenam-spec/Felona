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
const generateToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '30d',
  });
};

// Generate 6-digit OTP
const generateOtp = () => {
  return crypto.randomInt(100000, 999999).toString();
};

// ─── REGISTER (Gmail only) ──────────────────────────────────────
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
      const firstError = errors.array()[0];
      return res.status(400).json({ error: firstError.msg || 'Validation failed' });
    }

    const { full_name, email, password, role } = req.body;

    // Check if email exists
    const existing = await User.findOne({ where: { email } });
    if (existing) {
      return res.status(409).json({ error: 'Email already registered' });
    }

    // Create user (unverified)
    const user = await User.create({ full_name, email, password, role });

    // Send verification OTP
    const otp = generateOtp();
    await Otp.create({
      email,
      code: otp,
      purpose: 'email_verification',
      expires_at: new Date(Date.now() + 5 * 60 * 1000), // 5 minutes
    });
    await sendOtpEmail(email, otp, 'email_verification');

    // Signup bonus
    await EcoActivity.create({
      user_id: user.id,
      type: 'signup_bonus',
      points: 50,
      description: 'Welcome to FeloNa! 🌱',
    });
    await user.update({ eco_points: 50 });

    const token = generateToken(user.id);

    res.status(201).json({
      user: user.toJSON(),
      token,
      message: 'Account created! Check your email for verification code.',
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ error: 'Registration failed' });
  }
});

// ─── LOGIN (Gmail only) ─────────────────────────────────────────
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

    const token = generateToken(user.id);
    res.json({ user: user.toJSON(), token });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Login failed' });
  }
});

// ─── VERIFY OTP ─────────────────────────────────────────────────
router.post('/verify-otp', [
  body('email').isEmail().normalizeEmail(),
  body('code').isLength({ min: 6, max: 6 }),
  body('purpose').isIn(['email_verification', 'password_reset']),
], async (req, res) => {
  try {
    const { email, code, purpose } = req.body;

    const otp = await Otp.findOne({
      where: { email, code, purpose, is_used: false },
      order: [['created_at', 'DESC']],
    });

    if (!otp) {
      return res.status(400).json({ error: 'Invalid OTP code' });
    }

    if (new Date() > otp.expires_at) {
      return res.status(400).json({ error: 'OTP has expired. Please request a new one.' });
    }

    // Mark as used
    await otp.update({ is_used: true });

    // If password reset, return a temporary reset token
    if (purpose === 'password_reset') {
      const resetToken = jwt.sign({ email, purpose: 'reset' }, process.env.JWT_SECRET, { expiresIn: '10m' });
      return res.json({ message: 'OTP verified', reset_token: resetToken });
    }

    res.json({ message: 'Email verified successfully! 🌱' });
  } catch (error) {
    console.error('Verify OTP error:', error);
    res.status(500).json({ error: 'Verification failed' });
  }
});

// ─── RESEND OTP ─────────────────────────────────────────────────
router.post('/resend-otp', [
  body('email').isEmail().normalizeEmail(),
  body('purpose').isIn(['email_verification', 'password_reset']),
], async (req, res) => {
  try {
    const { email, purpose } = req.body;

    const otp = generateOtp();
    await Otp.create({
      email,
      code: otp,
      purpose,
      expires_at: new Date(Date.now() + 5 * 60 * 1000),
    });
    await sendOtpEmail(email, otp, purpose);

    res.json({ message: 'OTP sent to your email' });
  } catch (error) {
    console.error('Resend OTP error:', error);
    res.status(500).json({ error: 'Failed to send OTP' });
  }
});

// ─── FORGOT PASSWORD (send OTP) ─────────────────────────────────
router.post('/forgot-password', [
  body('email').isEmail().normalizeEmail(),
], async (req, res) => {
  try {
    const { email } = req.body;

    const user = await User.findOne({ where: { email } });
    if (!user) {
      // Don't reveal if email exists
      return res.json({ message: 'If this email is registered, you will receive a reset code.' });
    }

    const otp = generateOtp();
    await Otp.create({
      email,
      code: otp,
      purpose: 'password_reset',
      expires_at: new Date(Date.now() + 5 * 60 * 1000),
    });
    await sendOtpEmail(email, otp, 'password_reset');

    res.json({ message: 'If this email is registered, you will receive a reset code.' });
  } catch (error) {
    console.error('Forgot password error:', error);
    res.status(500).json({ error: 'Failed to process request' });
  }
});

// ─── RESET PASSWORD (after OTP verified) ────────────────────────
router.post('/reset-password', [
  body('reset_token').notEmpty(),
  body('new_password').isLength({ min: 8 }),
], async (req, res) => {
  try {
    const { reset_token, new_password } = req.body;

    // Verify reset token
    const decoded = jwt.verify(reset_token, process.env.JWT_SECRET);
    if (decoded.purpose !== 'reset') {
      return res.status(400).json({ error: 'Invalid reset token' });
    }

    const user = await User.findOne({ where: { email: decoded.email } });
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    await user.update({ password: new_password });

    res.json({ message: 'Password reset successfully! You can now log in.' });
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(400).json({ error: 'Reset link expired. Please request a new one.' });
    }
    console.error('Reset password error:', error);
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
    console.error('Change password error:', error);
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
