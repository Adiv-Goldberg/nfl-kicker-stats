# 1. Load the tools we need
# tidyverse handles the data, nflreadr pulls the scores.
library(nflreadr)
library(tidyverse)

# 2. Ask the user for the year
# This stops the code so you can choose which season to look at.
selected_year <- as.numeric(readline(prompt = "Enter the NFL season year (e.g., 2024): "))

# 3. Get the game data (Schedules and Scores)
# 'load_schedules' is faster for this than the play-by-play data.
games_data <- load_schedules(selected_year)

# 4. Clean up the table to show Winner and Loser scores
# We are identifying who had more points and labeling them clearly.
scores_table <- games_data %>%
    # Only look at games that have actually been finished
    filter(!is.na(result)) %>%
    mutate(
        win_team = ifelse(home_score > away_score, home_team, away_team),
        lose_team = ifelse(home_score > away_score, away_team, home_team),
        win_score = ifelse(home_score > away_score, home_score, away_score),
        lose_score = ifelse(home_score > away_score, away_score, home_score)
    ) %>%
    # Select and rename the columns for your final CSV
    select(
        week,
        game_date = gameday,
        win_team,
        win_score,
        lose_team,
        lose_score
    )

# 5. Save the file to your LOCAL Downloads folder
# This uses the same 'Master Key' as before to find your local Downloads.
user_profile <- Sys.getenv("USERPROFILE")
file_name <- paste0("nfl_scores_", selected_year, ".csv")
file_destination <- file.path(user_profile, "Downloads", file_name)

write_csv(scores_table, file_destination)

# 6. Success message
print(paste("Success! The game scores for", selected_year, "are saved at:", file_destination))
