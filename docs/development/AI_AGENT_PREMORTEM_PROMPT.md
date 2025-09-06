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

### **Step 2: Comprehensive Premortem Exercise Execution**

**Based on Gary Klein's premortem technique (as described by Daniel Kahneman):**

#### **2.1 Imagine Catastrophic Failure**
**Scenario**: "It's 6 months from now. The implementation of [ISSUE] has completely failed. The project is in disarray. What went wrong?"

**CRITICAL REQUIREMENT**: This analysis must be COMPREHENSIVE and THOROUGH. The goal is to identify EVERY possible failure mode so that no challenge surprises the project team.

#### **2.2 Iterative Failure Scenario Development**

**MANDATORY PROCESS**: For each category below, you MUST identify AT LEAST 10 specific failure scenarios. Use iterative brainstorming:

1. **First Pass**: Identify obvious failure modes
2. **Second Pass**: Think of edge cases and unusual circumstances  
3. **Third Pass**: Consider external factors and "acts of god"
4. **Fourth Pass**: Imagine malicious actors and worst-case scenarios
5. **Fifth Pass**: Consider cascading failures and compound risks

**Technical Failures** (Minimum 10 scenarios):
- Implementation introduced bugs that broke existing functionality
- Code quality degraded due to rushed or incomplete work
- Performance issues from poorly optimized solutions
- Integration conflicts with existing systems
- Privacy or security vulnerabilities introduced
- [Continue with 5+ additional specific technical failure scenarios]
- [Include edge cases like: hardware failures, network issues, dependency conflicts, memory leaks, race conditions, etc.]

**Process Failures** (Minimum 10 scenarios):
- Requirements were misunderstood or incomplete
- Testing was insufficient or skipped
- Documentation was inadequate or missing
- Review processes were bypassed or ineffective
- Timeline pressures led to shortcuts
- [Continue with 5+ additional specific process failure scenarios]
- [Include edge cases like: team member illness, key person departure, communication breakdowns, tool failures, etc.]

**Project Impact Failures** (Minimum 10 scenarios):
- CRAN submission delayed due to this issue's problems
- Quality standards compromised
- User experience degraded
- Project reputation damaged
- Maintainability issues created
- [Continue with 5+ additional specific project impact scenarios]
- [Include edge cases like: competitor releases, market changes, funding issues, regulatory changes, etc.]

**Ethical/Compliance Failures** (Minimum 10 scenarios):
- Privacy violations introduced
- FERPA compliance issues
- Inappropriate data handling
- Bias introduced in analysis
- Misuse of student data
- [Continue with 5+ additional specific ethical/compliance scenarios]
- [Include edge cases like: data breaches, regulatory investigations, media exposure, legal challenges, etc.]

**External/Environmental Failures** (Minimum 10 scenarios):
- Natural disasters affecting development
- Economic downturns impacting funding
- Political changes affecting regulations
- Technology platform changes
- Key personnel departures or illness
- [Continue with 5+ additional external failure scenarios]
- [Include edge cases like: pandemics, wars, supply chain issues, infrastructure failures, etc.]

**Malicious Actor Failures** (Minimum 10 scenarios):
- Vindictive reviewers sabotaging the project
- Competitors spreading misinformation
- Hackers targeting the system
- Disgruntled team members causing damage
- Academic rivals undermining credibility
- [Continue with 5+ additional malicious actor scenarios]
- [Include edge cases like: social engineering, insider threats, coordinated attacks, etc.]

**AI/Technology Failures** (Minimum 10 scenarios):
- AI agents hallucinating or providing incorrect information
- AI systems making inappropriate decisions
- Technology dependencies becoming unavailable
- AI bias affecting analysis results
- Automation failures causing data corruption
- [Continue with 5+ additional AI/technology failure scenarios]
- [Include edge cases like: model drift, training data poisoning, API changes, etc.]

### **Step 3: Comprehensive Root Cause Analysis**

#### **3.1 MANDATORY: Complete 5-Why Analysis for ALL Identified Failures**

**CRITICAL REQUIREMENT**: You MUST perform a complete 5-Why analysis for EVERY failure scenario identified in Step 2. This is not optional - it's the core of the premortem analysis.

**For EACH of the 60+ failure scenarios identified, perform this analysis**:

#### **3.2 5-Why Analysis Template**

**For each failure scenario, ask "Why?" five times to reach root causes:**

**Example - Technical Failure**:
1. Why did the implementation introduce a critical bug? → Didn't follow testing protocols
2. Why didn't it follow testing protocols? → Testing requirements weren't clear
3. Why weren't testing requirements clear? → Documentation was outdated
4. Why was documentation outdated? → No process for keeping it current
5. Why was there no process? → No ownership assigned for documentation maintenance

**Example - Process Failure**:
1. Why were requirements misunderstood? → Communication was unclear
2. Why was communication unclear? → No structured requirements review process
3. Why was there no review process? → Timeline pressure forced shortcuts
4. Why was there timeline pressure? → Unrealistic estimates were accepted
5. Why were unrealistic estimates accepted? → No historical data for similar work

**Example - External Failure**:
1. Why did a key team member leave? → Better opportunity elsewhere
2. Why was there a better opportunity? → Market conditions changed
3. Why did market conditions change? → Economic factors beyond our control
4. Why couldn't we adapt to economic factors? → No contingency planning
5. Why was there no contingency planning? → Focus was only on technical risks

#### **3.3 Document Root Causes for Each Category**

**For each failure category, identify common root cause patterns**:
- **Technical Root Causes**: Process gaps, skill deficiencies, tool limitations
- **Process Root Causes**: Communication failures, timeline pressures, resource constraints
- **Project Root Causes**: Scope creep, unrealistic expectations, insufficient planning
- **External Root Causes**: Market changes, regulatory shifts, environmental factors
- **Malicious Root Causes**: Security vulnerabilities, trust assumptions, access controls
- **AI/Technology Root Causes**: Model limitations, data quality, automation assumptions

### **Step 4: Comprehensive Prevention Strategy Development**

#### **4.1 MANDATORY: Develop Prevention Strategies for ALL Root Causes**

**CRITICAL REQUIREMENT**: For EVERY root cause identified in the 5-Why analysis, you MUST develop specific, actionable prevention strategies. This is the core value of the premortem analysis.

#### **4.2 Prevention Strategy Categories**

**For each of the 60+ failure scenarios and their root causes, develop prevention strategies in these categories**:

**Technical Safeguards** (for technical root causes):
- Comprehensive test coverage requirements
- Automated quality gates and validation
- Performance benchmarking and monitoring
- Privacy compliance validation
- Code review requirements
- [Develop specific strategies for each technical root cause identified]

**Process Improvements** (for process root causes):
- Clear requirement documentation and validation
- Mandatory testing protocols
- Documentation standards and review
- Timeline and scope management
- Quality gate enforcement
- [Develop specific strategies for each process root cause identified]

**Project Safeguards** (for project root causes):
- CRAN compliance validation
- User experience testing
- Privacy impact assessment
- Performance impact analysis
- Maintainability review
- [Develop specific strategies for each project root cause identified]

**External Risk Mitigation** (for external root causes):
- Contingency planning for key personnel
- Diversified funding sources
- Regulatory monitoring and compliance
- Market change adaptation strategies
- Infrastructure redundancy
- [Develop specific strategies for each external root cause identified]

**Security and Malicious Actor Protection** (for malicious root causes):
- Access control and authentication
- Security monitoring and incident response
- Reputation management strategies
- Legal protection and documentation
- Insider threat prevention
- [Develop specific strategies for each malicious root cause identified]

**AI/Technology Risk Management** (for AI/technology root causes):
- Model validation and testing
- Human oversight and review
- Fallback and manual processes
- Data quality monitoring
- Bias detection and mitigation
- [Develop specific strategies for each AI/technology root cause identified]

#### **4.3 Prioritized Prevention Strategy Matrix**

**Create a matrix ranking prevention strategies by**:
1. **Impact**: How much risk reduction does this strategy provide?
2. **Feasibility**: How easy is this to implement?
3. **Cost**: What resources are required?
4. **Timeline**: How quickly can this be implemented?

**Priority Categories**:
- **Immediate (High Impact, High Feasibility)**: Implement first
- **Short-term (High Impact, Medium Feasibility)**: Implement within 1-3 months
- **Medium-term (Medium Impact, High Feasibility)**: Implement within 3-6 months
- **Long-term (High Impact, Low Feasibility)**: Plan for 6+ months
- **Low Priority (Low Impact)**: Consider only if resources allow

#### **4.4 Design Comprehensive Monitoring Systems**

**For each prevention strategy, define monitoring mechanisms**:
- **Early Warning Indicators**: Specific metrics that signal potential problems
- **Quality Gates**: Automated checks that must pass before proceeding
- **Human Oversight**: Review processes and approval requirements
- **Feedback Loops**: Mechanisms for continuous improvement
- **Escalation Procedures**: What to do when monitoring detects issues

### **Step 5: Comprehensive Document Creation**

#### **5.1 Create Detailed Premortem Analysis Document**
Create: `ISSUE_[NUMBER]_PREMORTEM_ANALYSIS.md`

**CRITICAL REQUIREMENT**: This document must be COMPREHENSIVE and DETAILED. It should serve as the definitive risk assessment for this issue.

```markdown
# Premortem Analysis: Issue #[NUMBER] - [ISSUE_TITLE]

*Comprehensive Risk Assessment and Prevention Strategies*

## Executive Summary
[Comprehensive overview of ALL identified risks, their likelihood, impact, and prioritized prevention strategies]

## Issue Context
[Detailed summary of the issue, its requirements, expected outcomes, and dependencies]

## Comprehensive Failure Scenario Analysis

### Technical Failures (10+ scenarios)
[Detailed analysis of each technical failure mode with specific examples and impact assessment]

### Process Failures (10+ scenarios)
[Analysis of each workflow and process failure with specific examples and impact assessment]

### Project Impact Failures (10+ scenarios)
[Impact analysis for each failure on project success, CRAN submission, and overall quality]

### Ethical/Compliance Failures (10+ scenarios)
[Privacy, bias, and compliance concerns with specific examples and regulatory impact]

### External/Environmental Failures (10+ scenarios)
[External factors that could impact this issue's implementation with specific examples]

### Malicious Actor Failures (10+ scenarios)
[Potential malicious actions that could sabotage this issue with specific examples]

### AI/Technology Failures (10+ scenarios)
[AI and technology-related failures specific to this issue with specific examples]

## Comprehensive Root Cause Analysis

### 5-Why Analysis for Each Failure Scenario
[Complete 5-Why analysis for EVERY identified failure scenario - this should be the largest section]

### Root Cause Patterns
[Analysis of common root cause patterns across all failure categories]

## Comprehensive Prevention Strategy Matrix

### Immediate Priority Strategies (High Impact, High Feasibility)
[Specific, actionable strategies that should be implemented first]

### Short-term Strategies (High Impact, Medium Feasibility)
[Strategies to implement within 1-3 months]

### Medium-term Strategies (Medium Impact, High Feasibility)
[Strategies to implement within 3-6 months]

### Long-term Strategies (High Impact, Low Feasibility)
[Strategies to plan for 6+ months]

### Low Priority Strategies (Low Impact)
[Strategies to consider only if resources allow]

## Comprehensive Monitoring and Detection Systems

### Early Warning Indicators
[Specific metrics and indicators for each risk category]

### Quality Gates
[Automated checks and validation points]

### Human Oversight Requirements
[Review processes and approval requirements]

### Escalation Procedures
[What to do when risks materialize]

## Response Procedures and Contingency Plans

### Technical Response Procedures
[Specific steps for technical failures]

### Process Response Procedures
[Specific steps for process failures]

### External Response Procedures
[Specific steps for external threats]

### Malicious Actor Response Procedures
[Specific steps for security incidents]

## Implementation Recommendations

### Phase 1: Immediate Risk Mitigation
[Critical actions to take before starting implementation]

### Phase 2: Implementation Safeguards
[Ongoing protections during implementation]

### Phase 3: Post-Implementation Monitoring
[Ongoing monitoring after implementation]

## Success Criteria and Validation

### Technical Success Criteria
[Specific, measurable technical outcomes]

### Process Success Criteria
[Specific, measurable process outcomes]

### Project Success Criteria
[Specific, measurable project outcomes]

### Risk Mitigation Success Criteria
[Specific, measurable risk reduction outcomes]

## Appendices

### Appendix A: Complete Failure Scenario List
[Full list of all 60+ identified failure scenarios]

### Appendix B: Complete Root Cause Analysis
[Full 5-Why analysis for every failure scenario]

### Appendix C: Prevention Strategy Details
[Detailed implementation plans for each prevention strategy]

### Appendix D: Monitoring Implementation Guide
[Step-by-step guide for implementing monitoring systems]
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
