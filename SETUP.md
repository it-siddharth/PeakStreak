# PeakStreak Widget Setup Guide

## Step-by-Step: Adding the Widget to Your App

### Step 1: Add Widget Extension Target in Xcode

1. Open `PeakStreak.xcodeproj` in Xcode
2. Click **File > New > Target...**
3. Search for "Widget" and select **Widget Extension**
4. Click **Next**
5. Fill in the details:
   - **Product Name**: `PeakStreakWidget`
   - **Team**: Select your team
   - **Bundle Identifier**: Should auto-fill as `com.itsiddharth.PeakStreak.PeakStreakWidget`
   - **Include Live Activity**: **Uncheck** this
   - **Include Configuration App Intent**: **Check** this ✓
6. Click **Finish**
7. When asked "Activate PeakStreakWidget scheme?", click **Activate**

### Step 2: Replace Auto-Generated Widget Files

Xcode created some template files. Replace them with the custom ones:

1. In the Project Navigator, find the new `PeakStreakWidget` group
2. **Delete** all the auto-generated `.swift` files in that group (select them, right-click > Delete, choose "Move to Trash")
3. Right-click on the `PeakStreakWidget` group > **Add Files to "PeakStreak"...**
4. Navigate to the `PeakStreakWidget` folder in Finder
5. Select these files:
   - `PeakStreakWidget.swift`
   - `StreakWidgetView.swift`
6. Make sure **"Copy items if needed"** is checked
7. Make sure **"Add to targets"** has `PeakStreakWidget` selected
8. Click **Add**

### Step 3: Configure App Groups (Critical for Data Sharing!)

**For the Main App:**
1. In Project Navigator, click on `PeakStreak` project (blue icon at top)
2. Select **PeakStreak** target (under TARGETS)
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Search for and add **App Groups**
6. Click the **+** under App Groups
7. Enter: `group.com.itsiddharth.PeakStreak`
8. Press Enter

**For the Widget:**
1. Select **PeakStreakWidget** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **App Groups**
5. Check the same group: `group.com.itsiddharth.PeakStreak`

### Step 4: Build and Run

1. Select the **PeakStreak** scheme (not the widget scheme)
2. Select your device or simulator
3. Press **Cmd + R** to build and run
4. Create at least one habit in the app

### Step 5: Add Widget to Home Screen

**On Simulator:**
1. Press **Cmd + Shift + H** to go to home screen
2. Long press on the home screen background
3. Tap the **+** button in the top left
4. Search for "PeakStreak"
5. Select a widget size (Small or Medium)
6. Tap **Add Widget**
7. Long press the widget and tap **Edit Widget** to select which habit to display

**On Physical Device:**
1. Go to home screen
2. Long press on empty area
3. Tap **+** in top left corner
4. Search "PeakStreak"
5. Choose size and add
6. Long press widget > Edit Widget to configure

---

## Troubleshooting

### Widget Not Appearing in Widget Gallery
- Make sure you built and ran the main app at least once
- The widget extension must be embedded in the main app
- Check that the widget target's "Embed in Application" is set to PeakStreak

### Widget Shows "No Habit Selected"
- Open the main app and create at least one habit
- Long press the widget > Edit Widget > Select a habit
- Make sure App Groups are configured identically on both targets

### Widget Not Updating
- Widgets update on a schedule, not in real-time
- Force update: Edit the widget configuration or restart the app

### Build Errors About Missing Types
- Ensure `PeakStreakWidget.swift` and `StreakWidgetView.swift` are added to the widget target
- The model classes are duplicated inside `PeakStreakWidget.swift` - this is intentional

---

## Architecture Notes

The widget uses a self-contained copy of the data models to avoid complex shared framework setups. Data is shared between the app and widget via:

1. **App Groups**: Both targets use `group.com.itsiddharth.PeakStreak`
2. **SwiftData Store**: Located in the shared container at `PeakStreak.store`
3. **Read-Only Access**: Widget only reads data; main app writes

The widget supports:
- **Small**: 7-week contribution grid
- **Medium**: 14-week grid with streak counter
- **Configuration**: Users can select which habit to display per widget instance
