# Requirements Document

## Introduction

The FeloNa Backend API is a RESTful API system built with Node.js and Express.js that powers the FeloNa mobile application. The backend provides authentication, marketplace management, pickup coordination, eco-score tracking, and push notification services for three user roles: Normal Users (sellers/waste generators), Buyers/Recyclers, and Collectors. The system uses PostgreSQL for data persistence, JWT for authentication, and Firebase Cloud Messaging for push notifications. The backend enforces role-based access control, validates all inputs, handles image uploads, manages database transactions, and provides paginated responses for list endpoints.

---

## Glossary

- **API**: The FeloNa Backend RESTful API system.
- **Auth_Module**: The Express.js module responsible for user registration, login, JWT generation, and profile management.
- **Marketplace_Module**: The Express.js module responsible for listing CRUD operations, search, filtering, and offer management.
- **Pickup_Module**: The Express.js module responsible for pickup request management, collector assignment, and status tracking.
- **Eco_Score_Module**: The Express.js module responsible for calculating eco points, maintaining point totals, and tracking recycling history.
- **Notification_Module**: The Express.js module responsible for FCM token management and push notification delivery.
- **Database**: The PostgreSQL relational database storing all application data.
- **JWT**: JSON Web Token used for stateless authentication, containing user ID and role claims.
- **FCM**: Firebase Cloud Messaging service used for delivering push notifications to mobile devices.
- **Normal_User**: A user with role "normal_user" who can create listings and pickup requests.
- **Buyer**: A user with role "buyer" who can browse listings and send offers.
- **Collector**: A user with role "collector" who can accept and complete pickup requests.
- **Listing**: A marketplace item posted by a Normal_User, stored in the listings table.
- **Offer**: A price proposal from a Buyer to a Normal_User for a specific Listing, stored in the offers table.
- **Pickup_Request**: A waste collection request created by a Normal_User, stored in the pickup_requests table.
- **Eco_Points**: Integer reward points awarded to Normal_Users for recycling activities.
- **Waste_Category**: An enumeration of waste types: plastic, metal, paper, glass, electronics, other.
- **Pickup_Status**: An enumeration of pickup lifecycle states: pending, accepted, on_the_way, completed.
- **Offer_Status**: An enumeration of offer states: pending, accepted, rejected.
- **Listing_Status**: An enumeration of listing states: active, sold, deleted.
- **Request_Body**: The JSON payload of an HTTP request.
- **Response_Body**: The JSON payload of an HTTP response.
- **Authenticated_Request**: An HTTP request containing a valid JWT in the Authorization header.
- **Multipart_Request**: An HTTP request with Content-Type multipart/form-data for file uploads.
- **Transaction**: A PostgreSQL database transaction ensuring atomicity of multiple operations.

---

## Requirements

### Requirement 1: User Registration

**User Story:** As a new user, I want to register an account via the API, so that I can access the FeloNa system.

#### Acceptance Criteria

1. WHEN a POST request to /api/auth/register is received with a Request_Body containing full_name, email, password, and role fields, THE Auth_Module SHALL validate all fields and create a user record in the Database.
2. THE Auth_Module SHALL accept role values from the set: normal_user, buyer, collector.
3. WHEN a registration request contains an email that already exists in the users table, THE Auth_Module SHALL return HTTP status 409 with an error message indicating the email is already registered.
4. WHEN a registration request contains a password shorter than 8 characters, THE Auth_Module SHALL return HTTP status 400 with a validation error message.
5. WHEN a registration request contains an invalid email format, THE Auth_Module SHALL return HTTP status 400 with a validation error message.
6. WHEN a valid registration request is processed, THE Auth_Module SHALL hash the password using bcrypt with a cost factor of 10 before storing it in the Database.
7. WHEN a user record is successfully created, THE Auth_Module SHALL generate a JWT with user_id and role claims, valid for 30 days, and return HTTP status 201 with the JWT and user profile in the Response_Body.

---

### Requirement 2: User Login

**User Story:** As a registered user, I want to log in via the API, so that I can obtain a JWT for authenticated requests.

#### Acceptance Criteria

1. WHEN a POST request to /api/auth/login is received with a Request_Body containing email and password fields, THE Auth_Module SHALL verify the credentials against the Database.
2. WHEN login credentials match a user record, THE Auth_Module SHALL generate a JWT with user_id and role claims, valid for 30 days, and return HTTP status 200 with the JWT and user profile in the Response_Body.
3. WHEN login credentials do not match any user record, THE Auth_Module SHALL return HTTP status 401 with an error message indicating invalid credentials without specifying which field is incorrect.
4. THE Auth_Module SHALL use bcrypt to compare the provided password with the hashed password stored in the Database.
5. WHEN a login request contains missing or empty email or password fields, THE Auth_Module SHALL return HTTP status 400 with a validation error message.

---

### Requirement 3: JWT Authentication Middleware

**User Story:** As a backend developer, I want a middleware to validate JWTs, so that protected endpoints can verify user identity and role.

#### Acceptance Criteria

1. WHEN an Authenticated_Request is received at a protected endpoint, THE API SHALL extract the JWT from the Authorization header using the Bearer scheme.
2. WHEN a JWT is successfully verified, THE API SHALL decode the user_id and role claims and attach them to the request context for use by downstream handlers.
3. WHEN a JWT is missing from an Authenticated_Request, THE API SHALL return HTTP status 401 with an error message indicating authentication is required.
4. WHEN a JWT signature is invalid or the token has expired, THE API SHALL return HTTP status 401 with an error message indicating the token is invalid or expired.
5. THE API SHALL use the same secret key for JWT verification that was used for JWT generation during login and registration.

---

### Requirement 4: Profile Management

**User Story:** As a registered user, I want to update my profile via the API, so that I can keep my information current.

#### Acceptance Criteria

1. WHEN a PUT request to /api/auth/profile is received as an Authenticated_Request with a Request_Body containing full_name or phone_number fields, THE Auth_Module SHALL update the corresponding user record in the Database.
2. WHEN a profile update is successful, THE Auth_Module SHALL return HTTP status 200 with the updated user profile in the Response_Body.
3. WHEN a GET request to /api/auth/profile is received as an Authenticated_Request, THE Auth_Module SHALL return HTTP status 200 with the current user profile including user_id, full_name, email, role, phone_number, profile_picture_url, and created_at timestamp.
4. IF a user attempts to update the email or role fields, THEN THE Auth_Module SHALL ignore those fields and only update allowed fields.

---

### Requirement 5: Profile Picture Upload

**User Story:** As a registered user, I want to upload a profile picture via the API, so that other users can identify me.

#### Acceptance Criteria

1. WHEN a POST request to /api/auth/profile/picture is received as an Authenticated_Request and Multipart_Request containing an image file, THE Auth_Module SHALL validate the file type and size.
2. THE Auth_Module SHALL accept image files with MIME types image/jpeg or image/png.
3. WHEN an uploaded image exceeds 5 MB, THE Auth_Module SHALL return HTTP status 400 with an error message indicating the file size limit.
4. WHEN an uploaded image has an unsupported MIME type, THE Auth_Module SHALL return HTTP status 400 with an error message indicating the allowed file types.
5. WHEN a valid image is uploaded, THE Auth_Module SHALL store the file in a designated uploads directory with a unique filename, update the user's profile_picture_url in the Database, and return HTTP status 200 with the new profile_picture_url in the Response_Body.
6. WHEN a user uploads a new profile picture, THE Auth_Module SHALL delete the previous profile picture file from the uploads directory if one exists.

---

### Requirement 6: Listing Creation

**User Story:** As a Normal_User, I want to create item listings via the API, so that Buyers can discover and purchase my items.

#### Acceptance Criteria

1. WHEN a POST request to /api/listings is received as an Authenticated_Request and Multipart_Request containing title, description, price, category fields and between 1 and 5 image files, THE Marketplace_Module SHALL validate all fields and create a listing record in the Database.
2. THE Marketplace_Module SHALL verify the authenticated user has role normal_user before allowing listing creation.
3. IF a user with role buyer or collector attempts to create a listing, THEN THE Marketplace_Module SHALL return HTTP status 403 with an error message indicating insufficient permissions.
4. WHEN a listing creation request contains more than 5 images, THE Marketplace_Module SHALL return HTTP status 400 with an error message indicating the maximum image count.
5. WHEN a listing creation request contains zero images, THE Marketplace_Module SHALL return HTTP status 400 with an error message indicating at least one image is required.
6. THE Marketplace_Module SHALL accept image files with MIME types image/jpeg or image/png, each with a maximum size of 10 MB.
7. WHEN a listing creation request contains a price less than or equal to zero, THE Marketplace_Module SHALL return HTTP status 400 with a validation error message.
8. WHEN a valid listing is created, THE Marketplace_Module SHALL store all images with unique filenames, create a listing record with status active, and return HTTP status 201 with the listing object including listing_id, title, description, price, category, image_urls array, seller_id, seller_name, status, and created_at timestamp.

---

### Requirement 7: Listing Retrieval and Feed

**User Story:** As a Buyer, I want to retrieve listings via the API, so that I can browse available items.

#### Acceptance Criteria

1. WHEN a GET request to /api/listings is received with optional query parameters page and limit, THE Marketplace_Module SHALL return a paginated list of listings with status active, ordered by created_at descending.
2. THE Marketplace_Module SHALL default to page 1 and limit 20 when query parameters are not provided.
3. THE Marketplace_Module SHALL enforce a maximum limit of 50 listings per page.
4. WHEN a GET request to /api/listings/:id is received, THE Marketplace_Module SHALL return HTTP status 200 with the listing object if the listing exists, or HTTP status 404 if the listing does not exist.
5. THE Marketplace_Module SHALL include pagination metadata in the Response_Body containing current_page, total_pages, total_items, and items_per_page fields.
6. THE Marketplace_Module SHALL exclude listings with status deleted from all public listing endpoints.

---

### Requirement 8: Listing Search and Filtering

**User Story:** As a Buyer, I want to search and filter listings via the API, so that I can find specific items.

#### Acceptance Criteria

1. WHEN a GET request to /api/listings is received with a query parameter keyword, THE Marketplace_Module SHALL return only listings where the title or description contains the keyword using case-insensitive matching.
2. WHEN a GET request to /api/listings is received with a query parameter category, THE Marketplace_Module SHALL return only listings matching that category.
3. WHEN a GET request to /api/listings is received with a query parameter max_price, THE Marketplace_Module SHALL return only listings with price less than or equal to the specified max_price.
4. WHEN multiple filter parameters are provided, THE Marketplace_Module SHALL apply all filters using AND logic.
5. THE Marketplace_Module SHALL return an empty items array when no listings match the search and filter criteria.

---

### Requirement 9: Listing Update and Deletion

**User Story:** As a Normal_User, I want to update or delete my listings via the API, so that I can manage my marketplace presence.

#### Acceptance Criteria

1. WHEN a PUT request to /api/listings/:id is received as an Authenticated_Request with a Request_Body containing title, description, price, or category fields, THE Marketplace_Module SHALL verify the authenticated user owns the listing.
2. IF a user attempts to update a listing they do not own, THEN THE Marketplace_Module SHALL return HTTP status 403 with an error message indicating insufficient permissions.
3. WHEN a listing update is successful, THE Marketplace_Module SHALL update the listing record in the Database and return HTTP status 200 with the updated listing object.
4. WHEN a DELETE request to /api/listings/:id is received as an Authenticated_Request, THE Marketplace_Module SHALL verify the authenticated user owns the listing, update the listing status to deleted, and return HTTP status 200 with a success message.
5. THE Marketplace_Module SHALL not allow updates to listings with status sold or deleted.
6. WHEN a user attempts to update or delete a non-existent listing, THE Marketplace_Module SHALL return HTTP status 404 with an error message.

---

### Requirement 10: Offer Creation

**User Story:** As a Buyer, I want to send offers on listings via the API, so that I can negotiate purchases.

#### Acceptance Criteria

1. WHEN a POST request to /api/offers is received as an Authenticated_Request with a Request_Body containing listing_id and proposed_price fields, THE Marketplace_Module SHALL validate the fields and create an offer record in the Database.
2. THE Marketplace_Module SHALL verify the authenticated user has role buyer before allowing offer creation.
3. IF a user with role normal_user or collector attempts to create an offer, THEN THE Marketplace_Module SHALL return HTTP status 403 with an error message indicating insufficient permissions.
4. WHEN an offer creation request contains a proposed_price less than or equal to zero, THE Marketplace_Module SHALL return HTTP status 400 with a validation error message.
5. WHEN an offer is created for a listing with status sold or deleted, THE Marketplace_Module SHALL return HTTP status 400 with an error message indicating the listing is no longer available.
6. WHEN a valid offer is created, THE Marketplace_Module SHALL create an offer record with status pending, trigger a notification to the listing owner, and return HTTP status 201 with the offer object including offer_id, listing_id, buyer_id, buyer_name, proposed_price, status, and created_at timestamp.

---

### Requirement 11: Offer Management

**User Story:** As a Normal_User, I want to accept or reject offers via the API, so that I can complete sales.

#### Acceptance Criteria

1. WHEN a PUT request to /api/offers/:id/accept is received as an Authenticated_Request, THE Marketplace_Module SHALL verify the authenticated user owns the listing associated with the offer.
2. WHEN an offer is accepted, THE Marketplace_Module SHALL execute a Transaction that updates the offer status to accepted, updates all other offers on the same listing to status rejected, updates the listing status to sold, and commits all changes atomically.
3. IF the Transaction fails, THEN THE Marketplace_Module SHALL rollback all changes and return HTTP status 500 with an error message.
4. WHEN a PUT request to /api/offers/:id/reject is received as an Authenticated_Request, THE Marketplace_Module SHALL verify the authenticated user owns the listing associated with the offer, update the offer status to rejected, and return HTTP status 200.
5. WHEN an offer status changes to accepted or rejected, THE Marketplace_Module SHALL trigger a notification to the Buyer who created the offer.
6. THE Marketplace_Module SHALL not allow status changes to offers that are already accepted or rejected.

---

### Requirement 12: Offer Retrieval

**User Story:** As a user, I want to retrieve offers via the API, so that I can view sent or received offers.

#### Acceptance Criteria

1. WHEN a GET request to /api/listings/:id/offers is received as an Authenticated_Request, THE Marketplace_Module SHALL verify the authenticated user owns the listing and return all offers for that listing ordered by created_at descending.
2. WHEN a GET request to /api/offers/sent is received as an Authenticated_Request, THE Marketplace_Module SHALL return all offers created by the authenticated Buyer ordered by created_at descending.
3. THE Marketplace_Module SHALL include listing details in the offer response objects for the /api/offers/sent endpoint.
4. IF a user attempts to view offers for a listing they do not own, THEN THE Marketplace_Module SHALL return HTTP status 403 with an error message.

---

### Requirement 13: Pickup Request Creation

**User Story:** As a Normal_User, I want to create pickup requests via the API, so that Collectors can collect my waste materials.

#### Acceptance Criteria

1. WHEN a POST request to /api/pickups is received as an Authenticated_Request with a Request_Body containing waste_category, estimated_weight_kg, and pickup_address fields, THE Pickup_Module SHALL validate all fields and create a pickup request record in the Database.
2. THE Pickup_Module SHALL verify the authenticated user has role normal_user before allowing pickup request creation.
3. THE Pickup_Module SHALL accept waste_category values from the set: plastic, metal, paper, glass, electronics, other.
4. WHEN a pickup request contains an estimated_weight_kg less than or equal to zero, THE Pickup_Module SHALL return HTTP status 400 with a validation error message.
5. WHEN a pickup request contains an empty pickup_address field, THE Pickup_Module SHALL return HTTP status 400 with a validation error message.
6. WHEN a valid pickup request is created, THE Pickup_Module SHALL create a pickup request record with status pending, and return HTTP status 201 with the pickup request object including pickup_id, waste_category, estimated_weight_kg, pickup_address, status, requester_id, requester_name, and created_at timestamp.

---

### Requirement 14: Pickup Request Feed

**User Story:** As a Collector, I want to retrieve pending pickup requests via the API, so that I can find jobs to accept.

#### Acceptance Criteria

1. WHEN a GET request to /api/pickups/pending is received as an Authenticated_Request, THE Pickup_Module SHALL verify the authenticated user has role collector and return all pickup requests with status pending ordered by created_at ascending.
2. THE Pickup_Module SHALL include requester contact information in the pickup request response objects.
3. IF a user with role normal_user or buyer attempts to access the pending pickup feed, THEN THE Pickup_Module SHALL return HTTP status 403 with an error message indicating insufficient permissions.

---

### Requirement 15: Pickup Request Acceptance

**User Story:** As a Collector, I want to accept pickup requests via the API, so that I can claim jobs.

#### Acceptance Criteria

1. WHEN a PUT request to /api/pickups/:id/accept is received as an Authenticated_Request, THE Pickup_Module SHALL verify the authenticated user has role collector and the pickup request has status pending.
2. WHEN a pickup request is accepted, THE Pickup_Module SHALL update the pickup request status to accepted, assign the collector_id to the authenticated user, trigger a notification to the requester, and return HTTP status 200 with the updated pickup request object.
3. WHEN a Collector attempts to accept a pickup request with status accepted, on_the_way, or completed, THE Pickup_Module SHALL return HTTP status 400 with an error message indicating the request is no longer available.
4. THE Pickup_Module SHALL include the Collector's name and phone number in the pickup request response after acceptance.

---

### Requirement 16: Pickup Status Updates

**User Story:** As a Collector, I want to update pickup status via the API, so that requesters can track progress.

#### Acceptance Criteria

1. WHEN a PUT request to /api/pickups/:id/status is received as an Authenticated_Request with a Request_Body containing a status field, THE Pickup_Module SHALL verify the authenticated user is the assigned Collector.
2. THE Pickup_Module SHALL enforce the status transition sequence: pending → accepted → on_the_way → completed.
3. WHEN a status update violates the transition sequence, THE Pickup_Module SHALL return HTTP status 400 with an error message indicating the invalid transition.
4. WHEN a pickup request status is updated to on_the_way, THE Pickup_Module SHALL update the status in the Database, trigger a notification to the requester, and return HTTP status 200.
5. WHEN a pickup request status is updated to completed, THE Pickup_Module SHALL execute a Transaction that updates the status, triggers eco-point calculation, and commits all changes atomically.
6. IF a Collector who is not assigned to a pickup request attempts to update its status, THEN THE Pickup_Module SHALL return HTTP status 403 with an error message.

---

### Requirement 17: Pickup Request Retrieval

**User Story:** As a Normal_User, I want to retrieve my pickup requests via the API, so that I can track their status.

#### Acceptance Criteria

1. WHEN a GET request to /api/pickups/my-requests is received as an Authenticated_Request, THE Pickup_Module SHALL verify the authenticated user has role normal_user and return all pickup requests created by that user ordered by created_at descending.
2. WHEN a GET request to /api/pickups/:id is received as an Authenticated_Request, THE Pickup_Module SHALL return HTTP status 200 with the pickup request object if the user is either the requester or the assigned Collector, or HTTP status 403 if the user is neither.
3. THE Pickup_Module SHALL include Collector details in the pickup request response when the status is accepted, on_the_way, or completed.

---

### Requirement 18: Collector Job Tracking

**User Story:** As a Collector, I want to retrieve my accepted jobs via the API, so that I can manage my workload.

#### Acceptance Criteria

1. WHEN a GET request to /api/pickups/my-jobs is received as an Authenticated_Request, THE Pickup_Module SHALL verify the authenticated user has role collector and return all pickup requests assigned to that Collector ordered by created_at descending.
2. THE Pickup_Module SHALL support filtering by status using a query parameter status.
3. WHEN a GET request to /api/pickups/my-jobs/stats is received as an Authenticated_Request, THE Pickup_Module SHALL return statistics including total_completed_jobs and total_earnings calculated as the sum of estimated_weight_kg multiplied by a rate of 0.5 currency units per kilogram for all completed jobs.

---

### Requirement 19: Eco Points Calculation

**User Story:** As a Normal_User, I want eco points automatically calculated via the API, so that my recycling contributions are tracked.

#### Acceptance Criteria

1. WHEN a pickup request transitions to status completed, THE Eco_Score_Module SHALL calculate eco points as floor(estimated_weight_kg × 10) and add the points to the requester's total.
2. WHEN an offer is accepted and a listing transitions to status sold, THE Eco_Score_Module SHALL add 5 eco points to the listing owner's total.
3. THE Eco_Score_Module SHALL maintain a cumulative eco_points field in the users table that is never decremented.
4. THE Eco_Score_Module SHALL create an eco_points_history record for each point-earning event containing user_id, points_earned, event_type (pickup_completed or item_sold), event_id (pickup_id or listing_id), and created_at timestamp.

---

### Requirement 20: Eco Score Retrieval

**User Story:** As a Normal_User, I want to retrieve my eco score via the API, so that I can view my environmental impact.

#### Acceptance Criteria

1. WHEN a GET request to /api/eco-score is received as an Authenticated_Request, THE Eco_Score_Module SHALL return HTTP status 200 with a Response_Body containing total_eco_points, total_weight_recycled_kg (sum of estimated_weight_kg for all completed pickup requests), and total_items_sold (count of listings with status sold).
2. WHEN a GET request to /api/eco-score/history is received as an Authenticated_Request, THE Eco_Score_Module SHALL return a paginated list of eco_points_history records for the authenticated user ordered by created_at descending.
3. THE Eco_Score_Module SHALL include event details in the history response, such as waste_category for pickup events and listing_title for item_sold events.

---

### Requirement 21: Eco Score Leaderboard

**User Story:** As a Normal_User, I want to view a leaderboard via the API, so that I can compare my eco score with other users.

#### Acceptance Criteria

1. WHEN a GET request to /api/eco-score/leaderboard is received, THE Eco_Score_Module SHALL return the top 100 Normal_Users ordered by total_eco_points descending.
2. THE Eco_Score_Module SHALL include user_id, full_name, profile_picture_url, and total_eco_points for each leaderboard entry.
3. THE Eco_Score_Module SHALL exclude users with role buyer or collector from the leaderboard.
4. THE Eco_Score_Module SHALL include the authenticated user's rank and score in the Response_Body even if they are not in the top 100.

---

### Requirement 22: FCM Token Registration

**User Story:** As a mobile app user, I want to register my FCM token via the API, so that I can receive push notifications.

#### Acceptance Criteria

1. WHEN a POST request to /api/notifications/register-token is received as an Authenticated_Request with a Request_Body containing an fcm_token field, THE Notification_Module SHALL store or update the fcm_token for the authenticated user in the Database.
2. WHEN a user logs in from multiple devices, THE Notification_Module SHALL store multiple fcm_tokens associated with the same user_id.
3. WHEN a DELETE request to /api/notifications/unregister-token is received as an Authenticated_Request with a Request_Body containing an fcm_token field, THE Notification_Module SHALL remove that fcm_token from the Database.

---

### Requirement 23: Push Notification Delivery

**User Story:** As a user, I want to receive push notifications via FCM, so that I am informed of important events.

#### Acceptance Criteria

1. WHEN a new offer is created, THE Notification_Module SHALL send a push notification to all fcm_tokens associated with the listing owner within 30 seconds.
2. WHEN a pickup request is accepted, THE Notification_Module SHALL send a push notification to all fcm_tokens associated with the requester within 30 seconds.
3. WHEN a pickup request status changes to on_the_way or completed, THE Notification_Module SHALL send a push notification to all fcm_tokens associated with the requester within 30 seconds.
4. WHEN an offer status changes to accepted or rejected, THE Notification_Module SHALL send a push notification to all fcm_tokens associated with the Buyer within 30 seconds.
5. THE Notification_Module SHALL include a notification title, body, and data payload containing event_type and event_id fields in each push notification.
6. IF FCM returns an error indicating an invalid or expired token, THEN THE Notification_Module SHALL remove that fcm_token from the Database.

---

### Requirement 24: Input Validation Middleware

**User Story:** As a backend developer, I want centralized input validation, so that all endpoints reject malformed requests consistently.

#### Acceptance Criteria

1. THE API SHALL validate all Request_Body fields against expected types and constraints before processing requests.
2. WHEN a request contains unexpected fields, THE API SHALL ignore those fields and process only recognized fields.
3. WHEN a request is missing required fields, THE API SHALL return HTTP status 400 with an error message listing the missing fields.
4. WHEN a request contains fields with invalid types, THE API SHALL return HTTP status 400 with an error message indicating the expected type for each invalid field.
5. THE API SHALL sanitize all string inputs to prevent SQL injection by using parameterized queries for all Database operations.

---

### Requirement 25: Error Handling and Logging

**User Story:** As a backend developer, I want consistent error handling and logging, so that I can diagnose issues and maintain system reliability.

#### Acceptance Criteria

1. WHEN an unhandled exception occurs during request processing, THE API SHALL return HTTP status 500 with a generic error message without exposing internal implementation details.
2. THE API SHALL log all errors to the console or a log file with a timestamp, request path, HTTP method, user_id (if authenticated), and error stack trace.
3. THE API SHALL log all incoming requests with timestamp, HTTP method, request path, and response status code.
4. WHEN a Database query fails, THE API SHALL log the error details and return HTTP status 500 with a generic error message.
5. THE API SHALL return error responses in a consistent JSON format containing status, message, and optionally errors array fields.

---

### Requirement 26: CORS Configuration

**User Story:** As a mobile app developer, I want the API to support CORS, so that the mobile app can make requests from any origin during development.

#### Acceptance Criteria

1. THE API SHALL include CORS headers in all HTTP responses allowing requests from any origin.
2. THE API SHALL support preflight OPTIONS requests for all endpoints.
3. THE API SHALL include Access-Control-Allow-Origin, Access-Control-Allow-Methods, and Access-Control-Allow-Headers in CORS responses.
4. WHERE the API is deployed to production, THE API SHALL restrict Access-Control-Allow-Origin to the mobile app's registered domain.

---

### Requirement 27: Rate Limiting

**User Story:** As a system administrator, I want rate limiting on API endpoints, so that the system is protected from abuse.

#### Acceptance Criteria

1. THE API SHALL enforce a rate limit of 100 requests per 15-minute window per IP address for all endpoints.
2. WHEN a client exceeds the rate limit, THE API SHALL return HTTP status 429 with a Retry-After header indicating when the client can retry.
3. THE API SHALL use an in-memory store to track request counts per IP address.
4. THE API SHALL exclude health check endpoints from rate limiting.

---

### Requirement 28: Database Connection Management

**User Story:** As a backend developer, I want reliable database connection management, so that the API can handle concurrent requests efficiently.

#### Acceptance Criteria

1. THE API SHALL establish a connection pool to the Database on startup with a minimum of 5 connections and a maximum of 20 connections.
2. WHEN all connections in the pool are in use, THE API SHALL queue incoming requests until a connection becomes available or a timeout of 30 seconds is reached.
3. WHEN a Database connection timeout occurs, THE API SHALL return HTTP status 503 with an error message indicating the service is temporarily unavailable.
4. THE API SHALL gracefully close all Database connections when the server shuts down.

---

### Requirement 29: Health Check Endpoint

**User Story:** As a system administrator, I want a health check endpoint, so that I can monitor the API's availability.

#### Acceptance Criteria

1. WHEN a GET request to /api/health is received, THE API SHALL return HTTP status 200 with a Response_Body containing status field set to "healthy" and a timestamp field.
2. THE API SHALL verify Database connectivity as part of the health check.
3. WHEN the Database is unreachable, THE API SHALL return HTTP status 503 with status field set to "unhealthy" and an error message.

---

### Requirement 30: Static File Serving

**User Story:** As a mobile app developer, I want to retrieve uploaded images via HTTP, so that I can display them in the app.

#### Acceptance Criteria

1. THE API SHALL serve uploaded images from the /uploads directory via the /api/uploads/:filename endpoint.
2. WHEN a GET request to /api/uploads/:filename is received, THE API SHALL return the file with the appropriate Content-Type header based on the file extension.
3. WHEN a requested file does not exist, THE API SHALL return HTTP status 404.
4. THE API SHALL set Cache-Control headers on image responses to allow browser caching for 7 days.
