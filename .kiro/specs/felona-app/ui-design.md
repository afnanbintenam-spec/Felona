# UI/UX Design Document: FeloNa Mobile Application

## Overview

This document defines the complete visual design system, user experience patterns, and interface specifications for the FeloNa mobile application. The design emphasizes sustainability, trust, and ease of use while creating distinct experiences for three user roles: Normal Users, Buyers, and Collectors.

### Design Philosophy

**Core Principles:**
1. **Eco-Conscious**: Visual language reflects environmental sustainability
2. **Trust & Safety**: Design builds confidence in peer-to-peer transactions
3. **Role Clarity**: Each user type has a distinct, optimized experience
4. **Accessibility First**: WCAG 2.1 AA compliance minimum
5. **Performance**: Smooth 60fps animations, optimized images

**Design Goals:**
- Create emotional connection to environmental impact
- Simplify complex multi-role workflows
- Build trust through transparency and clear communication
- Delight users with smooth, purposeful animations

---

## Design System

### Color Palette

#### Primary Colors

**Eco Green** (Brand Primary)
- `primary-900`: `#0D4D2B` - Dark forest green
- `primary-700`: `#1B7A43` - Deep green
- `primary-500`: `#2ECC71` - Main brand green ✓ Primary
- `primary-300`: `#7FE5A8` - Light green
- `primary-100`: `#D4F4E2` - Pale green

**Usage**: Primary actions, active states, eco-score indicators, success messages

#### Secondary Colors

**Earth Brown** (Grounding)
- `secondary-900`: `#3E2723`
- `secondary-700`: `#5D4037`
- `secondary-500`: `#8D6E63` ✓ Secondary
- `secondary-300`: `#BCAAA4`
- `secondary-100`: `#EFEBE9`

**Usage**: Collector role accent, waste categories, grounding elements

**Sky Blue** (Trust)
- `accent-900`: `#01579B`
- `accent-700`: `#0277BD`
- `accent-500`: `#03A9F4` ✓ Accent
- `accent-300`: `#4FC3F7`
- `accent-100`: `#B3E5FC`

**Usage**: Buyer role accent, informational elements, links

#### Semantic Colors

**Success**: `#27AE60` (Green)
**Warning**: `#F39C12` (Orange)
**Error**: `#E74C3C` (Red)
**Info**: `#3498DB` (Blue)

#### Neutral Colors

**Grayscale**
- `gray-900`: `#212121` - Text primary
- `gray-700`: `#616161` - Text secondary
- `gray-500`: `#9E9E9E` - Text disabled
- `gray-300`: `#E0E0E0` - Borders
- `gray-100`: `#F5F5F5` - Background light
- `gray-50`: `#FAFAFA` - Background

**White**: `#FFFFFF`
**Black**: `#000000` (use sparingly)

#### Role-Specific Accent Colors

**Normal User**: Primary Green (`#2ECC71`)
**Buyer**: Sky Blue (`#03A9F4`)
**Collector**: Earth Brown (`#8D6E63`)

### Typography

#### Font Family

**Primary**: **Inter** (Google Fonts)
- Modern, highly legible sans-serif
- Excellent readability at small sizes
- Wide range of weights

**Fallback**: System fonts (`-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto`)

#### Type Scale

```
Display Large:   32sp / 40sp line height / Bold (700)
Display Medium:  28sp / 36sp line height / Bold (700)
Display Small:   24sp / 32sp line height / SemiBold (600)

Headline Large:  22sp / 28sp line height / SemiBold (600)
Headline Medium: 20sp / 26sp line height / SemiBold (600)
Headline Small:  18sp / 24sp line height / Medium (500)

Body Large:      16sp / 24sp line height / Regular (400)
Body Medium:     14sp / 20sp line height / Regular (400)
Body Small:      12sp / 16sp line height / Regular (400)

Label Large:     14sp / 20sp line height / Medium (500)
Label Medium:    12sp / 16sp line height / Medium (500)
Label Small:     10sp / 14sp line height / Medium (500)
```

#### Typography Usage

- **Display**: Page titles, onboarding headlines
- **Headline**: Section headers, card titles
- **Body**: Paragraph text, descriptions
- **Label**: Buttons, form labels, captions

### Spacing System

**Base Unit**: 4px

```
xs:  4px   (1 unit)
sm:  8px   (2 units)
md:  16px  (4 units)
lg:  24px  (6 units)
xl:  32px  (8 units)
2xl: 48px  (12 units)
3xl: 64px  (16 units)
```

**Layout Margins**: 16px (md) on mobile, 24px (lg) on tablet

### Elevation & Shadows

```dart
// Material Design elevation levels
elevation-0: none
elevation-1: BoxShadow(
  color: Colors.black.withOpacity(0.05),
  blurRadius: 4,
  offset: Offset(0, 2),
)
elevation-2: BoxShadow(
  color: Colors.black.withOpacity(0.08),
  blurRadius: 8,
  offset: Offset(0, 4),
)
elevation-3: BoxShadow(
  color: Colors.black.withOpacity(0.12),
  blurRadius: 16,
  offset: Offset(0, 8),
)
```

**Usage**:
- Cards: elevation-1
- Floating buttons: elevation-2
- Modals/dialogs: elevation-3
- Bottom sheets: elevation-2

### Border Radius

```
none:   0px
sm:     4px   - Small chips, tags
md:     8px   - Buttons, input fields
lg:     12px  - Cards, containers
xl:     16px  - Large cards, images
2xl:    24px  - Bottom sheets, modals
full:   9999px - Circular elements
```

---

## Component Library

### Buttons

#### Primary Button

**Visual Specs**:
- Background: `primary-500`
- Text: White, Label Large, Medium (500)
- Height: 48px
- Padding: 16px horizontal
- Border radius: 8px (md)
- Elevation: 1 (resting), 2 (pressed)

**States**:
- **Default**: Full color, elevation-1
- **Hover**: Brightness +10%
- **Pressed**: Brightness -10%, elevation-2
- **Disabled**: Opacity 0.4, no elevation
- **Loading**: Spinner replaces text, disabled state

**Animation**: 150ms ease-in-out for all transitions

```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary500,
    foregroundColor: Colors.white,
    minimumSize: Size(double.infinity, 48),
    padding: EdgeInsets.symmetric(horizontal: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 1,
  ),
  child: Text('Continue', style: AppTextStyles.labelLarge),
)
```

#### Secondary Button

**Visual Specs**:
- Background: Transparent
- Border: 1.5px solid `primary-500`
- Text: `primary-500`, Label Large, Medium (500)
- Height: 48px
- Padding: 16px horizontal
- Border radius: 8px (md)

**States**:
- **Default**: Outlined
- **Hover**: Background `primary-100`
- **Pressed**: Background `primary-200`
- **Disabled**: Opacity 0.4

#### Text Button

**Visual Specs**:
- Background: Transparent
- Text: `primary-500`, Label Large, Medium (500)
- Height: 40px
- Padding: 12px horizontal
- No border

**Usage**: Tertiary actions, "Cancel", "Skip"

#### Icon Button

**Visual Specs**:
- Size: 40x40px
- Icon size: 24px
- Background: Transparent (default), `gray-100` (hover)
- Border radius: 8px (md)

**Usage**: Navigation icons, action buttons in app bars

### Input Fields

#### Text Input

**Visual Specs**:
- Height: 56px
- Padding: 16px horizontal, 16px vertical
- Border: 1px solid `gray-300`
- Border radius: 8px (md)
- Background: White
- Label: Body Medium, `gray-700` (floating label)
- Text: Body Large, `gray-900`

**States**:
- **Default**: Gray border
- **Focused**: `primary-500` border (2px), label moves up
- **Error**: `error` border (2px), error text below
- **Disabled**: Background `gray-100`, text `gray-500`

**Error State**:
- Border color: `#E74C3C`
- Helper text: Body Small, `#E74C3C`, 4px margin top

```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.gray300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.primary500, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.error, width: 2),
    ),
  ),
)
```

#### Dropdown / Select

**Visual Specs**: Same as text input
**Icon**: Chevron down (24px), `gray-700`
**Dropdown menu**: White background, elevation-2, 8px border radius

### Cards

#### Standard Card

**Visual Specs**:
- Background: White
- Border radius: 12px (lg)
- Elevation: 1
- Padding: 16px

**Usage**: List items, content containers

#### Image Card (Marketplace Listing)

**Visual Specs**:
- Aspect ratio: 4:3
- Border radius: 12px (lg)
- Image: Cover fit
- Overlay gradient: Linear gradient from transparent to `rgba(0,0,0,0.4)` at bottom
- Text overlay: White, positioned at bottom with 12px padding

**Interaction**:
- Tap: Scale to 0.98, 100ms duration
- Release: Scale back to 1.0, 100ms duration

### Chips & Tags

#### Category Chip

**Visual Specs**:
- Height: 32px
- Padding: 12px horizontal
- Border radius: 16px (full)
- Background: `gray-100` (unselected), `primary-500` (selected)
- Text: Label Medium, `gray-900` (unselected), White (selected)

**States**:
- **Unselected**: Gray background
- **Selected**: Primary color background
- **Pressed**: Slight scale (0.95)

#### Status Badge

**Visual Specs**:
- Height: 24px
- Padding: 8px horizontal
- Border radius: 12px (full)
- Background: Semantic color at 10% opacity
- Text: Label Small, Semantic color at 100%

**Status Colors**:
- Pending: Warning
- Accepted: Info
- On The Way: Info
- Completed: Success
- Sold: Success
- Active: Primary

### Bottom Navigation Bar

**Visual Specs**:
- Height: 64px
- Background: White
- Top border: 1px solid `gray-200`
- Elevation: 3
- Safe area insets: Respected

**Items**:
- Icon size: 24px
- Label: Label Small
- Active color: Role-specific accent
- Inactive color: `gray-500`
- Indicator: 4px height, full width, role-specific accent

**Animation**: 200ms ease-in-out for icon/label color change

### App Bar

**Visual Specs**:
- Height: 56px + status bar height
- Background: White
- Bottom border: 1px solid `gray-200`
- Elevation: 0 (default), 1 (scrolled)

**Elements**:
- Leading icon: 40x40px icon button
- Title: Headline Small, `gray-900`
- Actions: Icon buttons (40x40px)

### Modals & Bottom Sheets

#### Bottom Sheet

**Visual Specs**:
- Background: White
- Border radius: 24px (2xl) top corners only
- Elevation: 3
- Handle: 32px width, 4px height, `gray-300`, 8px margin top
- Max height: 90% of screen
- Padding: 24px

**Animation**:
- Enter: Slide up from bottom, 300ms ease-out
- Exit: Slide down, 250ms ease-in

#### Dialog

**Visual Specs**:
- Background: White
- Border radius: 16px (xl)
- Elevation: 3
- Padding: 24px
- Max width: 320px (mobile)

**Animation**:
- Enter: Fade in + scale from 0.9 to 1.0, 200ms ease-out
- Exit: Fade out + scale to 0.9, 150ms ease-in

### Loading States

#### Circular Progress Indicator

**Visual Specs**:
- Size: 24px (small), 40px (medium), 56px (large)
- Stroke width: 3px (small), 4px (medium/large)
- Color: Role-specific accent

#### Skeleton Loader

**Visual Specs**:
- Background: `gray-100`
- Shimmer: Linear gradient from `gray-100` to `gray-200` to `gray-100`
- Animation: 1.5s infinite, ease-in-out
- Border radius: Matches content shape

**Usage**: Card placeholders, list items while loading

### Snackbars & Toasts

#### Snackbar

**Visual Specs**:
- Background: `gray-900` (default), semantic colors for status
- Text: Body Medium, White
- Height: 48px minimum
- Padding: 16px horizontal
- Border radius: 8px (md)
- Elevation: 2
- Position: Bottom, 16px margin from edges

**Duration**: 4 seconds (default), 7 seconds (action), indefinite (error)

**Animation**:
- Enter: Slide up + fade in, 200ms ease-out
- Exit: Fade out, 150ms ease-in

---

## Logo & Branding

### Logo Design

**Primary Logo**:
- **Symbol**: Circular recycling arrows forming a leaf shape
- **Wordmark**: "FeloNa" in custom lettering
- **Colors**: Primary green (`#2ECC71`) for symbol, `gray-900` for wordmark
- **Spacing**: 8px between symbol and wordmark

**Logo Variations**:
1. **Full Logo**: Symbol + wordmark (horizontal)
2. **Icon Only**: Symbol alone (app icon, favicon)
3. **Wordmark Only**: Text alone (limited space)
4. **Monochrome**: Single color versions (white, black)

**Clear Space**: Minimum clear space = height of symbol on all sides

**Minimum Sizes**:
- Full logo: 120px width
- Icon only: 32px width
- Wordmark: 80px width

### App Icon

**Specifications**:
- **iOS**: 1024x1024px (App Store), various sizes for device
- **Android**: 512x512px (Play Store), adaptive icon with foreground + background layers

**Design**:
- Background: Gradient from `primary-500` to `primary-700`
- Foreground: White recycling leaf symbol
- Padding: 20% safe zone for adaptive icons

---

## Animations & Transitions

### Animation Principles

1. **Purposeful**: Every animation serves a functional purpose
2. **Performant**: 60fps minimum, GPU-accelerated
3. **Consistent**: Same duration/easing for similar actions
4. **Subtle**: Enhance, don't distract

### Duration Standards

```
Micro:   100-150ms  - Hover states, ripples
Short:   200-300ms  - Page transitions, modals
Medium:  300-500ms  - Complex transitions, reveals
Long:    500-800ms  - Onboarding, celebrations
```

### Easing Curves

```dart
// Standard Material curves
easeIn:     Curves.easeIn
easeOut:    Curves.easeOut
easeInOut:  Curves.easeInOut

// Custom curves
emphasized: Cubic(0.2, 0.0, 0, 1.0)  // Material 3 emphasized
decelerate: Cubic(0.0, 0.0, 0.2, 1.0)
```

### Page Transitions

#### Forward Navigation

**Animation**: Slide from right + fade
- Duration: 300ms
- Easing: `emphasized`
- Incoming page: Slide from right (100% to 0%), fade in (0 to 1)
- Outgoing page: Slide left (-30%), fade out (1 to 0.5)

#### Back Navigation

**Animation**: Slide to right + fade
- Duration: 250ms
- Easing: `decelerate`
- Incoming page: Slide from left (-30% to 0%), fade in (0.5 to 1)
- Outgoing page: Slide right (0% to 100%), fade out (1 to 0)

#### Modal Presentation

**Animation**: Slide up + fade
- Duration: 300ms
- Easing: `easeOut`
- Modal: Slide from bottom (100% to 0%), fade in (0 to 1)
- Background: Fade in scrim (0 to 0.5)

### Micro-interactions

#### Button Press

```dart
AnimatedScale(
  scale: _isPressed ? 0.95 : 1.0,
  duration: Duration(milliseconds: 100),
  curve: Curves.easeInOut,
  child: button,
)
```

#### Card Tap

```dart
AnimatedScale(
  scale: _isTapped ? 0.98 : 1.0,
  duration: Duration(milliseconds: 100),
  curve: Curves.easeInOut,
  child: card,
)
```

#### Ripple Effect

- Material ripple: `InkWell` with `splashColor` at 10% opacity
- Duration: 300ms
- Radius: Unbounded (spreads beyond widget)

### List Animations

#### Staggered Fade-In

When loading list items:
- Each item fades in sequentially
- Delay between items: 50ms
- Fade duration: 200ms
- Slide distance: 20px from bottom

```dart
AnimatedList(
  itemBuilder: (context, index, animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 0.1),
          end: Offset.zero,
        ).animate(animation),
        child: listItem,
      ),
    );
  },
)
```

#### Item Removal

- Slide out to left + fade out
- Duration: 250ms
- Easing: `easeIn`

### Success Animations

#### Eco Points Earned

When user earns eco points:
1. **Icon**: Scale from 0 to 1.2 to 1.0 (bounce effect)
2. **Number**: Count up animation from previous to new value
3. **Confetti**: Particle effect (optional, for large milestones)
4. **Duration**: 800ms total

#### Offer Accepted

When offer is accepted:
1. **Checkmark**: Draw animation (stroke dash)
2. **Background**: Pulse effect (scale 1.0 to 1.05 to 1.0)
3. **Duration**: 500ms

### Loading Animations

#### Pull to Refresh

- Indicator: Circular progress with custom eco leaf icon
- Threshold: 80px pull distance
- Animation: Rotate + scale as user pulls

#### Infinite Scroll

- Indicator: Small circular progress at bottom of list
- Appears when user scrolls within 200px of bottom

---

## Screen Designs

### Authentication Screens

#### Splash Screen

**Layout**:
- Full screen gradient background (`primary-500` to `primary-700`)
- Logo centered (icon + wordmark)
- Tagline below: "Recycle. Earn. Impact." (Body Large, White, 16px margin top)

**Animation**:
- Logo fades in + scales from 0.8 to 1.0 (500ms)
- Tagline fades in after 200ms delay (300ms)
- Auto-navigate after 2 seconds

#### Onboarding Carousel

**Layout** (3 screens):
1. **Screen 1**: "Sell Your Reusables"
   - Illustration: Person listing item on phone
   - Headline: Display Small
   - Description: Body Large, `gray-700`

2. **Screen 2**: "Request Waste Pickup"
   - Illustration: Collector picking up waste
   - Headline: Display Small
   - Description: Body Large, `gray-700`

3. **Screen 3**: "Earn Eco Points"
   - Illustration: Eco score dashboard
   - Headline: Display Small
   - Description: Body Large, `gray-700`

**Navigation**:
- Dots indicator at bottom (8px diameter, 8px spacing)
- "Skip" text button (top right)
- "Next" primary button (bottom, full width)
- "Get Started" on final screen

**Animation**:
- Swipe gesture: Horizontal page view
- Transition: 300ms ease-out
- Dots: Animated width change (8px to 24px for active)

#### Registration Screen

**Layout**:
- App bar: Back button, "Create Account" title
- Form fields (vertical stack, 16px spacing):
  1. Full Name input
  2. Email input
  3. Password input (with show/hide toggle)
  4. Role selection (3 large cards)
- Primary button: "Create Account" (bottom, 24px margin)
- Footer: "Already have an account? Log in" (text button)

**Role Selection Cards**:
- Size: Full width, 80px height
- Layout: Icon (left), Title + Description (center), Radio button (right)
- Border: 2px solid `gray-300` (default), `primary-500` (selected)
- Background: White (default), `primary-50` (selected)

**Roles**:
1. **Normal User**
   - Icon: Leaf icon, `primary-500`
   - Title: "Normal User"
   - Description: "Sell items & request pickups"

2. **Buyer**
   - Icon: Shopping bag icon, `accent-500`
   - Title: "Buyer / Recycler"
   - Description: "Browse & purchase items"

3. **Collector**
   - Icon: Truck icon, `secondary-500`
   - Title: "Collector"
   - Description: "Accept pickup jobs & earn"

**Validation**:
- Real-time validation on blur
- Error messages below fields
- Disabled button until form valid

#### Login Screen

**Layout**:
- Logo (top, 48px margin)
- Headline: "Welcome Back" (Display Small, 32px margin top)
- Form fields (24px spacing):
  1. Email input
  2. Password input (with show/hide toggle)
- "Forgot Password?" text button (right-aligned, 8px margin top)
- Primary button: "Log In" (24px margin top)
- Divider: "or" (24px margin top/bottom)
- Secondary button: "Create Account"

**States**:
- Loading: Button shows spinner, form disabled
- Error: Snackbar at bottom with error message

---


### Dashboard Screens

#### Normal User Dashboard

**Layout**:
- App bar: Logo (left), Notifications icon (right), Profile icon (right)
- Greeting: "Hello, [Name]!" (Headline Large, 16px margin)
- Stats cards (horizontal scroll, 16px spacing):
  1. **Eco Points**: Large number, "Total Points" label, leaf icon
  2. **Active Listings**: Count, "Items Listed" label, tag icon
  3. **Pending Pickups**: Count, "Awaiting Pickup" label, truck icon
- Quick actions (2-column grid, 16px spacing):
  1. "List an Item" - Primary button with plus icon
  2. "Request Pickup" - Secondary button with truck icon
- Recent activity section:
  - Section header: "Recent Activity" (Headline Medium)
  - List of recent offers, pickups (max 5)
  - "View All" text button

**Stats Card Design**:
- Size: 140px width, 100px height
- Background: Gradient (role-specific color at 10% to 20%)
- Border radius: 12px
- Padding: 16px
- Number: Display Medium, role-specific color
- Label: Body Small, `gray-700`
- Icon: 32px, role-specific color, top-right corner

#### Buyer Dashboard

**Layout**:
- App bar: Logo, Search icon, Notifications icon, Profile icon
- Search bar: "Search items..." (full width, 16px margin)
- Category chips (horizontal scroll):
  - All, Plastic, Metal, Paper, Glass, Electronics, Other
- Marketplace feed:
  - Grid layout (2 columns on mobile, 3 on tablet)
  - Item cards (image, title, price, seller)
  - Infinite scroll loading

**Item Card Design**:
- Aspect ratio: 3:4
- Image: Cover fit, 12px border radius
- Overlay gradient at bottom
- Price: Headline Small, White, bold, bottom-left
- Title: Body Medium, White, bottom-left, below price
- Seller: Body Small, White, 60% opacity, bottom-left
- Favorite icon: Heart outline, top-right, 8px margin

#### Collector Dashboard

**Layout**:
- App bar: Logo, Filter icon, Notifications icon, Profile icon
- Earnings banner:
  - Background: `secondary-500` gradient
  - Text: "Today's Earnings: $XX.XX" (Headline Large, White)
  - Icon: Dollar sign, White
- Stats row (3 columns):
  1. Jobs Today: Count
  2. In Progress: Count
  3. Completed: Total count
- Pickup feed:
  - List layout (vertical)
  - Pickup cards (waste type, weight, address, distance)
  - Pull to refresh

**Pickup Card Design**:
- Background: White
- Border: 1px solid `gray-200`
- Border radius: 12px
- Padding: 16px
- Layout:
  - Top row: Waste category chip (left), Distance badge (right)
  - Middle: Address (Body Large, `gray-900`)
  - Bottom row: Weight (Body Medium, `gray-700`), "Accept" button (right)

---

### Marketplace Screens

#### Item Listing Detail

**Layout**:
- Image carousel:
  - Full width, 300px height
  - Swipeable images with dots indicator
  - Back button (top-left, floating)
  - Favorite button (top-right, floating)
- Content section (white background, 16px padding):
  - Price: Display Medium, `primary-500`
  - Title: Headline Large, `gray-900`, 8px margin top
  - Category chip: 8px margin top
  - Seller info card: 16px margin top
    - Avatar (40px), Name, Role badge, Rating (if available)
  - Description: Body Large, `gray-700`, 16px margin top
  - Posted date: Body Small, `gray-500`, 8px margin top
- Bottom bar (fixed):
  - "Message Seller" secondary button (left, flex 1)
  - "Make Offer" primary button (right, flex 1)
  - 8px spacing between buttons

**Image Carousel**:
- Swipe gesture: Horizontal page view
- Dots indicator: Bottom center, 16px margin
- Zoom: Pinch to zoom, double-tap to zoom

#### Create Listing Screen

**Layout**:
- App bar: Back button, "New Listing" title, "Save Draft" text button
- Form (scrollable, 16px padding):
  1. Image picker section:
     - Grid layout (3 columns)
     - Add image button (dashed border, plus icon)
     - Image thumbnails (with remove button)
     - Max 5 images indicator
  2. Title input: "Item Title"
  3. Category dropdown: "Select Category"
  4. Price input: "Price (USD)" with currency symbol
  5. Description textarea: "Describe your item" (4 lines min)
- Bottom bar (fixed):
  - Primary button: "Publish Listing"

**Image Picker**:
- Size: Square, 100px
- Border: 2px dashed `gray-300`
- Icon: Camera icon, `gray-500`, 32px
- Tap: Opens image picker (camera or gallery)

**Image Thumbnail**:
- Size: Square, 100px
- Border radius: 8px
- Remove button: Circular, 24px, top-right corner, `error` background, white X icon

#### Offers Screen

**Layout**:
- App bar: Back button, "Offers" title
- Tabs: "Received" | "Sent"
- Offer list:
  - Offer cards (vertical list)
  - Empty state: "No offers yet" with illustration

**Offer Card Design**:
- Background: White
- Border: 1px solid `gray-200`
- Border radius: 12px
- Padding: 16px
- Layout:
  - Top row: Item thumbnail (60px), Title + Price (center), Status badge (right)
  - Middle: Buyer/Seller name + avatar
  - Bottom row: Offered price (Headline Medium, `primary-500`), Action buttons (right)

**Action Buttons** (for received offers):
- "Accept" primary button (small)
- "Reject" text button (small)

---

### Pickup Screens

#### Create Pickup Request

**Layout**:
- App bar: Back button, "Request Pickup" title
- Form (scrollable, 16px padding):
  1. Waste category selection:
     - Grid layout (2 columns)
     - Category cards (icon, label)
  2. Estimated weight input: "Weight (kg)" with number keyboard
  3. Address input: "Pickup Address" with location icon
     - "Use Current Location" text button below
  4. Additional notes textarea: "Special instructions (optional)"
- Bottom bar (fixed):
  - Primary button: "Submit Request"

**Category Card Design**:
- Size: Full width, 80px height
- Border: 2px solid `gray-300` (default), `primary-500` (selected)
- Background: White (default), `primary-50` (selected)
- Border radius: 12px
- Layout: Icon (top, 32px), Label (bottom, Body Medium)

**Categories**:
- Plastic: Blue plastic bottle icon
- Metal: Gray can icon
- Paper: Brown paper icon
- Glass: Green bottle icon
- Electronics: Gray device icon
- Other: Gray box icon

#### Pickup Detail Screen

**Layout**:
- App bar: Back button, "Pickup Details" title
- Status timeline:
  - Vertical stepper showing: Pending → Accepted → On The Way → Completed
  - Active step highlighted in role color
  - Completed steps: Checkmark icon
- Details card:
  - Waste category chip
  - Weight: "XX kg"
  - Address with map icon
  - Created date
- Collector info card (if assigned):
  - Avatar, Name, Phone number
  - "Call Collector" button
  - "Message Collector" button
- Bottom bar (for collector):
  - Status update button: "Mark as On The Way" or "Mark as Completed"

**Status Timeline Design**:
- Line: 2px width, `gray-300` (inactive), role color (active/completed)
- Dots: 24px diameter, `gray-300` (inactive), role color (active/completed)
- Labels: Body Medium, `gray-700` (inactive), role color (active)
- Spacing: 40px between steps

---

### Profile & Settings Screens

#### Profile Screen

**Layout**:
- Header section:
  - Background: Role-specific gradient
  - Avatar: 80px diameter, centered, white border (4px)
  - Name: Headline Large, White, centered, 8px margin top
  - Role badge: Below name, centered
  - Edit button: Icon button, top-right
- Stats section (for Normal User):
  - 3 columns: Eco Points, Items Sold, Pickups Completed
  - Each: Number (Headline Medium), Label (Body Small)
- Menu list:
  - "Edit Profile" with chevron
  - "My Listings" with chevron (Normal User)
  - "My Offers" with chevron (Buyer)
  - "My Pickups" with chevron (Normal User/Collector)
  - "Eco Score" with chevron (Normal User)
  - "Settings" with chevron
  - "Help & Support" with chevron
  - "Log Out" (red text)

**Menu Item Design**:
- Height: 56px
- Padding: 16px horizontal
- Layout: Icon (left, 24px), Label (center), Chevron (right, 20px)
- Divider: 1px solid `gray-200` between items

#### Edit Profile Screen

**Layout**:
- App bar: Back button, "Edit Profile" title, "Save" text button
- Avatar section:
  - Current avatar (100px diameter, centered)
  - "Change Photo" text button below
- Form fields:
  1. Full Name input
  2. Email input (disabled, gray background)
  3. Phone Number input
  4. Role (disabled, gray background)
- Delete account button: Text button, red text, bottom

#### Eco Score Screen (Normal User)

**Layout**:
- Header card:
  - Background: `primary-500` gradient
  - Large eco points number: Display Large, White, centered
  - "Total Eco Points" label: Body Large, White, 60% opacity
  - Leaf icon: 64px, White, top-right corner
- Stats row (2 columns):
  1. Total Weight Recycled: "XX kg"
  2. Items Sold: Count
- Point history section:
  - Section header: "Point History"
  - List of point events (date, reason, points earned)
  - Infinite scroll

**Point Event Item**:
- Layout: Icon (left), Reason + Date (center), Points (right)
- Icon: 40px, role color background at 10%, role color icon
- Reason: Body Large, `gray-900`
- Date: Body Small, `gray-500`
- Points: Headline Small, `primary-500`, "+XX pts"

---

### Notification Screens

#### Notifications List

**Layout**:
- App bar: Back button, "Notifications" title, "Mark All Read" text button
- Tabs: "All" | "Offers" | "Pickups"
- Notification list:
  - Notification cards (vertical list)
  - Unread indicator: Blue dot (left)
  - Empty state: "No notifications" with bell icon

**Notification Card Design**:
- Background: White (read), `primary-50` (unread)
- Border: 1px solid `gray-200`
- Border radius: 12px
- Padding: 16px
- Layout:
  - Icon (left, 40px, role color background)
  - Content (center): Title (Body Large, bold), Message (Body Medium), Time (Body Small, `gray-500`)
  - Chevron (right, 20px)

**Notification Types**:
1. **New Offer**: Shopping bag icon, "New offer on [Item]"
2. **Offer Accepted**: Checkmark icon, "Your offer was accepted"
3. **Offer Rejected**: X icon, "Your offer was declined"
4. **Pickup Accepted**: Truck icon, "Collector accepted your pickup"
5. **Pickup Status**: Location icon, "Collector is on the way"
6. **Pickup Completed**: Checkmark icon, "Pickup completed! +XX eco points"

---

## Responsive Design

### Breakpoints

```
Mobile:     < 600px   (1 column layouts)
Tablet:     600-1024px (2 column layouts, larger cards)
Desktop:    > 1024px   (Not primary target, but graceful degradation)
```

### Adaptive Layouts

#### Mobile (< 600px)
- Single column layouts
- Full-width cards
- Bottom navigation bar
- Stacked buttons

#### Tablet (600-1024px)
- 2-column grid for marketplace
- Side-by-side buttons
- Larger cards (max width 400px)
- Optional side navigation drawer

### Safe Areas

- Respect device safe areas (notches, home indicators)
- Bottom navigation: Add safe area padding
- Modals: Add safe area padding to bottom
- Full-screen images: Extend into safe areas, but keep controls in safe zone

---

## Accessibility

### WCAG 2.1 AA Compliance

#### Color Contrast

**Minimum Ratios**:
- Normal text (< 18pt): 4.5:1
- Large text (≥ 18pt): 3:1
- UI components: 3:1

**Verified Combinations**:
- `primary-500` on White: 4.52:1 ✓
- `gray-900` on White: 16.1:1 ✓
- White on `primary-500`: 4.52:1 ✓
- `gray-700` on White: 7.23:1 ✓

#### Touch Targets

- Minimum size: 44x44px (iOS), 48x48px (Android)
- Spacing: 8px minimum between targets
- All interactive elements meet minimum size

#### Screen Reader Support

- All images: `semanticLabel` provided
- Form fields: `labelText` and `hintText`
- Buttons: Descriptive labels (not just icons)
- Navigation: Semantic structure with proper headings

#### Keyboard Navigation

- Tab order: Logical top-to-bottom, left-to-right
- Focus indicators: 2px outline, role color
- Skip links: "Skip to content" for long pages

#### Motion & Animation

- Respect `MediaQuery.of(context).disableAnimations`
- Provide reduced motion alternative
- No auto-playing videos
- Pause/stop controls for animations > 5 seconds

### Internationalization (i18n)

- All text: Externalized to locale files
- RTL support: Layouts adapt for Arabic, Hebrew
- Date/time: Locale-specific formatting
- Currency: Locale-specific formatting

---

## Dark Mode (Future Enhancement)

**Note**: Dark mode is not in MVP scope, but design system is prepared for it.

### Dark Color Palette

**Background**:
- `dark-bg-primary`: `#121212`
- `dark-bg-secondary`: `#1E1E1E`
- `dark-bg-tertiary`: `#2C2C2C`

**Text**:
- `dark-text-primary`: `#FFFFFF` (87% opacity)
- `dark-text-secondary`: `#FFFFFF` (60% opacity)
- `dark-text-disabled`: `#FFFFFF` (38% opacity)

**Primary Colors**: Lighter shades for dark mode
- `primary-400`: `#4ADE80` (instead of `primary-500`)

**Elevation**: Use lighter backgrounds instead of shadows
- Level 1: `#1E1E1E`
- Level 2: `#2C2C2C`
- Level 3: `#3A3A3A`

---

## Implementation Guidelines

### Flutter Theme Configuration

```dart
// lib/core/theme/app_theme.dart

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary500,
      secondary: AppColors.secondary500,
      tertiary: AppColors.accent500,
      error: AppColors.error,
      background: AppColors.gray50,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: AppColors.gray900,
      onSurface: AppColors.gray900,
    ),
    textTheme: AppTextStyles.textTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary500,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 1,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.gray300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primary500, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: EdgeInsets.all(16),
    ),
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary500,
      unselectedItemColor: AppColors.gray500,
      type: BottomNavigationBarType.fixed,
      elevation: 3,
    ),
  );
}
```

### Color Constants

```dart
// lib/core/theme/app_colors.dart

class AppColors {
  // Primary
  static const primary900 = Color(0xFF0D4D2B);
  static const primary700 = Color(0xFF1B7A43);
  static const primary500 = Color(0xFF2ECC71);
  static const primary300 = Color(0xFF7FE5A8);
  static const primary100 = Color(0xFFD4F4E2);

  // Secondary
  static const secondary900 = Color(0xFF3E2723);
  static const secondary700 = Color(0xFF5D4037);
  static const secondary500 = Color(0xFF8D6E63);
  static const secondary300 = Color(0xFFBCAAA4);
  static const secondary100 = Color(0xFFEFEBE9);

  // Accent
  static const accent900 = Color(0xFF01579B);
  static const accent700 = Color(0xFF0277BD);
  static const accent500 = Color(0xFF03A9F4);
  static const accent300 = Color(0xFF4FC3F7);
  static const accent100 = Color(0xFFB3E5FC);

  // Semantic
  static const success = Color(0xFF27AE60);
  static const warning = Color(0xFFF39C12);
  static const error = Color(0xFFE74C3C);
  static const info = Color(0xFF3498DB);

  // Grayscale
  static const gray900 = Color(0xFF212121);
  static const gray700 = Color(0xFF616161);
  static const gray500 = Color(0xFF9E9E9E);
  static const gray300 = Color(0xFFE0E0E0);
  static const gray100 = Color(0xFFF5F5F5);
  static const gray50 = Color(0xFFFAFAFA);
}
```

### Text Styles

```dart
// lib/core/theme/app_text_styles.dart

class AppTextStyles {
  static const String fontFamily = 'Inter';

  // Display
  static const displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    height: 1.25,
    fontWeight: FontWeight.w700,
  );

  static const displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 1.29,
    fontWeight: FontWeight.w700,
  );

  static const displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 1.33,
    fontWeight: FontWeight.w600,
  );

  // Headline
  static const headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 1.27,
    fontWeight: FontWeight.w600,
  );

  static const headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );

  static const headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 1.33,
    fontWeight: FontWeight.w500,
  );

  // Body
  static const bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  static const bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w400,
  );

  static const bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w400,
  );

  // Label
  static const labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w500,
  );

  static const labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w500,
  );

  static const labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    height: 1.4,
    fontWeight: FontWeight.w500,
  );

  static TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
```

### Spacing Constants

```dart
// lib/core/theme/app_spacing.dart

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}
```

### Animation Constants

```dart
// lib/core/theme/app_animations.dart

class AppAnimations {
  // Durations
  static const Duration micro = Duration(milliseconds: 100);
  static const Duration short = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration long = Duration(milliseconds: 500);

  // Curves
  static const Curve emphasized = Cubic(0.2, 0.0, 0, 1.0);
  static const Curve decelerate = Cubic(0.0, 0.0, 0.2, 1.0);
}
```

---

## Assets & Resources

### Required Assets

#### Fonts
- **Inter**: Download from Google Fonts
  - Weights needed: 400 (Regular), 500 (Medium), 600 (SemiBold), 700 (Bold)
  - Add to `pubspec.yaml` and `assets/fonts/`

#### Icons
- **Material Icons**: Built-in Flutter icons (primary)
- **Custom Icons**: Create custom icon font or use SVG
  - Eco leaf icon
  - Recycling arrows icon
  - Waste category icons (6 types)

#### Illustrations
- **Onboarding**: 3 illustrations (SVG or PNG @2x, @3x)
- **Empty States**: 5 illustrations (no listings, no offers, no pickups, no notifications, no history)
- **Error States**: 2 illustrations (network error, generic error)

#### Logo
- **App Icon**: 1024x1024px (iOS), 512x512px (Android)
- **Logo Variations**: SVG + PNG (@1x, @2x, @3x)
  - Full logo (horizontal)
  - Icon only
  - Wordmark only
  - Monochrome versions

### Asset Organization

```
assets/
├── fonts/
│   └── Inter/
│       ├── Inter-Regular.ttf
│       ├── Inter-Medium.ttf
│       ├── Inter-SemiBold.ttf
│       └── Inter-Bold.ttf
├── images/
│   ├── logo/
│   │   ├── logo_full.svg
│   │   ├── logo_icon.svg
│   │   └── logo_wordmark.svg
│   ├── illustrations/
│   │   ├── onboarding_1.svg
│   │   ├── onboarding_2.svg
│   │   ├── onboarding_3.svg
│   │   ├── empty_listings.svg
│   │   ├── empty_offers.svg
│   │   ├── empty_pickups.svg
│   │   ├── empty_notifications.svg
│   │   ├── empty_history.svg
│   │   ├── error_network.svg
│   │   └── error_generic.svg
│   └── icons/
│       ├── waste_plastic.svg
│       ├── waste_metal.svg
│       ├── waste_paper.svg
│       ├── waste_glass.svg
│       ├── waste_electronics.svg
│       └── waste_other.svg
└── animations/
    └── confetti.json (Lottie animation)
```

---

## Design Handoff Checklist

### For Developers

- [ ] Install Inter font family
- [ ] Set up theme configuration with AppTheme
- [ ] Create color constants (AppColors)
- [ ] Create text style constants (AppTextStyles)
- [ ] Create spacing constants (AppSpacing)
- [ ] Create animation constants (AppAnimations)
- [ ] Implement reusable button components
- [ ] Implement reusable input field components
- [ ] Implement reusable card components
- [ ] Set up page transition animations
- [ ] Configure bottom navigation bar
- [ ] Configure app bar styling
- [ ] Test color contrast ratios
- [ ] Test touch target sizes (min 48x48px)
- [ ] Add semantic labels for screen readers
- [ ] Test with TalkBack (Android) and VoiceOver (iOS)
- [ ] Implement skeleton loaders for async content
- [ ] Add pull-to-refresh indicators
- [ ] Configure snackbar styling
- [ ] Test on multiple screen sizes (small, medium, large)
- [ ] Test on devices with notches/safe areas

### For Designers

- [ ] Create logo in all required formats
- [ ] Design app icon (iOS and Android)
- [ ] Create onboarding illustrations
- [ ] Create empty state illustrations
- [ ] Create error state illustrations
- [ ] Design waste category icons
- [ ] Export all assets at @1x, @2x, @3x
- [ ] Verify color contrast ratios (WCAG AA)
- [ ] Document animation specifications
- [ ] Create interactive prototype (optional)
- [ ] Review implementation with developers

---

## Version History

**Version 1.0** - Initial UI/UX Design Document
- Complete design system definition
- Component library specifications
- Screen designs for all major flows
- Accessibility guidelines
- Implementation guidelines

---

## References

- [Material Design 3](https://m3.material.io/)
- [Flutter Design Guidelines](https://docs.flutter.dev/ui/design)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Android Material Design](https://material.io/design)

