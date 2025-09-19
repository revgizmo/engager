#!/usr/bin/env Rscript

# Generate synthetic VTT transcripts with diverse name cases for testing.

generate_vtt <- function(df, path) {
  lines <- c("WEBVTT", "")
  segments <- character(nrow(df) * 3)
  
  for (i in 1:nrow(df)) {
    idx <- (i - 1) * 3 + 1
    segments[idx] <- as.character(i)
    segments[idx + 1] <- paste0(df$start[i], " --> ", df$end[i])
    segments[idx + 2] <- paste0(df$speaker[i], ": ", df$text[i])
  }
  
  readr::write_lines(c(lines, segments), path)
}

output_dir <- file.path("inst", "extdata", "test_transcripts")
fs::dir_create(output_dir)

roster <- tibble::tribble(
  ~formal_name, ~preferred_name, ~transcript_names, ~attends_sessions,
  "Thomas Miller", "Tom", "Tom Miller", "1,2,3",
  "Samantha Smith", "Sam",
  "Samantha Smith; Sam Smith (she/her); Sam Smith", "1,2,3",
  "Robert Jones", "Rob", "Robert Jones; Rob Jones", "1,2",
  "Ling Wei", "Ling", "Wei Ling", "1",
  "José Álvarez", "Jose", "Jose Alvarez", "1,2,3",
  "Anthony García-Lopez", "Tony", "A.J. Lopez", "1,2,3",
  "Priya Patel", "Priya", "", ""
)

readr::write_csv(roster,
                 file.path(output_dir, "ideal_course_roster.csv"))

session1 <- tibble::tribble(
  ~start, ~end, ~speaker, ~text,
  "00:00:00.000", "00:00:02.000", "Professor Ed",
  "Welcome to our engager workshop.",
  "00:00:02.000", "00:00:04.000", "Professor Ed",
  "This package helps analyze Zoom class participation.",
  "00:00:04.500", "00:00:05.500", "Tom Miller",
  "Hello, I'm Tom.",
  "00:00:05.600", "00:00:06.600", "Tom Miller",
  "Looking forward to using it.",
  "00:00:07.000", "00:00:08.000", "Samantha Smith",
  "Hi everyone.",
  "00:00:28.000", "00:00:29.000", "Samantha Smith",
  "Sorry, was on mute earlier.",
  "00:00:29.500", "00:00:30.500", "Robert Jones",
  "Sounds useful for class discussions.",
  "00:00:31.000", "00:00:32.000", "Wei Ling",
  "Can it handle names in different orders?",
  "00:00:32.500", "00:00:33.500", "Jose Alvarez",
  "What about accents in names like Jose Alvarez?",
  "00:00:34.000", "00:00:35.000", "A.J. Lopez",
  "I'm curious about privacy features.",
  "00:00:35.500", "00:00:36.500", "Dr. Brown",
  "I'll be observing as a guest today.",
  "00:00:37.000", "00:00:38.000", "Professor Ed",
  "Great questions.",
  "00:00:38.500", "00:00:39.500", "Professor Ed",
  "Let's start with installation."
)

session2 <- tibble::tribble(
  ~start, ~end, ~speaker, ~text,
  "00:00:00.000", "00:00:01.500", "Professor Ed",
  "Welcome back to session two.",
  "00:00:02.000", "00:00:03.500", "Professor Ed",
  "Today we'll explore roster customization.",
  "00:00:04.000", "00:00:05.000", "Tom Miller",
  "I added our roster from CSV.",
  "00:00:05.200", "00:00:06.200", "Tom Miller",
  "It was straightforward.",
  "00:00:06.700", "00:00:07.700", "Samantha Smith",
  "I'm still figuring out preferred names.",
  "00:00:20.000", "00:00:21.000", "Sam Smith (she/her)",
  "I updated my display name, hope that's okay.",
  "00:00:21.500", "00:00:22.500", "Rob Jones",
  "I appreciate the name matching features.",
  "00:00:23.000", "00:00:24.000", "Jose Alvarez",
  "Do we log attendance automatically?",
  "00:00:24.500", "00:00:25.500", "A.J. Lopez",
  "Yes, and privacy filters too.",
  "00:00:26.000", "00:00:27.000", "Guest Librarian Grace",
  "I can help with citation tracking.",
  "00:00:27.500", "00:00:28.500", "Guest Mentor Hank",
  "And I'll assist with analytics.",
  "00:00:29.000", "00:00:30.000", "Professor Ed",
  "Thanks, guests."
)

session3 <- tibble::tribble(
  ~start, ~end, ~speaker, ~text,
  "00:00:00.000", "00:00:01.500", "Professor Ed",
  "Final session: applying metrics.",
  "00:00:02.000", "00:00:03.000", "Tom Miller",
  "The visualizations look helpful.",
  "00:00:03.200", "00:00:04.200", "Tom Miller",
  "Especially the equity chart.",
  "00:00:25.000", "00:00:26.000", "Sam Smith",
  "The summaries exported nicely.",
  "00:00:27.500", "00:00:28.500", "Jose Alvarez",
  "Dead air periods were captured too.",
  "00:00:29.000", "00:00:30.000", "A.J. Lopez",
  "And our guest features worked.",
  "00:00:30.500", "00:00:31.500", "Guest Mentor Hank",
  "Glad to hear that.",
  "00:00:32.000", "00:00:33.000", "Professor Ed",
  "Great work, everyone.",
  "00:00:40.000", "00:00:41.000", "Tom Miller",
  "Looking forward to testing more."
)

generate_vtt(session1,
             file.path(output_dir, "ideal_course_session1.vtt"))
generate_vtt(session2,
             file.path(output_dir, "ideal_course_session2.vtt"))
generate_vtt(session3,
             file.path(output_dir, "ideal_course_session3.vtt"))

