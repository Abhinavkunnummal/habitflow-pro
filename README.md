# HabitFlow Pro

HabitFlow Pro is a full-stack, production-ready habit tracking system inspired by contemporary wellness aesthetics (*"Forest Calm"* & *"Aurora Glow"*), based on 20 custom screens designed in Google Stitch.

---

## Architecture & Zero-Local-SDK Setup

This project is built under a **zero-local-SDK constraint** to keep RAM and disk usage at an absolute minimum on Windows:
- **No local Flutter SDK**
- **No Android Studio**
- **No local Android emulators**
- **Cloud APK Compilation**: Automated via **GitHub Actions** (`ubuntu-latest` 16GB runner).
- **Physical Device Testing**: Tested directly on your physical Android phone connected via USB cable or downloaded via phone browser.
- **Backend**: Node.js + Express + TypeScript with **MongoDB Atlas** cloud storage.

---

## How to Build the Android APK in the Cloud

1. Push your changes to GitHub:
   ```bash
   git add .
   git commit -m "Your commit message"
   git push origin main
   ```
2. Open your GitHub repository in your web browser.
3. Click on the **Actions** tab at the top.
4. You will see the workflow **"Build HabitFlow Pro Android APK"** running.
5. In ~3–4 minutes, the workflow completes with a green checkmark.
6. Click on the completed workflow run.
7. Scroll down to the **Artifacts** section at the bottom and click **`HabitFlowPro-Android-APK`** to download `app-debug.apk`.

---

## How to Install the APK on Your Physical Android Phone

### Method A: USB Cable (Easiest & Fastest, No Tools)
1. Download `app-debug.apk` onto your computer.
2. Connect your Android phone to your computer with a USB cable.
3. On your phone, tap the USB notification and select **File Transfer (MTP)**.
4. On your PC, open File Explorer, navigate to your phone's **Downloads** folder, and copy `app-debug.apk` into it.
5. On your phone, open your **Files** (or File Manager) app, go to **Downloads**, tap `app-debug.apk`, and tap **Install**.
   *(If prompted "Install unknown apps", toggle "Allow from this source" for your Files app).*

### Method B: Direct Download on Phone Browser
1. Open Google Chrome (or your default browser) on your phone.
2. Navigate to your GitHub repository: `https://github.com/<your-username>/<repo-name>/actions`.
3. Tap the latest workflow run and tap **`HabitFlowPro-Android-APK`** to download it directly.
4. Tap the downloaded file and choose **Install**.

---

## Project Structure

```
├── .github/workflows/
│   └── build_apk.yml             # Cloud CI/CD Android APK compiler
├── frontend/                     # Flutter Android Application
│   ├── android/                  # Android Gradle build & manifest configuration
│   ├── lib/                      # Flutter Dart source code
│   └── pubspec.yaml              # Riverpod, GoRouter, Dio dependencies
├── backend/                      # Node.js + Express + TypeScript API
│   ├── src/
│   │   ├── config/               # Environment & MongoDB Atlas connection
│   │   ├── controllers/          # Habit, Log, Goal, Journal, Auth controllers
│   │   ├── middleware/           # JWT auth & error handlers
│   │   ├── models/               # Mongoose schemas
│   │   └── routes/               # Express REST routes
│   ├── package.json
│   └── tsconfig.json
├── .gitignore
└── README.md
```
