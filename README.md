<p align="center">
  <img src="./img.png" alt="Salon Connect Banner" width="100%">
</p>

# Salon Connect 💇‍♀️✨

## Basic Details

### Team Name:
Genisis

### Team Members

* Greeshma A – CE Kalloopara
* Member 2 – CE Kalloopara

### Hosted Project Link

[Add your GitHub / APK / Hosted Link here]

---

## Project Description

Salon Connect is a smart salon service booking and management application that allows customers to browse salons, book treatments, and track their prior service history. It also provides salon admins with tools to manage services, staff, and appointments efficiently.

---

## The Problem Statement

Salon booking is often manual, unorganized, and lacks proper tracking of customer history and treatments. Customers struggle with availability checks, and salons face difficulty managing appointments and service records.

---

## The Solution

Salon Connect provides a digital platform that:

* Allows customers to browse services and book appointments.
* Tracks prior treatment history.
* Provides AI-based service suggestions.
* Enables admins to manage bookings, services, and payments efficiently.

---

# Technical Details

## Technologies/Components Used

### For Software:

* **Languages used:** Dart
* **Frameworks used:** Flutter
* **Libraries used:** Provider, Hive (Local Storage), fl_chart
* **Tools used:** VS Code, Git, GitHub, Android Emulator

---

# Features

* Role-based login (Customer / Admin)
* Browse salons & available treatments
* Real-time slot availability check
* Booking system with payment simulation
* Prior treatment history tracking
* AI-based service suggestions (rule-based)
* Admin dashboard with analytics
* Feedback & rating system

---

# Implementation

## For Software:

### Installation

```bash
git clone https://github.com/yourusername/salon-connect.git
cd salon-connect
flutter pub get
```

### Run

```bash
flutter run
```

---

# Project Documentation

## Screenshots

![Screenshot1](screenshots/home.png)
*Customer home screen showing available salons*

![Screenshot2](screenshots/booking.png)
*Booking interface with date & time selection*

![Screenshot3](screenshots/admin.png)
*Admin dashboard with analytics overview*

---

## System Architecture

![Architecture Diagram](docs/architecture.png)
Salon Connect follows a structured architecture:

* UI Layer (Flutter Screens)
* Business Logic Layer (Provider / Services)
* Local Storage Layer (Hive Database)
* Analytics & Suggestion Engine

Data flows from UI → Service Layer → Local Storage → UI update.

---

## Application Workflow

![Workflow](docs/workflow.png)

User Flow:

1. User selects role
2. Customer browses services
3. Checks slot availability
4. Books appointment
5. Payment simulation
6. Booking stored locally
7. Admin manages bookings

---

# Additional Documentation

## For Mobile Apps:

### App Flow Diagram

![App Flow](docs/app-flow.png)

* Login → Dashboard
* Customer: Browse → Book → History → Suggestions
* Admin: Dashboard → Manage Services → View Appointments → Analytics

---

## Installation Guide

### For Android (APK):

1. Download APK from release section
2. Enable "Install from Unknown Sources"
3. Install APK
4. Open Salon Connect

---

### Building from Source:

```bash
flutter build apk
```

---

# AI-Based Suggestion Logic

Salon Connect includes a simple rule-based AI system:

* If user frequently books hair spa → Suggest advanced hair therapy
* If user books bridal makeup → Suggest premium bridal package
* If no history → Suggest trending services

This logic analyzes stored booking history and generates recommendations.

---

# Feedback System

Customers can:

* Submit 1–5 star rating
* Write review
* View booking history

Admins can:

* View feedback list
* Calculate average rating
* Analyze customer satisfaction

---

# Real-Time Slot Availability Logic

When booking:

* System checks if selected stylist + date + time already exists
* If exists → Shows error
* If not → Allows booking

Prevents double booking.

---

# Admin Dashboard

Admin Features:

* Add / Edit / Delete services
* Add products used in treatments
* Manage stylists
* View all appointments
* Update appointment status
* View payment summary
* Analytics (Total bookings & revenue using fl_chart)

---

# Project Demo

### Video

[Add demo video link here]

This video demonstrates:

* Customer booking flow
* AI suggestion system
* Admin dashboard analytics
* Payment simulation

---

# AI Tools Used

**Tool Used:** GitHub Copilot

**Purpose:**

* Generated Flutter UI components
* Assisted in implementing booking logic
* Helped structure local storage models

**Percentage of AI-generated code:** ~40%

**Human Contributions:**

* Architecture design
* Feature planning
* Business logic implementation
* UI/UX decisions
* Testing & debugging

---

# Team Contributions

* Greeshma A: UI development, Booking logic, AI suggestion logic
* Member 2: Admin dashboard, Analytics, Feedback system

---

# License

This project is licensed under the MIT License.

---

Made with ❤️ at TinkerHub
