# 1. Load the tools we need
# nflreadr gets the stats, tidyverse organizes them.
library(nflreadr)
library(tidyverse)

# 2. Ask the user for the year
# This stops the code so you can type the season (like 2024) in the console below.
selected_year <- as.numeric(readline(prompt = "Enter the NFL season year (e.g., 2024): "))

# 3. Get the play-by-play data for the chosen year
pbp_data <- load_pbp(selected_year)

# 4. Create the "No Buckets" Player Table
# We are merging Field Goals and Extra Points into the same columns.
kicker_table <- pbp_data %>%
    # Filter for both types of kicks
    filter(play_type %in% c("field_goal", "extra_point")) %>%
    # Treat Extra Points as 33-yard kicks, otherwise use the actual distance
    mutate(dist = ifelse(play_type == "extra_point", 33, kick_distance)) %>%
    # Group by Name and the new Distance column to combine stats
    group_by(kicker_player_name, dist) %>%
    summarize(
        attempts = n(),
        made = sum(field_goal_result == "made" | extra_point_result == "good", na.rm = TRUE),
        percent = round(made / attempts * 100, 1),
        .groups = "drop"
    ) %>%
    # Remove rows where the distance is missing and rename columns for the final format
    filter(!is.na(dist)) %>%
    select(name = kicker_player_name, distance = dist, attempts, made, percent) %>%
    arrange(name, distance)

# 5. Save the file to your LOCAL Downloads folder
# This bypasses OneDrive to save directly to your computer.
user_profile <- Sys.getenv("USERPROFILE")
file_name <- paste0("kicker_stats_", selected_year, ".csv")
file_destination <- file.path(user_profile, "Downloads", file_name)

write_csv(kicker_table, file_destination)

# 6. Success message
print(paste("Success! Your exact format file is saved at:", file_destination))
