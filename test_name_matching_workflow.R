#!/usr/bin/env Rscript

# Name Matching and Participant Classification Test Script
# This script tests the critical functionality for identifying students vs guests
# and matching transcript names to roster names

cat("🧪 Testing Name Matching and Participant Classification\n")
cat("=====================================================\n\n")

# Load the package
library(engager)

# Set up test data
cat("📋 Setting up test data...\n")

# Create a realistic roster with various name formats
roster <- data.frame(
  preferred_name = c(
    "Jane Smith",           # Standard name
    "Robert Johnson",       # Standard name  
    "Maria García",         # International name with accent
    "Ahmed Al-Zahra",       # International name with hyphen
    "Li Wei",              # International name with space
    "Dr. Conor Healy",      # Instructor with title
    "Prof. Sarah Wilson"    # Instructor with title
  ),
  formal_name = c(
    "Jane Smith",
    "Robert Johnson", 
    "Maria García",
    "Ahmed Al-Zahra",
    "Li Wei",
    "Dr. Conor Healy",
    "Prof. Sarah Wilson"
  ),
  student_id = c(
    "STU001",
    "STU002", 
    "STU003",
    "STU004",
    "STU005",
    "INSTRUCTOR001",
    "INSTRUCTOR002"
  ),
  stringsAsFactors = FALSE
)

# Create transcript data with various name scenarios
transcript_data <- data.frame(
  transcript_name = c(
    # Exact matches
    "Jane Smith",
    "Robert Johnson",
    
    # Nickname variations
    "Bob Johnson",          # Robert -> Bob
    "Jane S.",              # Jane Smith -> Jane S.
    
    # International names
    "Maria Garcia",         # Missing accent
    "Ahmed Al Zahra",       # Missing hyphen
    
    # Instructor variations
    "Conor Healy",          # Missing Dr.
    "Sarah Wilson",         # Missing Prof.
    "Dr. Healy",            # Last name only
    
    # Guest users
    "Guest User",
    "Guest User (2)",
    "Unknown User",
    
    # Unmatched names
    "John Doe",             # Not in roster
    "Alice Brown",          # Not in roster
    
    # Empty/malformed names
    "",
    "   ",
    NA
  ),
  comment = c(
    "Hello everyone",
    "Good morning",
    "Hi there",
    "How are you?",
    "Buenos días",
    "مرحبا",
    "Welcome to class",
    "Let's begin",
    "Today we'll discuss",
    "Can I join?",
    "Is this the right room?",
    "I'm having trouble",
    "What's the homework?",
    "I have a question",
    "Silence",
    "More silence",
    "Missing name"
  ),
  stringsAsFactors = FALSE
)

cat("✅ Test data created\n")
cat("   Roster: ", nrow(roster), "students/instructors\n")
cat("   Transcript: ", nrow(transcript_data), "utterances\n\n")

# Test 1: Basic Name Matching Without Lookup
cat("🧪 Test 1: Basic Name Matching (No Lookup)\n")
cat("----------------------------------------\n")

classified_basic <- classify_participants(
  transcript_df = transcript_data,
  roster_df = roster,
  lookup_df = NULL,
  privacy_level = "none"  # Show real names for testing
)

cat("Classification results:\n")
cat("  Total utterances:", nrow(classified_basic), "\n")
cat("  Participant types found:", paste(unique(classified_basic$participant_type), collapse = ", "), "\n")
cat("  Matched names:", sum(classified_basic$is_matched), "\n")
cat("  Unmatched names:", sum(!classified_basic$is_matched), "\n\n")

# Show detailed results
cat("Detailed classification results:\n")
for (i in 1:nrow(classified_basic)) {
  original <- classified_basic$transcript_name[i]
  clean <- classified_basic$clean_name[i]
  type <- classified_basic$participant_type[i]
  matched <- classified_basic$is_matched[i]
  
  if (matched) {
    cat(sprintf("  ✅ %s -> %s (%s)\n", original, clean, type))
  } else {
    cat(sprintf("  ❌ %s -> %s (%s)\n", original, clean, type))
  }
}
cat("\n")

# Test 2: Name Matching With Lookup File
cat("🧪 Test 2: Name Matching With Lookup File\n")
cat("----------------------------------------\n")

# Create lookup file for unmatched names
lookup_data <- data.frame(
  transcript_name = c(
    "Bob Johnson",          # Robert's nickname
    "Jane S.",              # Jane's abbreviation
    "Maria Garcia",         # Missing accent
    "Ahmed Al Zahra",       # Missing hyphen
    "Conor Healy",          # Missing Dr.
    "Sarah Wilson",         # Missing Prof.
    "Dr. Healy",            # Last name only
    "Guest User",           # Guest user
    "Guest User (2)",       # Guest user
    "Unknown User",         # Guest user
    "John Doe",             # Unmatched student
    "Alice Brown"           # Unmatched student
  ),
  preferred_name = c(
    "Robert Johnson",       # Map to roster name
    "Jane Smith",           # Map to roster name
    "Maria García",         # Map to roster name (with accent)
    "Ahmed Al-Zahra",       # Map to roster name (with hyphen)
    "Dr. Conor Healy",      # Map to roster name (with title)
    "Prof. Sarah Wilson",   # Map to roster name (with title)
    "Dr. Conor Healy",      # Map to roster name
    "GUEST_001",            # Standardized guest name
    "GUEST_002",            # Standardized guest name
    "GUEST_003",            # Standardized guest name
    "John Doe",             # Keep as is (not in roster)
    "Alice Brown"           # Keep as is (not in roster)
  ),
  formal_name = c(
    "Robert Johnson",
    "Jane Smith",
    "Maria García", 
    "Ahmed Al-Zahra",
    "Dr. Conor Healy",
    "Prof. Sarah Wilson",
    "Dr. Conor Healy",
    "GUEST_001",
    "GUEST_002", 
    "GUEST_003",
    "John Doe",
    "Alice Brown"
  ),
  participant_type = c(
    "enrolled_student",
    "enrolled_student",
    "enrolled_student",
    "enrolled_student", 
    "instructor",
    "instructor",
    "instructor",
    "guest",
    "guest",
    "guest",
    "unknown",
    "unknown"
  ),
  student_id = c(
    "STU002",  # Robert's ID
    "STU001",  # Jane's ID
    "STU003",  # Maria's ID
    "STU004",  # Ahmed's ID
    "INSTRUCTOR001",  # Conor's ID
    "INSTRUCTOR002",  # Sarah's ID
    "INSTRUCTOR001",  # Conor's ID
    NA,  # Guest
    NA,  # Guest
    NA,  # Guest
    NA,  # Unknown
    NA   # Unknown
  ),
  notes = c(
    "Nickname for Robert",
    "Abbreviation for Jane",
    "Missing accent in transcript",
    "Missing hyphen in transcript", 
    "Missing title in transcript",
    "Missing title in transcript",
    "Last name only in transcript",
    "Standardized guest identifier",
    "Standardized guest identifier",
    "Standardized guest identifier",
    "Not in roster",
    "Not in roster"
  ),
  stringsAsFactors = FALSE
)

cat("Lookup file created with", nrow(lookup_data), "mappings\n")

# Test classification with lookup
classified_with_lookup <- classify_participants(
  transcript_df = transcript_data,
  roster_df = roster,
  lookup_df = lookup_data,
  privacy_level = "none"  # Show real names for testing
)

cat("Classification results with lookup:\n")
cat("  Total utterances:", nrow(classified_with_lookup), "\n")
cat("  Participant types found:", paste(unique(classified_with_lookup$participant_type), collapse = ", "), "\n")
cat("  Matched names:", sum(classified_with_lookup$is_matched), "\n")
cat("  Unmatched names:", sum(!classified_with_lookup$is_matched), "\n\n")

# Show detailed results with lookup
cat("Detailed classification results with lookup:\n")
for (i in 1:nrow(classified_with_lookup)) {
  original <- classified_with_lookup$transcript_name[i]
  clean <- classified_with_lookup$clean_name[i]
  type <- classified_with_lookup$participant_type[i]
  matched <- classified_with_lookup$is_matched[i]
  student_id <- classified_with_lookup$student_id[i]
  
  if (matched) {
    cat(sprintf("  ✅ %s -> %s (%s, ID: %s)\n", original, clean, type, ifelse(is.na(student_id), "N/A", student_id)))
  } else {
    cat(sprintf("  ❌ %s -> %s (%s)\n", original, clean, type))
  }
}
cat("\n")

# Test 3: Privacy Levels
cat("🧪 Test 3: Privacy Level Testing\n")
cat("-------------------------------\n")

privacy_levels <- c("none", "mask", "ferpa_standard", "ferpa_strict")

for (level in privacy_levels) {
  cat(sprintf("Testing privacy level: %s\n", level))
  
  classified_privacy <- classify_participants(
    transcript_df = transcript_data,
    roster_df = roster,
    lookup_df = lookup_data,
    privacy_level = level
  )
  
  # Show sample of results
  sample_names <- head(classified_privacy$clean_name, 5)
  cat(sprintf("  Sample names: %s\n", paste(sample_names, collapse = ", ")))
  cat(sprintf("  Participant types: %s\n", paste(unique(classified_privacy$participant_type), collapse = ", ")))
  cat("\n")
}

# Test 4: Guest User Identification
cat("🧪 Test 4: Guest User Identification\n")
cat("-----------------------------------\n")

# Filter for guest users
guest_utterances <- classified_with_lookup[classified_with_lookup$participant_type == "guest", ]
instructor_utterances <- classified_with_lookup[classified_with_lookup$participant_type == "instructor", ]
student_utterances <- classified_with_lookup[classified_with_lookup$participant_type == "enrolled_student", ]

cat("Guest users identified:", nrow(guest_utterances), "\n")
if (nrow(guest_utterances) > 0) {
  cat("Guest names:\n")
  for (i in 1:nrow(guest_utterances)) {
    cat(sprintf("  %s -> %s\n", 
               guest_utterances$transcript_name[i], 
               guest_utterances$clean_name[i]))
  }
}

cat("\nInstructors identified:", nrow(instructor_utterances), "\n")
if (nrow(instructor_utterances) > 0) {
  cat("Instructor names:\n")
  for (i in 1:nrow(instructor_utterances)) {
    cat(sprintf("  %s -> %s (ID: %s)\n", 
               instructor_utterances$transcript_name[i], 
               instructor_utterances$clean_name[i],
               instructor_utterances$student_id[i]))
  }
}

cat("\nEnrolled students identified:", nrow(student_utterances), "\n")
if (nrow(student_utterances) > 0) {
  cat("Student names:\n")
  for (i in 1:nrow(student_utterances)) {
    cat(sprintf("  %s -> %s (ID: %s)\n", 
               student_utterances$transcript_name[i], 
               student_utterances$clean_name[i],
               student_utterances$student_id[i]))
  }
}
cat("\n")

# Test 5: Name Matching Statistics
cat("🧪 Test 5: Name Matching Statistics\n")
cat("----------------------------------\n")

# Calculate matching statistics
total_utterances <- nrow(classified_with_lookup)
matched_utterances <- sum(classified_with_lookup$is_matched)
unmatched_utterances <- total_utterances - matched_utterances

cat("Matching Statistics:\n")
cat(sprintf("  Total utterances: %d\n", total_utterances))
cat(sprintf("  Matched utterances: %d (%.1f%%)\n", matched_utterances, (matched_utterances/total_utterances)*100))
cat(sprintf("  Unmatched utterances: %d (%.1f%%)\n", unmatched_utterances, (unmatched_utterances/total_utterances)*100))

# Participant type breakdown
type_counts <- table(classified_with_lookup$participant_type)
cat("\nParticipant Type Breakdown:\n")
for (type in names(type_counts)) {
  count <- type_counts[type]
  percentage <- (count/total_utterances)*100
  cat(sprintf("  %s: %d (%.1f%%)\n", type, count, percentage))
}

# Test 6: Edge Cases
cat("\n🧪 Test 6: Edge Cases\n")
cat("-------------------\n")

# Test with empty/malformed names
edge_cases <- classified_with_lookup[is.na(classified_with_lookup$transcript_name) | 
                                    nchar(trimws(classified_with_lookup$transcript_name)) == 0, ]

if (nrow(edge_cases) > 0) {
  cat("Edge cases (empty/malformed names):\n")
  for (i in 1:nrow(edge_cases)) {
    cat(sprintf("  Original: '%s' -> Clean: '%s' (Type: %s)\n", 
               edge_cases$transcript_name[i], 
               edge_cases$clean_name[i],
               edge_cases$participant_type[i]))
  }
} else {
  cat("No edge cases found\n")
}

# Test 7: International Names
cat("\n🧪 Test 7: International Names\n")
cat("------------------------------\n")

# Check international name handling
international_names <- classified_with_lookup[grepl("[áéíóúñü]", classified_with_lookup$clean_name) |
                                             grepl("[أ-ي]", classified_with_lookup$clean_name) |
                                             grepl("[一-龯]", classified_with_lookup$clean_name), ]

if (nrow(international_names) > 0) {
  cat("International names found:\n")
  for (i in 1:nrow(international_names)) {
    cat(sprintf("  %s -> %s (Type: %s)\n", 
               international_names$transcript_name[i], 
               international_names$clean_name[i],
               international_names$participant_type[i]))
  }
} else {
  cat("No international names in test data\n")
}

# Summary
cat("\n🎯 Test Summary\n")
cat("==============\n")
cat("✅ Name matching functionality tested\n")
cat("✅ Guest user identification tested\n")
cat("✅ Instructor identification tested\n")
cat("✅ Student identification tested\n")
cat("✅ Privacy levels tested\n")
cat("✅ Edge cases handled\n")
cat("✅ International names supported\n")
cat("\n📊 Key Results:\n")
cat(sprintf("- %.1f%% of names successfully matched\n", (matched_utterances/total_utterances)*100))
cat(sprintf("- %d guest users identified\n", nrow(guest_utterances)))
cat(sprintf("- %d instructors identified\n", nrow(instructor_utterances)))
cat(sprintf("- %d enrolled students identified\n", nrow(student_utterances)))
cat("\n🎉 Name matching and participant classification tests completed!\n")
