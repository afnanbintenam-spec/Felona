/**
 * Eco Impact Engine
 *
 * Calculates real environmental impact based on material type.
 * Sources: EPA, EU Waste Statistics, recycling industry averages.
 */

// CO2 saved per kg recycled (vs landfilling/new production)
const CO2_PER_KG = {
  plastic: 1.5,      // PET/HDPE recycling vs virgin
  metal: 4.0,        // Aluminum especially impactful
  paper: 0.9,        // Saves trees + reduces methane
  glass: 0.3,        // Lower impact but still beneficial
  electronics: 6.0,  // Heavy metals + rare earth recovery
  organic: 0.5,      // Composting vs landfill methane
  textile: 2.5,      // Fashion industry waste
  mixed: 1.0,
  unknown: 0.5,
};

// Eco points per kg recycled
const POINTS_PER_KG = {
  plastic: 10,
  metal: 20,
  paper: 8,
  glass: 6,
  electronics: 30,
  organic: 5,
  textile: 12,
  mixed: 8,
  unknown: 5,
};

// Average weight estimates per item (kg)
const AVG_WEIGHT = {
  plastic: 0.3,      // bottle/container
  metal: 0.5,        // can/small piece
  paper: 0.4,        // box/stack
  glass: 0.6,        // bottle/jar
  electronics: 1.5,  // phone/small device
  organic: 0.5,
  textile: 0.4,
  mixed: 0.5,
  unknown: 0.5,
};

// Resale value ranges (USD) for marketplace items by category + condition
const RESALE_VALUE = {
  electronics: { min: 20, max: 200 },
  furniture: { min: 15, max: 150 },
  textile: { min: 5, max: 50 },
  glass: { min: 2, max: 15 },
  metal: { min: 1, max: 30 },
  paper: { min: 1, max: 10 },
  plastic: { min: 1, max: 8 },
};

// Danger levels for improper disposal
const DANGER_LEVELS = {
  electronics: 'high',     // Heavy metals, batteries
  metal: 'medium',         // Sharp edges, lead in solder
  plastic: 'medium',       // Microplastics, ocean pollution
  glass: 'low',            // Minimal toxicity
  paper: 'none',           // Biodegradable
  organic: 'low',          // Methane from landfill
  textile: 'medium',       // Synthetic fibers
  mixed: 'medium',
  unknown: 'medium',
};

class EcoImpactEngine {
  /**
   * Calculate environmental impact from a waste scan
   * @param {Object} params
   * @param {string} params.category - Material category
   * @param {boolean} params.isRecyclable - Whether item is recyclable
   * @param {number} params.weightKg - Estimated weight (optional, defaults to avg)
   * @returns {Object} Impact metrics
   */
  static calculate({ category, isRecyclable = true, weightKg = null }) {
    const cat = (category || 'unknown').toLowerCase();
    const weight = weightKg || AVG_WEIGHT[cat] || AVG_WEIGHT.unknown;

    const co2Multiplier = CO2_PER_KG[cat] || CO2_PER_KG.unknown;
    const pointsMultiplier = POINTS_PER_KG[cat] || POINTS_PER_KG.unknown;

    // Only award full points if recyclable
    const recyclableFactor = isRecyclable ? 1.0 : 0.3;

    const co2SavedKg = +(weight * co2Multiplier * recyclableFactor).toFixed(2);
    const landfillSavedKg = +(weight * recyclableFactor).toFixed(2);
    const points = Math.round(weight * pointsMultiplier * recyclableFactor);

    return {
      estimated_weight_kg: weight,
      co2_saved_kg: co2SavedKg,
      landfill_saved_kg: landfillSavedKg,
      points_earned: Math.max(points, 5), // Minimum 5 points for any scan
      danger_level: DANGER_LEVELS[cat] || 'medium',
    };
  }

  /**
   * Get recommended action based on item type
   */
  static recommendAction({ category, isRecyclable, condition = 'good' }) {
    const cat = (category || '').toLowerCase();

    // Electronics → pickup (e-waste collection)
    if (cat === 'electronics') {
      return {
        action: 'pickup',
        reason: 'E-waste needs special handling — schedule a pickup',
      };
    }

    // Furniture/textile in good condition → marketplace
    if (['textile', 'furniture'].includes(cat) && condition !== 'poor') {
      return {
        action: 'sell',
        reason: 'This item could find a new home on the marketplace',
      };
    }

    // Recyclable plastics/metals/paper/glass → recycle
    if (isRecyclable && ['plastic', 'metal', 'paper', 'glass'].includes(cat)) {
      return {
        action: 'recycle',
        reason: 'Drop in your local recycling bin',
      };
    }

    // Organic → compost
    if (cat === 'organic') {
      return {
        action: 'reuse',
        reason: 'Compost or use as plant food',
      };
    }

    // Default: dispose properly
    return {
      action: 'dispose',
      reason: 'Follow local waste disposal guidelines',
    };
  }

  /**
   * Estimate resale value for marketplace
   */
  static estimateValue({ category, condition = 'good', weightKg = null }) {
    const cat = (category || '').toLowerCase();
    const range = RESALE_VALUE[cat] || { min: 0, max: 0 };

    const conditionMultiplier = {
      new: 1.0,
      like_new: 0.8,
      good: 0.6,
      fair: 0.4,
      poor: 0.2,
    }[condition] || 0.5;

    return {
      min: +(range.min * conditionMultiplier).toFixed(2),
      max: +(range.max * conditionMultiplier).toFixed(2),
    };
  }

  /**
   * Generate emotional eco tip based on impact
   */
  static generateEcoTip({ category, co2SavedKg }) {
    const tips = {
      plastic: `Recycling 1kg of plastic saves enough energy to power a lightbulb for 3 hours! 💡`,
      metal: `Recycling aluminum uses 95% less energy than making it new ⚡`,
      paper: `One recycled tree saves 17 trees, 7000 gallons of water, and 463 gallons of oil 🌳`,
      glass: `Glass can be recycled forever without losing quality ♻️`,
      electronics: `One million recycled phones recover 35,000 lbs of copper 📱`,
      organic: `Composting reduces methane emissions by 50% 🌱`,
      textile: `It takes 2,700L of water to make one cotton shirt — recycling matters! 💧`,
    };

    return tips[(category || '').toLowerCase()] ||
      `Every action counts — you saved ${co2SavedKg}kg of CO₂! 🌍`;
  }
}

module.exports = EcoImpactEngine;
