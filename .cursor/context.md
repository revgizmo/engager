🔍 Generating context for zoomstudentengagement R Package...
==================================================
🔍 Validating dependencies...
📅 Date: 2025-08-16 16:13:00 UTC
🌿 Branch: fix/context-script-coverage-display-issue
📊 Uncommitted changes: 4

🎯 PROJECT STATUS SUMMARY
------------------------
Package: zoomstudentengagement (R package for Zoom transcript analysis)
Goal: CRAN submission preparation
Current Status: Status unknown - check PROJECT.md

📈 KEY METRICS
-------------
🔍 Checking test status...
Test Status: FAILING (0 failures, 50 warnings, 1424 passed, 15 skipped)
🔍 Checking R CMD check status...
R CMD Check: 0 errors, 0 warnings, 3 notes
🔍 Checking test coverage...
Test Coverage: 88.63% (target: 90%)
🔍 Counting exported functions...
Exported Functions: 60

🔒 PRIVACY & ETHICAL COMPLIANCE
-----------------------------
⚠️  Open privacy/ethical issues:
   Privacy issues: 3
   Ethical issues: 1
   FERPA issues: 2

🚨 CRITICAL ISSUES (High Priority)
--------------------------------
#230: docs: Create CRAN submission preparation guide [priority:high]
#230: docs: Create CRAN submission preparation guide [CRAN:submission]
#227: test: Add missing tests for analyze_transcripts.R [priority:high]
#227: test: Add missing tests for analyze_transcripts.R [CRAN:submission]
#220: fix: Wrap diagnostic output in test environment checks for CRAN compliance [priority:high]
#220: fix: Wrap diagnostic output in test environment checks for CRAN compliance [CRAN:submission]
#220: fix: Wrap diagnostic output in test environment checks for CRAN compliance [area:testing]
#218: test: Achieve 100% test coverage with comprehensive user experience testing [priority:high]
#218: test: Achieve 100% test coverage with comprehensive user experience testing [CRAN:submission]
#218: test: Achieve 100% test coverage with comprehensive user experience testing [area:testing]
#129: HIGH: Complete Real-World Testing with Confidential Data [priority:high]
#129: HIGH: Complete Real-World Testing with Confidential Data [CRAN:submission]
#129: HIGH: Complete Real-World Testing with Confidential Data [area:testing]

🎯 CRAN SUBMISSION BLOCKERS
--------------------------
#230: docs: Create CRAN submission preparation guide (OPEN)
#229: test: Improve test coverage for safe_name_matching_workflow.R (OPEN)
#228: test: Improve test coverage for privacy_audit.R (OPEN)
#227: test: Add missing tests for analyze_transcripts.R (OPEN)
#220: fix: Wrap diagnostic output in test environment checks for CRAN compliance (OPEN)

🕒 RECENT ACTIVITY (Last 5 Issues)
--------------------------------
#230: docs: Create CRAN submission preparation guide (OPEN) - 2025-08-16
#229: test: Improve test coverage for safe_name_matching_workflow.R (OPEN) - 2025-08-16
#228: test: Improve test coverage for privacy_audit.R (OPEN) - 2025-08-16
#227: test: Add missing tests for analyze_transcripts.R (OPEN) - 2025-08-16
#223: feat: Optimize Docker container launch performance for Dev Containers (OPEN) - 2025-08-15

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
1. High Priority Issues (7 issues)
2. CRAN Submission Blockers (9 issues)
3. Test Coverage Improvement (88.63% → 90%)
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
R/ - Core functions (60 exported)
tests/ - Test suite (57 test files)
man/ - Documentation (78 files)
vignettes/ - Usage examples (8 files)
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
⚠️  Test Coverage: 88.63% (need 90%)
⚠️  R CMD Notes: 3 minor notes

🎯 IMMEDIATE NEXT STEPS
---------------------
2. Improve test coverage to 90% (currently 88.63%)
3. Address high priority issues (7 issues)
4. Resolve CRAN submission blockers (9 issues)
5. Update documentation and examples
6. Complete real-world testing

==================================================
💡 TIP: Copy the output above and paste it into your new Cursor chat
💡 TIP: Use 'gh issue view <NUMBER>' to get detailed issue information
💡 TIP: Check PROJECT.md for the most current status information
==================================================
