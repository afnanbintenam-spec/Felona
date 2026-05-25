const { GoogleGenerativeAI } = require('@google/generative-ai');

const GEMINI_API_KEY = process.env.GEMINI_API_KEY || 'REDACTED_KEY';

class AIVisionService {
  constructor() {
    this.genAI = new GoogleGenerativeAI(GEMINI_API_KEY);
    this.model = this.genAI.getGenerativeModel({
      model: 'gemini-2.0-flash-lite',
    });
  }

  /**
   * Analyze waste/recyclable item from image bytes
   * @param {Buffer} imageBuffer - Image data
   * @param {string} mimeType - e.g. 'image/jpeg'
   * @returns {Promise<Object>} Structured analysis
   */
  async analyzeWaste(imageBuffer, mimeType = 'image/jpeg') {
    const prompt = `Analyze this image of a waste or recyclable item. Respond with ONLY valid JSON (no markdown, no explanation):

{
  "item_name": "specific item name (e.g. 'PET water bottle', 'cardboard box')",
  "material": "primary material (e.g. 'PET plastic', 'cardboard', 'aluminum')",
  "category": "one of: plastic, metal, paper, glass, electronics, organic, textile, mixed, unknown",
  "is_recyclable": "yes, no, or partially",
  "confidence": 0.0 to 1.0,
  "estimated_weight_kg": estimated weight in kg (e.g. 0.3),
  "condition": "one of: new, like_new, good, fair, poor",
  "disposal_method": "one sentence on how to dispose/recycle properly",
  "eco_tip": "one short encouraging tip about this item type",
  "has_resale_value": true or false,
  "raw_description": "brief description of what you see"
}

If the image does not show a waste/recyclable item, set category to "unknown", confidence to 0.0, and item_name to "Not identifiable".`;

    try {
      const imagePart = {
        inlineData: {
          data: imageBuffer.toString('base64'),
          mimeType,
        },
      };

      const result = await this.model.generateContent([prompt, imagePart]);
      const text = result.response.text();

      // Extract JSON from response (in case AI wraps it in markdown)
      const jsonMatch = text.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        throw new Error('AI response did not contain valid JSON');
      }

      const parsed = JSON.parse(jsonMatch[0]);

      // Normalize values
      return {
        item_name: parsed.item_name || 'Unknown item',
        material: parsed.material || 'Unknown',
        category: this._normalizeCategory(parsed.category),
        is_recyclable: this._normalizeRecyclable(parsed.is_recyclable),
        confidence: Math.min(Math.max(parseFloat(parsed.confidence) || 0, 0), 1),
        estimated_weight_kg: parseFloat(parsed.estimated_weight_kg) || 0.3,
        condition: parsed.condition || 'good',
        disposal_method: parsed.disposal_method || 'Follow local recycling guidelines',
        eco_tip: parsed.eco_tip || 'Every action helps the planet!',
        has_resale_value: parsed.has_resale_value === true,
        raw_description: parsed.raw_description || '',
      };
    } catch (error) {
      console.error('AI analysis error:', error.message);
      // Fallback response
      return {
        item_name: 'Could not identify',
        material: 'Unknown',
        category: 'unknown',
        is_recyclable: 'no',
        confidence: 0,
        estimated_weight_kg: 0.5,
        condition: 'good',
        disposal_method: 'Please retake the photo with better lighting',
        eco_tip: 'Try scanning a clearer image of the item',
        has_resale_value: false,
        raw_description: '',
        error: error.message,
      };
    }
  }

  /**
   * Recycling chatbot
   */
  async chat(message, history = []) {
    try {
      const chat = this.model.startChat({
        history: history.map(h => ({
          role: h.role === 'user' ? 'user' : 'model',
          parts: [{ text: h.text }],
        })),
        systemInstruction: {
          parts: [{
            text: 'You are FeloNa AI — a friendly recycling and sustainability assistant. ' +
                  'Keep responses concise (2-3 sentences). Use emojis sparingly. ' +
                  'Encourage eco-friendly actions. If asked about non-sustainability topics, ' +
                  'politely redirect.',
          }],
        },
      });

      const result = await chat.sendMessage(message);
      return result.response.text();
    } catch (error) {
      console.error('AI chat error:', error.message);
      return "Sorry, I'm having trouble right now. Please try again!";
    }
  }

  // ─── Helpers ───────────────────────────────────────────────
  _normalizeCategory(cat) {
    const valid = ['plastic', 'metal', 'paper', 'glass', 'electronics', 'organic', 'textile', 'mixed', 'unknown'];
    const lower = (cat || '').toLowerCase();
    return valid.includes(lower) ? lower : 'unknown';
  }

  _normalizeRecyclable(val) {
    const lower = (val || '').toString().toLowerCase();
    if (lower === 'yes' || lower === 'true') return 'yes';
    if (lower === 'partially' || lower === 'partial') return 'partially';
    return 'no';
  }
}

module.exports = new AIVisionService();
