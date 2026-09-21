# AlgoJob AI Candidate Assistant — Test Environments & Assessment Deep-Dive

> **Official Host**: `https://algojob.ai`  
> **Audience**: Candidate / Student / Job Seeker  
> **Purpose**: In-depth, 100% accurate manual for all test runners, assessment mechanics, runtime states, scoring systems, and proctoring policies on AlgoJob.

---

## 1. Unified Assessment Architecture & The Test Runner

All assessments on AlgoJob (Aptitude, Code Byte, Debug, SVAR, AI Interview) are powered by the **Assessment Shell** (`AssessmentShell.tsx`). This provides a seamless, secure in-browser test environment.

### 1.1 The Pre-Test Hardware Wizard (6-Step Check)
Before entering any proctored test, candidates pass through a sequential hardware verification wizard:
1. **Browser Check**: Verifies Chromium or modern browser with HTML5/WebRTC support.
2. **Camera Check**: Captures video stream, checks framing, face lighting, and camera availability.
3. **Microphone Check**: Listens for voice input, displays real-time green audio level bar.
4. **Speaker / Audio Output Check**: Plays an audio tone and requires the candidate to click "I heard it" (essential for SVAR and AI Interview).
5. **Screen Share Verification**: Candidate must share their **"Entire Screen"**. Sharing only a single application window or browser tab is rejected.
6. **Single Monitor Check**: Detects connected displays. If dual monitors or an HDMI/USB-C external display is detected, the test blocks until the external display is unplugged.

*Note on Resumed Sessions*: If a candidate reloads or reconnects to an in-flight test, the wizard runs in **Fast Re-acquire Mode** to quickly reconnect camera/mic/screen share without re-asking introductory setup questions.

---

### 1.2 In-Test Proctoring & Violation Mechanics
During the test, background detectors continuously monitor compliance:
- **Tab Lock & Alt-Tab**: Any window switch, tab change, or application switch emits a `violation`.
- **Fullscreen Enforcement**: Tests require native fullscreen. Exiting triggers the `FullscreenReentryModal`, blocking the test canvas until the candidate clicks **"Re-enter Fullscreen"**.
- **Window Blur / Mouse Leave**: Clicking outside the test window or moving the mouse off-screen triggers a warning.
- **Clipboard & Context Menu**: Right-clicking and copy-pasting (`Ctrl+C`, `Ctrl+V`, `Cmd+C`, `Cmd+V`) are intercepted and blocked.
- **Screen Share Loss**: If screen share stops, the test automatically pauses into the `ReacquireHardwareModal`.
- **The 5-Violation Rule**:
  - Violation 1: Warning banner / toast displayed.
  - Violations 2–4: Progressive warning dialogs.
  - **Violation 5**: **Immediate termination and force-submission.** The test ends instantly, untouched questions are marked `unreached` (scored 0), and the daily attempt is forfeited.

---

## 2. In-Depth Guide to Each Test Environment

### 2.1 Mock Aptitude (The 20-Question Timed Challenge)
- **Direct Link**: `https://algojob.ai/aptitude` (runner at `/aptitude/test`)
- **Icon**: `CheckSquare` ☑️
- **Arena Key**: `mcq`
- **Total Questions**: **20 questions** across **4 sections** (5 questions per section):
  1. Quantitative Aptitude (**Quant**)
  2. Logical Reasoning (**Reasoning**)
  3. Verbal Ability (**English**)
  4. Data Interpretation (**DI**)

#### Execution & Clock Rules:
- **Per-Section Timers**: Each of the 4 sections has its own isolated countdown clock (`useSectionClock`). 
  - If you finish a section early, the remaining time **does not carry over** to the next section.
  - When the section timer expires, any unanswered questions in that section are marked `unreached`, and the test auto-advances to the next section.
- **One-Shot Locking**:
  - Once a candidate selects an option (A, B, C, D) and confirms, the answer is locked with the server.
  - There is **no question palette or back button**. You cannot revisit earlier questions.
- **No Negative Marking**:
  - Incorrect answers and blanks score 0. Candidates should always select their best guess before confirming.
- **Refresh & Disconnect Proof**:
  - The current question index is derived directly from the server's list of locked answers (`answered.length`).
  - Reloading the page re-fetches the current server session without resetting the timer or losing locked answers.

#### 5 Diagnostic Performance Quadrants (Post-Test Report):
Every question is categorized in the post-test autopsy at `https://algojob.ai/analysis`:
1. 🟢 **Mastered**: Correct answer, solved within expected pacing time.
2. 🟡 **Fragile**: Correct answer, but candidate took significantly longer than normal. Indicates lack of formula fluency or manual calculation drag.
3. 🟠 **Careless**: Incorrect answer, but answered in less than half the expected time (or skipped hastily). Indicates rushing and careless errors.
4. 🔴 **Gap**: Incorrect answer despite spending significant time attempting it. Indicates a fundamental conceptual knowledge gap.
5. ⚫ **Not Reached**: The section clock expired before the candidate reached this question.

---

### 2.2 Code Byte (Structured 5-Phase Coding Assessment)
- **Direct Link**: `https://algojob.ai/coding-assessment`
- **Runner Route**: `https://algojob.ai/coding-assessment/session`
- **Icon**: `Braces` 💻 `{ }`
- **Supported Languages**: Python, C++, Java, JavaScript.
- **Editor**: Monaco Code Editor (VS Code in the browser) with syntax highlighting, auto-indentation, and line numbers.

#### The 5 Guided Phases:
Unlike traditional coding platforms where candidates blindly jump into coding, Code Byte enforces structured engineering problem-solving:

```
[Phase 1: Understand] ➡️ [Phase 2: Plan] ➡️ [Phase 3: Implement] ➡️ [Phase 4: Refactor] ➡️ [Phase 5: Explain]
```

1. 🧠 **Phase 1: Understand (`understand`)**:
   - Candidate reads the problem statement, constraints, and examples.
   - Must answer multiple-choice comprehension questions verifying boundary constraints (e.g. array size, negative numbers, empty inputs, null cases).
2. 📋 **Phase 2: Plan (`plan`)**:
   - Interactive visual workspace:
     - **Decomposition Board**: Select subproblems, define step-by-step logic, identify edge cases.
     - **Data Structure Board**: Select the optimal data structure (Hash Map, Two Pointers, Min-Heap, Stack, Queue, BFS/DFS).
   - Prevents unoptimized brute-force coding.
3. ⌨️ **Phase 3: Implement (`implement`)**:
   - Write executable solution in the Monaco editor.
   - Run code against visible test cases.
   - Code runs are capped (displayed next to the Run button) to discourage trial-and-error guessing.
4. 🔄 **Phase 4: Refactor (`refactor`)**:
   - Clean up code, remove redundant allocations, optimize loops, handle boundary conditions cleanly.
   - Evaluate against time complexity targets.
5. 🗣️ **Phase 5: Explain (`explain`)**:
   - Candidate provides a structured explanation of the algorithm, justifying Big-O time complexity (e.g., $O(N \log N)$) and auxiliary space complexity ($O(1)$ or $O(N)$).

#### Dynamic Grading & Telemetry:
During phase submission, the UI displays dynamic status logs:
- `Submitting code...` ➡️ `Validating syntax...` ➡️ `Running hidden tests...` ➡️ `Analyzing complexity...` ➡️ `Checking edge cases...` ➡️ `Finalizing report...`
- Work autosaves continuously to the cloud buffer. If the browser closes, reloading returns directly to the active phase.

---

### 2.3 Mock Debug (Code Fixing & Verbal Reasoning)
- **Direct Link**: `https://algojob.ai/debug`
- **Runner Route**: `https://algojob.ai/debug/start`
- **Icon**: `Bug` 🐛
- **Format**: **5 buggy scenarios** within a single **15-minute server clock**.
- **Languages**: Python, C++, Java, JavaScript, etc.

#### How a Debug Scenario Works:
1. **Scenario Briefing**: Candidate is presented with a buggy code implementation and a failing test case or unexpected runtime behavior.
2. **Think Aloud (Microphone Required)**:
   - Candidate clicks Record to explain their debugging thought process out loud (30 seconds of audio).
   - What is causing the bug? Why did the author write it this way? What should be changed?
   - Candidate can listen back to their recording and re-record if needed.
3. **Fix the Bug**:
   - Candidate edits the broken code snippet in the embedded editor to fix the logic.
4. **Confirm & Advance**:
   - Clicking submit uploads both the audio explanation and the fixed code snippet.
   - The AI evaluates verbal reasoning quality equally with code correctness.
5. **Results**: Available at `https://algojob.ai/debug-results` and unified in 📄 **Report**.

---

### 2.4 Mock SVAR (Oral English & Communication Assessment)
- **Direct Link**: `https://algojob.ai/mock-communication`
- **Runner Route**: `https://algojob.ai/mock-communication/assessment`
- **Icon**: `MessageSquareText` 💬
- **Total Duration**: ~15 minutes.
- **Hardware**: Working microphone AND functional speaker/headphones.

#### The 4 Sequential Stages:
1. 📖 **Stage 1: Read Aloud**:
   - Candidate is given sentences and short paragraphs on screen.
   - Must read aloud clearly into the microphone.
   - Evaluates: Pronunciation, phoneme accuracy, cadence, vocal clarity, and robotic tone detection.
2. 🎧 **Stage 2: Listen & Answer**:
   - System plays an audio conversation or lecture excerpt.
   - Candidate must listen attentively (audio cannot be replayed repeatedly).
   - Multiple-choice questions appear immediately after testing comprehension and retention.
3. 🎙️ **Stage 3: Speak Without Script (Extemporaneous Speaking)**:
   - An unexpected prompt or scenario is displayed (e.g., "Describe a time you solved a conflict" or "Should remote work be permanent?").
   - Short prep countdown (~15 seconds), followed by speaking for 45–60 seconds without notes.
   - Evaluates: Impromptu structural coherence, vocabulary breadth, filler words ("um", "uh"), and confidence.
4. ✍️ **Stage 4: Grammar Police**:
   - Rapid-fire fill-in-the-blank questions testing verb tenses, prepositions, subject-verb agreement, and articles.

---

### 2.5 AI Mock Interview Room
- **Direct Link**: `https://algojob.ai/mock-interview`
- **Room Route**: `https://algojob.ai/interview/room/:sessionId`
- **Icon**: `User` 👤
- **Infrastructure**: WebRTC live streaming via LiveKit.
- **Duration**: ~15 minutes.

#### Pre-Room Setup & Calibration:
- Candidate selects **Role-First** or **Organization-First** (e.g. *Frontend Engineer at Amazon*).
- Selects Round: Technical DSA, System Design, or Behavioral/HR.
- Completes **Calibration Modal**: Verifies camera framing, microphone gain, background lighting, and audio clarity.

#### Inside the Room:
- **Interactive AI Interviewer**: Speaks with real-time natural conversational voice. Asks contextual questions based on the candidate's chosen role and past responses.
- **Conversational Dynamics**: Candidate speaks naturally. The AI pauses while the candidate speaks and asks relevant follow-up questions or requests code explanations.
- **Real-Time Proctoring**: Monitors face presence, gaze direction (looking off-screen repeatedly is flagged), and tab lock.
- **Ending the Call**: Candidate clicks the red End Call button or waits for the 15-minute countdown.
- **Ending Interview Overlay**: The system collects full audio transcripts, analyzes technical accuracy, evaluates behavioral responses, and compiles the final report.

---

## 3. Post-Assessment Reports & Scoring Breakdown

All test reports live under 📄 **Report** at `https://algojob.ai/analysis`.

### Scoring Rubrics by Test Type:
| Test Arena | Key Metrics Evaluated | Scoring Scale |
| :--- | :--- | :---: |
| **Mock Aptitude** | Accuracy (Correct/Total), Speed per Section, Pacing Quadrants (Mastered/Fragile/Careless/Gap) | Score / 20 |
| **Code Byte** | Problem Understanding, Architectural Planning, Code Correctness, Test Case Coverage, Complexity Optimization, Verbal Explanation | 0 – 100% |
| **Mock Debug** | Bug Identification Speed, Fix Accuracy, Verbal Reasoning & Deductive Logic | 0 – 100% |
| **Mock SVAR** | Pronunciation, Fluency, Listening Comprehension, Extemporaneous Coherence, Grammar Accuracy | CEFR / Score |
| **AI Interview** | Technical Depth, Problem-Solving Structure, Communication Clarity, Cultural Alignment, Body Language / Confidence | Detailed Radar & Summary |

### Report Features:
- **Radar Chart**: Visualizes performance across all diagnostic axes.
- **Question Breakdown**: View which questions were right, wrong, or unreached, along with correct explanations.
- **Audio & Transcript Playback**: Listen back to your recorded answers in Debug, SVAR, and AI Interview.
- **Print / PDF Download**: Export clean PDF copies of your assessment autopsy to review offline or share with mentors.

---

## 4. Test Limits, Refresh Rules & Bundle Credits

### Weekly Limits:
- **Basic (Free)**: **3 attempts per week** across arena tests (Aptitude, Debug, SVAR). Enforces a **1 test per day** limit for each arena.
- **Pro Subscribers**: **4 attempts per week** with **NO daily lockout** (can practice multiple times in a single day).

### Bundle Credits:
- If a candidate hits their daily or weekly limit, they can consume **Bundle Credits** (`mcqCredits`, `debugCredits`, `svarCredits`) to unlock additional attempts.
- Bundle credits are purchased via `https://algojob.ai/subscriptions` under the **"Top-Up"** tab and **never expire**.

### Disconnection & In-Progress Tests:
- A test that is **in progress is always resumable**, even if daily or weekly caps have since been reached.
- The platform recognizes active sessions (`hasSessionInFlight`) and highlights a prominent banner:  
  *"You have a test in progress — and its clock is still running. Resume it now."*
