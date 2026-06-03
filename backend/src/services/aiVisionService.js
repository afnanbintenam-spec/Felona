const { GoogleGenerativeAI } = require('@google/generative-ai');

if (!process.env.GEMINI_API_KEY) {
  console.error('❌ GEMINI_API_KEY environment variable is required');
  process.exit(1);
}
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

class AIVisionService {
  constructor() {
    this.genAI = new GoogleGenerativeAI(GEMINI_API_KEY);
    // Vision model: responseMimeType forces clean JSON — avoids thinking
    // preamble and markdown code fences that break JSON.parse on gemini-2.5-flash
    this.model = this.genAI.getGenerativeModel({
      model: 'gemini-2.5-flash',
      generationConfig: {
        responseMimeType: 'application/json',
      },
    });
    // Chat/text model: plain text responses (JSON mime type would break conversation)
    this.textModel = this.genAI.getGenerativeModel({
      model: 'gemini-2.5-flash',
    });
  }

  /**
   * Analyze waste/recyclable item from image bytes
   * @param {Buffer} imageBuffer - Image data
   * @param {string} mimeType - e.g. 'image/jpeg'
   * @returns {Promise<Object>} Structured analysis
   */
  async analyzeWaste(imageBuffer, mimeType = 'image/jpeg') {
    const prompt = `You are a waste classification AI. Analyze the image and identify the waste or recyclable item.

Return a JSON object with these exact fields:
- item_name: specific name like "Cardboard box", "PET water bottle", "Aluminum can"
- material: primary material like "cardboard", "PET plastic", "aluminum"
- category: one of exactly: plastic, metal, paper, glass, electronics, organic, textile, mixed, unknown
- is_recyclable: one of exactly: yes, no, partially
- confidence: number 0.0–1.0 (use 0.85+ if you can clearly see the item)
- estimated_weight_kg: realistic weight as a number
- condition: one of exactly: new, like_new, good, fair, poor
- disposal_method: one sentence on how to properly dispose or recycle
- eco_tip: one short encouraging tip
- has_resale_value: true or false
- raw_description: one sentence describing what you see

Important: cardboard is category "paper". If the item is clearly visible, set confidence to 0.8 or above.`;

    try {
      const imagePart = {
        inlineData: {
          data: imageBuffer.toString('base64'),
          mimeType,
        },
      };

      const result = await this.model.generateContent([prompt, imagePart]);
      const text = result.response.text();

      // Log raw response for debugging (first 500 chars)
      console.log('🤖 Gemini raw response:', text.substring(0, 500));

      // With responseMimeType: 'application/json', the response should already
      // be clean JSON. Still attempt to extract {} in case of any wrapping.
      let parsed;
      try {
        parsed = JSON.parse(text);
      } catch (_) {
        // Fallback: strip any accidental markdown fences and find JSON object
        const cleanText = text
          .replace(/^```(?:json)?\s*/i, '')
          .replace(/\s*```\s*$/i, '')
          .trim();

        const jsonMatch = cleanText.match(/\{[\s\S]*\}/);
        if (!jsonMatch) {
          console.error('❌ No JSON found in Gemini response. Full text:', text);
          throw new Error('AI response did not contain valid JSON');
        }

        try {
          parsed = JSON.parse(jsonMatch[0]);
        } catch (parseErr) {
          console.error('❌ JSON.parse failed on:', jsonMatch[0]);
          throw new Error('Failed to parse AI JSON: ' + parseErr.message);
        }
      }

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
      const chat = this.textModel.startChat({
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
