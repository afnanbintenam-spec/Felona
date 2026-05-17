# Implementation Plan: FeloNa Backend API

## Overview

This implementation plan breaks down the FeloNa Backend API into discrete coding tasks. The system is built with Node.js and Express.js, using PostgreSQL for data persistence, JWT for authentication, and Firebase Cloud Messaging for push notifications. The implementation follows a modular architecture with five core modules: Authentication, Marketplace, Pickup, Eco-Score, and Notifications.

## Tasks

- [ ] 1. Set up project structure and core infrastructure
  - Initialize Node.js project with Express.js
  - Install dependencies: express, pg, jsonwebtoken, bcrypt, multer, firebase-admin, express-validator, cors, express-rate-limit, winston/morgan
  - Create directory structure: src/config, src/middleware, src/modules, src/utils, uploads/profiles, uploads/listings
  - Set up .env file with environment variables (DB credentials, JWT secret, Firebase config)
  - Create database connection pool configuration (src/config/database.js)
  - Initialize Firebase Admin SDK (src/config/firebase.js)
  - Create JWT configuration (src/config/jwt.js)
  - Set up Express app with middleware stack (CORS, rate limiting, body parsers, static file serving)
  - Create server entry point (src/server.js)
  - _Requirements: 25.1, 25.2, 25.3, 27.1, 30.1_

- [ ] 2. Create database schema and migrations
  - Create PostgreSQL migration for users table with indexes
  - Create PostgreSQL migration for listings table with indexes
  - Create PostgreSQL migration for offers table with indexes
  - Create PostgreSQL migration for pickup_requests table with indexes
  - Create PostgreSQL migration for eco_points_history table with indexes
  - Create PostgreSQL migration for fcm_tokens table with indexes
  - Run migrations to set up database schema
  - _Requirements: 1.1, 6.1, 10.1, 13.1, 19.4, 22.1_

- [ ] 3. Implement core middleware components
  - [ ] 3.1 Create JWT authentication middleware (src/middleware/auth.js)
    - Extract JWT from Authorization header using Bearer scheme
    - Verify JWT signature and expiration
    - Decode user_id and role claims and attach to request context
    - Handle missing, invalid, or expired tokens with 401 responses
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

  - [ ]* 3.2 Write property tests for JWT authentication middleware
    - **Property 5: JWT Round-Trip Integrity**
    - **Property 6: JWT Expiration Validation**
    - **Property 7: Authorization Header Parsing**
    - **Validates: Requirements 1.7, 2.2, 3.1, 3.2, 3.3, 3.4, 3.5**

  - [ ] 3.3 Create role-based access control middleware (src/middleware/roleCheck.js)
    - Implement requireRole function accepting allowed roles
    - Verify authenticated user's role matches allowed roles
    - Return 403 for insufficient permissions
    - _Requirements: 6.2, 10.2, 13.2, 14.1_

  - [ ]* 3.4 Write property tests for role validation
    - **Property 1: Role Validation**
    - **Validates: Requirements 1.2, 6.2, 10.2, 13.2, 14.1**

  - [ ] 3.5 Create input validation middleware (src/middleware/validation.js)
    - Implement validateRequest function using express-validator
    - Return 400 with field-specific errors for validation failures
    - Filter unexpected fields and process only recognized fields
    - _Requirements: 24.1, 24.2, 24.3, 24.4_

  - [ ]* 3.6 Write property tests for input validation
    - **Property 2: Email Format Validation**
    - **Property 3: Password Length Validation**
    - **Property 46: Unexpected Field Filtering**
    - **Property 47: Missing Required Fields Error**
    - **Property 48: Type Validation Error**
    - **Validates: Requirements 1.4, 1.5, 24.2, 24.3, 24.4**

  - [ ] 3.7 Create file upload middleware (src/middleware/upload.js)
    - Configure Multer storage with unique filename generation
    - Implement file filter for MIME type validation (image/jpeg, image/png)
    - Set up uploadProfile with 5 MB limit
    - Set up uploadListingImages with 10 MB limit and 5 file maximum
    - _Requirements: 5.1, 5.2, 5.3, 6.4, 6.5, 6.6_

  - [ ]* 3.8 Write property tests for file validation
    - **Property 9: File Type Validation**
    - **Property 10: File Size Validation**
    - **Property 11: Image Count Validation**
    - **Property 13: Unique Filename Generation**
    - **Validates: Requirements 5.2, 5.3, 5.4, 6.4, 6.5, 6.6**

  - [ ] 3.9 Create global error handling middleware (src/middleware/errorHandler.js)
    - Log all errors with timestamp, path, method, user_id, error message, and stack trace
    - Handle Multer errors (LIMIT_FILE_SIZE, LIMIT_FILE_COUNT)
    - Handle database errors (constraint violations, query failures)
    - Return consistent error response format with status and message
    - Return 500 with generic message for unhandled exceptions
    - _Requirements: 25.1, 25.2, 25.4, 25.5_

  - [ ]* 3.10 Write property tests for error handling
    - **Property 49: Generic Error Response**
    - **Property 50: Error Logging Completeness**
    - **Property 52: Consistent Error Response Format**
    - **Validates: Requirements 25.1, 25.2, 25.5**

- [ ] 4. Checkpoint - Ensure middleware tests pass
  - Ensure all tests pass, ask the user if questions arise.


- [ ] 5. Implement Authentication Module
  - [ ] 5.1 Create authentication service layer (src/modules/auth/auth.service.js)
    - Implement user registration with bcrypt password hashing (cost factor 10)
    - Implement user login with password verification
    - Implement JWT generation with user_id and role claims (30-day expiration)
    - Implement profile retrieval by user_id
    - Implement profile update with field filtering (allow full_name, phone_number only)
    - Implement profile picture upload with previous file deletion
    - _Requirements: 1.1, 1.6, 1.7, 2.1, 2.2, 2.4, 4.1, 4.3, 4.4, 5.5, 5.6_

  - [ ]* 5.2 Write property tests for authentication service
    - **Property 4: Password Hashing Verification**
    - **Property 8: Protected Field Filtering**
    - **Property 14: Previous File Deletion**
    - **Validates: Requirements 1.6, 2.4, 4.4, 5.6**

  - [ ] 5.3 Create authentication controller (src/modules/auth/auth.controller.js)
    - Implement register endpoint handler with validation
    - Implement login endpoint handler with credential verification
    - Implement profile GET endpoint handler
    - Implement profile PUT endpoint handler
    - Implement profile picture POST endpoint handler
    - Handle duplicate email errors (409), validation errors (400), invalid credentials (401)
    - _Requirements: 1.3, 1.4, 1.5, 2.3, 2.5, 4.2, 5.3, 5.4_

  - [ ] 5.4 Create authentication routes (src/modules/auth/auth.routes.js)
    - Define POST /api/auth/register with validation rules
    - Define POST /api/auth/login with validation rules
    - Define GET /api/auth/profile with JWT authentication
    - Define PUT /api/auth/profile with JWT authentication and validation
    - Define POST /api/auth/profile/picture with JWT authentication and file upload
    - _Requirements: 1.1, 2.1, 4.1, 4.3, 5.1_

  - [ ]* 5.5 Write unit tests for authentication endpoints
    - Test registration success, duplicate email, validation errors
    - Test login success, invalid credentials, missing fields
    - Test profile retrieval authenticated and unauthenticated
    - Test profile update with field filtering
    - Test profile picture upload with file validation

- [ ] 6. Implement Marketplace Module - Listings
  - [ ] 6.1 Create listings service layer (src/modules/marketplace/listings.service.js)
    - Implement listing creation with image storage
    - Implement paginated listing feed with default page=1, limit=20, max limit=50
    - Implement listing search by keyword (case-insensitive title/description match)
    - Implement listing filtering by category and max_price with AND logic
    - Implement listing retrieval by ID
    - Implement listing update with ownership verification
    - Implement listing soft delete (status update to "deleted")
    - Exclude deleted listings from all queries
    - _Requirements: 6.1, 6.8, 7.1, 7.2, 7.3, 7.6, 8.1, 8.2, 8.3, 8.4, 9.1, 9.3, 9.4_

  - [ ]* 6.2 Write property tests for listings service
    - **Property 12: Price Validation**
    - **Property 15: Pagination Correctness**
    - **Property 16: Maximum Limit Enforcement**
    - **Property 17: Deleted Listing Exclusion**
    - **Property 18: Keyword Search Correctness**
    - **Property 19: Category Filter Correctness**
    - **Property 20: Price Filter Correctness**
    - **Property 21: Combined Filter AND Logic**
    - **Property 22: Ownership Verification**
    - **Property 23: Soft Delete Behavior**
    - **Property 24: Status-Based Update Restriction**
    - **Validates: Requirements 6.7, 7.1, 7.2, 7.3, 7.6, 8.1, 8.2, 8.3, 8.4, 9.1, 9.2, 9.4, 9.5**

  - [ ] 6.3 Create listings controller (src/modules/marketplace/listings.controller.js)
    - Implement POST /listings handler with role check (normal_user only)
    - Implement GET /listings handler with pagination and filters
    - Implement GET /listings/:id handler with 404 for not found
    - Implement PUT /listings/:id handler with ownership and status checks
    - Implement DELETE /listings/:id handler with ownership check
    - Return pagination metadata (current_page, total_pages, total_items, items_per_page)
    - Handle validation errors, permission errors (403), not found errors (404)
    - _Requirements: 6.3, 7.4, 7.5, 8.5, 9.2, 9.5, 9.6_

  - [ ] 6.4 Create listings routes (src/modules/marketplace/listings.routes.js)
    - Define POST /api/listings with JWT auth, role check, file upload, validation
    - Define GET /api/listings with optional query parameters
    - Define GET /api/listings/:id
    - Define PUT /api/listings/:id with JWT auth, validation
    - Define DELETE /api/listings/:id with JWT auth
    - _Requirements: 6.1, 7.1, 9.1, 9.4_

  - [ ]* 6.5 Write unit tests for listings endpoints
    - Test listing creation with images, role check, validation errors
    - Test listing feed with pagination, search, filters
    - Test listing retrieval by ID (found, not found)
    - Test listing update with ownership check, status restrictions
    - Test listing soft delete with ownership check

- [ ] 7. Checkpoint - Ensure authentication and listings tests pass
  - Ensure all tests pass, ask the user if questions arise.


- [ ] 8. Implement Marketplace Module - Offers
  - [ ] 8.1 Create offers service layer (src/modules/marketplace/offers.service.js)
    - Implement offer creation with listing status validation
    - Implement offer acceptance with transaction (update offer, reject others, update listing)
    - Implement offer rejection with ownership verification
    - Implement offer retrieval by listing_id with ownership check
    - Implement offer retrieval by buyer_id (sent offers)
    - Prevent status changes to already accepted/rejected offers
    - _Requirements: 10.1, 10.5, 11.1, 11.2, 11.4, 11.6, 12.1, 12.2_

  - [ ]* 8.2 Write property tests for offers service
    - **Property 25: Listing Status Validation for Offers**
    - **Property 26: Offer Acceptance Transaction Atomicity**
    - **Property 27: Offer Status Immutability**
    - **Validates: Requirements 10.5, 11.2, 11.3, 11.6**

  - [ ] 8.3 Create offers controller (src/modules/marketplace/offers.controller.js)
    - Implement POST /offers handler with role check (buyer only)
    - Implement PUT /offers/:id/accept handler with ownership check
    - Implement PUT /offers/:id/reject handler with ownership check
    - Implement GET /listings/:id/offers handler with ownership check
    - Implement GET /offers/sent handler for buyer's offers
    - Trigger notifications on offer creation, acceptance, rejection
    - Handle validation errors, permission errors (403), transaction failures (500)
    - _Requirements: 10.3, 10.6, 11.3, 11.5, 12.3, 12.4_

  - [ ] 8.4 Create offers routes (src/modules/marketplace/offers.routes.js)
    - Define POST /api/offers with JWT auth, role check, validation
    - Define PUT /api/offers/:id/accept with JWT auth
    - Define PUT /api/offers/:id/reject with JWT auth
    - Define GET /api/listings/:id/offers with JWT auth
    - Define GET /api/offers/sent with JWT auth
    - _Requirements: 10.1, 11.1, 11.4, 12.1, 12.2_

  - [ ]* 8.5 Write unit tests for offers endpoints
    - Test offer creation with role check, listing status validation
    - Test offer acceptance with transaction atomicity, ownership check
    - Test offer rejection with ownership check
    - Test offer retrieval by listing (ownership check)
    - Test sent offers retrieval

- [ ] 9. Implement Pickup Module
  - [ ] 9.1 Create pickup service layer (src/modules/pickup/pickup.service.js)
    - Implement pickup request creation with validation
    - Implement pending pickup feed for collectors
    - Implement pickup acceptance with collector assignment
    - Implement pickup status updates with transition validation (pending → accepted → on_the_way → completed)
    - Implement pickup completion with transaction (update status, calculate eco-points, update user total, create history)
    - Implement pickup retrieval by requester_id
    - Implement pickup retrieval by collector_id with status filtering
    - Implement collector statistics calculation (total jobs, total earnings)
    - Implement pickup access control (requester or assigned collector only)
    - _Requirements: 13.1, 13.4, 13.5, 14.1, 15.1, 15.2, 16.1, 16.2, 16.5, 17.1, 17.2, 18.1, 18.2, 18.3_

  - [ ]* 9.2 Write property tests for pickup service
    - **Property 28: Waste Category Validation**
    - **Property 29: Weight Validation**
    - **Property 30: Address Required Field Validation**
    - **Property 31: Pickup Status Transition Validation**
    - **Property 32: Pickup Completion Transaction Atomicity**
    - **Property 33: Pickup Access Control**
    - **Property 34: Conditional Collector Data Inclusion**
    - **Property 35: Pickup Status Filtering**
    - **Property 36: Collector Statistics Calculation**
    - **Validates: Requirements 13.3, 13.4, 13.5, 16.2, 16.3, 16.5, 17.2, 17.3, 18.2, 18.3, 19.1, 19.4**

  - [ ] 9.3 Create pickup controller (src/modules/pickup/pickup.controller.js)
    - Implement POST /pickups handler with role check (normal_user only)
    - Implement GET /pickups/pending handler with role check (collector only)
    - Implement PUT /pickups/:id/accept handler with role check and status validation
    - Implement PUT /pickups/:id/status handler with collector verification and transition validation
    - Implement GET /pickups/my-requests handler for requester's pickups
    - Implement GET /pickups/my-jobs handler for collector's jobs with status filter
    - Implement GET /pickups/my-jobs/stats handler for collector statistics
    - Implement GET /pickups/:id handler with access control
    - Trigger notifications on pickup acceptance, status updates
    - Handle validation errors, permission errors (403), invalid transitions (400)
    - _Requirements: 13.2, 14.3, 15.3, 15.4, 16.3, 16.4, 16.6, 17.3_

  - [ ] 9.4 Create pickup routes (src/modules/pickup/pickup.routes.js)
    - Define POST /api/pickups with JWT auth, role check, validation
    - Define GET /api/pickups/pending with JWT auth, role check
    - Define PUT /api/pickups/:id/accept with JWT auth, role check
    - Define PUT /api/pickups/:id/status with JWT auth, validation
    - Define GET /api/pickups/my-requests with JWT auth, role check
    - Define GET /api/pickups/my-jobs with JWT auth, role check
    - Define GET /api/pickups/my-jobs/stats with JWT auth, role check
    - Define GET /api/pickups/:id with JWT auth
    - _Requirements: 13.1, 14.1, 15.1, 16.1, 17.1, 18.1_

  - [ ]* 9.5 Write unit tests for pickup endpoints
    - Test pickup creation with role check, validation
    - Test pending pickup feed with role check
    - Test pickup acceptance with role check, status validation
    - Test status updates with transition validation, transaction on completion
    - Test pickup retrieval with access control
    - Test collector job tracking and statistics

- [ ] 10. Checkpoint - Ensure marketplace and pickup tests pass
  - Ensure all tests pass, ask the user if questions arise.


- [ ] 11. Implement Eco-Score Module
  - [ ] 11.1 Create eco-score service layer (src/modules/ecoscore/ecoscore.service.js)
    - Implement eco-points calculation for pickup completion (floor(weight × 10))
    - Implement eco-points addition for item sold (5 points)
    - Implement eco-points history creation with event details
    - Implement user eco-score retrieval with aggregated statistics (total points, weight recycled, items sold)
    - Implement paginated eco-points history retrieval with event details
    - Implement leaderboard generation (top 100 normal_users by eco_points, excluding buyers/collectors)
    - Implement user rank calculation (1 + count of users with higher points)
    - Ensure eco_points field is never decremented (monotonic increase)
    - _Requirements: 19.1, 19.2, 19.3, 19.4, 20.1, 20.2, 20.3, 21.1, 21.2, 21.3, 21.4_

  - [ ]* 11.2 Write property tests for eco-score service
    - **Property 37: Eco-Points Calculation Formula**
    - **Property 38: Fixed Eco-Points for Item Sold**
    - **Property 39: Eco-Points Monotonic Increase**
    - **Property 40: Eco-Score Aggregation Correctness**
    - **Property 41: Leaderboard Sorting and Limiting**
    - **Property 42: User Rank Calculation**
    - **Validates: Requirements 19.1, 19.2, 19.3, 20.1, 21.1, 21.3, 21.4**

  - [ ] 11.3 Create eco-score controller (src/modules/ecoscore/ecoscore.controller.js)
    - Implement GET /eco-score handler with aggregated statistics
    - Implement GET /eco-score/history handler with pagination and event details
    - Implement GET /eco-score/leaderboard handler with top 100 and user rank
    - _Requirements: 20.1, 20.2, 20.3, 21.1, 21.2, 21.4_

  - [ ] 11.4 Create eco-score routes (src/modules/ecoscore/ecoscore.routes.js)
    - Define GET /api/eco-score with JWT auth
    - Define GET /api/eco-score/history with JWT auth
    - Define GET /api/eco-score/leaderboard (public endpoint)
    - _Requirements: 20.1, 20.2, 21.1_

  - [ ]* 11.5 Write unit tests for eco-score endpoints
    - Test eco-score retrieval with correct aggregations
    - Test eco-points history with pagination and event details
    - Test leaderboard with sorting, filtering, and rank calculation

- [ ] 12. Implement Notifications Module
  - [ ] 12.1 Create notifications service layer (src/modules/notifications/notifications.service.js)
    - Implement FCM token registration with support for multiple tokens per user
    - Implement FCM token unregistration
    - Implement push notification delivery via Firebase Admin SDK
    - Implement notification payload construction (title, body, data with event_type and event_id)
    - Implement invalid token cleanup on FCM errors
    - Implement notification triggers for events (offer created, offer accepted/rejected, pickup accepted, pickup status updates)
    - Handle FCM errors gracefully (log and continue, non-blocking)
    - _Requirements: 22.1, 22.2, 22.3, 23.1, 23.2, 23.3, 23.4, 23.5, 23.6_

  - [ ]* 12.2 Write property tests for notifications service
    - **Property 43: Multiple FCM Token Storage**
    - **Property 44: Notification Structure Validation**
    - **Property 45: Invalid Token Cleanup**
    - **Validates: Requirements 22.2, 23.5, 23.6**

  - [ ] 12.3 Create notifications controller (src/modules/notifications/notifications.controller.js)
    - Implement POST /notifications/register-token handler
    - Implement DELETE /notifications/unregister-token handler
    - _Requirements: 22.1, 22.3_

  - [ ] 12.4 Create notifications routes (src/modules/notifications/notifications.routes.js)
    - Define POST /api/notifications/register-token with JWT auth, validation
    - Define DELETE /api/notifications/unregister-token with JWT auth, validation
    - _Requirements: 22.1, 22.3_

  - [ ]* 12.5 Write unit tests for notifications endpoints
    - Test FCM token registration with multiple devices
    - Test FCM token unregistration
    - Test notification delivery on events (mocked FCM)
    - Test invalid token cleanup

- [ ] 13. Implement system endpoints and utilities
  - [ ] 13.1 Create health check endpoint
    - Implement GET /api/health handler
    - Check database connectivity
    - Return 200 with status "healthy" or 503 with status "unhealthy"
    - _Requirements: 26.1, 26.2_

  - [ ] 13.2 Create file serving endpoint
    - Implement GET /api/uploads/:filename handler
    - Serve files from uploads directory
    - Set Content-Type header based on file extension (image/jpeg, image/png)
    - Set Cache-Control header with max-age=604800 (7 days)
    - Return 404 for non-existent files
    - _Requirements: 30.1, 30.2, 30.3, 30.4_

  - [ ]* 13.3 Write property tests for file serving
    - **Property 55: Content-Type Header Correctness**
    - **Property 56: Cache-Control Header Presence**
    - **Validates: Requirements 30.2, 30.4**

  - [ ] 13.4 Create file management utility (src/utils/fileManager.js)
    - Implement file deletion function
    - Implement file existence check
    - Handle file system errors gracefully
    - _Requirements: 5.6_

  - [ ] 13.5 Create logging utility (src/utils/logger.js)
    - Configure Winston or Morgan for structured logging
    - Set up request logging (timestamp, method, path, status, response time)
    - Set up error logging (timestamp, method, path, user_id, error, stack trace)
    - Configure log rotation for production
    - _Requirements: 25.2, 25.3_

  - [ ] 13.6 Implement rate limiting configuration
    - Configure express-rate-limit middleware (100 requests per 15 minutes per IP)
    - Return 429 for requests exceeding limit
    - Exclude /api/health endpoint from rate limiting
    - _Requirements: 27.1, 27.2, 27.3, 27.4_

  - [ ]* 13.7 Write property tests for rate limiting
    - **Property 53: Rate Limit Enforcement**
    - **Property 54: Health Check Exclusion from Rate Limiting**
    - **Validates: Requirements 27.1, 27.2, 27.4**

  - [ ]* 13.8 Write unit tests for system endpoints
    - Test health check endpoint (healthy, unhealthy)
    - Test file serving with correct headers
    - Test file serving 404 for non-existent files

- [ ] 14. Integration and wiring
  - [ ] 14.1 Wire all module routes to Express app
    - Mount auth routes at /api/auth
    - Mount listings routes at /api/listings
    - Mount offers routes at /api/offers
    - Mount pickup routes at /api/pickups
    - Mount eco-score routes at /api/eco-score
    - Mount notifications routes at /api/notifications
    - Mount health check at /api/health
    - Mount file serving at /api/uploads
    - _Requirements: All endpoint requirements_

  - [ ] 14.2 Configure CORS for production
    - Set CORS origin to mobile app domain (or * for development)
    - Configure allowed methods and headers
    - _Requirements: 28.1, 28.2_

  - [ ] 14.3 Set up request logging middleware
    - Log all incoming requests with timestamp, method, path
    - Log response status and time
    - _Requirements: 25.3_

  - [ ] 14.4 Integrate notification triggers in controllers
    - Trigger notification on offer creation (to listing owner)
    - Trigger notification on offer acceptance/rejection (to buyer)
    - Trigger notification on pickup acceptance (to requester)
    - Trigger notification on pickup status updates (to requester)
    - _Requirements: 10.6, 11.5, 15.2, 16.4_

  - [ ]* 14.5 Write integration tests for complete workflows
    - Test authentication flow (register → login → profile operations)
    - Test marketplace flow (create listing → receive offer → accept offer → eco-points)
    - Test pickup flow (create request → collector accepts → status updates → completion → eco-points)
    - Test eco-score flow (earn points → view history → check leaderboard)
    - Test notification delivery on events
    - Test error scenarios (401, 403, 404, 409, 429, 500)

- [ ] 15. Final checkpoint and documentation
  - [ ] 15.1 Create README.md with setup instructions
    - Document environment variables
    - Document database setup and migrations
    - Document API endpoints
    - Document testing commands
    - _Requirements: All requirements_

  - [ ] 15.2 Create .env.example file
    - Include all required environment variables with example values
    - Document each variable's purpose
    - _Requirements: All configuration requirements_

  - [ ] 15.3 Run all tests and verify coverage
    - Run unit tests (including property-based tests)
    - Run integration tests
    - Verify code coverage >= 80%
    - Fix any failing tests
    - _Requirements: All requirements_

  - [ ] 15.4 Final verification checkpoint
    - Ensure all tests pass
    - Verify database schema matches design
    - Verify all endpoints are accessible
    - Verify error handling works correctly
    - Ask the user if questions arise

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- Integration tests validate end-to-end workflows
- The implementation uses Node.js with Express.js, PostgreSQL, JWT, bcrypt, Multer, and Firebase Admin SDK
- All database operations use parameterized queries to prevent SQL injection
- All file uploads are validated for type and size
- All endpoints enforce authentication and authorization as specified in requirements
- Transaction-based operations ensure atomicity for critical business logic (offer acceptance, pickup completion)


## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1", "2"] },
    { "id": 1, "tasks": ["3.1", "3.3", "3.5", "3.7", "3.9"] },
    { "id": 2, "tasks": ["3.2", "3.4", "3.6", "3.8", "3.10"] },
    { "id": 3, "tasks": ["5.1", "13.4", "13.5"] },
    { "id": 4, "tasks": ["5.2", "5.3"] },
    { "id": 5, "tasks": ["5.4", "5.5"] },
    { "id": 6, "tasks": ["6.1"] },
    { "id": 7, "tasks": ["6.2", "6.3"] },
    { "id": 8, "tasks": ["6.4", "6.5"] },
    { "id": 9, "tasks": ["8.1"] },
    { "id": 10, "tasks": ["8.2", "8.3"] },
    { "id": 11, "tasks": ["8.4", "8.5"] },
    { "id": 12, "tasks": ["9.1"] },
    { "id": 13, "tasks": ["9.2", "9.3"] },
    { "id": 14, "tasks": ["9.4", "9.5"] },
    { "id": 15, "tasks": ["11.1"] },
    { "id": 16, "tasks": ["11.2", "11.3"] },
    { "id": 17, "tasks": ["11.4", "11.5"] },
    { "id": 18, "tasks": ["12.1"] },
    { "id": 19, "tasks": ["12.2", "12.3"] },
    { "id": 20, "tasks": ["12.4", "12.5"] },
    { "id": 21, "tasks": ["13.1", "13.2", "13.6"] },
    { "id": 22, "tasks": ["13.3", "13.7", "13.8"] },
    { "id": 23, "tasks": ["14.1", "14.2", "14.3"] },
    { "id": 24, "tasks": ["14.4"] },
    { "id": 25, "tasks": ["14.5"] },
    { "id": 26, "tasks": ["15.1", "15.2"] },
    { "id": 27, "tasks": ["15.3", "15.4"] }
  ]
}
```
