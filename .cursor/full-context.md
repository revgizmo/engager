🔍 Generating complete context for zoomstudentengagement...
==================================================

🔍 Validating scripts...
✅ Scripts validated

📝 Running shell context script...
🔍 Generating context for zoomstudentengagement R Package...
==================================================
🔍 Validating dependencies...
📅 Date: 2025-09-01 01:08:07 UTC
🌿 Branch: feature/issue-segfault-fix-implementation
📊 Uncommitted changes: 4

🎯 PROJECT STATUS SUMMARY
------------------------
Package: zoomstudentengagement (R package for Zoom transcript analysis)
Goal: CRAN submission preparation
Current Status: Status unknown - check PROJECT.md

📈 KEY METRICS
-------------
🔍 Checking test status...
Test Status: FAILING (0 failures, 55 warnings, 1781 passed, 15 skipped)
🔍 Checking R CMD check status...
R CMD Check: 0 errors, 0 warnings, 3 notes
🔍 Checking test coverage...
Test Coverage: 90.33% (target: 90%)
🔍 Counting exported functions...
Exported Functions: 72

🔒 PRIVACY & ETHICAL COMPLIANCE
-----------------------------
⚠️  Open privacy/ethical issues:
   Privacy issues: 7
   Ethical issues: 1
   FERPA issues: 2

🚨 CRITICAL ISSUES (High Priority)
--------------------------------
#406: BLOCKER: CI temporarily disabled; follow temporary self-merge policy [priority:high]
#394: [PRD] Basic UX Simplification [priority:high]
#394: [PRD] Basic UX Simplification [CRAN:submission]
#394: [PRD] Basic UX Simplification [area:core]
#393: [PRD] Core Function Audit & Categorization [priority:high]
#393: [PRD] Core Function Audit & Categorization [CRAN:submission]
#393: [PRD] Core Function Audit & Categorization [area:core]
#392: [PRD] Success Metrics Definition & Implementation [priority:high]
#392: [PRD] Success Metrics Definition & Implementation [CRAN:submission]
#392: [PRD] Success Metrics Definition & Implementation [area:core]
#298: feat(privacy): name masking helper with docs [priority:high]
#298: feat(privacy): name masking helper with docs [area:core]

🎯 CRAN SUBMISSION BLOCKERS
--------------------------
#394: [PRD] Basic UX Simplification (OPEN)
#393: [PRD] Core Function Audit & Categorization (OPEN)
#392: [PRD] Success Metrics Definition & Implementation (OPEN)
#301: release(0.1.0): prepare NEWS.md, tag and build (OPEN)
#300: chore(metadata): verify DESCRIPTION/NAMESPACE/license (OPEN)

🕒 RECENT ACTIVITY (Last 5 Issues)
--------------------------------
#441: Batch Export Capabilities (OPEN) - 2025-08-30
#440: Enhanced Excel Chart Functionality (OPEN) - 2025-08-30
#439: Performance Optimization for Large Datasets (OPEN) - 2025-08-30
#438: Enhanced File Write Error Handling (OPEN) - 2025-08-30
#437: Enhanced Privacy Framework (OPEN) - 2025-08-30

📁 ESSENTIAL FILES TO REVIEW
---------------------------
• README.md - Package overview and quick start
• PROJECT.md - Current status and CRAN readiness
• ISSUE_MANAGEMENT_QUICK_REFERENCE.md - Issue workflow
• CONTRIBUTING.md - Contribution guidelines
• CRAN_CHECKLIST.md - CRAN submission checklist
• docs/development/AUDIT_LOG.md - Recent audit results

🎯 CURRENT DEVELOPMENT FOCUS
---------------------------
1. High Priority Issues (15 issues)
2. CRAN Submission Blockers (14 issues)
4. R CMD Check Issues (0 errors, 0 warnings, 3 notes)
5. Documentation and Testing
6. Real-world Testing

⚡ QUICK COMMANDS FOR CONTEXT
---------------------------
# Check current status:
devtools::check()
devtools::test()
covr::package_coverage()

# View recent issues:
gh issue list --limit 10

# Check specific issue:
gh issue view <ISSUE_NUMBER>

📂 PROJECT STRUCTURE
-------------------
R/ - Core functions (72 exported)
tests/ - Test suite (76 test files)
man/ - Documentation (98 files)
vignettes/ - Usage examples (9 files)
inst/extdata/ - Sample data
docs/ - Development documentation
scripts/ - Development utilities

🔄 DEVELOPMENT WORKFLOW
---------------------
1. Check current issues: gh issue list
2. Create feature branch: git checkout -b feature/issue-XX
3. Make changes and test: devtools::test()
4. Update documentation: devtools::document()
5. Run full check: devtools::check()
6. Create PR: gh pr create --title 'fix: Address #XX'
7. Merge with admin: gh pr merge --admin

📦 CRAN READINESS STATUS
----------------------
❌ Test Suite: FAILING
✅ R CMD Check: PASSING (0 errors, 0 warnings)
✅ Test Coverage: 90.33% (target achieved)
⚠️  R CMD Notes: 3 minor notes

🎯 IMMEDIATE NEXT STEPS
---------------------
3. Address high priority issues (15 issues)
4. Resolve CRAN submission blockers (14 issues)
5. Update documentation and examples
6. Complete real-world testing

==================================================
💡 TIP: Copy the output above and paste it into your new Cursor chat
💡 TIP: Use 'gh issue view <NUMBER>' to get detailed issue information
💡 TIP: Check PROJECT.md for the most current status information
==================================================

✅ Shell context completed successfully

==================================================

📝 Running R context script...
🔍 Generating R-specific context for zoomstudentengagement R Package...
==================================================

📦 PACKAGE LOADING STATUS
------------------------
✅ Package loaded successfully

🧪 TEST STATUS
-------------
✅ Package loaded successfully
📊 Test status: Run 'devtools::test()' for current results
   Last known: 450 tests passing, 4 skipped, 0 failures
   Note: Run tests manually for detailed output

📊 TEST COVERAGE
---------------
🔍 Calculating coverage...
📈 Coverage: 90.33 %
   Target: 90%
   ✅ Target achieved
   💡 Run 'covr::file_coverage()' for detailed file breakdown

🔍 R CMD CHECK STATUS
-------------------
📊 Current Status: Run 'devtools::check()' for current results
   Last known: 0 errors, 0 warnings, 3 notes
   Note: Run check manually for detailed output

Note: Full R CMD check takes time. Run manually with:
   devtools::check()
   devtools::check_man()
   devtools::spell_check()

📂 PACKAGE STRUCTURE
------------------
R/ functions: 61 
Tests: 76 
Vignettes: 9 
Documentation: 98 

🔧 EXPORTED FUNCTIONS
-------------------
📋 Total exported functions: 72 
   First 5: "%>%", add_dead_air_rows, analyze_multi_session_attendance, analyze_transcripts, anonymize_educational_data 
   ... and 67 more

📦 DEPENDENCIES
-------------
📥 Imports: digest,
dplyr,
ggplot2,
hms,
jsonlite,
lubridate,
magrittr,
readr,
rlang,
stringr,
tibble 
💡 Suggests: testthat (>= 3.0.0),
withr,
covr,
knitr,
rmarkdown 

📚 DOCUMENTATION STATUS
---------------------
✅ Documentation appears complete
Note: Run devtools::check_man() for detailed documentation check

🔒 PRIVACY & ETHICAL COMPLIANCE
-----------------------------
📋 Privacy/ethical considerations for educational data:
   • FERPA compliance: Student data protection
   • Ethical use: Focus on participation equity
   • Data anonymization: Name masking functions
   • Privacy-first defaults: Secure by default
   • Educational purpose: Avoid surveillance

🔍 Check Issues #84, #85 for detailed compliance requirements
   • #84: FERPA/security compliance review
   • #85: Ethical use and equitable participation focus

⚡ QUICK HEALTH CHECK COMMANDS
----------------------------
# Load and test package:
devtools::load_all()
devtools::test()

# Check documentation:
devtools::check_man()
devtools::spell_check()

# Full package check:
devtools::check()

# Build package:
devtools::build()

🔧 COMMON ISSUES AND SOLUTIONS
-----------------------------
• Test failures: Check test data and function changes
• Documentation errors: Run devtools::document()
• Global variable warnings: Use .data$ or !! for tidy evaluation
• Coverage gaps: Add tests for untested functions
• R CMD check notes: Review file timestamps and structure
• Privacy concerns: Review Issues #84, #85

💡 DEVELOPMENT TIPS
-----------------
• Use styler::style_pkg() for consistent formatting
• Run devtools::test() before committing
• Update documentation with devtools::document()
• Check examples with devtools::check_examples()
• Use lintr::lint_package() for code quality
• Review privacy/ethical implications of new features

==================================================
💡 TIP: Run this script to get current R package status
💡 TIP: Combine with shell script for complete context
💡 TIP: Use devtools::check() for comprehensive validation
💡 TIP: Always consider privacy/ethical implications
==================================================

🔄 PROJECT.md UPDATE REQUIRED
==================================================
⚠️  IMPORTANT: PROJECT.md is outdated and needs manual update

📊 Current Metrics (from R context above):
   • Test Coverage: 90.33 % (PROJECT.md claims 90.69 %)
   • Test Suite: 1900 tests (PROJECT.md claims 1825 )
   • R CMD Check: 2 notes (PROJECT.md claims 2 )
   • Status: EXCELLENT (PROJECT.md claims EXCELLENT - Very Close to CRAN Ready )

🎯 ACTION REQUIRED:
   • Manually update PROJECT.md with current metrics above
   • Update status from 'EXCELLENT - Very Close to CRAN Ready' to 'EXCELLENT - Very Close to CRAN Ready'
   • Update last modified date to 2025-08-31 
   • Update issue count from 31 to 30

📝 Update these lines in PROJECT.md:
   • Line 13: 'Updated: 2025-08-31 '
   • Line 15: 'Package Status: EXCELLENT - Very Close to CRAN Ready'
   • Line 37: 'Test Suite: 1900 tests passing'
   • Line 38: 'R CMD Check: 0 errors, 0 warnings, 2 notes'
   • Line 39: 'Test Coverage: 90.33 % (target achieved)'
==================================================
💾 Metrics JSON written to .cursor/metrics.json

🤖 AI AGENT INSTRUCTIONS
==================================================
⚠️  CRITICAL: You MUST update PROJECT.md before proceeding with any other work!

🔧 WORKFLOW TO UPDATE PROJECT.md:

1️⃣  Check if PROJECT.md needs updating:
   ./scripts/save-context.sh --check-project-md

2️⃣  If changes are needed, apply them:
   ./scripts/save-context.sh --fix-project-md

3️⃣  Alternative manual workflow:
   • Run pre-PR checks: devtools::check(), devtools::test(), covr::package_coverage()
   • Generate fresh context: ./scripts/save-context.sh
   • Update PROJECT.md based on @full-context.md

💡 TIP: Use the automated updater for faster, more reliable updates!

✅ VERIFICATION:
   After updating, run: grep -n 'Test Coverage:\|Test Suite:\|R CMD Check:\|Package Status:' PROJECT.md

🎯 SUCCESS CRITERIA:
   ✅ PROJECT.md matches current metrics from context above
   ✅ Date updated to 2025-08-31 
   ✅ No more discrepancy warnings in context scripts

⚠️  DO NOT PROCEED WITH ANY OTHER WORK until PROJECT.md is updated!
==================================================

✅ R context completed successfully

==================================================
💡 Copy the output above and paste it into your new Cursor chat
💡 For quick context only, run: ./scripts/context-for-new-chat.sh
💡 For R-specific context only, run: Rscript scripts/context-for-new-chat.R
💡 To save context files, run: ./scripts/save-context.sh
==================================================

🔄 PROJECT.md UPDATE REQUIRED
==================================================
⚠️  IMPORTANT: PROJECT.md is outdated and needs manual update

📊 Current Metrics (from metrics source):
   • Test Coverage: 90.33% (PROJECT.md claims 90.69%)
   • Test Suite: 1900 tests (PROJECT.md claims 1825)
   • R CMD Check: 2 notes (PROJECT.md claims 2)
   • Status: EXCELLENT (PROJECT.md claims EXCELLENT - Very Close to CRAN Ready)

🎯 ACTION REQUIRED:
   • Manually update PROJECT.md with current metrics above
   • Update status from 'EXCELLENT - Very Close to CRAN Ready' to 'EXCELLENT - Very Close to CRAN Ready'
   • Update last modified date to 2025-08-31
   • Update issue count from 31 to 30

📝 Update these lines in PROJECT.md:
   • Line 13: 'Updated: 2025-08-31'
   • Line 15: 'Package Status: EXCELLENT - Very Close to CRAN Ready'
   • Line 37: 'Test Suite: 1065 tests passing'
   • Line 38: 'R CMD Check: 0 errors, 0 warnings, 2 notes'
   • Line 39: 'Test Coverage: 93.82% (target achieved)'
==================================================

🤖 AI AGENT INSTRUCTIONS
==================================================
⚠️  CRITICAL: You MUST update PROJECT.md before proceeding with any other work!

🔧 WORKFLOW TO UPDATE PROJECT.md:

1️⃣  Check if PROJECT.md needs updating:
   ./scripts/save-context.sh --check-project-md

2️⃣  If changes are needed, apply them:
   ./scripts/save-context.sh --fix-project-md

3️⃣  Alternative manual workflow:
   • Run pre-PR checks: devtools::check(), devtools::test(), covr::package_coverage()
   • Generate fresh context: ./scripts/save-context.sh
   • Update PROJECT.md based on @full-context.md

💡 TIP: Use the automated updater for faster, more reliable updates!

✅ VERIFICATION:
   After updating, run: grep -n 'Test Coverage:\|Test Suite:\|R CMD Check:\|Package Status:' PROJECT.md

🎯 SUCCESS CRITERIA:
   ✅ PROJECT.md matches current metrics from context above
   ✅ Date updated to 2025-08-31
   ✅ No more discrepancy warnings in context scripts

⚠️  DO NOT PROCEED WITH ANY OTHER WORK until PROJECT.md is updated!
==================================================
