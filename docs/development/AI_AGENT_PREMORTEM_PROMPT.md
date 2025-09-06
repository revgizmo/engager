# AI Agent Premortem Analysis Prompt

**This document guides AI agents to perform comprehensive premortem analysis on any issue using Gary Klein's premortem technique.**

## 🎯 **Instructions for AI Agent**

When a user asks: **"Please implement a premortem analysis on [ISSUE] with @AI_AGENT_PREMORTEM_PROMPT.md"**

**Complete these steps automatically:**

### **Step 1: Issue Analysis and Context Gathering**

1. **Read and understand the issue**:
   - Review the issue description, requirements, and context
   - Identify the scope, complexity, and potential impact
   - Note any existing work, dependencies, or constraints

2. **Assess project context**:
   - Review `@PROJECT.md` for current project status and goals
   - Check `@full-context.md` for complete project context
   - Understand CRAN readiness requirements and quality standards

3. **Create branch for premortem work**:
   ```bash
   git checkout -b feature/issue-[NUMBER]-premortem-analysis
   git push -u origin feature/issue-[NUMBER]-premortem-analysis
   ```

### **Step 2: Premortem Exercise Execution**

**Based on Gary Klein's premortem technique (as described by Daniel Kahneman):**

#### **2.1 Imagine Catastrophic Failure**
**Scenario**: "It's 6 months from now. The implementation of [ISSUE] has completely failed. The project is in disarray. What went wrong?"

**Key Questions to Answer**:
1. What specific failures occurred with this issue's implementation?
2. When did things start going wrong?
3. Who or what was responsible for the failures?
4. What were the warning signs that were missed?
5. How did the failures cascade and impact the broader project?

#### **2.2 Document Failure Scenarios**

**Create detailed failure scenarios for each category**:

**Technical Failures**:
- Implementation introduced bugs that broke existing functionality
- Code quality degraded due to rushed or incomplete work
- Performance issues from poorly optimized solutions
- Integration conflicts with existing systems
- Privacy or security vulnerabilities introduced

**Process Failures**:
- Requirements were misunderstood or incomplete
- Testing was insufficient or skipped
- Documentation was inadequate or missing
- Review processes were bypassed or ineffective
- Timeline pressures led to shortcuts

**Project Impact Failures**:
- CRAN submission delayed due to this issue's problems
- Quality standards compromised
- User experience degraded
- Project reputation damaged
- Maintainability issues created

**Ethical/Compliance Failures**:
- Privacy violations introduced
- FERPA compliance issues
- Inappropriate data handling
- Bias introduced in analysis
- Misuse of student data

### **Step 3: Root Cause Analysis**

#### **3.1 For Each Failure Scenario, Identify**:
- **Immediate Causes**: What directly caused the failure?
- **Contributing Factors**: What made the failure more likely?
- **Root Causes**: What underlying issues enabled the failure?
- **Systemic Issues**: What organizational or process problems existed?

#### **3.2 Use 5-Why Analysis**
For each major failure, ask "Why?" five times to reach root causes.

**Example**:
1. Why did the implementation introduce a critical bug? → Didn't follow testing protocols
2. Why didn't it follow testing protocols? → Testing requirements weren't clear
3. Why weren't testing requirements clear? → Documentation was outdated
4. Why was documentation outdated? → No process for keeping it current
5. Why was there no process? → No ownership assigned for documentation maintenance

### **Step 4: Prevention Strategy Development**

#### **4.1 Create Prevention Measures**
For each root cause identified, develop specific prevention strategies:

**Technical Safeguards**:
- Comprehensive test coverage requirements
- Automated quality gates and validation
- Performance benchmarking and monitoring
- Privacy compliance validation
- Code review requirements

**Process Improvements**:
- Clear requirement documentation and validation
- Mandatory testing protocols
- Documentation standards and review
- Timeline and scope management
- Quality gate enforcement

**Project Safeguards**:
- CRAN compliance validation
- User experience testing
- Privacy impact assessment
- Performance impact analysis
- Maintainability review

#### **4.2 Design Monitoring Systems**
- **Early Warning Indicators**: Metrics that signal potential problems
- **Quality Gates**: Automated checks that must pass
- **Human Oversight**: Review processes and approval requirements
- **Feedback Loops**: Mechanisms for continuous improvement

### **Step 5: Document Creation**

#### **5.1 Create Premortem Analysis Document**
Create: `ISSUE_[NUMBER]_PREMORTEM_ANALYSIS.md`

```markdown
# Premortem Analysis: Issue #[NUMBER] - [ISSUE_TITLE]

*Risk Assessment and Prevention Strategies*

## Executive Summary
[Brief overview of key risks and prevention strategies for this specific issue]

## Issue Context
[Summary of the issue, its requirements, and expected outcomes]

## Failure Scenarios

### Technical Failures
[Detailed analysis of technical failure modes specific to this issue]

### Process Failures  
[Analysis of workflow and process failures for this implementation]

### Project Impact Failures
[Impact on project success, CRAN submission, and overall quality]

### Ethical/Compliance Failures
[Privacy, bias, and compliance concerns specific to this issue]

## Root Cause Analysis
[5-why analysis for each major failure scenario]

## Prevention Strategies
[Specific measures to prevent each risk category for this issue]

## Monitoring and Detection
[Early warning systems and quality gates specific to this implementation]

## Response Procedures
[What to do when risks materialize during implementation]

## Implementation Recommendations
[Specific steps to implement this issue safely and successfully]

## Success Criteria
[Clear, measurable criteria for successful implementation]
```

#### **5.2 Integration with Project Documentation**
- Update relevant project documentation with risk awareness
- Link to existing quality processes and standards
- Reference CRAN compliance requirements
- Connect to privacy and ethical guidelines

### **Step 6: Validation and Quality Assurance**

#### **6.1 Review Analysis Completeness**
- [ ] All major risk categories covered for this specific issue
- [ ] Root causes identified with specific examples
- [ ] Prevention strategies are specific and actionable
- [ ] Monitoring and response procedures defined
- [ ] Integration with project standards documented

#### **6.2 Validate Against Project Context**
```bash
# Ensure alignment with project goals
cat PROJECT.md | grep -i "cran\|quality\|privacy"

# Check integration with existing processes
cat CONTRIBUTING.md | grep -i "testing\|review\|quality"
```

## 🎯 **Success Criteria**

### **Analysis Quality**
- [ ] Comprehensive risk analysis covering all major failure modes for this issue
- [ ] Clear root cause analysis with specific examples
- [ ] Actionable prevention strategies tailored to this implementation
- [ ] Integration with existing project workflows and standards

### **Risk Coverage**
- [ ] **Technical Risks**: Code quality, performance, integration specific to this issue
- [ ] **Process Risks**: Workflow efficiency, testing, documentation for this implementation
- [ ] **Project Risks**: CRAN compliance, timeline, quality impact
- [ ] **Ethical Risks**: Privacy, bias, compliance concerns specific to this issue

### **Actionability**
- [ ] Specific prevention measures defined for this issue
- [ ] Clear escalation procedures documented
- [ ] Monitoring mechanisms established
- [ ] Recovery procedures outlined

## 🔧 **Commands and Tools**

### **Research Commands**
```bash
# Analyze the specific issue
gh issue view [NUMBER] --json title,body,labels,assignees

# Check project status and context
cat PROJECT.md | grep -A 5 -B 5 "CRAN\|quality\|risk"

# Review related issues or PRs
gh issue list --search="related to #[NUMBER]"
gh pr list --search="related to #[NUMBER]"
```

### **Documentation Commands**
```bash
# Create the premortem document
touch ISSUE_[NUMBER]_PREMORTEM_ANALYSIS.md

# Update project documentation as needed
# (Edit files based on integration requirements)
```

## 📊 **Timeline and Milestones**

- **Hour 1**: Issue analysis and context gathering
- **Hour 2**: Failure scenario development and documentation
- **Hour 3**: Root cause analysis and 5-why exercises  
- **Hour 4**: Prevention strategy development
- **Hour 5**: Document creation and integration
- **Hour 6**: Validation and final review

## 🚨 **Critical Success Factors**

1. **Issue-Specific Focus**: Tailor all analysis to the specific issue, not generic risks
2. **Thoroughness**: Don't rush the risk identification phase
3. **Specificity**: Avoid generic risks; focus on issue-specific failure modes
4. **Actionability**: Every prevention strategy must be implementable for this issue
5. **Integration**: Ensure seamless integration with existing project workflows
6. **Validation**: Test all recommendations against project context and CRAN requirements

## 📋 **Template Variables**

| Variable | Description | Example |
|----------|-------------|---------|
| `[ISSUE]` | The specific issue to analyze | `Issue #160`, `Issue #367`, `Issue #392` |
| `[NUMBER]` | GitHub issue number | `160`, `367`, `392` |
| `[ISSUE_TITLE]` | Title of the issue | `Name Matching Enhancement`, `Performance Optimization` |

---

**This prompt enables any AI agent to perform a comprehensive, issue-specific premortem analysis that will significantly improve implementation success probability and risk management.**
