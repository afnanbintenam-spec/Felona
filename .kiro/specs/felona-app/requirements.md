# Requirements Document

## Introduction
06+
FeloNa is a Flutter mobile application that connects three types of users in a circular-economy ecosystem: **Normal Users** (sellers / waste generators), **Buyers / Recyclers**, and **Collectors**. Normal Users can list reusable items for sale, request waste pickups, and earn eco points. Buyers can browse the marketplace and send purchase offers. Collectors can accept nearby pickup jobs and track their earnings. The MVP covers authentication, item listings, the offers system, pickup requests, collector acceptance, push notifications, and the eco-score system. Real-time chat, payment gateway, AI waste detection, and live map routing are deferred to a later version.

---

## Glossary

- **App**: The FeloNa Flutter mobile application.
- **Normal_User**: A registered user with the "seller / waste generator" role.
- **Buyer**: A registered user with the "buyer / recycler" role.
- **Collector**: A registered user with the "collector" role.
- **Auth_Service**: The backend service responsible for identity, authentication, and session management.
- **Marketplace_Service**: The backend service responsible for item listings, images, and offers.
- **Pickup_Service**: The backend service responsible for pickup requests, collector assignment, and status tracking.
- **Notification_Service**: The backend service responsible for delivering push notifications to users.
- **Eco_Score_Service**: The backend service responsible for calculating and storing eco points.
- **JWT**: JSON Web Token used as the session credential after login.
- **Listing**: A marketplace entry created by a Normal_User to sell a reusable item.
- **Offer**: A price proposal sent by a Buyer to a Normal_User for a specific Listing.
- **Pickup_Request**: A request created by a Normal_User for a Collector to collect waste materials.
- **Eco_Points**: Reward points awarded to a Normal_User for completed recycling or pickup activities.
- **Waste_Category**: A predefined classification of waste material (e.g., Plastic, Metal, Paper, Glass, Electronics, Other).
- **Pickup_Status**: The lifecycle state of a Pickup_Request: `Pending`, `Accepted`, `On_The_Way`, `Completed`.

---

## Requirements

### Requirement 1: User Registration and Role Selection

**User Story:** As a new user, I want to register an account and choose my role, so that I can access the features relevant to me.

#### Acceptance Criteria

1. THE Auth_Service SHALL accept registration requests containing a full name, email address, password, and a selected role (Normal_User, Buyer, or Collector).
2. WHEN a registration request is received with an email address that already exists in the system, THE Auth_Service SHALL return an error indicating the email is already registered.
3. WHEN a registration request is received with a password shorter than 8 characters, THE Auth_Service SHALL return a validation error.
4. WHEN a valid registration request is received, THE Auth_Service SHALL store the user record and return a JWT valid for 30 days.
5. THE App SHALL display a role-selection screen during registration that presents exactly three options: Normal_User, Buyer, and Collector.

---

### Requirement 2: User Login

**User Story:** As a registered user, I want to log in with my email and password, so that I can access my account.

#### Acceptance Criteria

1. WHEN a login request is received with a valid email and matching password, THE Auth_Service SHALL return a JWT valid for 30 days.
2. WHEN a login request is received with an unrecognised email or an incorrect password, THE Auth_Service SHALL return an authentication error without specifying which field is wrong.
3. WHEN a JWT expires, THE App SHALL redirect the user to the login screen and clear locally stored credentials.

---

### Requirement 3: Profile Management

**User Story:** As a registered user, I want to edit my profile and upload a profile picture, so that other users can identify me.

#### Acceptance Criteria

1. WHEN an authenticated user submits a profile update containing a new full name or phone number, THE Auth_Service SHALL persist the updated values and return the updated profile.
2. WHEN an authenticated user uploads a profile picture, THE Auth_Service SHALL accept image files in JPEG or PNG format with a maximum size of 5 MB and store the image.
3. IF an uploaded profile picture exceeds 5 MB, THEN THE Auth_Service SHALL return a validation error without storing the file.
4. THE App SHALL display the user's current profile picture, full name, email address, role, and phone number on the profile screen.

---

### Requirement 4: Item Listing Creation

**User Story:** As a Normal_User, I want to post a used item with images and a price, so that Buyers can find and purchase it.

#### Acceptance Criteria

1. WHEN an authenticated Normal_User submits a new listing containing a title, description, price, category, and at least one image, THE Marketplace_Service SHALL create the listing and return the listing identifier.
2. THE Marketplace_Service SHALL accept between 1 and 5 images per listing, each in JPEG or PNG format with a maximum size of 10 MB.
3. IF a listing submission contains more than 5 images, THEN THE Marketplace_Service SHALL return a validation error.
4. WHEN an authenticated Normal_User submits an update to an existing listing they own, THE Marketplace_Service SHALL apply the changes and return the updated listing.
5. WHEN an authenticated Normal_User requests deletion of a listing they own, THE Marketplace_Service SHALL mark the listing as deleted and remove it from the public feed.
6. IF a user who does not own a listing attempts to edit or delete it, THEN THE Marketplace_Service SHALL return an authorisation error.

---

### Requirement 5: Marketplace Feed and Search

**User Story:** As a Buyer, I want to browse, search, and filter item listings, so that I can find items I want to purchase.

#### Acceptance Criteria

1. THE Marketplace_Service SHALL return a paginated feed of active listings, with each page containing at most 20 listings, ordered by creation date descending.
2. WHEN a search request is received containing a keyword, THE Marketplace_Service SHALL return listings whose title or description contains the keyword (case-insensitive).
3. WHEN a filter request is received specifying a category, THE Marketplace_Service SHALL return only listings matching that category.
4. WHEN a filter request is received specifying a maximum price, THE Marketplace_Service SHALL return only listings with a price less than or equal to the specified maximum.
5. THE App SHALL display each listing card with the item title, primary image, price, and seller name.

---

### Requirement 6: Offers System

**User Story:** As a Buyer, I want to send a price offer on a listing, so that I can negotiate and purchase items.

#### Acceptance Criteria

1. WHEN an authenticated Buyer submits an offer containing a listing identifier and a proposed price greater than zero, THE Marketplace_Service SHALL record the offer and notify the listing owner.
2. WHEN an authenticated Normal_User accepts an offer, THE Marketplace_Service SHALL mark the offer as `Accepted`, mark all other offers on the same listing as `Rejected`, and mark the listing as `Sold`.
3. WHEN an authenticated Normal_User rejects an offer, THE Marketplace_Service SHALL mark the offer as `Rejected`.
4. IF a Buyer attempts to send an offer on a listing with status `Sold` or `Deleted`, THEN THE Marketplace_Service SHALL return an error indicating the listing is no longer available.
5. THE App SHALL display all received offers for a listing to the listing owner, showing the Buyer's name and proposed price.
6. WHEN an offer status changes to `Accepted` or `Rejected`, THE Notification_Service SHALL deliver a push notification to the Buyer who submitted the offer.

---

### Requirement 7: Waste Pickup Request

**User Story:** As a Normal_User, I want to request a waste pickup by specifying the waste type and estimated weight, so that a Collector can come and collect it.

#### Acceptance Criteria

1. WHEN an authenticated Normal_User submits a pickup request containing a Waste_Category, an estimated weight in kilograms (greater than 0), and a pickup address, THE Pickup_Service SHALL create the request with status `Pending` and return the request identifier.
2. THE Pickup_Service SHALL accept Waste_Category values from the set: Plastic, Metal, Paper, Glass, Electronics, Other.
3. IF a pickup request is submitted with an estimated weight of zero or a negative value, THEN THE Pickup_Service SHALL return a validation error.
4. THE App SHALL allow a Normal_User to view all their own pickup requests and their current Pickup_Status.

---

### Requirement 8: Collector Pickup Feed and Acceptance

**User Story:** As a Collector, I want to view nearby pending pickup requests and accept jobs, so that I can earn money by collecting waste.

#### Acceptance Criteria

1. WHEN an authenticated Collector requests the pickup feed, THE Pickup_Service SHALL return all requests with status `Pending`, including the Waste_Category, estimated weight, and pickup address for each.
2. WHEN an authenticated Collector accepts a pickup request with status `Pending`, THE Pickup_Service SHALL update the request status to `Accepted`, assign the Collector to the request, and notify the Normal_User who created the request.
3. IF a Collector attempts to accept a pickup request that already has status `Accepted`, `On_The_Way`, or `Completed`, THEN THE Pickup_Service SHALL return an error indicating the request is no longer available.
4. THE App SHALL display the Collector's name and contact information to the Normal_User once a pickup request reaches status `Accepted`.

---

### Requirement 9: Pickup Status Updates

**User Story:** As a Collector, I want to update the status of a pickup job as I progress, so that the Normal_User knows when to expect me.

#### Acceptance Criteria

1. WHEN an authenticated Collector updates the status of an assigned pickup request from `Accepted` to `On_The_Way`, THE Pickup_Service SHALL persist the new status.
2. WHEN an authenticated Collector updates the status of an assigned pickup request from `On_The_Way` to `Completed`, THE Pickup_Service SHALL persist the new status and trigger eco-point calculation.
3. THE Pickup_Service SHALL enforce the status transition order: `Pending` → `Accepted` → `On_The_Way` → `Completed`. IF a status update skips a step or moves backwards, THEN THE Pickup_Service SHALL return a validation error.
4. WHEN a pickup request status changes to `Accepted`, `On_The_Way`, or `Completed`, THE Notification_Service SHALL deliver a push notification to the Normal_User who created the request.

---

### Requirement 10: Eco Score System

**User Story:** As a Normal_User, I want to earn eco points for completed pickups and recycling activities, so that I can track my environmental contribution.

#### Acceptance Criteria

1. WHEN a pickup request transitions to status `Completed`, THE Eco_Score_Service SHALL award eco points to the Normal_User who created the request, calculated as: `floor(estimated_weight_kg × 10)` points.
2. WHEN an offer on a listing is accepted and the listing is marked `Sold`, THE Eco_Score_Service SHALL award 5 eco points to the Normal_User who owned the listing.
3. THE Eco_Score_Service SHALL maintain a cumulative eco-point total per Normal_User that is never decremented by normal operations.
4. THE App SHALL display the Normal_User's current eco-point total and a history of point-earning events on the eco-score screen.
5. THE App SHALL display the total weight of waste recycled (sum of estimated weights of all Completed pickup requests) for each Normal_User on the eco-score screen.

---

### Requirement 11: Push Notifications

**User Story:** As a user, I want to receive push notifications for key events, so that I stay informed without having to check the app constantly.

#### Acceptance Criteria

1. WHEN a new offer is received on a Normal_User's listing, THE Notification_Service SHALL deliver a push notification to that Normal_User within 30 seconds of the offer being created.
2. WHEN a pickup request is accepted by a Collector, THE Notification_Service SHALL deliver a push notification to the Normal_User who created the request within 30 seconds.
3. WHEN a pickup request status changes to `On_The_Way` or `Completed`, THE Notification_Service SHALL deliver a push notification to the Normal_User who created the request within 30 seconds.
4. WHEN an offer status changes to `Accepted` or `Rejected`, THE Notification_Service SHALL deliver a push notification to the Buyer who submitted the offer within 30 seconds.
5. THE App SHALL request notification permissions from the user on first launch and display a permission rationale before the system prompt.
6. WHERE a user has denied notification permissions, THE App SHALL continue to function normally and display in-app notification banners as a fallback.

---

### Requirement 12: Role-Based Dashboards

**User Story:** As a user, I want a dashboard tailored to my role, so that I can quickly access the features most relevant to me.

#### Acceptance Criteria

1. WHEN an authenticated Normal_User opens the App, THE App SHALL display a dashboard containing: active listings count, pending pickup requests count, current eco-point total, and a shortcut to create a new listing or pickup request.
2. WHEN an authenticated Buyer opens the App, THE App SHALL display a dashboard containing: the marketplace feed, active offers sent, and purchase history.
3. WHEN an authenticated Collector opens the App, THE App SHALL display a dashboard containing: the pending pickup feed, accepted jobs in progress, total completed jobs count, and total earnings to date.
4. THE App SHALL prevent a Normal_User from accessing Buyer-only or Collector-only screens, and vice versa, based on the role stored in the JWT.
