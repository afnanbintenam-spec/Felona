# Requirements Document

## Introduction

Smart Pickup Scheduling enhances the FeloNa waste management app's existing pickup feature with real-time tracking, calendar-based scheduling, recurring pickups, live map tracking, QR code verification, smart notifications, and post-pickup rating. The feature extends the current `PickupBloc` and Clean Architecture patterns already established in the codebase.

## Glossary

- **Scheduling_System**: The module responsible for creating, managing, and displaying pickup schedules including date/time slot selection and recurring configurations.
- **Tracking_System**: The module responsible for real-time pickup status updates, ETA calculations, and live collector location display on a map.
- **Notification_Engine**: The component that dispatches push notifications to users at each pickup status transition, leveraging the existing Firebase Messaging infrastructure.
- **QR_Verification_Module**: The component that generates unique QR codes for pickup requests and validates them when scanned by collectors at pickup time.
- **Rating_System**: The component that collects user feedback (star rating and optional text) after a pickup is completed.
- **Collector**: A waste collection agent assigned to fulfill pickup requests.
- **User**: A FeloNa app user who creates pickup requests and schedules waste collection.
- **Time_Slot**: A predefined window of time (e.g., 08:00–10:00) during which a pickup can be scheduled.
- **Recurring_Schedule**: A weekly repeating pickup configuration with a fixed day and time slot.
- **ETA**: Estimated Time of Arrival — the predicted time remaining until the collector reaches the user's location.
- **Pickup_Status**: One of: pending, assigned, collector_on_the_way, arrived, completed, cancelled.

## Requirements

### Requirement 1: Calendar-Based Pickup Scheduling

**User Story:** As a user, I want to select a specific date and time slot for my pickup, so that I can plan waste collection around my availability.

#### Acceptance Criteria

1. WHEN the user opens the scheduling screen, THE Scheduling_System SHALL display a calendar view showing available dates for the next 14 days, starting from tomorrow.
2. WHEN the user selects a date, THE Scheduling_System SHALL display available time slots for that date, where a time slot is considered available if it has not reached its maximum booking capacity and its start time is at least 2 hours in the future.
3. THE Scheduling_System SHALL present time slots in 2-hour windows starting from 08:00 to 18:00 (08:00–10:00, 10:00–12:00, 12:00–14:00, 14:00–16:00, 16:00–18:00).
4. WHEN the user selects a date and time slot and confirms, THE Scheduling_System SHALL create a pickup request with the chosen schedule, transition the pickup status to pending, and display a confirmation message indicating the scheduled date and time slot.
5. IF the user selects a date that is today and the current time has passed all available time slots, THEN THE Scheduling_System SHALL disable that date and display a message indicating no slots are available today.
6. IF the backend returns an error during schedule creation, THEN THE Scheduling_System SHALL display an error message indicating the schedule was not created and retain the user's selected date and time slot so the user can retry without re-entering selections.
7. IF no time slots are available for the selected date, THEN THE Scheduling_System SHALL display a message indicating no slots are available for that date and prevent the user from confirming a pickup for that date.

### Requirement 2: Recurring Weekly Pickup

**User Story:** As a user, I want to set up a recurring weekly pickup, so that I do not have to manually schedule a pickup every week.

#### Acceptance Criteria

1. WHEN the user enables the recurring option on the scheduling screen, THE Scheduling_System SHALL allow the user to select a day of the week and a time slot for weekly repetition.
2. WHEN a recurring schedule is active, THE Scheduling_System SHALL automatically create a new pickup request each week on the configured day and time slot, at least 24 hours before the scheduled time.
3. WHEN the user views the scheduling screen, THE Scheduling_System SHALL display the active recurring schedule with the configured day and time slot, along with the date of the next scheduled pickup.
4. WHEN the user disables the recurring option, THE Scheduling_System SHALL stop creating future automatic pickup requests while preserving already-created requests.
5. IF the automatic pickup creation fails due to a network error, THEN THE Scheduling_System SHALL retry the creation up to 3 times with exponential backoff (starting at 5 seconds, doubling each attempt) and notify the user via push notification if all retries fail.
6. THE Scheduling_System SHALL allow a maximum of one active recurring schedule per user at any given time.
7. IF the selected time slot for the recurring day is fully booked, THEN THE Scheduling_System SHALL notify the user and skip that week's automatic creation without disabling the recurring schedule.

### Requirement 3: Live Pickup Status Tracking

**User Story:** As a user, I want to see the real-time status of my pickup request, so that I know exactly where my pickup is in the process.

#### Acceptance Criteria

1. THE Tracking_System SHALL display the current pickup status as one of: pending, assigned, collector_on_the_way, arrived, completed, or cancelled.
2. WHEN the pickup status changes on the backend, THE Tracking_System SHALL update the displayed status within 5 seconds using a real-time connection (WebSocket or Firebase Realtime Database).
3. THE Tracking_System SHALL display a visual timeline showing all status transitions with timestamps (date and time to the minute) for the most recent non-completed and non-cancelled pickup belonging to the user.
4. WHEN the pickup status transitions to assigned, THE Tracking_System SHALL display the assigned collector's name, profile photo (or a default placeholder avatar if no photo is available), and average rating displayed as a numeric value on a scale of 1.0 to 5.0 with one decimal place.
5. IF the real-time connection is lost, THEN THE Tracking_System SHALL display a connectivity warning and attempt to reconnect using exponential backoff starting at 1 second, doubling each attempt, up to a maximum interval of 30 seconds, for a maximum of 10 retry attempts.
6. IF all reconnection attempts are exhausted, THEN THE Tracking_System SHALL display a persistent error message indicating the connection could not be restored and provide a manual retry option.

### Requirement 4: ETA Tracking

**User Story:** As a user, I want to see the estimated time of arrival of my collector, so that I can prepare for the pickup.

#### Acceptance Criteria

1. WHILE the pickup status is collector_on_the_way, THE Tracking_System SHALL display the ETA as a whole number of minutes (ranging from 1 to 120) and SHALL refresh the displayed value at least once every 30 seconds.
2. WHEN the ETA changes by more than 2 minutes from the previously displayed value between scheduled 30-second refreshes, THE Tracking_System SHALL immediately update the displayed ETA without waiting for the next refresh cycle.
3. WHEN the ETA is 5 minutes or less, THE Tracking_System SHALL display an "Arriving Soon" indicator that is visually distinct from the standard ETA display by using a larger font size or contrasting background, visible without scrolling.
4. IF the ETA cannot be calculated due to the collector's location data being unavailable, THEN THE Tracking_System SHALL display "Calculating ETA..." instead of a numeric value.
5. IF the Tracking_System displays "Calculating ETA..." for more than 60 seconds continuously, THEN THE Tracking_System SHALL display a message indicating that the collector's location is temporarily unavailable and advising the user to wait.

### Requirement 5: Live Map Tracking

**User Story:** As a user, I want to see the collector's live location on a map, so that I can visually track their approach.

#### Acceptance Criteria

1. WHILE the pickup status is collector_on_the_way, THE Tracking_System SHALL display a map showing the collector's current location marker and the user's pickup address marker as two visually distinct indicators.
2. WHILE the pickup status is collector_on_the_way, THE Tracking_System SHALL update the collector's position on the map every 5 seconds using real-time location data.
3. WHILE the pickup status is collector_on_the_way, THE Tracking_System SHALL display a route line between the collector's current position and the user's pickup address.
4. WHEN the user opens the tracking screen, THE Tracking_System SHALL center the map to show both the collector's location and the pickup address within the visible area with sufficient padding so that neither marker is at the edge of the viewport.
5. IF location data is unavailable for more than 30 seconds, THEN THE Tracking_System SHALL display a message indicating that the collector's location is temporarily unavailable and show the collector's last known position on the map.
6. IF location data becomes available again after being unavailable, THEN THE Tracking_System SHALL dismiss the unavailability message and resume live position updates within 5 seconds.
7. IF the route between the collector and the pickup address cannot be calculated, THEN THE Tracking_System SHALL hide the route line and display only the collector's location marker and the pickup address marker without the connecting route.

### Requirement 6: Assigned Collector Information

**User Story:** As a user, I want to see details about my assigned collector, so that I know who is coming to pick up my waste.

#### Acceptance Criteria

1. WHEN a collector is assigned to the pickup (status transitions from pending to assigned), THE Tracking_System SHALL display the collector's full name, profile photo, and average rating on a scale of 1.0 to 5.0 stars.
2. IF the collector has received at least one rating, THEN THE Tracking_System SHALL display the collector's average rating rounded to one decimal place (e.g., 4.3).
3. IF the collector has not received any ratings, THEN THE Tracking_System SHALL display "No ratings yet" in place of the star rating.
4. IF the collector does not have a profile photo, THEN THE Tracking_System SHALL display a default avatar showing the collector's first-name initial and last-name initial.
5. WHEN the pickup status transitions from pending to assigned, THE Tracking_System SHALL display the collector information card with a slide-in animation lasting no longer than 300 milliseconds.

### Requirement 7: Pickup History

**User Story:** As a user, I want to view my past pickups with details, so that I can track my waste collection activity over time.

#### Acceptance Criteria

1. THE Scheduling_System SHALL display a list of all pickups with status "completed" or "cancelled" sorted by completion date (or cancellation date for cancelled pickups) in descending order.
2. THE Scheduling_System SHALL display for each history entry: date, time slot, waste category, weight in kilograms (kg), collector name, status, and eco points earned.
3. IF a history entry has status "cancelled" and lacks a collector assignment or weight, THEN THE Scheduling_System SHALL display a placeholder indicator (e.g., dash or "N/A") for the missing fields.
4. WHEN the user taps a history entry, THE Scheduling_System SHALL navigate to a detail screen showing the full pickup timeline with all status transitions and their timestamps.
5. WHEN the user scrolls to the bottom of the history list, THE Scheduling_System SHALL display a loading indicator and load the next page of results (pagination with 20 items per page).
6. IF the history list is empty, THEN THE Scheduling_System SHALL display an empty state message indicating no past pickups exist.
7. IF the history data fails to load due to a network error, THEN THE Scheduling_System SHALL display an error message indicating the failure and provide a retry option.
8. IF a pagination request fails while loading the next page, THEN THE Scheduling_System SHALL display an error message at the bottom of the list and allow the user to retry loading the next page.

### Requirement 8: QR Code Verification

**User Story:** As a user, I want to verify the pickup through a QR code, so that the collection is securely confirmed when the collector arrives.

#### Acceptance Criteria

1. WHEN a pickup request is created, THE QR_Verification_Module SHALL generate a unique QR code containing a one-time token of at least 128 bits of entropy, associated with that pickup request.
2. WHILE the pickup status is assigned or collector_on_the_way or arrived, THE QR_Verification_Module SHALL display the QR code on the user's pickup detail screen.
3. WHEN the collector scans the user's QR code and the QR code token matches the assigned pickup request for that collector, THE QR_Verification_Module SHALL transition the pickup status to completed and display a success confirmation to both the user and the collector within 3 seconds.
4. IF the scanned QR code does not match any active pickup request or does not match the scanning collector's assigned pickup, THEN THE QR_Verification_Module SHALL reject the scan and display an error message indicating invalid QR code without revealing which condition failed.
5. IF the QR code has already been used for verification, THEN THE QR_Verification_Module SHALL reject the scan and display a message indicating the pickup has already been verified.
6. IF the pickup status transitions to cancelled, THEN THE QR_Verification_Module SHALL invalidate the associated QR code and remove it from the user's pickup detail screen.
7. IF the QR code validation fails due to a network error, THEN THE QR_Verification_Module SHALL display an error message indicating a connectivity issue and allow the collector to retry the scan.

### Requirement 9: Smart Notifications

**User Story:** As a user, I want to receive push notifications at each status change, so that I stay informed without constantly checking the app.

#### Acceptance Criteria

1. WHEN the pickup status transitions to assigned, THE Notification_Engine SHALL send a push notification to the requesting user within 10 seconds, with the message "Collector assigned to your pickup".
2. WHEN the pickup status transitions to collector_on_the_way, THE Notification_Engine SHALL send a push notification to the requesting user within 10 seconds, with the message "Your collector is on the way".
3. WHEN the collector's ETA decreases to 5 minutes or below for the first time during a pickup, THE Notification_Engine SHALL send a single push notification with the message "Your collector is arriving in 5 minutes".
4. WHEN the pickup status transitions to completed, THE Notification_Engine SHALL send a push notification to the requesting user within 10 seconds, with the message "Pickup completed! Rate your experience".
5. WHEN a recurring pickup is automatically created, THE Notification_Engine SHALL send a push notification to the requesting user within 30 seconds, with the message "Your weekly pickup has been scheduled".
6. THE Notification_Engine SHALL deliver notifications using the existing Firebase Cloud Messaging infrastructure.
7. IF the push notification delivery fails due to an invalid device token or FCM service unavailability, THEN THE Notification_Engine SHALL retry delivery up to 3 times with exponential backoff, and persist the notification for in-app retrieval if all retries are exhausted.
8. IF the user has not granted notification permissions or has no registered device token, THEN THE Notification_Engine SHALL skip push delivery and persist the notification for in-app retrieval only.

### Requirement 10: Pickup Rating and Feedback

**User Story:** As a user, I want to rate my pickup experience after completion, so that I can provide feedback on the collector's service.

#### Acceptance Criteria

1. WHEN the pickup status transitions to completed, THE Rating_System SHALL display a rating prompt within 5 seconds of the status update.
2. THE Rating_System SHALL allow the user to select a whole-number star rating from 1 to 5, and SHALL require a star rating selection before enabling the submit action.
3. THE Rating_System SHALL allow the user to optionally enter a text comment of up to 500 characters.
4. WHEN the user submits a rating, THE Rating_System SHALL associate the rating with both the pickup request and the collector's profile, and SHALL display a success confirmation to the user within 3 seconds of successful submission.
5. IF the user dismisses the rating prompt without submitting, THEN THE Rating_System SHALL allow the user to rate the pickup later from the pickup history detail screen within 30 days of pickup completion.
6. IF the rating submission fails due to a network error, THEN THE Rating_System SHALL store the rating locally and retry submission up to 3 times when connectivity is restored, notifying the user if all retries fail.
7. IF the user has already submitted a rating for a pickup, THEN THE Rating_System SHALL display the previously submitted rating as read-only and SHALL NOT allow a duplicate submission.
