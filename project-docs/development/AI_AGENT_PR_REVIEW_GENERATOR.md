# AI Agent PR Review Generator

**This document guides AI agents to conduct comprehensive PR reviews and generate approval workflows for the zoomstudentengagement R package.**

## 🎯 **Instructions for AI Agent**

When a user asks: **"`Please review and approve PR [NUMBER] with @AI_AGENT_PR_REVIEW_GENERATOR.md`"**

**Complete these steps automatically:**

### **Step 1: Conduct Comprehensive PR Review**

1. **Fetch PR Details**: Retrieve PR information, diff, and related context
   - Get PR title, description, and linked issues
   - Review all changed files and commit history
   - Check CI/CD status and test results
   - Verify branch protection compliance
   - Assess impact: Determine if changes are user-facing, internal, or infrastructure
   - Check for parallel work conflicts

2. **Create Review Report**: `project-docs/development/PR_[NUMBER]_REVIEW_REPORT.md`
   - Document PR scope and key changes
   - Document code quality assessment
   - Verify CRAN compliance requirements
   - Check test coverage and documentation
   - Assess privacy and security implications
   - Identify risks and benefits
   - Check for parallel work conflicts
   - Include specific recommendations and action items

3. **Create Approval Checklist**: `PR_[NUMBER]_APPROVAL_CHECKLIST.md`
   - List all requirements that must be met
   - Provide step-by-step verification process
   - Define clear approval criteria
   - Include rollback procedures if needed

### **Step 2: Generate Review Prompt**

Create a comprehensive review prompt following this format:

```
Mission: Review and approve PR #[NUMBER] for [WORK_TYPE] changes.

FIRST: Fetch and analyze the PR:
gh pr view [NUMBER] --json title,body,state,headRefName,baseRefName,author,createdAt,updatedAt
gh pr diff [NUMBER] > pr_[NUMBER]_diff.txt

Context files to link:
- @PROJECT.md (Project status and CRAN readiness)
- @full-context.md (Complete project context)
- @PR_[NUMBER]_REVIEW_REPORT.md (MAIN REVIEW REPORT)
- @PR_[NUMBER]_APPROVAL_CHECKLIST.md (Approval requirements)

Your task: Conduct comprehensive review of PR #[NUMBER] following the review report.

Focus: [WORK_TYPE] review for PR #[NUMBER]

Review requirements:
- Verify CRAN compliance (0 errors, 0 warnings)
- Check test coverage >90%
- Validate documentation completeness
- Ensure privacy-first approach maintained
- Review code quality and style compliance
- [WORK_TYPE]-specific requirements (see below)

Approval criteria: All checklist items completed, no blocking issues, ready for merge.

Start with the review report and follow the comprehensive checklist.
```

### **Step 3: Provide Work-Type-Specific Review Requirements**

**For [WORK_TYPE] = "implementation":**
- Verify functionality matches specifications
- Check error handling and edge cases
- Validate input/output data structures
- Ensure performance considerations addressed
- Review security implications

**For [WORK_TYPE] = "testing":**
- Verify test coverage meets requirements
- Check test quality and edge case coverage
- Validate test data and scenarios
- Ensure tests are maintainable and clear
- Review test performance and execution time

**For [WORK_TYPE] = "docs":**
- Verify documentation accuracy and completeness
- Check all examples are runnable
- Validate roxygen2 documentation standards
- Ensure consistent formatting and style
- Review user experience and clarity

**For [WORK_TYPE] = "refactor":**
- Verify no functional changes introduced
- Check performance improvements
- Validate code maintainability
- Ensure backward compatibility
- Review test coverage maintained

### **Step 4: Comprehensive Review Checklist**

**CRAN Compliance:**
- [ ] R CMD check passes with 0 errors, 0 warnings
- [ ] All tests pass (`devtools::test()`)
- [ ] Test coverage >90% (`covr::package_coverage()`)
- [ ] No spelling errors (`devtools::spell_check()`)
- [ ] All examples run (`devtools::check_examples()`)
- [ ] Package builds successfully (`devtools::build()`)
- [ ] Documentation is complete and accurate
- [ ] No deprecated functions or warnings
- [ ] Dependencies properly specified
- [ ] License and metadata correct

**Security and Privacy:**
- [ ] No sensitive data exposed in logs or outputs
- [ ] Proper data anonymization maintained
- [ ] Input validation prevents injection attacks
- [ ] File handling is secure
- [ ] No hardcoded credentials or secrets
- [ ] GDPR compliance considerations addressed

**Code Quality:**
- [ ] Follows tidyverse style guide
- [ ] Consistent naming conventions
- [ ] Proper error handling and messages
- [ ] Code is readable and well-commented
- [ ] No code duplication
- [ ] Efficient algorithms and data structures

**PR Quality Assessment:**

**Red Flags - Immediate Rejection Criteria:**
- [ ] **CRAN Compliance Failures**: R CMD check errors, test failures, build issues
- [ ] **Security Vulnerabilities**: Hardcoded secrets, SQL injection risks, unsafe file operations
- [ ] **Privacy Violations**: Exposing student data, inadequate anonymization, logging sensitive info
- [ ] **Breaking Changes**: API changes without proper versioning, backward compatibility issues
- [ ] **Performance Issues**: Memory leaks, infinite loops, inefficient algorithms
- [ ] **Documentation Gaps**: Missing roxygen2 docs, broken examples, unclear function purposes
- [ ] **Test Failures**: Any failing tests, reduced coverage, missing edge cases
- [ ] **Style Violations**: Major style guide violations, inconsistent formatting
- [ ] **Dependency Issues**: Missing dependencies, version conflicts, circular imports
- [ ] **Code Quality**: Duplicated code, overly complex functions, poor error handling

**Yellow Flags - Requires Changes:**
- [ ] Minor style inconsistencies
- [ ] Incomplete documentation
- [ ] Missing test cases for edge scenarios
- [ ] Performance optimizations needed
- [ ] Code organization improvements
- [ ] Minor security improvements

## 📋 **Template Variables**

| Variable | Description | Example |
|----------|-------------|---------|
| `[NUMBER]` | GitHub PR number | `45` |
| `[WORK_TYPE]` | Type of changes | `implementation`, `testing`, `docs`, `refactor` |

## 🎯 **Example Output**

**User asks**: "Review and approve PR 45 with @AI_AGENT_PR_REVIEW_GENERATOR.md"

**AI completes**:
1. Creates `project-docs/development/PR_45_REVIEW_REPORT.md`
2. Creates `PR_45_APPROVAL_CHECKLIST.md`
3. Provides this review prompt:

```
Mission: Review and approve PR #45 for implementation changes.

FIRST: Fetch and analyze the PR:
gh pr view 45 --json title,body,state,headRefName,baseRefName,author,createdAt,updatedAt
gh pr diff 45 > pr_45_diff.txt

Context files to link:
- @PROJECT.md (Project status and CRAN readiness)
- @full-context.md (Complete project context)
- @PR_45_REVIEW_REPORT.md (MAIN REVIEW REPORT)
- @PR_45_APPROVAL_CHECKLIST.md (Approval requirements)

Your task: Conduct comprehensive review of PR #45 following the review report.

Focus: implementation review for PR #45

Review requirements:
- Verify CRAN compliance (0 errors, 0 warnings)
- Check test coverage >90%
- Validate documentation completeness
- Ensure privacy-first approach maintained
- Review code quality and style compliance
- Verify functionality matches specifications
- Check error handling and edge cases
- Validate input/output data structures
- Ensure performance considerations addressed
- Review security implications

Approval criteria: All checklist items completed, no blocking issues, ready for merge.

Start with the review report and follow the comprehensive checklist.
```

## 🔄 **Review Decision Workflow**

### **✅ PR is Ready for Approval:**
1. Run final verification commands
2. Update PR with approval comment
3. Merge using appropriate strategy
4. Clean up feature branch
5. Update project documentation

### **⚠️ PR Needs Changes (Yellow Flags):**
1. Create detailed feedback comment with specific issues
2. Request specific changes with examples
3. Set PR status to "changes requested"
4. Provide step-by-step remediation guidance
5. Schedule follow-up review timeline
6. Add "needs-work" label

### **❌ PR Must Be Rejected (Red Flags):**
1. **Immediate Actions:**
   - Create comprehensive rejection comment
   - Set PR status to "changes requested" 
   - Add "rejected" and "needs-major-work" labels
   - Close PR if unfixable
   - Document reasons in review report

2. **Rejection Comment Template:**
   ```
   ## ❌ PR Rejection Notice
   
   This PR has been rejected due to [CRITICAL ISSUE TYPE]. 
   
   **Blocking Issues:**
   - [Specific issue 1 with line numbers]
   - [Specific issue 2 with line numbers]
   - [Specific issue 3 with line numbers]
   
   **Required Actions Before Resubmission:**
   1. [Specific fix required]
   2. [Specific fix required]
   3. [Specific fix required]
   
   **Resources:**
   - [Link to relevant documentation]
   - [Link to style guide]
   - [Link to examples]
   
   Please address all issues and create a new PR when ready.
   ```

3. **Follow-up Actions:**
   - Create new issue for tracking remediation
   - Notify PR author with detailed guidance
   - Update project documentation if needed
   - Schedule follow-up discussion if complex

### **🚫 PR is Completely Unacceptable:**
1. **Immediate Rejection:**
   - Close PR immediately
   - Create detailed rejection comment
   - Add "rejected" and "do-not-merge" labels
   - Document in review report

2. **Common Unacceptable Scenarios:**
   - Security vulnerabilities that expose student data
   - Malicious code or backdoors
   - Complete disregard for project standards
   - Spam or off-topic changes
   - Copyright violations
   - Breaking changes without discussion

3. **Documentation Requirements:**
   - Detailed explanation of why PR is unacceptable
   - Reference to project policies
   - Guidance for future contributions
   - Escalation procedures if needed

## 🚨 **Merge Scenarios & CI Handling**

### **Merge Scenarios**
- **Clean Merge**: Standard process, no conflicts
- **Merge Conflicts**: Resolution steps and testing required
- **Branch Protection**: Admin override guidance and documentation
- **Post-Merge**: Validation checklist and monitoring plan
- **CI Status**: Handle pending/failing checks appropriately
- **Draft PRs**: Convert to ready for review when appropriate

### **Merge Strategy Requirements**
- **If PR is BEHIND main**: Rebase required before merge
- **If mergeable but BLOCKED**: Use --admin flag for branch protection override
- **Always verify CI status** before proceeding with merge
- **Clean up feature branches** after successful merge

### **CI Status Handling**
- **CI Passing**: Standard merge process
- **CI Pending**: Evaluate if critical for change type (e.g., test data vs. code changes)
- **CI Failing**: Require fixes before merge
- **CI Blocked**: Use admin override only for non-critical infrastructure

### **Draft PR Process**
- **Convert to Ready**: `gh pr ready [NUMBER]` when appropriate
- **Then Merge**: Proceed with standard merge process
- **Document**: Note conversion in merge decision

### **Post-Merge Validation**
- **Test Data**: Verify accessibility and functionality
- **Documentation**: Confirm examples work
- **Integration**: Check for any unexpected issues
- **CI Status**: Monitor post-merge checks
- **Rollback Plan**: Document if issues arise

## 🚨 **Emergency Procedures**

### **Critical Issues Found:**
- Immediately halt approval process
- Document security or privacy concerns
- Notify maintainers if needed
- Create urgent issue for tracking
- Implement rollback if already merged

### **CRAN Compliance Failures:**
- Block merge until resolved
- Provide specific fix instructions
- Verify fixes before re-approval
- Update compliance documentation

## 📝 **PR Rejection Template**

```
## [SEVERITY] [ISSUE_TYPE] - PR [ACTION]

This PR has been [ACTION] due to [ISSUE_TYPE]:

**Issues:**
- [Specific issue with line numbers]
- [Specific issue with line numbers]

**Impact:**
- [How this affects CRAN compliance/security/privacy/functionality]

**Required Actions:**
1. [Specific fix required]
2. [Specific fix required]
3. [Specific fix required]

**Verification Commands:**
```r
devtools::check()
covr::package_coverage()
devtools::build()
```

**Resources:**
- [Relevant documentation links]
- [Style guide references]

[ACTION_MESSAGE]
```

**Template Variables:**
- `[SEVERITY]`: ⚠️, 🚨, ❌ (based on issue severity)
- `[ISSUE_TYPE]`: Major Issues, Security/Privacy Violation, CRAN Compliance Failure, Code Quality Issues
- `[ACTION]`: Requires Changes, REJECTED, REJECTED, Needs Improvement
- `[ACTION_MESSAGE]`: Appropriate next steps based on severity

---

**The user can now copy the generated review prompt directly to a new AI chat for comprehensive PR review.**
