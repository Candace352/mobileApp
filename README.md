# 📱 Job Finder Mobile App

## Overview

The **Job Finder Mobile App**, developed in collaboration with **VacancyMail**, is a mobile-first solution tailored for Zimbabwean job seekers. With the growing shift from traditional job search methods to digital platforms, this app bridges the gap by providing a lightweight, real-time, and offline-capable job application experience.

The app is part of VacancyMail's mission to streamline employment access in urban areas like Harare by offering a centralized platform for browsing job listings, submitting applications, and managing user documents—all on a mobile device.

---

## 🌍 Problem Context

In Harare, Zimbabwe, job seekers have traditionally relied on newspapers and community notice boards for job listings. This often results in:
- **Delayed access** to opportunities
- **Limited geographic reach**
- **Manual, time-consuming application processes**

With increasing smartphone penetration, the need for a **digital and accessible job discovery platform** became evident.

---

## ✅ Solution

VacancyMail created the **Job Finder Mobile App** that integrates with its web platform and provides users with:
- Real-time job alerts
- Document (CVs, cover letters) storage and reusability
- In-app application submissions
- Offline document access
- Push notifications for opportunities

---

## 🔧 Features

- 🧭 **User-friendly onboarding and authentication**
- 📄 **Resume and cover letter upload & storage**
- 🔄 **Real-time job listing updates**
- 📡 **Offline job viewing and cached data**
- 🔔 **Push notifications for new jobs**
- 📌 **Document scanning via camera**
- 🗂 **Application history tracking**

---

## 🏗 Architecture

### System Overview

**Client-Server Architecture:**

| Component       | Tech Stack                      |
|----------------|----------------------------------|
| Frontend       | Flutter (Dart)                  |
| Backend        | Javascript,Node.js + Express    |
| Database       | Firebase Firestore              |
| Authentication | Firebase Authentication         |
| File Storage   | Firebase Storage                |
| Offline Cache  | SQLite (local device storage)   |

### Communication Flow

1. Employer posts a job via web app.
2. Data is stored in **Firestore**.
3. Mobile app retrieves job data through **RESTful APIs**.
4. User applies for a job; data is stored and feedback sent.

---

## 🛠 Tools & Packages

- `file_picker` – File upload functionality
- `firebase_core`, `cloud_firestore`, `firebase_auth`, `firebase_storage` – Firebase integration
- `path_provider`, `sqflite` – Offline caching

---

## 📸 Screenshots

*(Add screenshots here if available)*

---

## 📥 APK Download

**[Download APK here](#)**  
*(Replace `#` with actual link to the APK)*

---

## 🎥 Demo Video

A 15-minute walkthrough showing all major functionalities, including:
- Onboarding and sign-up
- Browsing jobs by location
- Uploading resumes via device/camera
- Real-time application submission
- Backend and API overview

▶️ [Watch the demo](https://youtu.be/JhDAxj5bkl8)  
AOK DOWNLOAD LINK: https://drive.google.com/file/d/17W3MI54cf6cIAn68YvAQtOu7Z3fdsOvb/view?usp=sharing
*(Ensure video is public and tested externally)*

---

## 🤝 Contribution & License

This project is part of an academic and community-driven initiative.I struggled, fought and lost.
MIT License © 2025 VacancyMail & Contributors

---

## 📬 Contact

For support or queries:  
**Candace Tariro Hunzwi**  
📧 candace.hunzwi@gmail.com  
🌐 [GitHub: Candace352](https://github.com/Candace352)

