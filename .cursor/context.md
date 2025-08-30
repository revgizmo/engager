🔍 Generating context for zoomstudentengagement R Package...
==================================================
🔍 Validating dependencies...
📅 Date: 2025-08-30 20:01:17 UTC
🌿 Branch: feature/issue-426-export-functions-implementation
📊 Uncommitted changes: 1

🎯 PROJECT STATUS SUMMARY
------------------------
Package: zoomstudentengagement (R package for Zoom transcript analysis)
Goal: CRAN submission preparation
Current Status: Status unknown - check PROJECT.md

📈 KEY METRICS
-------------
🔍 Checking test status...
Test Status: FAILING (7 failures, 57 warnings, 2125 passed, 15 skipped)
🔍 Checking R CMD check status...
R CMD Check: Failed (run manually with devtools::check())
🔍 Checking test coverage...
Test Coverage: N/A (covr not available)
🔍 Counting exported functions...
Exported Functions: 84

🔒 PRIVACY & ETHICAL COMPLIANCE
-----------------------------
⚠️  Open privacy/ethical issues:
   Privacy issues: 6
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
#429: meta: Followup work for ideal course transcripts implementation (OPEN) - 2025-08-30
#428: feat: Add configuration system for ideal course transcripts (OPEN) - 2025-08-30
#427: feat: Add visualization functions for ideal course transcripts (OPEN) - 2025-08-30
#426: feat: Add export functions for ideal course transcripts (OPEN) - 2025-08-30
#406: BLOCKER: CI temporarily disabled; follow temporary self-merge policy (OPEN) - 2025-08-27

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
R/ - Core functions (84 exported)
tests/ - Test suite (81 test files)
man/ - Documentation (158 files)
vignettes/ - Usage examples (10 files)
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
❌ R CMD Check: FAILING ( errors,  warnings)
⚠️  Test Coverage: Unable to check

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
