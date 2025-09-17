# Issue #406: CI Restoration - Implementation Guide

## **Mission Statement**

Restore the CI pipeline to full functionality, enabling automated testing, code quality checks, and deployment workflows. This is a critical CRAN submission blocker that must be resolved to enable automated development processes.

## **Prerequisites**

- Access to GitHub repository with admin privileges
- Understanding of GitHub Actions and CI/CD concepts
- R package development knowledge
- Ability to test workflows and troubleshoot issues

## **Implementation Steps**

### **Phase 1: Assessment and Diagnosis**

#### **Step 1.1: Analyze Current CI Configuration**
```bash
# Navigate to workflows directory
cd .github/workflows/

# List all workflow files
ls -la *.yml *.yaml

# Check workflow file syntax
for file in *.yml *.yaml; do
  echo "Checking $file..."
  yamllint "$file" || echo "Syntax issues in $file"
done
```

#### **Step 1.2: Review Workflow Files**
Examine each workflow file for:
- **Syntax errors** in YAML
- **Deprecated actions** or versions
- **Missing dependencies** or secrets
- **Incorrect trigger conditions**
- **Environment setup issues**

**Key Files to Check:**
- `R-CMD-check.yaml` - R package checking
- `coverage.yaml` - Test coverage reporting
- `lint.yaml` - Code linting
- `benchmarks.yaml` - Performance testing
- `sync-issues.yml` - Issue synchronization
- `pages.yml` - Documentation deployment

#### **Step 1.3: Test Workflow Execution**
```bash
# Create a test branch for CI testing
git checkout -b test/ci-restoration

# Make a small change to trigger workflows
echo "# CI Test" >> README.md
git add README.md
git commit -m "test: Trigger CI workflows for testing"
git push origin test/ci-restoration

# Monitor workflow execution in GitHub Actions tab
```

#### **Step 1.4: Analyze Workflow Logs**
For each failing workflow:
1. Navigate to GitHub Actions tab
2. Click on failed workflow run
3. Review error messages and logs
4. Identify root causes
5. Document findings

### **Phase 2: Configuration Fixes**

#### **Step 2.1: Update GitHub Actions Dependencies**
```yaml
# Example: Update R-CMD-check.yaml
name: R-CMD-check

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  R-CMD-check:
    runs-on: ${{ matrix.config.os }}
    
    name: ${{ matrix.config.os }} (${{ matrix.config.r }})
    
    strategy:
      fail-fast: false
      matrix:
        config:
          - {os: ubuntu-latest, r: 'release'}
          - {os: windows-latest, r: 'release'}
          - {os: macos-latest, r: 'release'}

    steps:
      - uses: actions/checkout@v4
      
      - uses: r-lib/actions/setup-r@v2
        with:
          r-version: ${{ matrix.config.r }}
          
      - uses: r-lib/actions/setup-pandoc@v2
      
      - name: Install dependencies
        run: |
          install.packages(c("remotes", "rcmdcheck"))
          remotes::install_deps(dependencies = TRUE)
          
      - name: Check
        env:
          _R_CHECK_CRAN_INCOMING_REMOTE_: false
        run: rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"), error_on = "warning")
```

#### **Step 2.2: Fix Common Issues**

**Issue: Deprecated Actions**
```yaml
# OLD (deprecated)
- uses: actions/checkout@v2

# NEW (current)
- uses: actions/checkout@v4
```

**Issue: Missing R Setup**
```yaml
# Add R setup step
- uses: r-lib/actions/setup-r@v2
  with:
    r-version: 'release'
```

**Issue: Missing Pandoc**
```yaml
# Add Pandoc setup
- uses: r-lib/actions/setup-pandoc@v2
```

**Issue: Incorrect Trigger Conditions**
```yaml
# Ensure proper triggers
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]
```

#### **Step 2.3: Update Coverage Workflow**
```yaml
name: Coverage

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  coverage:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: r-lib/actions/setup-r@v2
        with:
          r-version: 'release'
          
      - uses: r-lib/actions/setup-pandoc@v2
      
      - name: Install dependencies
        run: |
          install.packages(c("remotes", "covr"))
          remotes::install_deps(dependencies = TRUE)
          
      - name: Test coverage
        run: covr::codecov()
        
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
          flags: unittests
          name: codecov-umbrella
```

#### **Step 2.4: Update Lint Workflow**
```yaml
name: Lint

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  lint:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: r-lib/actions/setup-r@v2
        with:
          r-version: 'release'
          
      - name: Install dependencies
        run: |
          install.packages(c("remotes", "lintr"))
          remotes::install_deps(dependencies = TRUE)
          
      - name: Lint
        run: lintr::lint_package()
```

### **Phase 3: Testing and Validation**

#### **Step 3.1: Test Individual Workflows**
```bash
# Test R CMD check workflow
gh workflow run "R-CMD-check" --ref test/ci-restoration

# Test coverage workflow
gh workflow run "Coverage" --ref test/ci-restoration

# Test lint workflow
gh workflow run "Lint" --ref test/ci-restoration

# Test benchmarks workflow
gh workflow run "Benchmarks" --ref test/ci-restoration
```

#### **Step 3.2: Verify Workflow Success**
For each workflow:
1. Check execution status
2. Review logs for errors
3. Verify output quality
4. Test error handling
5. Document results

#### **Step 3.3: Test PR Integration**
```bash
# Create a test PR
gh pr create --title "test: CI restoration validation" \
  --body "Testing CI pipeline restoration" \
  --head test/ci-restoration \
  --base main

# Monitor PR checks
gh pr checks test/ci-restoration

# Verify all checks pass
gh pr view test/ci-restoration
```

#### **Step 3.4: Test Documentation Deployment**
```bash
# Trigger pages workflow
gh workflow run "pages" --ref main

# Check deployment status
gh api repos/:owner/:repo/pages/health

# Verify site updates
curl -I https://revgizmo.github.io/zoomstudentengagement/
```

### **Phase 4: Documentation and Monitoring**

#### **Step 4.1: Update Project Documentation**
```bash
# Update PROJECT.md with CI status
sed -i 's/CI temporarily disabled/CI fully operational/g' PROJECT.md

# Update README.md with CI badges
echo "[![R-CMD-check](https://github.com/revgizmo/zoomstudentengagement/workflows/R-CMD-check/badge.svg)](https://github.com/revgizmo/zoomstudentengagement/actions)" >> README.md
echo "[![Coverage](https://codecov.io/gh/revgizmo/zoomstudentengagement/branch/main/graph/badge.svg)](https://codecov.io/gh/revgizmo/zoomstudentengagement)" >> README.md
```

#### **Step 4.2: Create CI Monitoring**
```bash
# Create CI health check script
cat > scripts/ci-health-check.sh << 'EOF'
#!/bin/bash
# CI Health Check Script

echo "Checking CI workflow status..."

# Check recent workflow runs
gh run list --limit 10 --json status,conclusion,name,createdAt

# Check for failed runs in last 24 hours
gh run list --limit 50 --json status,conclusion,createdAt | \
  jq '.[] | select(.createdAt > (now - 86400 | strftime("%Y-%m-%dT%H:%M:%SZ"))) | select(.conclusion == "failure")'

echo "CI health check complete."
EOF

chmod +x scripts/ci-health-check.sh
```

#### **Step 4.3: Update Development Workflow**
```bash
# Update pre-PR validation to include CI checks
cat >> scripts/pre-pr-validation.sh << 'EOF'

# Check CI status before PR
echo "Checking CI pipeline status..."
gh run list --limit 5 --json status,conclusion,name | \
  jq '.[] | select(.name | contains("R-CMD-check")) | select(.conclusion != "success")' && \
  echo "WARNING: Recent CI failures detected" || \
  echo "CI pipeline healthy"
EOF
```

## **Validation Checklist**

### **Workflow Functionality**
- [ ] R CMD check runs successfully on all platforms
- [ ] Test coverage reporting works accurately
- [ ] Code linting executes without errors
- [ ] Performance benchmarks complete successfully
- [ ] Documentation deployment updates site
- [ ] Issue synchronization works properly

### **Integration Testing**
- [ ] All workflows trigger on PR creation
- [ ] All workflows trigger on push to main/develop
- [ ] Workflow status appears correctly in PRs
- [ ] Failed workflows block PR merge (if configured)
- [ ] Successful workflows allow PR merge

### **Quality Assurance**
- [ ] Workflow execution time <15 minutes
- [ ] No false positive failures
- [ ] Error messages are clear and actionable
- [ ] Logs provide sufficient debugging information
- [ ] Workflows handle edge cases gracefully

### **Documentation**
- [ ] CI status updated in PROJECT.md
- [ ] README.md includes CI badges
- [ ] Development workflow documented
- [ ] Troubleshooting guide created
- [ ] Monitoring procedures established

## **Troubleshooting Guide**

### **Common Issues and Solutions**

**Issue: Workflow Not Triggering**
```bash
# Check workflow file syntax
yamllint .github/workflows/*.yml

# Verify trigger conditions
grep -A 5 "on:" .github/workflows/*.yml
```

**Issue: R Environment Setup Fails**
```yaml
# Ensure proper R setup
- uses: r-lib/actions/setup-r@v2
  with:
    r-version: 'release'
    use-public-rspm: true
```

**Issue: Package Installation Fails**
```yaml
# Add system dependencies
- name: Install system dependencies
  run: |
    sudo apt-get update
    sudo apt-get install -y libcurl4-openssl-dev libssl-dev libxml2-dev
```

**Issue: Coverage Upload Fails**
```yaml
# Ensure proper Codecov setup
- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v3
  with:
    token: ${{ secrets.CODECOV_TOKEN }}
    file: ./coverage.xml
```

### **Debugging Commands**
```bash
# Check workflow runs
gh run list --limit 10

# View specific run logs
gh run view <run-id> --log

# Check workflow file syntax
yamllint .github/workflows/*.yml

# Test workflow locally (if possible)
act -j R-CMD-check
```

## **Success Criteria**

### **Primary Objectives**
- [ ] All CI workflows running automatically
- [ ] Automated testing on all pull requests
- [ ] Code quality checks functioning
- [ ] Documentation deployment working
- [ ] No manual self-merge policy required

### **Quality Metrics**
- [ ] CI pipeline success rate >95%
- [ ] Average workflow completion time <15 minutes
- [ ] All platforms (Ubuntu, macOS, Windows) passing
- [ ] Test coverage reporting accurate
- [ ] Documentation site updating automatically

### **CRAN Readiness**
- [ ] Automated R CMD check passing
- [ ] Test suite running automatically
- [ ] Code quality standards enforced
- [ ] Documentation up-to-date
- [ ] No manual intervention required

## **Post-Implementation**

### **Monitoring**
- Set up weekly CI health checks
- Monitor workflow success rates
- Track performance metrics
- Review and update dependencies regularly

### **Maintenance**
- Update GitHub Actions monthly
- Review and optimize workflow performance
- Update R versions as needed
- Maintain documentation accuracy

### **Continuous Improvement**
- Optimize workflow execution time
- Add additional quality checks
- Implement advanced monitoring
- Enhance error reporting

---

**Implementation Timeline**: 5-8 days  
**Risk Level**: Medium (with proper testing and rollback plan)  
**Success Probability**: High (with systematic approach)
