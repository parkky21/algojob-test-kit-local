# AlgoJob AI Candidate Assistant — Core Knowledge Base & UI Navigation Guide

> **Official Host**: `https://algojob.ai`  
> **Audience**: Candidate / Student / Job Seeker  
> **Purpose**: Single authoritative source of truth for the AlgoJob candidate-facing AI chatbot. Contains zero hallucinations, 100% accurate UI mapping, direct links (`https://algojob.ai/...`), exact in-app icons (Lucide + emoji), rules, and step-by-step navigation workflows.

---

## 1. Chatbot Persona & Response Instructions

When interacting with candidates on **AlgoJob**, always follow these core principles:
1. **Candidate-First & Practical**: Speak with clarity, encouragement, and actionable guidance. Avoid corporate fluff.
2. **Always Provide Direct Links**: Whenever referencing a feature, screen, or assessment, give the full clickable URL (e.g., `https://algojob.ai/mock-interview`).
3. **Use App Icons for Visual Navigation**: Help candidates identify elements on screen by mentioning both the icon symbol and its name (e.g., "Click on 👤 **AI Interview** in the top navigation bar").
4. **Absolute Accuracy**: Never invent hypothetical features, alternative plans, or imaginary pricing tiers. Only state what actually exists on `https://algojob.ai`.

---

## 2. Master UI Navigation & Icon Index

Candidates see a floating top navigation bar (or mobile menu drawer via ☰ `Menu` on small screens) containing the core platform sections:

| Feature / Arena | In-App Lucide Icon | Emoji | Direct URL | Description |
| :--- | :--- | :---: | :--- | :--- |
| **Campus Buzz** | `Home` | 🏠 | `https://algojob.ai/dashboard` | Social feed for students: posts, peer discussions, achievements, follow peers. |
| **Analytics** | `BarChart2` | 📊 | `https://algojob.ai/analytics` | Personal diagnostic dashboard, radar charts, college & national leaderboards. |
| **Code Byte** | `Braces` | 💻 `{ }` | `https://algojob.ai/coding-assessment` | Structured 5-phase coding assessment (Understand, Plan, Implement, Refactor, Explain). |
| **Mock Aptitude** | `CheckSquare` | ☑️ | `https://algojob.ai/aptitude` | 20-question timed aptitude assessment across Quant, Reasoning, English & DI. |
| **Mock Debug** | `Bug` | 🐛 | `https://algojob.ai/debug` | 5 debugging scenarios: fix buggy code + explain logic out loud via microphone. |
| **Mock SVAR** | `MessageSquareText` | 💬 | `https://algojob.ai/mock-communication` | 4-round spoken English & voice communication assessment. |
| **AI Interview** | `User` | 👤 | `https://algojob.ai/mock-interview` | Live proctored AI technical/HR mock interview with real-time video & audio. |
| **Report** | `FileText` | 📄 | `https://algojob.ai/analysis` | Comprehensive history & deep-dive reports for all completed assessments. |
| **AlgoBuddy** | `HeartHandshake` | 🤝 | `https://algojob.ai/counselling` | Real-time AI guidance & counselling bridges (career, wellness, study planning). |
| **Payments / Pricing** | `CreditCard` | 💳 | `https://algojob.ai/subscriptions` | Subscription plans (Basic vs. Pro), top-up credit packs, and transaction receipts. |

### Top Header Utilities (Visible on Every Authenticated Page)
- 🔍 **Peer Search Bar** (`Search`): Centered in the top bar (`Search your peers...`). Type at least 2 characters to search candidates by name or email, view avatars, and click **Follow** / **Following** (👤➕ `UserPlus` / 👤✔️ `UserCheck`).
- ☀️ / 🌙 **Theme Switcher** (`Sun` / `Moon`): Click to seamlessly toggle between **Dark Mode** and **Light Mode** with circular reveal animation.
- 🔔 **Notification Bell** (`Bell` / `NotificationBell`): Shows unread alerts for ready test reports, score bonuses, or peer interactions. Full page: `https://algojob.ai/notifications`.
- 👑 **Pro Upgrade Badge** (`Crown` / `ProUpgradeBadge`): Displays current status or one-click upgrade button to AlgoJob Pro.
- 👤 **Profile Avatar Dropdown** (Top-Right):
  - Displays plan tag: **"Free Plan" (₹0)** or **"Pro User" (Crown 👑)** along with subscription renewal date.
  - ⚙️ **Account Settings**: `https://algojob.ai/account-settings`
  - 💳 **Pricing**: `https://algojob.ai/subscriptions`
  - 🚪 **Logout** (`LogOut`): Securely ends session and routes to the homepage.

---

## 3. Product Arenas & How to Navigate Them

### 3.1 👤 AI Interview
- **Direct Link**: `https://algojob.ai/mock-interview`
- **Icon**: `User` 👤
- **What It Is**: A full simulation of real-world hiring rounds with an AI interviewer asking contextual technical and behavioral questions over live video and audio.
- **Duration**: ~15 minutes.
- **Cost**: Requires **1 Interview Credit** OR **300 XP** to book a slot.
- **How to Book and Start an Interview**:
  1. Open `https://algojob.ai/mock-interview`.
  2. Under **"Build Your Persona"**, choose your selection mode:
     - **Role First**: Pick your Target Role (e.g. *Software Engineer*, *Product Manager*), then choose Organization/Company (e.g. *Google*, *TCS*, *Meta*), then choose Round Type ("Choose Your Pain Level": Technical, HR, etc.).
     - **Organization First**: Pick your Company first, then choose Role, then Round Type.
  3. Click **"Claim First Slot"** or **"Book Another Slot"** (➕ `Plus`).
  4. Select an available date and time window.
  5. In the **"Your Slots"** section:
     - 🔵 **UPCOMING**: Shows scheduled start time and countdown. You can click 🗑️ **Cancel** if you need to reschedule.
     - 🟢 **LIVE NOW**: The button illuminates as ⚡ **ENTER ARENA**.
     - 🔴 **MISSED IT**: Slot expired.
  6. When the slot is live, click ⚡ **ENTER ARENA** to enter the proctored interview room (`https://algojob.ai/interview/room/:id`).
- **Proctoring Rules**: Full-screen locked, active gaze tracking, zero-tolerance tab switching.
- **Past Interviews**: Listed at the bottom table under **"Completed AI Interviews"** with date, score, and a **"View Analysis"** button.

---

### 3.2 💻 Code Byte (Structured Coding Assessment)
- **Direct Link**: `https://algojob.ai/coding-assessment`
- **Icon**: `Braces` 💻 `{ }`
- **What It Is**: A rigorous, 5-phase structured coding assessment that tests end-to-end engineering skills rather than just memorized syntax.
- **Active Session Route**: `https://algojob.ai/coding-assessment/session`
- **Topic Filters**: Arrays, Strings, Hashing, Linked List, Bitwise, Stack & Queue, Two Pointers, Binary Search, Recursion, Trees & BST, Heap, Graphs, Dynamic Programming, Greedy.
- **Difficulty Filters**: Easy, Medium, Hard.
- **The 5 Timed Phases**:
  1. 🧠 **Phase 1: Understand** (`understand`): Read the problem description, review edge cases, and answer constraint verification questions.
  2. 📋 **Phase 2: Plan** (`plan`): Use the visual **Decomposition Board** & **Data Structure Board** to map out components, choose data structures, and define subproblems.
  3. ⌨️ **Phase 3: Implement** (`implement`): In the Monaco code editor, write your solution in your chosen programming language (Python, C++, Java, JavaScript). Run your code against sample test cases.
  4. 🔄 **Phase 4: Refactor** (`refactor`): Optimize time and space complexity, improve code cleanliness, and handle remaining corner cases.
  5. 🗣️ **Phase 5: Explain** (`explain`): Explain your algorithm, justifying your Big-O time and space complexity.
- **Key Rules**:
  - Each phase has its own individual countdown timer (`ServerCountdown`).
  - Progress is one-way: once you submit a phase, you cannot return to it.
  - Work autosaves continuously. If you accidentally reload, you resume in the current phase with remaining time.
  - Submitting or timer expiry auto-advances you to the next phase.
  - Completion report generated at `https://algojob.ai/coding-assessment/report?sessionId=...` and saved in 📄 **Report**.

---

### 3.3 ☑️ Mock Aptitude
- **Direct Link**: `https://algojob.ai/aptitude` *(legacy `/practice` redirects here)*
- **Icon**: `CheckSquare` ☑️
- **What It Is**: Fast-paced multiple-choice test simulating campus recruitment and corporate screening exams.
- **Format**: **20 questions** total, split across **4 distinct sections**:
  1. Quantitative Aptitude (**Quant**)
  2. Logical Reasoning (**Reasoning**)
  3. Verbal Ability (**English**)
  4. Data Interpretation (**DI**)
- **Rules & Constraints**:
  - **4 Section Clocks**: Each section has its own countdown clock. Unused time does *never* roll over to subsequent sections.
  - **One-Shot Locking**: Once you select and confirm an answer, it locks permanently. There is no back button.
  - **No Negative Marking**: Unanswered questions score zero—never leave a question blank!
  - **Clock Keeps Running**: Closing or refreshing the browser does not pause the timer.
- **Limits**:
  - Basic: 1 attempt/day, up to 3 attempts/week.
  - Pro: 4 attempts/week with no daily block.
  - Extra attempts can be unlocked using MCQ / Bundle Credits.
- **The 5 Diagnostic Quadrants** (visible in post-test analysis):
  - 🟢 **Mastered**: Correct answer, solved within expected pacing.
  - 🟡 **Fragile**: Correct answer, but spent too much time solving.
  - 🟠 **Careless**: Wrong answer due to rushing, or skipped with excess time on the clock (pacing issue).
  - 🔴 **Gap**: Wrong answer after genuine effort (fundamental conceptual knowledge gap).
  - ⚫ **Not Reached**: Section clock ran out before you reached the question.

---

### 3.4 🐛 Mock Debug
- **Direct Link**: `https://algojob.ai/debug`
- **Icon**: `Bug` 🐛
- **Test Room**: `https://algojob.ai/debug/start`
- **What It Is**: Test of real debugging ability and verbal code explanation.
- **Format**: **5 buggy code scenarios** within a single **15-minute server clock**.
- **How It Works**:
  1. Choose your language: C++, Java, Python, JavaScript, etc.
  2. Select your battlefield (Stream) and Difficulty level (Subject).
  3. Click **"ENTER THE DEBUG ARENA"** (or use bundle credits).
  4. In the test runner:
     - Review the broken code snippet.
     - Speak your reasoning into your microphone (30 seconds per question).
     - Fix the bug directly in the code editor.
     - Submit and move forward (answers lock immediately).
- **Proctoring**: Microphone required, full-screen lock enforced.
- **Results**: Deep-dive code analysis and verbal reasoning score generated at `https://algojob.ai/debug-results`.

---

### 3.5 💬 Mock SVAR (Spoken English & Communication)
- **Direct Link**: `https://algojob.ai/mock-communication`
- **Icon**: `MessageSquareText` 💬
- **Test Room**: `https://algojob.ai/mock-communication/assessment`
- **What It Is**: Automated AI evaluation of oral English communication, pronunciation, fluency, listening, and grammar.
- **Duration**: ~15 minutes total.
- **Hardware Requirements**: Working microphone AND functional speakers/headphones (audio prompt played beforehand).
- **The 4 Sequential Stages**:
  1. 📖 **Stage 1: Read Aloud**: Read on-screen sentences clearly. Evaluates pronunciation, cadence, and vocal fluency.
  2. 🎧 **Stage 2: Listen & Answer**: Listen to spoken audio clips and answer comprehension MCQs.
  3. 🎙️ **Stage 3: Speak Without Script**: Given an impromptu topic with minimal prep time, speak extemporaneously for the allotted time. Evaluates coherence, vocabulary, and impromptu structure.
  4. ✍️ **Stage 4: Grammar Police**: Fill-in-the-blank questions testing tense, syntax, and sentence structure.
- **Limits**: 1 test/day; weekly limits apply according to plan tier (or using SVAR bundle credits).

---

## 4. Performance, Reports & Leaderboards

### 4.1 📄 Report (All Assessment Reports)
- **Direct Link**: `https://algojob.ai/analysis`
- **Icon**: `FileText` 📄
- **Features**:
  - Unified library of all historical reports across **AI Interview**, **Aptitude**, **Debug**, **SVAR**, and **Coding Assessment**.
  - **Filter by Type**: All, SVAR, AI Interview, Aptitude, Debug, Coding Assessment.
  - **Filter by Status**: Completed, In Progress, Expired.
  - **Score Filters**: Filter reports by score criteria using `>= `, `<= `, or `== ` against target scores.
  - **Search**: Locate attempts by role name, company, or test title.
  - **View Modes**: Switch between **Grid** (card layout) and **Table** (compact list) via the top toggle.
  - **View Analysis Button**: Click on any card or row to open full granular analysis with radar breakdown, transcript reviews, quadrant classification, and actionable improvement steps.

### 4.2 📊 Analytics Dashboard
- **Direct Link**: `https://algojob.ai/analytics`
- **Icon**: `BarChart2` 📊
- **Features**:
  - **Leaderboards**: Real-time **National Rank** and **College Rank**.
  - **Diagnostic Radar**: Comprehensive visual mapping of your strengths across Quant, Logical Reasoning, Verbal, Coding, Debugging, and Interview Presence.
  - **Skill Growth Heatmaps**: Visualizes consistency, test completion frequency, and month-over-month score improvement.
  - **Recent Achievements**: Badges earned through practice milestones.

---

## 5. XP, Levels, Badges & Rewards

Candidates earn **Experience Points (XP)** through continuous practice:
- **Daily Login Streak**: Earn XP every day you open the app (tracked by the 🔥 `Flame` indicator).
- **Assessments**: Taking Aptitude, SVAR, Debug, and Coding tests awards XP based on effort and score.
- **AI Interviews**: Completing interviews grants significant XP rewards.
- **Profile Completion**: Completing all sections in `https://algojob.ai/account-settings` grants bonus XP.
- **Referrals**: Inviting friends via `https://algojob.ai/referrals` earns XP and free perks.

### ⚡ The XP-to-Credit Conversion Rule
> **300 XP = 1 Free AI Interview Credit!**  
> Candidates do NOT need to spend real money to take AI Mock Interviews. By practicing daily tests, earning 300 XP automatically unlocks an AI interview credit.

### 🎁 Reward Milestone Levels
Candidates level up as lifetime XP grows. Rewards can be claimed at month-end via the Claim Reward dialog:
1. **Insignia**: Official Skill Certificate
2. **Oracle**: 1 Free AI Mock Interview Credit
3. **Gauntlet**: Free AlgoSprint Competitive Access
4. **Mythos**: Official AlgoRoot Swag T-Shirt
5. **Warlord**: Exclusive Premium Career Swag & Gift Box

---

## 6. Plans, Subscriptions & Billing

Manage plans, buy credits, or view invoice receipts at: `https://algojob.ai/subscriptions`.

### 6.1 Plan Comparison (Basic vs. Pro)
| Feature | Basic Plan (Free - ₹0) | Pro Plan (Subscription) |
| :--- | :--- | :--- |
| **Arena Sessions (MCQ / Debug / SVAR)** | 3 attempts / week (daily limit enforced) | **4 attempts / week + No daily lockout** |
| **AI Mock Interviews** | 1 / month + 100 XP signup bonus (or earn via 300 XP) | **Unlimited attempts + Priority queue** |
| **Reports** | Basic score summaries | **Advanced pain-point autopsy & line-by-line feedback** |
| **XP Gain Rate** | 1.0x standard reward | **1.5x on level-ups + 2x milestone boost** |
| **Daily Challenges** | Limited access | **Curated daily challenges every morning** |
| **Top-Up Pack Discounts** | Standard price | **Up to 50% discount on credit bundles** |
| **Campus Buzz** | Read & post | **Blue verified checkmark badge** |
| **Customer Support** | Community help | **Direct mentor chat & priority escalation** |

### 6.2 Top-Up Credit Packs
Candidates can purchase top-ups without subscribing to Pro:
- **AI Interview Top-Up**: Extra standalone live interview sessions.
- **Assessment Bundle**: Extra MCQ + Debug + SVAR credits.
- **Combo Bundle**: All arena tests + AI Mock Interviews.
- **AlgoBuddy Pack**: Mentorship & counselling bridge credits.
- ⚠️ **Key Rule**: **Purchased top-up credits NEVER expire.** They remain in your account until used.

### 6.3 Billing & Refund Policy
- **Billing Cycles**: Available as Monthly or Yearly (yearly offers substantial cost savings).
- **Currency**: Indian Rupees (INR), inclusive of GST where applicable.
- **Refund Guarantee**: 7-day money-back guarantee for initial Pro subscription purchases. Contact support within 7 days of purchase.

---

## 7. Account Management & Profile Setup

- **Account Settings**: `https://algojob.ai/account-settings` (Icon: `Settings` ⚙️)
  - **Profile**: Full Name, Username, Bio, Avatar picture, Email, Mobile phone.
  - **Education**: College/University name, Degree, Branch/Stream, Graduation Year, CGPA.
  - **Location**: Country, State, City.
  - **Links**: LinkedIn, GitHub, LeetCode, Personal Portfolio website.
  - **Skills**: Add programming languages, frameworks, and technical domains.
  - **Billing**: View active subscription plan, renewal date, and downloadable invoices.
  - **Security**: Update password.
- **Public Profile View**: `https://algojob.ai/profile` (see how peers view your achievements and stats).

---

## 8. Proctoring, Anti-Cheating & System Requirements

All assessments run entirely in the web browser (Chrome, Edge, Brave, Firefox, Safari). No desktop app download is needed.

### Hardware Check Flow (Before Starting Any Proctored Arena):
1. **Browser Compatibility Check**: Modern Chromium-based or modern browser with WebRTC support.
2. **Camera Check**: Required for AI Interview and Code Byte. Must have an unobstructed front view of the face.
3. **Microphone Check**: Required for AI Interview, Mock SVAR, Mock Debug, and Code Byte. Test input levels before proceeding.
4. **Speaker / Audio Check**: Required for SVAR and AI Interview. Test sample audio to confirm you can hear prompts.
5. **Screen Share Verification**: Required for full proctoring. You must share your entire screen, not just a single tab or window.
6. **Single Monitor Check**: Multiple monitors are prohibited. If an external display is connected, you must disconnect it before the test starts.

### Anti-Cheating Violations:
- **Tab Switching / Alt+Tab**: Switching away from the exam tab is immediately flagged.
- **Fullscreen Exit**: Assessments force full-screen mode. Exiting triggers an instant warning modal.
- **Window Blur / Mouse Leave**: Clicking outside the assessment container records a violation.
- **Copy-Paste & Right-Click**: Context menus and clipboard pasting are locked during test sessions.
- **Violation Cap**: Reaching **5 violations** will **instantly terminate and force-submit** your assessment. Any untouched questions will be marked unreached and score zero.

---

## 9. Quick Navigation Lookup (URLs & Icons Summary)

Whenever a candidate asks how to reach something, give them the exact icon and link:

| Destination | App Icon | Link |
| :--- | :---: | :--- |
| **Practice Aptitude** | ☑️ `CheckSquare` | `https://algojob.ai/aptitude` |
| **Practice Spoken English (SVAR)** | 💬 `MessageSquareText` | `https://algojob.ai/mock-communication` |
| **Practice Code Debugging** | 🐛 `Bug` | `https://algojob.ai/debug` |
| **Take 5-Phase Coding Test** | 💻 `{ }` `Braces` | `https://algojob.ai/coding-assessment` |
| **Take AI Mock Interview** | 👤 `User` | `https://algojob.ai/mock-interview` |
| **View Test Reports & Autopsies** | 📄 `FileText` | `https://algojob.ai/analysis` |
| **Check Rankings & Skill Radar** | 📊 `BarChart2` | `https://algojob.ai/analytics` |
| **Campus Buzz Feed & Peer Discussion**| 🏠 `Home` | `https://algojob.ai/dashboard` |
| **Upgrade to Pro or Buy Credits** | 💳 `CreditCard` | `https://algojob.ai/subscriptions` |
| **Edit Profile & Resume Links** | ⚙️ `Settings` | `https://algojob.ai/account-settings` |
| **View Notifications** | 🔔 `Bell` | `https://algojob.ai/notifications` |
| **Invite Friends & Earn Rewards** | 🎁 `Share2` | `https://algojob.ai/referrals` |
| **Career Counselling (AlgoBuddy)** | 🤝 `HeartHandshake` | `https://algojob.ai/counselling` |
| **Candidate Login** | 🔑 `LogIn` | `https://algojob.ai/user/login` |
| **Candidate Signup** | 📝 `UserPlus` | `https://algojob.ai/user/signup` |
