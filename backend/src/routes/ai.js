const express = require('express');
const fs = require('fs');
const path = require('path');
const { body, validationResult } = require('express-validator');
const { WasteScan, EcoActivity, User } = require('../models');
const { authenticate } = require('../middleware/auth');
const upload = require('../middleware/upload');
const aiVision = require('../services/aiVisionService');
const EcoImpactEngine = require('../services/ecoImpactEngine');

const router = express.Router();

// ─── POST /ai/scan ─────────────────────────────────────────────
// Upload an image, AI analyzes it, eco impact calculated, points awarded
router.post('/scan', authenticate, upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No image file provided' });
    }

    // Read image bytes
    const imageBuffer = fs.readFileSync(req.file.path);
    const mimeType = req.file.mimetype || 'image/jpeg';

    // Analyze with Gemini Vision
    const aiResult = await aiVision.analyzeWaste(imageBuffer, mimeType);

    // Calculate eco impact
    const isRecyclable = aiResult.is_recyclable === 'yes' || aiResult.is_recyclable === 'partially';
    const impact = EcoImpactEngine.calculate({
      category: aiResult.category,
      isRecyclable,
      weightKg: aiResult.estimated_weight_kg,
    });

    // Get recommended action
    const recommendation = EcoImpactEngine.recommendAction({
      category: aiResult.category,
      isRecyclable,
      condition: aiResult.condition,
    });

    // Estimate resale value
    const resaleValue = aiResult.has_resale_value
      ? EcoImpactEngine.estimateValue({
          category: aiResult.category,
          condition: aiResult.condition,
        })
      : { min: 0, max: 0 };

    // Save scan to DB
    const imageUrl = `/uploads/${req.file.filename}`;
    const scan = await WasteScan.create({
      user_id: req.userId,
      image_url: imageUrl,
      item_name: aiResult.item_name,
      material: aiResult.material,
      category: aiResult.category,
      is_recyclable: aiResult.is_recyclable,
      confidence: aiResult.confidence,
      estimated_weight_kg: impact.estimated_weight_kg,
      co2_saved_kg: impact.co2_saved_kg,
      landfill_saved_kg: impact.landfill_saved_kg,
      recommended_action: recommendation.action,
      disposal_method: aiResult.disposal_method,
      estimated_value_min: resaleValue.min,
      estimated_value_max: resaleValue.max,
      danger_level: impact.danger_level,
      eco_tip: aiResult.eco_tip,
      points_earned: impact.points_earned,
      raw_response: aiResult,
    });

    // Award eco points
    if (impact.points_earned > 0 && aiResult.confidence > 0.3) {
      await req.user.increment('eco_points', { by: impact.points_earned });
      await EcoActivity.create({
        user_id: req.userId,
        type: 'scan_completed',
        points: impact.points_earned,
        description: `📸 Scanned ${aiResult.item_name} — ${impact.co2_saved_kg}kg CO₂ saved!`,
        metadata: { scan_id: scan.id, category: aiResult.category },
      });
    }

    // Build response
    res.json({
      scan: {
        id: scan.id,
        image_url: imageUrl,
        // Identification
        item_name: aiResult.item_name,
        material: aiResult.material,
        category: aiResult.category,
        is_recyclable: aiResult.is_recyclable,
        confidence: aiResult.confidence,
        condition: aiResult.condition,
        // Impact
        estimated_weight_kg: impact.estimated_weight_kg,
        co2_saved_kg: impact.co2_saved_kg,
        landfill_saved_kg: impact.landfill_saved_kg,
        danger_level: impact.danger_level,
        // Recommendations
        recommended_action: recommendation.action,
        recommendation_reason: recommendation.reason,
        disposal_method: aiResult.disposal_method,
        estimated_value: resaleValue,
        eco_tip: aiResult.eco_tip,
        // Reward
        points_earned: impact.points_earned,
        new_total_points: req.user.eco_points + impact.points_earned,
      },
    });
  } catch (error) {
    console.error('Scan error:', error);
    res.status(500).json({ error: 'Scan failed: ' + error.message });
  }
});

// ─── GET /ai/scan/history ──────────────────────────────────────
router.get('/scan/history', authenticate, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const offset = (page - 1) * limit;

    const { count, rows } = await WasteScan.findAndCountAll({
      where: { user_id: req.userId },
      order: [['created_at', 'DESC']],
      limit,
      offset,
    });

    res.json({
      scans: rows,
      pagination: { total: count, page, pages: Math.ceil(count / limit) },
    });
  } catch (error) {
    console.error('Scan history error:', error);
    res.status(500).json({ error: 'Failed to fetch scan history' });
  }
});

// ─── GET /ai/scan/:id ──────────────────────────────────────────
router.get('/scan/:id', authenticate, async (req, res) => {
  try {
    const scan = await WasteScan.findOne({
      where: { id: req.params.id, user_id: req.userId },
    });
    if (!scan) return res.status(404).json({ error: 'Scan not found' });
    res.json({ scan });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch scan' });
  }
});

// ─── POST /ai/chat ─────────────────────────────────────────────
router.post('/chat', authenticate, [
  body('message').notEmpty().isLength({ max: 500 }),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: 'Message is required (max 500 chars)' });
    }

    const { message, history = [] } = req.body;
    const reply = await aiVision.chat(message, history);

    res.json({ reply });
  } catch (error) {
    console.error('Chat error:', error);
    res.status(500).json({ error: 'Chat failed' });
  }
});

// ─── POST /ai/suggest-price ────────────────────────────────────
// AI suggests resale price based on item name + condition + category
router.post('/suggest-price', authenticate, [
  body('item_name').notEmpty(),
  body('category').isIn(['plastic', 'metal', 'paper', 'glass', 'electronics', 'textile', 'furniture', 'other']),
  body('condition').isIn(['new', 'like_new', 'good', 'fair', 'poor']),
], async (req, res) => {
  try {
    const { item_name, category, condition } = req.body;

    // Use eco engine for base estimate
    const baseEstimate = EcoImpactEngine.estimateValue({ category, condition });

    // Optionally, ask AI to refine the estimate
    const prompt = `Suggest a realistic resale price range (USD) for this second-hand item:
- Item: ${item_name}
- Category: ${category}
- Condition: ${condition}

Respond with ONLY valid JSON: {"min": <number>, "max": <number>, "tip": "<one sentence pricing advice>"}`;

    let aiEstimate = baseEstimate;
    let tip = `Based on category and condition, this is a fair price range.`;

    try {
      const result = await aiVision.model.generateContent(prompt);
      const text = result.response.text();
      const jsonMatch = text.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        const parsed = JSON.parse(jsonMatch[0]);
        if (parsed.min && parsed.max) {
          aiEstimate = { min: parsed.min, max: parsed.max };
          tip = parsed.tip || tip;
        }
      }
    } catch (_) {
      // Fallback to base estimate
    }

    res.json({
      suggestion: {
        min: aiEstimate.min,
        max: aiEstimate.max,
        suggested: ((aiEstimate.min + aiEstimate.max) / 2).toFixed(2),
        tip,
      },
    });
  } catch (error) {
    console.error('Price suggestion error:', error);
    res.status(500).json({ error: 'Price suggestion failed' });
  }
});

module.exports = router;
