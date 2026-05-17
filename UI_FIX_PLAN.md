# UI Fix Plan - Make Everything Dark & Beautiful

## 🎯 Goal
Transform all screens to use pure black backgrounds with premium fintech aesthetic.

## 🎨 Design Rules

### Colors
- **Background:** Pure Black (#000000) - EVERYWHERE
- **Cards:** Deep Charcoal (#1C1C1E) with 28px radius
- **Text:** White (#FFFFFF) primary, Light Grey (#E5E5E7) secondary
- **Accent:** Vibrant Lime (#D7FF00) for actions and highlights
- **Borders:** Subtle (#2C2C2E) or Lime for emphasis

### Components
- **All Buttons:** Glass effect, pill-shaped (100px radius), 56px height
- **All Cards:** Charcoal background, 28px radius, no shadows
- **All Inputs:** Charcoal background, 20px radius, lime focus
- **All AppBars:** Transparent or black, no elevation
- **Bottom Nav:** Floating pill shape with charcoal background

### Spacing
- Generous padding (24px minimum)
- Clean layouts with breathing room
- Consistent 16px gaps between elements

## 📋 Screens to Fix

### Priority 1 (User Sees First)
1. ✅ Splash Screen - Already black
2. ⏳ Onboarding Screen - Needs black background
3. ⏳ Login Screen - Needs black + glass buttons
4. ⏳ Register Screen - Needs black + glass buttons
5. ⏳ Dashboard - Needs complete redesign

### Priority 2 (Main Features)
6. ⏳ Marketplace Screen - Black + charcoal cards
7. ⏳ Item Detail - Black + glass buttons
8. ⏳ Create Listing - Black + charcoal form
9. ⏳ Eco Score - Black + lime accents
10. ⏳ Notifications - Black + charcoal cards

### Priority 3 (Secondary)
11. ⏳ Profile Screen - Black + charcoal cards
12. ⏳ Pickup Screens - Black + charcoal
13. ⏳ Settings - Black + charcoal

## 🚀 Implementation Strategy

1. Update all `backgroundColor` to `AppColors.black`
2. Replace all white cards with `AppColors.cardSurface`
3. Update all text colors to white/light grey
4. Apply glass buttons everywhere
5. Increase border radius to 28px for cards
6. Remove all shadows/elevations
7. Add subtle lime accents for emphasis

## ✨ Quick Wins

- Change `gray50` to `black` globally
- Change `white` cards to `cardSurface`
- Update all button styles to glass
- Increase all border radius values
- Remove all `elevation` properties
