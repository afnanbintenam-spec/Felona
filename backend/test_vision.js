/**
 * Quick test for aiVisionService.
 * Usage: node test_vision.js <path-to-image>
 * Example: node test_vision.js test_cardboard.jpg
 *
 * Run from the backend directory with your .env loaded.
 */
require('dotenv').config();
const fs = require('fs');
const path = require('path');
const aiVision = require('./src/services/aiVisionService');

const imagePath = process.argv[2];

if (!imagePath) {
  console.error('Usage: node test_vision.js <path-to-image>');
  process.exit(1);
}

const absPath = path.resolve(imagePath);
if (!fs.existsSync(absPath)) {
  console.error('File not found:', absPath);
  process.exit(1);
}

const ext = path.extname(absPath).toLowerCase();
const mimeMap = { '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.png': 'image/png', '.webp': 'image/webp' };
const mimeType = mimeMap[ext] || 'image/jpeg';

console.log(`\n📸 Testing image: ${absPath}`);
console.log(`   MIME type: ${mimeType}`);
console.log('   Sending to Gemini...\n');

const imageBuffer = fs.readFileSync(absPath);

aiVision.analyzeWaste(imageBuffer, mimeType).then(result => {
  console.log('\n✅ Final parsed result:');
  console.log(JSON.stringify(result, null, 2));

  if (result.confidence === 0) {
    console.log('\n⚠️  Confidence is 0 — check the raw response log above for what Gemini returned.');
  } else {
    console.log(`\n🎉 Success! Identified: "${result.item_name}" with ${Math.round(result.confidence * 100)}% confidence`);
  }
  process.exit(0);
}).catch(err => {
  console.error('\n❌ Unexpected error:', err);
  process.exit(1);
});
