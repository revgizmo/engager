# AI Agent Workflow Guide

**This document provides a comprehensive guide for AI agents working on the zoomstudentengagement R package project.**

## 🎯 **Overview**

The AI Agent Workflow is a structured approach for AI agents to contribute to this R package project while maintaining quality, consistency, and CRAN compliance standards.

## 🔄 **Workflow Overview**

### **Phase 1: Issue Analysis & Planning**
1. **Review Issue Requirements**
   - Read the GitHub issue description thoroughly
   - Identify the specific phase or work type needed
   - Understand success criteria and technical requirements

2. **Create Planning Documents**
   - Generate consolidated plan if not exists
   - Create or update implementation guide
   - Document current status and next steps

3. **Branch Creation**
   - Create feature branch following naming convention
   - Set upstream and push to remote
   - Ensure branch is ready for development

### **Phase 2: Development & Implementation**
1. **Code Implementation**
   - Follow R package development standards
   - Implement functionality according to specifications
   - Maintain privacy-first approach
   - Ensure CRAN compliance

2. **Documentation**
   - Update roxygen2 documentation
   - Create comprehensive examples
   - Update relevant documentation files
   - Ensure all examples are runnable

3. **Testing**
   - Write comprehensive tests
   - Achieve >90% code coverage
   - Test edge cases and error conditions
   - Validate with realistic scenarios

### **Phase 3: Validation & Submission**
1. **Pre-PR Validation**
   - Run complete validation checklist
   - Fix any issues found
   - Ensure all tests pass
   - Validate documentation completeness

2. **Pull Request Creation**
   - Create PR with descriptive title and body
   - Link to relevant issues
   - Request review from maintainers
   - Ensure CI checks pass

3. **Review & Merge**
   - Address review feedback
   - Resolve conflicts if any
   - Merge when approved
   - Clean up branches

## 📋 **Key Workflow Components**

### **Branch Naming Convention**
```
feature/issue-[NUMBER]-[PHASE]-[WORK_TYPE]
```
Examples:
- `feature/issue-160-phase2-implementation`
- `feature/issue-454-documentation-creation`
- `feature/issue-367-testing-validation`

### **Documentation Standards**
- **Roxygen2**: All exported functions must have complete documentation
- **Examples**: All examples must be runnable and tested
- **Cross-references**: Link related functions and concepts
- **Privacy**: Document privacy considerations and FERPA compliance

### **Testing Requirements**
- **Coverage**: Aim for >90% test coverage
- **Test Organization**: One test file per R file
- **Edge Cases**: Test error conditions and boundary cases
- **Real Data**: Use realistic test scenarios

### **CRAN Compliance**
- **R CMD check**: Must pass with 0 errors, 0 warnings
- **Examples**: All examples must run successfully
- **Documentation**: Complete and accurate
- **Dependencies**: Properly specified and versioned

## 🛠 **Tools and Commands**

### **Essential R Commands**
```r
# Load package for development
devtools::load_all()

# Run tests
devtools::test()

# Check package
devtools::check()

# Generate documentation
devtools::document()

# Build package
devtools::build()

# Check examples
devtools::check_examples()
```

### **Pre-PR Validation**
```bash
# Run complete validation
Rscript scripts/pre-pr-validation.R

# Style check
Rscript -e "styler::style_pkg()"

# Lint check
Rscript -e "lintr::lint_package()"
```

### **Git Workflow**
```bash
# Create and switch to feature branch
git checkout -b feature/issue-[NUMBER]-[PHASE]-[WORK_TYPE]

# Set upstream and push
git push -u origin feature/issue-[NUMBER]-[PHASE]-[WORK_TYPE]

# Create pull request
gh pr create --title "feat: [Description]" --body "Fixes #[NUMBER]"
```

## 🔒 **Privacy and Security Guidelines**

### **Data Handling**
- **Never commit real student data**
- **Use synthetic test data only**
- **Implement proper anonymization**
- **Follow FERPA compliance requirements**

### **Privacy Functions**
- **`ensure_privacy()`**: Apply privacy protection
- **`set_privacy_defaults()`**: Configure privacy settings
- **`privacy_audit()`**: Validate privacy compliance
- **Name masking and anonymization**

## 📚 **Documentation Integration**

### **Required Documentation Updates**
- **Function Documentation**: Complete roxygen2 docs
- **Examples**: Runnable and tested examples
- **Vignettes**: Comprehensive workflow guides
- **README**: Installation and usage instructions
- **Contributing**: Development workflow updates

### **Documentation Standards**
- **Accuracy**: All information must be current and correct
- **Completeness**: Cover all aspects of functionality
- **Accessibility**: Clear language and examples
- **Maintenance**: Regular updates and validation

## 🚨 **Common Issues and Solutions**

### **R CMD Check Failures**
- **Documentation Issues**: Check roxygen2 syntax and examples
- **Test Failures**: Verify test data and environment
- **Dependency Issues**: Check DESCRIPTION and NAMESPACE
- **Example Failures**: Test all examples manually

### **Test Coverage Issues**
- **Missing Tests**: Add tests for uncovered functions
- **Edge Cases**: Test error conditions and boundaries
- **Integration Tests**: Test function interactions
- **Real Data Tests**: Validate with realistic scenarios

### **Documentation Problems**
- **Missing Documentation**: Add roxygen2 comments
- **Broken Examples**: Fix and test all examples
- **Outdated Information**: Update to current state
- **Inconsistent Formatting**: Apply style guidelines

## ✅ **Success Criteria Validation**

### **Before PR Submission**
- [ ] All tests pass (`devtools::test()`)
- [ ] Code coverage >90% (`covr::package_coverage()`)
- [ ] No linting errors (`lintr::lint_package()`)
- [ ] All examples run (`devtools::check_examples()`)
- [ ] R CMD check passes (`devtools::check()`)
- [ ] Documentation complete and accurate

### **Before Merge**
- [ ] Code review completed
- [ ] All feedback addressed
- [ ] CI checks passing
- [ ] No merge conflicts
- [ ] Branch protection satisfied

## 🔗 **Related Documentation**

- **[AI Agent Prompt Generator](AI_AGENT_PROMPT_GENERATOR.md)**: Create prompts for new AI agents
- **[AI Assisted Development](AI_ASSISTED_DEVELOPMENT.md)**: General AI development guidelines
- **[Contributing Guidelines](../../CONTRIBUTING.md)**: Overall contribution workflow
- **[Project Documentation](../../PROJECT.md)**: Project status and priorities
- **[CRAN Checklist](../../CRAN_CHECKLIST.md)**: CRAN submission requirements

## 📞 **Support and Resources**

### **When to Ask for Help**
- **Unclear Requirements**: Issue description is ambiguous
- **Technical Challenges**: Complex implementation issues
- **Integration Problems**: Conflicts with existing code
- **CRAN Compliance**: Uncertain about submission requirements

### **Available Resources**
- **Project Documentation**: Comprehensive guides and examples
- **GitHub Issues**: Search for similar problems and solutions
- **R Package Resources**: Official R package development guides
- **Community Support**: R package development community

---

**This workflow ensures consistent, high-quality contributions while maintaining the project's standards and CRAN readiness.**
