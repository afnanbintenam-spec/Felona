# Requirements Document

## Introduction

The AI Waste Scanner is the hero feature of the FeloNa circular economy platform. It enables users to photograph waste or reusable items, submit the image for AI-powered analysis via Google Gemini, and receive structured results including item identification, recyclability assessment, eco impact metrics, resale value estimates, and actionable recommendations. The feature integrates with the Marketplace, Pickup, and Eco Score modules to provide a seamless path from scanning to action.

## Glossary

- **Scanner**: The AI Waste Scanner feature module encompassing image capture, backend analysis, result display, and action navigation
- **Backend**: The Node.js/Express server that receives image uploads, invokes the Gemini API, calculates eco impact, and persists scan records
- **Gemini_API**: The Google Generative AI service (gemini-2.0-flash-lite model) used for image analysis
- **Scan_Result**: The structured response returned by the Backend after AI analysis, containing identification, impact, and recommendation data
- **Eco_Impact_Engine**: The backend service that calculates CO₂ savings, landfill diversion, eco points, and danger levels based on material category
- **Scan_History**: The paginated list of previous scans stored per authenticated user
- **Recommendation**: The suggested next action derived from the scan (sell, recycle, pickup, reuse, or dispose)
- **Eco_Points**: Gamification currency awarded to users for completing scans and other eco activities
- **Image_Source**: The origin of the scanned image, either the device camera or the photo gallery
- **Confidence_Score**: A decimal value between 0.0 and 1.0 indicating the AI model certainty of its classification

## Requirements

### Requirement 1: Image Capture

**User Story:** As a Normal User, I want to capture or select an image of a waste item, so that I can submit it for AI analysis.

#### Acceptance Criteria

1. WHEN the user taps the scan button, THE Scanner SHALL present options to capture a photo using the device camera or select an image from the device gallery
2. WHEN the user captures a photo via the camera, THE Scanner SHALL obtain the image file, constrain it to a maximum resolution of 1024×1024 pixels, and prepare it for upload
3. WHEN the user selects an image from the gallery, THE Scanner SHALL obtain the image file, constrain it to a maximum resolution of 1024×1024 pixels, and prepare it for upload
4. THE Scanner SHALL accept only JPEG, PNG, or WebP image formats and SHALL reject any file exceeding 5 MB in size
5. IF the user denies camera or gallery permission, THEN THE Scanner SHALL display a message explaining that the permission is required and provide a way to open device settings
6. IF the user cancels image selection without choosing an image, THEN THE Scanner SHALL return to the previous screen state without error
7. IF the selected or captured image exceeds the maximum file size or is not a supported format, THEN THE Scanner SHALL display an error message indicating the constraint violated and allow the user to select a different image

### Requirement 2: Image Upload and AI Analysis

**User Story:** As a Normal User, I want my waste image analyzed by AI, so that I can learn what the item is and how to handle it responsibly.

#### Acceptance Criteria

1. WHEN the user confirms an image for scanning, THE Scanner SHALL upload the image to the Backend endpoint POST /ai/scan as a multipart form-data request with the authenticated user token, with a maximum file size of 5 MB
2. WHILE the image is being uploaded and analyzed, THE Scanner SHALL display a loading indicator to inform the user that analysis is in progress, and SHALL treat the operation as failed if no response is received within 30 seconds
3. WHEN the Backend receives the image, THE Backend SHALL forward the image data to the Gemini_API with a structured prompt requesting JSON output containing item name, material, category, recyclability, confidence, estimated weight, condition, disposal method, eco tip, and resale value indicator
4. WHEN the Gemini_API returns a valid response, THE Backend SHALL parse the JSON and normalize category to one of the allowed values (plastic, metal, paper, glass, electronics, organic, textile, mixed, or unknown), recyclability to one of (yes, no, or partially), and Confidence_Score to a decimal clamped between 0.0 and 1.0
5. WHEN the Gemini_API returns a valid response, THE Eco_Impact_Engine SHALL calculate CO₂ savings, landfill diversion, eco points, and danger level based on the identified material category and estimated weight
6. IF the Gemini_API fails or returns an unparseable response, THEN THE Backend SHALL return a fallback response with category set to "unknown", Confidence_Score set to 0.0, and a message prompting the user to retake the photo
7. IF the image upload fails due to network error or timeout, THEN THE Scanner SHALL display an error message indicating the connection issue and offer a retry option
8. IF the uploaded image exceeds the 5 MB file size limit, THEN THE Backend SHALL reject the request with an error message indicating the file is too large without forwarding to the Gemini_API

### Requirement 3: Scan Result Display

**User Story:** As a Normal User, I want to see a clear and informative breakdown of the scan results, so that I understand what the item is and its environmental impact.

#### Acceptance Criteria

1. WHEN the Backend returns a successful Scan_Result, THE Scanner SHALL display the item name, material type, and waste category (one of: plastic, metal, paper, glass, electronics, organic, textile, mixed, or unknown)
2. WHEN the Backend returns a successful Scan_Result, THE Scanner SHALL display the recyclability status (yes, no, or partially) with a distinct visual indicator for each of the three states so the user can differentiate them at a glance
3. WHEN the Backend returns a successful Scan_Result, THE Scanner SHALL display the Confidence_Score as a percentage value ranging from 0% to 100%, calculated by multiplying the decimal Confidence_Score (0.0–1.0) by 100 and rounding to the nearest whole number
4. WHEN the Backend returns a successful Scan_Result, THE Scanner SHALL display eco impact metrics including estimated weight in kg, CO₂ saved in kg, and landfill diverted in kg, each shown with its numeric value and unit label
5. WHEN the Backend returns a successful Scan_Result, THE Scanner SHALL display the danger level (none, low, medium, or high) with a visual severity indicator that uses escalating visual prominence corresponding to each level so the user can distinguish severity at a glance
6. WHEN the Scan_Result includes a resale value estimate greater than zero, THE Scanner SHALL display the estimated price range showing both the minimum and maximum values with currency denomination
7. WHEN the Backend returns a successful Scan_Result, THE Scanner SHALL display the recommended action (one of: recycle, reuse, sell, pickup, or dispose) and its reasoning text
8. WHEN the Backend returns a successful Scan_Result and the eco tip field is present and non-empty, THE Scanner SHALL display the eco tip text
9. WHEN the Backend returns a successful Scan_Result, THE Scanner SHALL display the eco points earned from the scan and the updated total points balance as integer values
10. IF the Scan_Result eco tip field is absent or empty, THEN THE Scanner SHALL omit the eco tip section without displaying an error or empty placeholder

### Requirement 4: Actionable Recommendations

**User Story:** As a Normal User, I want to act on the scan recommendation directly, so that I can sell, recycle, or schedule a pickup without extra navigation.

#### Acceptance Criteria

1. WHEN the Recommendation is "sell", THE Scanner SHALL display an action button that navigates the user to the Marketplace listing creation screen with the item name, category, estimated value minimum, and estimated value maximum pre-filled from the Scan_Result
2. WHEN the Recommendation is "pickup", THE Scanner SHALL display an action button that navigates the user to the Pickup scheduling screen with the item name and category pre-filled from the Scan_Result
3. WHEN the Recommendation is "recycle", THE Scanner SHALL display an action button that navigates the user to a recycling information view showing the disposal method text from the Scan_Result
4. WHEN the Recommendation is "reuse" or "dispose", THE Scanner SHALL display the disposal method text and eco tip from the Scan_Result as inline guidance without a navigation button
5. IF the user taps an action button and the target module screen fails to load, THEN THE Scanner SHALL display an error message indicating the destination is unavailable and retain the Scan_Result view
6. WHEN the Recommendation is "sell", "pickup", or "recycle", THE Scanner SHALL display the action button within 1 second of the Scan_Result being rendered

### Requirement 5: Scan History

**User Story:** As a Normal User, I want to view my past scans, so that I can review previous results and track my scanning activity.

#### Acceptance Criteria

1. THE Scanner SHALL provide a scan history screen accessible from the AI feature section
2. WHEN the user opens the scan history screen, THE Scanner SHALL fetch the first page of scan records (20 records per page) from the Backend endpoint GET /ai/scan/history, ordered by most recent scan first
3. WHEN scan records are returned, THE Scanner SHALL display each scan as a list item showing the scanned image thumbnail, item name, category, and scan date formatted as a relative timestamp (e.g., "2 hours ago") for scans less than 24 hours old or as a calendar date (e.g., "15 Jan 2025") for older scans
4. WHEN the user scrolls to the end of the currently loaded scan list and more pages are available, THE Scanner SHALL automatically fetch the next page of records and append them to the list
5. WHEN the user taps a scan history item, THE Scanner SHALL fetch the full scan record from the Backend endpoint GET /ai/scan/:id and navigate to a detail view displaying the complete Scan_Result
6. WHILE scan history is loading, THE Scanner SHALL display a loading indicator
7. IF the user has no previous scans, THEN THE Scanner SHALL display an empty state message encouraging the user to perform a first scan
8. IF the scan history fetch fails due to a network or server error, THEN THE Scanner SHALL display an error message indicating the failure and provide a retry option to re-attempt the fetch

### Requirement 6: Eco Points Integration

**User Story:** As a Normal User, I want to earn eco points for each scan, so that I am motivated to scan and recycle more items.

#### Acceptance Criteria

1. WHEN the Backend processes a scan with a Confidence_Score greater than 0.3, THE Backend SHALL award eco points calculated as estimated_weight_kg multiplied by the category point rate (plastic: 10, metal: 20, paper: 8, glass: 6, electronics: 30, organic: 5, textile: 12, mixed: 8, unknown: 5), applying a factor of 1.0 for recyclable items and 0.3 for non-recyclable items, with a minimum of 5 points per scan
2. WHEN eco points are awarded, THE Backend SHALL create an EcoActivity record with type "scan_completed" and a description including the item name and CO₂ saved
3. WHEN eco points are awarded, THE Backend SHALL increment the user total eco_points balance by the awarded points amount
4. IF the Backend processes a scan with a Confidence_Score of 0.3 or below, THEN THE Backend SHALL save the scan record with 0 points earned and SHALL NOT create an EcoActivity record or increment the user eco_points balance
5. WHEN the Scan_Result is displayed, THE Scanner SHALL show the points earned and the updated total points balance within the scan response payload

### Requirement 7: Authentication Guard

**User Story:** As a Normal User, I want my scans to be securely tied to my account, so that only I can view my scan history and earn points.

#### Acceptance Criteria

1. THE Scanner SHALL require a valid JWT token in the request header before allowing image upload
2. WHEN a scan request is sent to the Backend with a valid JWT token, THE Backend SHALL verify the token signature and expiry, confirm the user exists and is active, and associate the scan record with the authenticated user's ID
3. IF the authentication token is missing, expired, or invalid, THEN THE Backend SHALL respond with HTTP 401 status and an error message indicating the authentication failure reason
4. IF the Scanner receives a 401 response from the Backend, THEN THE Scanner SHALL navigate the user to the login screen within 2 seconds and discard any in-progress upload
5. THE Backend SHALL restrict scan history queries and individual scan record access to records belonging to the authenticated user only, returning HTTP 404 for scan IDs that do not belong to the requesting user
6. IF the authenticated user's account is inactive, THEN THE Backend SHALL reject the request with HTTP 401 status and an error message indicating the account is inactive

### Requirement 8: Input Validation and Error Handling

**User Story:** As a Normal User, I want clear feedback when something goes wrong, so that I can understand the issue and take corrective action.

#### Acceptance Criteria

1. IF no image file is provided in the upload request, THEN THE Backend SHALL return HTTP 400 with an error message "No image file provided"
2. IF the uploaded file is not a valid image format (JPEG, PNG, or WebP), THEN THE Backend SHALL reject the request with HTTP 400 and an error message specifying the allowed formats
3. IF the Backend encounters an internal error during scan processing, THEN THE Backend SHALL return HTTP 500 with a descriptive error message and log the error details including timestamp, user ID, and stack trace
4. WHEN the Scanner receives an error response from the Backend, THE Scanner SHALL display a user-friendly error message with an option to retry the scan
5. IF the Confidence_Score is below 0.3, THEN THE Scanner SHALL display a low-confidence warning suggesting the user retake the photo with better lighting or a clearer angle
