# Create Habit Feature Specification

**Document Version:** 1.0  
**Last Updated:** 2025-11-08  
**Feature:** Add/Create New Habit

---

## Table of Contents
- [Overview](#overview)
- [User Interface Components](#user-interface-components)
- [Field Specifications](#field-specifications)
- [Frequency Types](#frequency-types)
- [Notification System](#notification-system)
- [Data Model](#data-model)
- [User Flow](#user-flow)
- [Validation Rules](#validation-rules)
- [Examples](#examples)

---

## Overview

The Create Habit feature allows users to define new habits they want to track. Users can customize various aspects including title, description, visual appearance (icon and color), frequency pattern, optional scheduled time, and privacy settings.

### Access Point
- **Location:** Floating Action Button (FAB) on the Habits Tab
- **Button Label:** "New Habit"
- **Icon:** Plus (+) symbol

---

## User Interface Components

### Screen Layout
The Add Habit screen consists of the following sections in order:

1. **App Bar**
   - Title: "New Habit"
   - Back button (left)
   - Save button (right)

2. **Form Fields** (scrollable)
   - Habit Title (required)
   - Description (optional)
   - Icon Selection
   - Color Selection
   - Frequency Selection
   - Custom Days Selector (conditional)
   - Scheduled Time Picker (optional)
   - Share Toggle

---

## Field Specifications

### 1. Habit Title

**Field Type:** Text Input  
**Label:** "Habit Title"  
**Placeholder:** "e.g., Morning Exercise"  
**Required:** Yes  
**Character Limit:** None (reasonable length expected)  
**Text Capitalization:** Sentences (first letter uppercase)

**Validation Rules:**
- ❌ Cannot be empty
- ❌ Cannot be only whitespace
- ✅ Must contain at least one character after trimming

**Error Message:**
```
"Please enter a habit title"
```

**Storage:**
- Stored trimmed (leading/trailing whitespace removed)
- Database field: `title` (TEXT NOT NULL)

---

### 2. Description

**Field Type:** Multi-line Text Input  
**Label:** "Description (optional)"  
**Placeholder:** "Add more details..."  
**Required:** No  
**Max Lines:** 3  
**Text Capitalization:** Sentences

**Behavior:**
- If left empty → Stored as `null` in database
- If filled → Stored trimmed (whitespace removed)
- Appears in:
  - Habit detail screen
  - Notification body (if set)

**Storage:**
- Database field: `description` (TEXT, nullable)

---

### 3. Icon Selection

**Component Type:** Icon Grid Selector  
**Label:** "Choose an Icon"  
**Required:** No (optional)  
**Default:** None selected

**Available Icons:** (16 total)
```
fitness          → fitness_center icon
book             → book icon
water            → water_drop icon
sleep            → bedtime icon
restaurant       → restaurant icon
run              → directions_run icon
meditation       → spa icon
yoga             → self_improvement icon
art              → palette icon
music            → music_note icon
work             → work icon
school           → school icon
heart            → favorite icon
walk             → directions_walk icon
bike             → directions_bike icon
code             → code icon
```

**Visual Behavior:**
- **Unselected:** Gray background (`Colors.grey.shade200`)
- **Selected:** 
  - Primary container background color
  - Primary color border (2px)
  - Primary color icon
- Grid layout: 8px spacing, wrapped

**Storage:**
- Stored as icon name string (e.g., "fitness", "book")
- Database field: `icon` (TEXT, nullable)

**Usage:**
- Displayed on habit cards
- Used in notifications (Android only, via icon mapping)
- Visual identification of habit type

---

### 4. Color Selection

**Component Type:** Color Picker (Circle Grid)  
**Label:** "Choose a Color"  
**Required:** Yes  
**Default:** `#6366F1` (Indigo)

**Available Colors:** (8 options)
```
#6366F1  → Indigo (default)
#EF4444  → Red
#10B981  → Green
#F59E0B  → Amber
#8B5CF6  → Purple
#EC4899  → Pink
#06B6D4  → Cyan
#F97316  → Orange
```

**Visual Behavior:**
- Circular color swatch (48x48px)
- **Selected:** Black border (3px) + white checkmark icon
- **Unselected:** Plain color circle
- Grid layout: 8px spacing, wrapped

**Storage:**
- Stored as hex color string with # prefix
- Database field: `color` (TEXT, NOT NULL, default: '#6366F1')

**Usage:**
- Habit card background/accent
- Progress indicators
- Notification color (Android only)
- Visual categorization

---

### 5. Frequency Selection

**Component Type:** Segmented Button (Radio Group)  
**Label:** "Frequency"  
**Required:** Yes  
**Default:** Daily

**Options:**
1. **Daily** 
   - Icon: `calendar_today`
   - Label: "Daily"
   
2. **Weekly**
   - Icon: `calendar_view_week`
   - Label: "Weekly"
   
3. **Custom**
   - Icon: `edit_calendar`
   - Label: "Custom"

**Visual Behavior:**
- Material 3 segmented button design
- Only one option selectable at a time
- Selected option highlighted with primary color

**Storage:**
- Stored as enum index (0=daily, 1=weekly, 2=custom)
- Database field: `frequency` (INTEGER, default: 0)

---

## Frequency Types

### 📆 Daily Frequency

**Behavior:**
```
User selects: "Daily"
```

**Today's Journey:**
- ✅ Appears **every single day**
- No exceptions, no skips

**Notification Schedule:**
- If scheduled time set → Fires **every day** at (time - 30 min)
- Uses `matchDateTimeComponents: DateTimeComponents.time`
- Auto-repeats indefinitely

**Completion:**
- Can be completed every day
- Streak increases daily
- Missed days break streak

**Use Cases:**
- Morning routine
- Daily medication
- Water intake
- Exercise
- Journaling

**Example:**
```
Habit: "Morning Exercise"
Frequency: Daily
Scheduled Time: 7:00 AM

Result:
- Appears in Today's Journey: Every day
- Notification: 6:30 AM every day
- Can complete: Every day
```

---

### 📅 Weekly Frequency

**Behavior:**
```
User selects: "Weekly"
Creation Day: [Automatically captured from habit.createdAt]
```

**Today's Journey:**
- ✅ Appears **only on the same weekday** the habit was created
- Uses `habit.createdAt.weekday` to determine the weekly day

**Notification Schedule:**
- If scheduled time set → Fires **once per week** on creation weekday at (time - 30 min)
- Uses `matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime`
- Auto-repeats weekly

**Completion:**
- Can only be completed on the designated weekday
- Missed week breaks streak
- Streak increases weekly

**Use Cases:**
- Weekly therapy session
- Church/religious service
- Weekly planning
- Cheat meal day
- Team meetings

**Important Notes:**
- ⚠️ The weekly day is **determined by creation date**
- ⚠️ User **cannot change** which day of the week (by design)
- ⚠️ If user wants a different day → Must delete and recreate habit on that day

**Example 1:**
```
User creates habit on: Wednesday, Nov 8, 2025
Habit: "Yoga Class"
Frequency: Weekly
Scheduled Time: 6:00 PM

Result:
- Appears in Today's Journey: Every Wednesday
- Notification: 5:30 PM every Wednesday
- Cannot complete: Mon, Tue, Thu, Fri, Sat, Sun
- Can complete: Wednesday only
```

**Example 2:**
```
User creates habit on: Sunday, Nov 10, 2025
Habit: "Meal Prep"
Frequency: Weekly
Scheduled Time: 10:00 AM

Result:
- Appears in Today's Journey: Every Sunday
- Notification: 9:30 AM every Sunday
- Weekly occurrence: Sunday
```

**Weekday Mapping:**
```
DateTime.weekday values:
1 = Monday
2 = Tuesday
3 = Wednesday
4 = Thursday
5 = Friday
6 = Saturday
7 = Sunday

Storage (0-based for custom days):
0 = Monday
1 = Tuesday
2 = Wednesday
3 = Wednesday
4 = Thursday
5 = Friday
6 = Saturday
```

---

### 🗓️ Custom Frequency

**Behavior:**
```
User selects: "Custom"
System shows: Day selector chips (Mon-Sun)
User selects: One or more days
```

**Day Selector UI:**
- 7 filter chips: Mon, Tue, Wed, Thu, Fri, Sat, Sun
- Multi-select enabled
- **Visual States:**
  - Unselected: Default chip style
  - Selected: Primary color background + checkmark

**Today's Journey:**
- ✅ Appears **only on selected days**
- Checks if `habit.customDays.contains(todayIndex)`

**Notification Schedule:**
- Creates **separate notification for each selected day**
- Each notification has unique ID: `${habitId}_day${dayIndex}`
- All notifications repeat weekly on their respective days
- Uses `matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime`

**Completion:**
- Can only be completed on selected days
- Other days: habit doesn't appear at all
- Streak logic: Based on selected days pattern

**Storage:**
- Array of day indices (0-6, where 0=Monday, 6=Sunday)
- Database field: `custom_days` (INTEGER[], default: [])
- Example: `[0, 2, 4]` = Monday, Wednesday, Friday

**Use Cases:**
- Gym days (Mon, Wed, Fri)
- Work-from-home days
- Specific weekday routines
- Flexible schedules
- Part-time commitments

**Validation:**
- ⚠️ If Custom selected → At least one day should be selected (optional validation)
- ⚠️ Empty selection = habit never appears in Today's Journey

**Example 1:**
```
Habit: "Gym Workout"
Frequency: Custom
Selected Days: Mon, Wed, Fri (indices: [0, 2, 4])
Scheduled Time: 6:00 PM

Result:
- Appears in Today's Journey: Monday, Wednesday, Friday
- Notifications: 
  → Monday 5:30 PM (ID: habitId_day0)
  → Wednesday 5:30 PM (ID: habitId_day2)
  → Friday 5:30 PM (ID: habitId_day4)
- Cannot complete: Tue, Thu, Sat, Sun
- Can complete: Mon, Wed, Fri
```

**Example 2:**
```
Habit: "Client Meetings"
Frequency: Custom
Selected Days: Tue, Thu (indices: [1, 3])
Scheduled Time: 2:00 PM

Result:
- Appears in Today's Journey: Tuesday, Thursday
- Notifications:
  → Tuesday 1:30 PM (repeats weekly)
  → Thursday 1:30 PM (repeats weekly)
- Only appears twice per week
```

**Example 3: Weekend Only**
```
Habit: "Meal Prep"
Frequency: Custom
Selected Days: Sat, Sun (indices: [5, 6])
Scheduled Time: 10:00 AM

Result:
- Appears in Today's Journey: Saturday, Sunday only
- Notifications:
  → Saturday 9:30 AM
  → Sunday 9:30 AM
- Weekday habits separate from weekend habits
```

---

### 6. Scheduled Time

**Component Type:** Time Picker  
**Label:** "Scheduled Time"  
**Sublabel:** "Optional"  
**Required:** No  
**Default:** None (null)

**Behavior:**
- Tap button → Opens native time picker dialog
- Time displayed in 12/24 hour format (based on device settings)
- Shows "Select time" when not set
- Clear button (X) appears when time is selected

**Visual States:**
- **Not Set:**
  - Gray background
  - Gray border (1px)
  - Gray clock icon
  - Text: "Select time" (gray)
  
- **Set:**
  - Light background
  - Primary color border (2px)
  - Primary color clock icon
  - Text: Selected time (bold, primary color)
  - Clear button visible

**Time Handling:**
- Stored as DateTime with only hour/minute significant
- Date portion set to creation date (but only time used)
- Past time validation:
  - If selected time < current time → Automatically schedules for tomorrow
  - User sees orange snackbar: "Note: Notification scheduled for tomorrow at [time]"

**Notification Behavior:**
- If time set → Notification fires **30 minutes before** scheduled time
- Notification respects habit frequency:
  - Daily → Every day at (time - 30 min)
  - Weekly → Same weekday at (time - 30 min)
  - Custom → Selected days at (time - 30 min)

**Storage:**
- Database field: `scheduled_time` (TIMESTAMPTZ, nullable)
- Stored as full timestamp but only hour/minute used

**Example:**
```
User selects: 6:00 PM
Current time: 2:00 PM

Storage: 2025-11-08 18:00:00 (full datetime)
Usage: Only 18:00 (6:00 PM) time portion
Notification: 5:30 PM (30 min before)
```

---

### 7. Share with Friends

**Component Type:** Switch with description  
**Label:** "Share with friends"  
**Description:** "Let your friends see your progress"  
**Required:** No  
**Default:** False (off)

**Behavior:**
- Toggle switch ON → `isPublic = true`
- Toggle switch OFF → `isPublic = false`

**Effects:**
- **When ON:**
  - Friends can see this habit in activity feed
  - Completions generate activity posts
  - Friends receive notifications of milestones
  
- **When OFF:**
  - Habit is private
  - Only visible to user
  - No activity feed posts

**Storage:**
- Database field: `is_public` (BOOLEAN, default: false)

---

## Data Model

### Habit Object Structure

```dart
class Habit {
  final String id;              // UUID v4, auto-generated
  final String userId;          // User's ID (from auth)
  final String title;           // Required, user input
  final String? description;    // Optional, user input
  final String? icon;           // Optional, selected icon name
  final String color;           // Required, hex color (default: #6366F1)
  final HabitFrequency frequency; // Required, enum (0=daily, 1=weekly, 2=custom)
  final List<int> customDays;   // Empty if not custom, [0-6] if custom
  final int targetCount;        // Default: 1 (future: allow user to set)
  final DateTime createdAt;     // Auto-set to DateTime.now()
  final bool isPublic;          // User toggle, default: false
  final DateTime? scheduledTime; // Optional, time picker value
  
  // Tracking fields (managed by system)
  int currentStreak;            // Default: 0
  int longestStreak;            // Default: 0
  DateTime? lastCompletedDate;  // Default: null
  int totalCompletions;         // Default: 0
  final List<String> accountabilityPartners; // Future feature
}
```

### Supabase Database Schema

```sql
CREATE TABLE habits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  color TEXT DEFAULT '#6366F1',
  frequency INTEGER DEFAULT 0,  -- 0=daily, 1=weekly, 2=custom
  custom_days INTEGER[] DEFAULT '{}',
  target_count INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  is_public BOOLEAN DEFAULT false,
  scheduled_time TIMESTAMPTZ,  -- Only hour/minute used
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  total_completions INTEGER DEFAULT 0,
  last_completed_date TIMESTAMPTZ,
  accountability_partners UUID[] DEFAULT '{}',
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## User Flow

### Complete Creation Flow

```
1. User taps "New Habit" FAB
   ↓
2. Add Habit Screen opens
   ↓
3. User enters title (required)
   - Real-time validation
   - Error if empty on save
   ↓
4. User enters description (optional)
   - Can skip
   ↓
5. User selects icon (optional)
   - Visual feedback on selection
   - Can skip (no default)
   ↓
6. User selects color (required)
   - Default: Indigo (#6366F1)
   - Shows checkmark on selected
   ↓
7. User selects frequency (required)
   - Default: Daily
   - Options: Daily, Weekly, Custom
   ↓
8. IF Custom selected:
   - Custom day chips appear
   - User selects one or more days
   - Days stored as indices [0-6]
   ↓
9. User sets scheduled time (optional)
   - Tap "Select time"
   - Native time picker opens
   - Time displays if selected
   - Can clear with X button
   ↓
10. User toggles "Share with friends" (optional)
    - Default: OFF
    - ON = public habit
    ↓
11. User taps "Save" button
    ↓
12. Validation runs:
    - Title not empty? ✓
    ↓
13. Habit object created with:
    - UUID generated
    - User ID attached
    - Created timestamp set
    - Default values for tracking fields
    ↓
14. Data saved to Supabase
    ↓
15. IF scheduled time set:
    - Notification permissions requested (if not granted)
    - Notification scheduled based on frequency
    ↓
16. Screen closes
    ↓
17. User returns to Habits Tab
    - New habit appears in list
    - If should appear today → Shows in "Today's Journey"
```

---

## Validation Rules

### On Save (Save Button Tap)

**Required Validations:**
1. ✅ Title must not be empty
2. ✅ Title must not be only whitespace

**Optional Field Checks:**
- Description → If empty, save as null
- Icon → If not selected, save as null
- Scheduled Time → If not selected, save as null
- Custom Days → If custom frequency but no days selected, save empty array

**UI Feedback:**
- Invalid fields show red error message below field
- Save button disabled while saving (prevents double-tap)
- Loading indicator in app bar during save

---

## Notification System Integration

### Notification Scheduling Logic

```
IF habit.scheduledTime != null {
  
  1. Initialize NotificationService
  
  2. Request permissions (Android 13+, iOS)
     - If denied → Show warning snackbar
     - If granted → Continue
  
  3. Based on habit.frequency:
  
     CASE Daily:
       - Create 1 notification
       - ID: habit.id.hashCode
       - Schedule for: (scheduledTime - 30 min) today or tomorrow
       - Repeat: matchDateTimeComponents.time (daily)
     
     CASE Weekly:
       - Create 1 notification
       - ID: habit.id.hashCode
       - Schedule for: Next occurrence of createdAt.weekday
       - Time: (scheduledTime - 30 min)
       - Repeat: matchDateTimeComponents.dayOfWeekAndTime (weekly)
     
     CASE Custom:
       - Create N notifications (N = number of selected days)
       - IDs: ${habit.id}_day0, ${habit.id}_day1, etc.
       - Schedule for: Each selected day
       - Time: (scheduledTime - 30 min) on each day
       - Repeat: matchDateTimeComponents.dayOfWeekAndTime (weekly)
  
  4. Notification content:
     - Title: "🔔 Time for: [habit.title]"
     - Body: [habit.description] OR "Your habit starts in 30 minutes. Get ready! 💪"
     - Icon: Habit icon (Android only) or app icon
     - Color: Habit color (Android only)
}
```

---

## Examples

### Example 1: Simple Daily Habit

**User Input:**
```
Title: "Drink Water"
Description: ""
Icon: water
Color: #06B6D4 (Cyan)
Frequency: Daily
Scheduled Time: None
Share: OFF
```

**Result:**
```
✅ Appears in Today's Journey: Every day
✅ Can be completed: Every day
❌ No notifications (no time set)
✅ Private (not shared with friends)
```

---

### Example 2: Weekly Habit with Notification

**User Input:**
```
Title: "Therapy Session"
Description: "Weekly mental health check-in"
Icon: heart
Color: #EC4899 (Pink)
Frequency: Weekly
Created: Thursday
Scheduled Time: 3:00 PM
Share: OFF
```

**Result:**
```
✅ Appears in Today's Journey: Every Thursday only
✅ Can be completed: Thursday only
✅ Notification: 2:30 PM every Thursday
✅ Private
📅 Weekly occurrence: Thursday (from creation date)
```

---

### Example 3: Custom Days Gym Routine

**User Input:**
```
Title: "Gym Workout"
Description: "Upper body: Mon/Fri, Lower body: Wed"
Icon: fitness
Color: #EF4444 (Red)
Frequency: Custom
Selected Days: Monday, Wednesday, Friday
Scheduled Time: 6:00 PM
Share: ON
```

**Result:**
```
✅ Appears in Today's Journey: Mon, Wed, Fri only
✅ Can be completed: Mon, Wed, Fri only
✅ Notifications: 
   → Monday 5:30 PM (repeats weekly)
   → Wednesday 5:30 PM (repeats weekly)
   → Friday 5:30 PM (repeats weekly)
✅ Public (friends can see in activity feed)
📅 Total: 3 notifications created
```

---

### Example 4: Morning Routine with Past Time

**User Input:**
```
Title: "Morning Exercise"
Description: ""
Icon: run
Color: #10B981 (Green)
Frequency: Daily
Current Time: 10:00 AM
Scheduled Time: 7:00 AM (PAST TIME)
Share: OFF
```

**System Behavior:**
```
⚠️ Time is in the past!
→ Automatically schedules for tomorrow
→ Shows snackbar: "Note: Notification scheduled for tomorrow at 7:00 AM"

Result:
✅ Appears in Today's Journey: Every day
✅ First notification: Tomorrow at 6:30 AM
✅ Then repeats: Every day at 6:30 AM
```

---

## Technical Notes

### Performance Considerations
- Form fields use local state (not provider)
- Validation only on save (not real-time except title)
- Debounced text input for description
- Lazy loading of icon grid

### Platform Differences
- **Android:**
  - Custom notification icons supported
  - Notification colors visible
  - Exact alarm permission required (Android 12+)
  
- **iOS:**
  - App icon only in notifications
  - No custom colors
  - Permission prompt on first use

### Edge Cases Handled
1. ✅ User selects Custom but no days → Habit still saves, never appears
2. ✅ User selects past time → Auto-schedules for tomorrow
3. ✅ Notification permission denied → Habit still saved, warning shown
4. ✅ Weekly habit created late at night → Appears next week same day
5. ✅ Custom days all unselected → Habit orphaned (by design, user choice)

---

## Future Enhancements

### Potential Features (Not Yet Implemented)
- [ ] Target count customization (currently fixed at 1)
- [ ] Multiple scheduled times per day
- [ ] Reminder intervals (not just 30 min before)
- [ ] Accountability partners assignment
- [ ] Template habits (pre-filled common habits)
- [ ] Habit categories/tags
- [ ] Change weekly day after creation
- [ ] Biweekly/monthly frequency options
- [ ] Smart suggestions based on user behavior

---

## Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-11-08 | Initial specification document |
| 1.0 | 2025-11-08 | Fixed weekly frequency to use creation day |
| 1.0 | 2025-11-08 | Added recurring notifications for all frequencies |

---

**End of Specification**

