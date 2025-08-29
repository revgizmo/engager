🔍 Generating context for zoomstudentengagement R Package...
==================================================
🔍 Validating dependencies...
📅 Date: 2025-08-28 21:49:35 UTC
🌿 Branch: feature/process-improvements-precommit
📊 Uncommitted changes: 2

🎯 PROJECT STATUS SUMMARY
------------------------
Package: zoomstudentengagement (R package for Zoom transcript analysis)
Goal: CRAN submission preparation
Current Status: Status unknown - check PROJECT.md

📈 KEY METRICS
-------------
🔍 Checking test status...
Test Status: FAILING (8 failures, 51 warnings, 1764 passed, 15 skipped)
🔍 Checking R CMD check status...
R CMD Check: Failed (run manually with devtools::check())
🔍 Checking test coverage...
Test Coverage: N/A (covr not available)
🔍 Counting exported functions...
Exported Functions: 71

🔒 PRIVACY & ETHICAL COMPLIANCE
-----------------------------
✅ No open privacy/ethical issues found
   Note: Check Issues #84, #85 for privacy/ethical compliance

🚨 CRITICAL ISSUES (High Priority)
--------------------------------
Unable to fetch high priority issues

🎯 CRAN SUBMISSION BLOCKERS
--------------------------
Unable to fetch CRAN submission issues

🕒 RECENT ACTIVITY (Last 5 Issues)
--------------------------------
Unable to fetch recent issues

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
R/ - Core functions (71 exported)
tests/ - Test suite (75 test files)
man/ - Documentation (97 files)
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
❌ R CMD Check: FAILING ( errors,  warnings)
⚠️  Test Coverage: Unable to check

🎯 IMMEDIATE NEXT STEPS
---------------------
5. Update documentation and examples
6. Complete real-world testing

==================================================
💡 TIP: Copy the output above and paste it into your new Cursor chat
💡 TIP: Use 'gh issue view <NUMBER>' to get detailed issue information
💡 TIP: Check PROJECT.md for the most current status information
==================================================
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
❌ Coverage check failed:  Failure in `/private/var/folders/gm/wnk5gljx6yd_ffmqb8vf48qh0000gn/T/RtmpP6YMbR/R_LIBS13357237ba241/zoomstudentengagement/zoomstudentengagement-tests/testthat.Rout.fail`
atching_workflow handles international names --
Error: Found unmatched names: Dr. <U+674E><U+6559><U+6388>, Jos<U+00E9> Mar<U+00ED>a L<U+00F3>pez
Please update your section_names_lookup.csv file with these mappings.
See vignette('name-matching-troubleshooting') for detailed instructions.
Example mappings:
  Dr. <U+674E><U+6559><U+6388> -> [Your roster name]
  Jos<U+00E9> Mar<U+00ED>a L<U+00F3>pez -> [Your roster name]
Lookup file path: ./section_names_lookup.csv
For guided assistance, set unmatched_names_action = 'warn' to receive a template.
Backtrace:
    x
 1. \-zoomstudentengagement::safe_name_matching_workflow(...) at test-safe_name_matching_workflow_coverage.R:428:3
 2.   \-zoomstudentengagement:::handle_unmatched_names(...)

[ FAIL 8 | WARN 51 | SKIP 20 | PASS 1748 ]
Error: Test failures
Execution halted 

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
R/ functions: 60 
Tests: 75 
Vignettes: 9 
Documentation: 97 

🔧 EXPORTED FUNCTIONS
-------------------
📋 Total exported functions: 71 
   First 5: "%>%", add_dead_air_rows, analyze_multi_session_attendance, analyze_transcripts, anonymize_educational_data 
   ... and 66 more

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
   • Test Coverage: 93.82% (PROJECT.md claims 90.69 %)
   • Test Suite: 1065 tests (PROJECT.md claims 1825 )
   • R CMD Check: 2 notes (PROJECT.md claims 2 )
   • Status: EXCELLENT (PROJECT.md claims EXCELLENT - Very Close to CRAN Ready )

🎯 ACTION REQUIRED:
   • Manually update PROJECT.md with current metrics above
   • Update status from 'EXCELLENT - Very Close to CRAN Ready' to 'EXCELLENT - Very Close to CRAN Ready'
   • Update last modified date to 2025-08-28 
   • Update issue count from 31 to 30

📝 Update these lines in PROJECT.md:
   • Line 13: 'Updated: 2025-08-28 '
   • Line 15: 'Package Status: EXCELLENT - Very Close to CRAN Ready'
   • Line 37: 'Test Suite: 1065 tests passing'
   • Line 38: 'R CMD Check: 0 errors, 0 warnings, 2 notes'
   • Line 39: 'Test Coverage: 93.82% (target achieved)'
==================================================
⚠️  Failed to write metrics JSON:  objet 'coverage_percent' introuvable 

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
   ✅ Date updated to 2025-08-28 
   ✅ No more discrepancy warnings in context scripts

⚠️  DO NOT PROCEED WITH ANY OTHER WORK until PROJECT.md is updated!
==================================================
