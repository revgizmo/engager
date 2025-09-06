# User Profiles and Use Cases: zoomstudentengagement Package

**Repository**: `revgizmo/zoomstudentengagement`  
**Analysis Date**: January 2025  
**Package Purpose**: Analyze student engagement from Zoom transcripts with focus on participation equity

## Executive Summary

The `zoomstudentengagement` R package is designed for **instructors and educational researchers** who want to analyze student participation patterns in Zoom-recorded classes. The package prioritizes **privacy-first design** with FERPA compliance, **participation equity** over surveillance, and **educational outcomes** over punitive measures.

## Primary User Profile: Multi-Section Instructor

### **Profile Description**
- **Role**: University/college instructor teaching multiple sections of multiple classes
- **Technical Level**: Intermediate R users (comfortable with basic data analysis)
- **Primary Goal**: Understand student participation patterns to improve teaching effectiveness
- **Data Sources**: Zoom transcript files (.transcript.vtt), student rosters (CSV), optional Zoom recording logs (CSV)

### **Typical Workflow**
1. **Upload Data**: Roster files, Zoom transcript files, optional recording logs
2. **Name Alignment**: Match Zoom transcript names with roster names (handles variations, nicknames, international names)
3. **Analysis**: Calculate participation metrics and engagement patterns
4. **Privacy Protection**: Automatic masking of student names in outputs
5. **Insights**: Identify participation equity issues and teaching improvement opportunities

### **Expected Use Cases**

#### **Use Case 1: Weekly Participation Analysis**
**Scenario**: Instructor wants to track participation across multiple class sections over time

**Workflow**:
```r
# Load roster for all sections
roster <- load_roster(data_folder = "data", roster_file = "spring2024_roster.csv")

# Analyze all transcripts in a folder
metrics <- analyze_transcripts(
  transcripts_folder = "data/transcripts/week3",
  names_to_exclude = c("dead_air", "Instructor")
)

# Generate privacy-safe visualizations
plot_users(metrics, metric = "session_ct", facet_by = "section")
```

**Expected Outcomes**:
- Identify students with consistently low participation
- Compare participation patterns across different sections
- Track improvement in student engagement over time
- Generate reports for department meetings

#### **Use Case 2: Multi-Session Course Analysis**
**Scenario**: Instructor teaching a semester-long course wants to analyze participation trends

**Workflow**:
```r
# Process multiple sessions
sessions <- c("week1", "week2", "week3", "week4")
all_metrics <- list()

for (week in sessions) {
  week_metrics <- analyze_transcripts(
    transcripts_folder = paste0("data/transcripts/", week)
  )
  all_metrics[[week]] <- week_metrics
}

# Multi-session analysis
attendance_report <- analyze_multi_session_attendance(all_metrics)
```

**Expected Outcomes**:
- Track student engagement progression throughout semester
- Identify students who may need additional support
- Compare participation patterns across different topics
- Generate semester-end participation reports

#### **Use Case 3: Cross-Section Comparison**
**Scenario**: Instructor wants to compare participation patterns across different course sections

**Workflow**:
```r
# Load section-specific rosters
section_a_roster <- load_roster(roster_file = "section_a_roster.csv")
section_b_roster <- load_roster(roster_file = "section_b_roster.csv")

# Analyze each section
section_a_metrics <- analyze_transcripts("data/section_a/transcripts")
section_b_metrics <- analyze_transcripts("data/section_b/transcripts")

# Compare sections
comparison <- compare_section_participation(section_a_metrics, section_b_metrics)
```

**Expected Outcomes**:
- Identify which sections have more equitable participation
- Understand how different teaching approaches affect engagement
- Generate insights for improving future course delivery
- Create reports for curriculum development

## Secondary User Profiles

### **Profile 2: Educational Researcher**

#### **Profile Description**
- **Role**: Academic researcher studying online learning and student engagement
- **Technical Level**: Advanced R users (comfortable with statistical analysis)
- **Primary Goal**: Conduct research on participation equity and educational outcomes
- **Data Sources**: Large datasets from multiple institutions, anonymized student data

#### **Typical Use Cases**

**Use Case 4: Institutional Research**
```r
# Large-scale analysis across multiple courses
institutional_data <- load_institutional_transcripts("research_data/")

# Privacy-compliant analysis
research_metrics <- analyze_transcripts(
  transcripts_folder = institutional_data,
  privacy_level = "ferpa_strict"
)

# Statistical analysis
participation_equity <- calculate_equity_metrics(research_metrics)
```

**Use Case 5: Comparative Studies**
```r
# Compare different course types
stem_courses <- analyze_transcripts("data/stem_courses/")
humanities_courses <- analyze_transcripts("data/humanities_courses/")

# Cross-disciplinary analysis
comparison <- compare_course_types(stem_courses, humanities_courses)
```

### **Profile 3: Department Administrator**

#### **Profile Description**
- **Role**: Department head or program coordinator
- **Technical Level**: Basic R users (comfortable with running scripts)
- **Primary Goal**: Monitor teaching effectiveness and student engagement across department
- **Data Sources**: Aggregated data from multiple instructors

#### **Typical Use Cases**

**Use Case 6: Department-Wide Analysis**
```r
# Aggregate data from multiple instructors
department_metrics <- aggregate_department_data("data/department/")

# Generate department reports
department_report <- generate_department_report(department_metrics)
```

**Use Case 7: Faculty Development**
```r
# Identify instructors who might benefit from teaching support
teaching_effectiveness <- analyze_teaching_patterns(department_metrics)

# Generate recommendations
recommendations <- generate_teaching_recommendations(teaching_effectiveness)
```

## Core Workflows and Functions

### **1. Data Ingestion Workflow**

#### **Input Data Types**
- **Zoom Transcripts**: `.transcript.vtt` files (canonical Zoom transcript format)
- **Student Rosters**: CSV files with student enrollment information
- **Recording Logs**: Optional CSV files with Zoom recording metadata

#### **Key Functions**
- `load_zoom_transcript()` - Load individual transcript files
- `load_roster()` - Load student enrollment data
- `load_zoom_recorded_sessions_list()` - Load recording metadata

#### **Data Structure Requirements**
```r
# Roster structure
roster <- tibble(
  student_id = c("12345", "67890"),
  preferred_name = c("Alice Johnson", "Bob Smith"),
  email = c("alice@university.edu", "bob@university.edu"),
  section = c("A", "B"),
  enrolled = c(TRUE, TRUE)
)

# Transcript structure (automatically parsed)
transcript <- tibble(
  speaker = c("Alice Johnson", "Bob Smith", "Instructor"),
  message = c("Hello", "Good morning", "Welcome to class"),
  timestamp = c("00:01:00", "00:02:00", "00:00:30"),
  duration = c(2.5, 3.2, 4.1)
)
```

### **2. Name Matching and Privacy Workflow**

#### **Privacy-First Design**
- **Default Privacy Level**: `"mask"` - automatically masks student names
- **FERPA Compliance**: Built-in compliance checking and validation
- **Configurable Privacy**: Multiple privacy levels for different institutional requirements

#### **Key Functions**
- `safe_name_matching_workflow()` - Main privacy-safe name matching
- `make_clean_names_df()` - Match transcript names to roster
- `ensure_privacy()` - Apply privacy protection to data
- `validate_ferpa_compliance()` - Check FERPA compliance

#### **Privacy Levels**
```r
# FERPA Strict (maximum protection)
set_privacy_defaults("ferpa_strict")

# FERPA Standard (educational compliance)
set_privacy_defaults("ferpa_standard")

# Basic Mask (default)
set_privacy_defaults("mask")

# No Masking (not recommended)
set_privacy_defaults("none")  # Will emit warning
```

### **3. Analysis and Metrics Workflow**

#### **Core Analysis Functions**
- `analyze_transcripts()` - High-level orchestration function
- `summarize_transcript_metrics()` - Calculate engagement metrics
- `analyze_multi_session_attendance()` - Multi-session analysis
- `generate_attendance_report()` - Generate attendance reports

#### **Engagement Metrics**
```r
# Key metrics calculated
metrics <- tibble(
  speaker = c("Student 01", "Student 02", "Student 03"),
  session_ct = c(5, 3, 8),           # Number of times speaking
  word_ct = c(45, 23, 67),           # Total words spoken
  perc_session_ct = c(31.25, 18.75, 50.0),  # Percentage of total participation
  avg_words_per_session = c(9.0, 7.7, 8.4), # Average words per speaking turn
  total_duration = c(120, 85, 180)   # Total speaking time in seconds
)
```

### **4. Visualization and Reporting Workflow**

#### **Privacy-Safe Visualization**
- `plot_users()` - Unified plotting with privacy-aware options
- `write_metrics()` - Export metrics with privacy protection
- `run_student_reports()` - Generate individual student reports

#### **Visualization Examples**
```r
# Basic participation plot
plot_users(metrics, metric = "session_ct", facet_by = "none", mask_by = "name")

# Section comparison
plot_users(metrics, metric = "perc_session_ct", facet_by = "section", mask_by = "name")

# Export privacy-safe data
write_metrics(metrics, what = "engagement", path = "engagement_metrics.csv")
```

## Privacy and Ethical Considerations

### **Privacy-First Design Principles**

1. **Default Privacy Protection**: All outputs are privacy-masked by default
2. **FERPA Compliance**: Built-in compliance checking and validation
3. **Data Minimization**: Only necessary data is processed and stored
4. **Secure Processing**: Privacy protection applied throughout the workflow
5. **Audit Trail**: Comprehensive logging of privacy-sensitive operations

### **Ethical Use Guidelines**

#### **✅ Recommended Uses**
- **Participation Equity**: Identify students who need additional support
- **Teaching Improvement**: Understand which teaching methods promote engagement
- **Curriculum Development**: Use insights to improve course design
- **Student Success**: Provide targeted support for struggling students
- **Research**: Conduct ethical research on educational outcomes

#### **❌ Discouraged Uses**
- **Surveillance**: Monitoring students without educational purpose
- **Punitive Measures**: Using participation data for punishment
- **Bias Reinforcement**: Using data to reinforce existing biases
- **Privacy Violations**: Exposing student data without proper protection
- **Non-Educational Tracking**: Using data for non-educational purposes

### **FERPA Compliance Features**

#### **Built-in Compliance Functions**
```r
# Validate FERPA compliance
validation_result <- validate_ferpa_compliance(student_data)

# Generate compliance reports
compliance_report <- generate_ferpa_report(student_data)

# Check data retention policies
retention_check <- check_data_retention_policy(
  student_data,
  retention_period = "academic_year"
)
```

#### **Institutional Compliance Levels**
- **Educational Institutions**: Standard FERPA compliance
- **Research Institutions**: Enhanced privacy for research data
- **Mixed Institutions**: Flexible compliance for different use cases

## Technical Requirements and Constraints

### **System Requirements**
- **R Version**: 4.0 or higher
- **Dependencies**: data.table, dplyr, ggplot2, lubridate, readr, stringr, tibble
- **File Formats**: Zoom .transcript.vtt files, CSV rosters
- **Memory**: Suitable for typical class sizes (20-200 students)

### **Performance Characteristics**
- **File Size**: Optimized for typical Zoom transcripts (1-10 MB)
- **Processing Speed**: 1MB transcript processed in <30 seconds
- **Memory Usage**: Efficient memory management for large datasets
- **Scalability**: Supports multiple sessions and sections

### **Data Format Support**
- **Supported**: Zoom .transcript.vtt files (canonical format)
- **Not Supported**: .cc.vtt (closed captions), .newChat.txt (chat logs)
- **Future Support**: Additional Zoom file types planned

## User Experience and Onboarding

### **Getting Started Workflow**
```r
# 1. Install package
devtools::install_github("revgizmo/zoomstudentengagement")

# 2. Load package
library(zoomstudentengagement)

# 3. Quick start example
transcript_file <- system.file(
  "extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt",
  package = "zoomstudentengagement"
)
metrics <- summarize_transcript_metrics(transcript_file_path = transcript_file)

# 4. Visualize results
plot_users(metrics, metric = "session_ct", facet_by = "none", mask_by = "name")
```

### **Learning Resources**
- **Vignettes**: Comprehensive guides for different use cases
- **Documentation**: Complete function documentation with examples
- **Sample Data**: Realistic test data for learning and testing
- **Tutorials**: Step-by-step guides for common workflows

### **Support and Community**
- **GitHub Issues**: Bug reports and feature requests
- **Documentation**: Comprehensive guides and examples
- **Community**: Educational technology community support
- **Updates**: Regular updates and improvements

## Success Metrics and Outcomes

### **For Instructors**
- **Improved Teaching**: Better understanding of student engagement patterns
- **Equity Focus**: Identification and support for underrepresented students
- **Efficiency**: Streamlined analysis of participation data
- **Compliance**: Confidence in FERPA compliance and data protection

### **For Students**
- **Better Support**: More targeted assistance for struggling students
- **Equitable Participation**: Reduced bias in participation assessment
- **Privacy Protection**: Confidence that their data is protected
- **Educational Outcomes**: Improved learning through better teaching

### **For Institutions**
- **Compliance**: FERPA-compliant data handling and analysis
- **Research**: Ethical research on educational outcomes
- **Quality Assurance**: Better understanding of teaching effectiveness
- **Student Success**: Improved student outcomes through better teaching

## Future Development and Roadmap

### **Planned Features**
- **Additional File Types**: Support for .cc.vtt and .newChat.txt files
- **Advanced Analytics**: More sophisticated engagement metrics
- **Integration**: Better integration with learning management systems
- **Performance**: Optimizations for larger datasets

### **Community Contributions**
- **Open Source**: Community-driven development and improvements
- **Documentation**: User-contributed examples and tutorials
- **Testing**: Community testing with real-world data
- **Feedback**: User feedback driving feature development

---

*This analysis is based on comprehensive examination of the package codebase, documentation, test data, and development history. The package is designed with privacy-first principles and focuses on educational outcomes rather than surveillance.*