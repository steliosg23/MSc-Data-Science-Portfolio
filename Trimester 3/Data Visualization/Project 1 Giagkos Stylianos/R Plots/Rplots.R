# PISA 2018 Education Analysis for the Greek Ministry of Education
# An Apple-Inspired Data Visualization Dashboard
#
# This script is designed to analyze PISA 2018 data, focusing on Greece's performance
# in comparison to other OECD countries. It generates a series of visualizations
# with an aesthetic inspired by Apple's design principles, aiming for clarity and impact.
#
# Author: A Data Visualization Enthusiast (with a soft spot for clean design)

# --- Setup: Load Libraries and Define Visual Styles ---
setwd("C:/Users/steli/Stelios/DS AUEB/Trimester 3/Data Visualization/Project 1 Giagkos Stylianos/R Plots") # Commented out for broader compatibility
# Ensure all necessary R packages are loaded.
library(ggplot2)    # The go-to for elegant data visualizations
library(dplyr)      # For powerful data manipulation (think SQL for R)
library(tidyr)      # Great for reshaping data (pivoting, unpivoting)
library(readr)      # For fast and friendly reading of CSV files
library(ggrepel)    # Essential for preventing overlapping text labels on plots
library(RColorBrewer) # Provides a nice array of color palettes
library(tidytext)   # Handy for reordering factors within facets
library(stringr)    # For flexible string operations, like pattern detection
library(forcats)
library(patchwork)


# Define a custom ggplot2 theme that mimics Apple's clean aesthetic.
# This ensures all our plots have a consistent, polished look.
# --- Refined Apple Design Theme for Consistency Across All Plots ---
apple_design_theme <- function() {
  theme_minimal(base_family = "Helvetica") +
    theme(
      text = element_text(color = "#1d1d1f"),
      plot.title = element_text(size = 18, face = "bold", hjust = 0.5, margin = margin(b = 20)),
      plot.subtitle = element_text(size = 14, hjust = 0.5, color = "#86868b", margin = margin(b = 20)),
      axis.title = element_text(size = 22, face = "bold"),
      axis.text = element_text(size = 20),
      legend.title = element_text(size = 16, face = "bold"),
      legend.text = element_text(size = 14),
      panel.grid.major = element_line(color = "#f5f5f7"),
      panel.grid.minor = element_blank(),
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),
      strip.text = element_text(size = 12, face = "bold"),
      legend.position = "bottom"
    )
}



# A curated Apple-inspired color palette for our plots.
# These colors are chosen for their vibrancy and visual appeal.
apple_brand_colors <- c("#007AFF", "#FF3B30", "#34C759", "#FF9500", "#AF52DE", "#FF2D92", "#5AC8FA", "#FFCC00","#6EB5F3")

# --- Data Acquisition and Initial Transformation ---

cat("Initiating data loading and preparation...\n")

# Load the core PISA 2018 dataset.
# Make sure 'pisa2018.Rdata' is in your working directory or provide the full path.
# This file is expected to contain a data frame named 'newdata'.
load("pisa2018.Rdata")
pisa_raw_data <- newdata # Renaming for clarity: 'newdata' becomes 'pisa_raw_data'

# Load supplementary education expenditure data from a CSV file.
expenditure_raw_data <- read_csv("Education_Expenditure_GDP.csv")

# Clean and enrich the PISA dataset.
# This involves deriving gender, calculating an overall average score,
# and categorizing parental education levels for later analysis.
pisa_processed_data <- pisa_raw_data %>%
  mutate(
    # Standardize gender information for consistency
    Gender = case_when(
      ST004D01T == "Male" ~ "Male",
      ST004D01T == "Female" ~ "Female",
      TRUE ~ "Other" # Catch-all 
    ),
    # Calculate an average PISA score from available subject scores.
    # This handles cases where not all subject scores are present.
    Overall_PISA_Score = rowMeans(select(., MATH, READ, SCIE,GLCM), na.rm = TRUE),
    # Categorize parental education levels using vectorized operations (optimized from sapply)
    Mother_Education_Category = case_when(
      grepl("ISCED level (3A|3B|4|5|6|7|8)", ST005Q01TA) ~ "Tertiary",
      grepl("ISCED level (0|1|2)", ST005Q01TA) ~ "Primary or Below",
      TRUE ~ NA_character_
    ),
    Father_Education_Category = case_when(
      grepl("ISCED level (3A|3B|4|5|6|7|8)", ST007Q01TA) ~ "Tertiary",
      grepl("ISCED level (0|1|2)", ST007Q01TA) ~ "Primary or Below",
      TRUE ~ NA_character_
    ),
    # Determine the highest education level achieved by either parent.
    Highest_Parental_Education = ifelse(Mother_Education_Category == "Tertiary" | Father_Education_Category == "Tertiary", "Tertiary", "Primary or Below")
  )

# Aggregate PISA data to the country level.
# This summarizes key performance metrics and student counts for each country.
country_performance_summary <- pisa_processed_data %>%
  group_by(CNT) %>%
  summarise(
    Avg_Math_Score = mean(MATH, na.rm = TRUE),
    Avg_Read_Score = mean(READ, na.rm = TRUE),
    Avg_Scie_Score = mean(SCIE, na.rm = TRUE),
    Avg_GLCM_Score = mean(GLCM, na.rm = TRUE),
    Overall_PISA_Avg = mean(Overall_PISA_Score, na.rm = TRUE),
    Total_Student_Count = n(),
    Tertiary_Parent_Count = sum(Highest_Parental_Education == "Tertiary", na.rm = TRUE),
    Primary_Below_Parent_Count = sum(Highest_Parental_Education == "Primary or Below", na.rm = TRUE),
    .groups = 'drop' # Important to drop grouping after summarization
  ) %>%
  # Sort countries by their overall PISA average for easy ranking.
  arrange(desc(Overall_PISA_Avg))

# Prepare the education expenditure data.
# We'll calculate average expenditure over a specific period (2008-2018)
# and ensure we have enough years of data for a reliable average.
expenditure_processed_data <- expenditure_raw_data %>%
  pivot_longer(cols = -Country, names_to = "Year", values_to = "Expenditure_GDP_Percent") %>%
  filter(Year %in% as.character(2008:2018)) %>% # Focus on the relevant decade
  group_by(Country) %>%
  summarise(
    Avg_Expenditure_GDP = mean(Expenditure_GDP_Percent, na.rm = TRUE),
    Years_with_Data = sum(!is.na(Expenditure_GDP_Percent)),
    Expenditure_2018 = Expenditure_GDP_Percent[Year == "2018"], # Capture 2018 specific value
    .groups = 'drop'
  ) %>%
  filter(Years_with_Data >= 5) %>% # Only include countries with sufficient data points
  rename(CNT = Country) %>% # Align column name for merging
  select(CNT, Avg_Expenditure_GDP, Years_with_Data, Expenditure_2018)

# Merge the PISA performance data with the education expenditure data.
# This combined dataset will be the foundation for most of our visualizations.
combined_education_data <- country_performance_summary %>%
  left_join(expenditure_processed_data, by = "CNT") %>%
  mutate(
    # Flag countries that have expenditure data for filtering later
    Has_Expenditure_Info = !is.na(Avg_Expenditure_GDP),
    # Create a special flag for Greece to highlight it in plots
    Is_Greece = ifelse(CNT == "Greece", "Greece", "Other Countries")
  )

cat("Data preparation complete. Now, let's create some compelling visualizations!\n")

# --- Visualization Section: Crafting Insights with Plots ---

# Plot 1: Global Education Excellence: Top 20 Performing Countries
# This bar chart highlights the top 20 countries by average PISA score,
# with a special emphasis on Greece's position if it falls within or near this group.

# Step 1: Compute global statistics from full dataset
global_average_score <- mean(combined_education_data$Overall_PISA_Avg, na.rm = TRUE)
median_overall_score <- median(combined_education_data$Overall_PISA_Avg, na.rm = TRUE)

# Step 2: Add synthetic Global Average row
global_average_row <- tibble(
  CNT = "Global Average",
  Overall_PISA_Avg = global_average_score,
  Country_Type = "Global Average"
)

# Step 3: Prepare the countries to be plotted (top 20 + Greece + Global Average)
countries_for_top_performance_plot <- combined_education_data %>%
  arrange(desc(Overall_PISA_Avg)) %>%
  slice(1:20) %>%
  bind_rows(filter(combined_education_data, CNT == "Greece")) %>%
  distinct(CNT, .keep_all = TRUE) %>%
  mutate(Country_Type = ifelse(CNT == "Greece", "Greece", "Others")) %>%
  bind_rows(global_average_row)

# Step 4: Create the plot
plot_global_performance <- countries_for_top_performance_plot %>%
  ggplot(aes(x = reorder(CNT, Overall_PISA_Avg), y = Overall_PISA_Avg, fill = Country_Type)) +
  geom_col(width = 0.7, alpha = 0.9) +
  scale_fill_manual(values = c(
    "Greece" = apple_brand_colors[1],         
    "Others" = apple_brand_colors[9],         
    "Global Average" = "#999999"              
  )) +
  coord_flip() +
  labs(
    title = "Global Education Excellence: Top Performing Countries",
    subtitle = paste("Average PISA 2018 Scores (Mathematics, Reading, Science,GLCM)"),
    x = "Country",
    y = "Average PISA Score",
    fill = "Country Category",
    caption = "Source: OECD PISA 2018"
  ) +
  apple_design_theme() +
  theme(legend.position = "right") +
  geom_text(aes(label = round(Overall_PISA_Avg, 0)), hjust = -0.1, size = 5, color = "#1d1d1f") +
  geom_hline(yintercept = median_overall_score, linetype = "dashed", color = "#86868b", size = 0.7) +
  annotate("text", x = 1, y = median_overall_score + 35,
           label = paste("Median:", round(median_overall_score)),
           color = "#86868b", size = 6)

# Step 5: Save the plot


# Plot 2: PISA Score Distribution by Gender: Greece vs. Top Performers
# This plot uses density curves to illustrate the spread of PISA scores for
# male and female students in Greece compared to a selection of top-performing nations.
selected_countries_for_density_plot <- pisa_processed_data %>%
  filter(CNT %in% c("Greece", "Singapore", "Finland", "Japan", "Korea", "Estonia") &
           Gender %in% c("Male", "Female")) %>%
  mutate(
    Country_Group = case_when(
      CNT == "Greece" ~ "Greece",
      TRUE ~ "Top Performers" # Group all other selected countries as "Top Performers"
    )
  )

plot_gender_distribution <- selected_countries_for_density_plot %>%
  ggplot(aes(x = Overall_PISA_Score, fill = Gender, color = Gender)) +
  geom_density(alpha = 0.6, linewidth = 0.8) + # Use density plots for distribution
  facet_wrap(~Country_Group, scales = "free_y", ncol = 1) + # Separate panels for Greece and Top Performers
  scale_fill_manual(values = c("Male" = apple_brand_colors[1], "Female" = apple_brand_colors[2])) +
  scale_color_manual(values = c("Male" = apple_brand_colors[1], "Female" = apple_brand_colors[2])) +
  labs(
    title = "PISA Score Distribution by Gender: Greece vs. Top Performers",
    subtitle = "Density plots showing the spread of average PISA scores for male and female students",
    x = "Average PISA Score",
    y = "Density",
    fill = "Gender",
    color = "Gender",
    caption = "Source: OECD PISA 2018"
  ) +
  apple_design_theme() +
  theme(legend.position = "bottom") +
  # Add mean lines for each group for easy comparison
  geom_vline(data = selected_countries_for_density_plot %>%
               group_by(Country_Group, Gender) %>%
               summarise(mean_score = mean(Overall_PISA_Score, na.rm = TRUE), .groups = 'drop'),
             aes(xintercept = mean_score, color = Gender),
             linetype = "dashed", size = 0.8)


# Plot 3: Subject Excellence Across Top Performing Nations
# This visualization compares performance across Mathematics, Reading, and Science
# for the top 15 overall performing countries, offering a detailed subject-wise breakdown.
# Prepare subject-specific performance data for plotting
# Clean and structure
# --- Step 1: Prepare subject-specific data ---
# --- Step 1: Prepare subject-specific data ---
top_countries <- combined_education_data %>%
  top_n(15, Overall_PISA_Avg) %>%
  pull(CNT)

subject_circular_data <- pisa_processed_data %>%
  select(CNT, MATH, READ, SCIE) %>%
  pivot_longer(cols = c(MATH, READ, SCIE),
               names_to = "Subject", values_to = "Score") %>%
  mutate(
    Subject = recode(Subject,
                     MATH = "Mathematics",
                     READ = "Reading",
                     SCIE = "Science"),
    Is_Greece = ifelse(CNT == "Greece", "Greece", "Other Countries")
  ) %>%
  group_by(CNT, Subject, Is_Greece) %>%
  summarise(Score = mean(Score, na.rm = TRUE), .groups = "drop") %>%
  filter(CNT %in% top_countries | CNT == "Greece") %>%
  mutate(CNT = as.character(CNT)) %>%  # convert to string explicitly
  mutate(CNT = ifelse(CNT == "B-S-J-Z (China)", "B-S-J-Z\nChina", CNT)) %>%
  group_by(Subject) %>%
  arrange(Score) %>%
  mutate(
    CNT = factor(CNT, levels = unique(CNT)),
    Angle = 360 * (as.numeric(CNT) - 0.5) / n(),
    Hjust = ifelse(Angle > 180, 1, 0),
    Angle = ifelse(Angle > 180, Angle - 180, Angle),
    Score_Adjusted = Score + 20
  ) %>%
  ungroup()


# --- Step 2: Function to create one circular barplot ---
make_circular_plot <- function(subject_name) {
  data <- subject_circular_data %>% filter(Subject == subject_name)
  
  ggplot(data, aes(x = CNT, y = Score, fill = Is_Greece)) +
    geom_col(width = 1, color = "white", alpha = 0.9) +
    geom_text(aes(label = round(Score), y = Score - 100),
              color = "white", size = 4,face="bold") +

    coord_polar(start = -pi / 2) +
    scale_fill_manual(values = c("Greece" = apple_brand_colors[1],
                                 "Other Countries" = apple_brand_colors[9])) +
    labs(title = subject_name) +
    apple_design_theme() +
    theme(
      plot.title = element_text(size = 16, face = "bold", hjust = 0.5)
    )
}

# --- Step 3: Create the 3 circular barplots ---
plot_math <- make_circular_plot("Mathematics")
plot_read <- make_circular_plot("Reading")
plot_scie <- make_circular_plot("Science")

# --- Step 4: Combine into one plot and save ---
plot_subject_excellence <- plot_math + plot_read + plot_scie + plot_layout(ncol = 3)

# Plot 4: Greece in Global Context: PISA 2018 Performance Ranking
# This plot visualizes the global ranking of countries based on their average PISA scores,
# categorizing countries into performance tiers (Excellent, Good, Average, Below Average) 
# and highlighting Greece along with top-performing countries.

plot_global_ranking <- combined_education_data %>%
  mutate(
    # Define performance tiers based on average PISA scores
    Performance_Tier = case_when(
      Overall_PISA_Avg >= 520 ~ "Excellent (≥520)",
      Overall_PISA_Avg >= 480 ~ "Good (480-519)",
      Overall_PISA_Avg >= 440 ~ "Average (440-479)",
      Overall_PISA_Avg < 440 ~ "Below Average (<440)",
      is.na(Overall_PISA_Avg) ~ "No Data"
    ),
    # Custom highlight for Greece and other key top performers
    Country_Highlight_Group = ifelse(CNT == "Greece", "Greece",
                                     ifelse(CNT %in% c("Finland", "Singapore", "Japan", "Korea", "Estonia"),
                                            "Top Performers", "Others")),
    # Order the performance tiers for consistent plotting
    Performance_Tier = factor(Performance_Tier, levels = c("Excellent (≥520)", "Good (480-519)", "Average (440-479)", "Below Average (<440)", "No Data"))
  ) %>%
  ggplot(aes(x = Overall_PISA_Avg, y = reorder(CNT, Overall_PISA_Avg))) +
  geom_point(aes(color = Performance_Tier, size = Total_Student_Count), alpha = 0.7) + # Color by Performance_Tier
  scale_color_manual(values = c(
    "Excellent (≥520)" = apple_brand_colors[3],  # Dark Green for Excellent
    "Good (480-519)" = apple_brand_colors[1],    # Lime Green for Good
    "Average (440-479)" = apple_brand_colors[8], # Gold for Average
    "Below Average (<440)" = apple_brand_colors[2], # Tomato for Below Average
    "No Data" = "#808080"            # Grey for No Data
  )) +
  scale_size_continuous(range = c(1, 6), name = "Sample Size") +
  # Add vertical lines to delineate performance tiers
  geom_vline(xintercept = c(440, 480, 520), linetype = "dashed", alpha = 0.5, color = "#86868b") +
  labs(
    title = "Greece in Global Context: PISA 2018 Performance Ranking",
    subtitle = "Average scores across Mathematics, Reading, and Science, highlighting performance tiers",
    x = "Average PISA Score",
    y = "Country",
    color = "Performance Tier", # Changed to Performance Tier for clarity
    caption = "Source: OECD PISA 2018"
  ) +
  apple_design_theme() +
  theme(axis.text.y = element_text(size = 14),  # Increased Y-axis label size
        plot.margin = margin(5, 5, 5, 5, "cm")) + # Added extra margin to accommodate wider plot
  # Annotate the performance tiers on the plot more robustly and centrally
  annotate("text", x = 420, y = Inf, label = "Below Average", size = 8, color = "#86868b", hjust = 0.5, vjust = 1.5) + 
  annotate("text", x = 460, y = Inf, label = "Average", size = 8, color = "#86868b", hjust = 0.5, vjust = 1.5) + 
  annotate("text", x = 500, y = Inf, label = "Good", size = 8, color = "#86868b", hjust = 0.5, vjust = 1.5) + 
  annotate("text", x = 540, y = Inf, label = "Excellent", size = 8, color = "#86868b", hjust = 0.5, vjust = 1.5) +
  # Adjust the placement of the Below Average label to fit within plot's view
  annotate("text", x = 430, y = 1, label = "Below Average ", size = 8, color = "#86868b", hjust = 0.5, vjust = -150)
  # Add x-axis limits for each performance tier
  scale_x_continuous(limits = c(430, 550), breaks = c(440, 480, 520))


# Plot 5: Gender Performance Gaps Across Countries
# This violin plot visualizes the distribution of gender performance gaps across different subjects
# for various countries, highlighting Greece's specific gaps.
plot_gender_gap_analysis <- pisa_processed_data %>%
  filter(Gender %in% c("Male", "Female")) %>%
  group_by(CNT, Gender) %>%
  summarise(
    Avg_Math_Score = mean(MATH, na.rm = TRUE),
    Avg_Read_Score = mean(READ, na.rm = TRUE),
    Avg_Scie_Score = mean(SCIE, na.rm = TRUE),
    Student_Count = n(),
    .groups = 'drop'
  ) %>%
  pivot_wider(names_from = Gender, values_from = c(Avg_Math_Score, Avg_Read_Score, Avg_Scie_Score, Student_Count)) %>%
  mutate(
    # Calculate gender gaps (Male score - Female score)
    Math_Gender_Gap = Avg_Math_Score_Male - Avg_Math_Score_Female,
    Read_Gender_Gap = Avg_Read_Score_Male - Avg_Read_Score_Female,
    Scie_Gender_Gap = Avg_Scie_Score_Male - Avg_Scie_Score_Female,
    Total_Students_Combined = Student_Count_Male + Student_Count_Female
  ) %>%
  filter(Total_Students_Combined >= 100) %>% # Filter for countries with sufficient sample size
  mutate(Is_Greece = ifelse(CNT == "Greece", "Greece", "Other")) %>%
  select(CNT, Math_Gender_Gap, Read_Gender_Gap, Scie_Gender_Gap, Is_Greece) %>%
  pivot_longer(cols = c(Math_Gender_Gap, Read_Gender_Gap, Scie_Gender_Gap), names_to = "Subject", values_to = "Gender_Gap_Value") %>%
  mutate(Subject = recode(Subject, "Math_Gender_Gap" = "Mathematics", "Read_Gender_Gap" = "Reading", "Scie_Gender_Gap" = "Science")) %>%
  ggplot(aes(x = Gender_Gap_Value, y = Subject, fill = Subject)) +
  geom_violin(alpha = 0.6, scale = "width") + # Violin plot for distribution shape
  geom_boxplot(width = 0.1, alpha = 0.8, outlier.shape = NA) + # Boxplot inside violin for quartiles
  # Highlight Greece's data point specifically
  geom_point(data = . %>% filter(CNT == "Greece"),
             aes(color = "Greece Highlight"), size = 4, alpha = 0.9, shape = 21, stroke = 1.5,
             fill = apple_brand_colors[2]) + # Keep fill for the red color
  scale_fill_manual(values = apple_brand_colors[c(1, 3, 4)]) + # Use distinct colors for subjects
  scale_color_manual(name = "Country Highlight", values = c("Greece Highlight" = "black")) +
  geom_vline(xintercept = 0, linetype = "dashed", alpha = 0.7) + # Zero line for easy gap interpretation
  labs(
    title = "Gender Performance Gaps Across Countries",
    subtitle = "Positive values indicate male advantage, negative values indicate female advantage",
    x = "Gender Gap (Male - Female Score Difference)",
    y = "Subject Area",
    caption = "Source: OECD PISA 2018"
  ) +
  apple_design_theme() +
  guides(fill = "none") + # Hide fill legend as subject is on y-axis
  # Annotate the advantage sides of the zero line
  annotate("text", x = -30, y = 3.3, label = "Female\nAdvantage", size = 5, color = "#86868b", hjust = 0.5) +
  annotate("text", x = 20, y = 3.3, label = "Male\nAdvantage", size = 5, color = "#86868b", hjust = 0.5)


# Plot 6: Gross Learning Capital Measure vs Academic Performance
# This scatter plot investigates the relationship between a country's Gross Learning Capital Measure (GLCM)
# and its average PISA score, including a linear regression line and highlighting Greece.
glcm_analysis_data <- combined_education_data # Renaming for clarity

# Calculate the correlation coefficient between GLCM and PISA score.
correlation_glcm_pisa <- glcm_analysis_data %>%
  summarise(
    correlation = cor(Avg_GLCM_Score, Overall_PISA_Avg, use = "complete.obs")
  ) %>%
  pull(correlation)

plot_glcm_performance <- glcm_analysis_data %>%
  ggplot(aes(x = Avg_GLCM_Score, y = Overall_PISA_Avg)) +
  geom_point(aes(color = Is_Greece, size = Total_Student_Count), alpha = 0.7) +
  geom_smooth(method = "lm", color = apple_brand_colors[4], fill = apple_brand_colors[4], alpha = 0.2) + # Linear regression line
  scale_color_manual(values = c("Greece" = apple_brand_colors[2], "Other Countries" = apple_brand_colors[1])) +
  scale_size_continuous(range = c(2, 8), name = "Student Count") +
  labs(
    title = "Gross Learning Capital Measure vs Academic Performance",
    subtitle = paste0("Relationship between GLCM and overall PISA performance (Correlation: ", round(correlation_glcm_pisa, 2), ")"),
    x = "GLCM (Gross Learning Capital Measure)",
    y = "Average PISA Score",
    color = "Country Focus",
    caption = "Source: OECD PISA 2018"
  ) +
  apple_design_theme() +
  # Add labels for Greece and top GLCM countries to avoid clutter
  geom_label_repel(
    data = glcm_analysis_data %>% filter(Is_Greece == "Greece" | Avg_GLCM_Score > quantile(Avg_GLCM_Score, 0.9, na.rm = TRUE)),
    aes(label = CNT),
    size = 4,
    box.padding = 0.5,
    point.padding = 0.5,
    segment.color = 'grey50',
    label.size = 0.2,
    fill = "white",
    color = "black",
    fontface = "bold",
    max.overlaps = Inf # Allow all labels to be displayed
  )


# Plot 9: Education Investment Trends: Greece vs Top Performers
# This line plot illustrates the evolution of education expenditure as a percentage of GDP
# over a decade (2008-2018) for Greece and a selection of comparator countries.
investment_trend_data <- expenditure_raw_data %>%
  filter(Country %in% c("Greece", "Singapore", "Japan", "Finland", "France", "Germany")) %>%
  pivot_longer(cols = -Country, names_to = "Year", values_to = "Expenditure_GDP_Percent") %>%
  filter(Year %in% as.character(2008:2018)) %>% # Ensure years are treated as character strings for filtering
  mutate(
    Year = as.numeric(Year), # Convert year back to numeric for plotting
    Is_Greece = ifelse(Country == "Greece", "Greece", "Comparator Countries")
  )

plot_investment_trends <- investment_trend_data %>%
  ggplot(aes(x = Year, y = Expenditure_GDP_Percent, color = Country, group = Country)) +
  geom_line(size = 1, alpha = 0.8) +
  geom_point(size = 2, alpha = 0.7) +
  scale_color_manual(values = c("Greece" = apple_brand_colors[1],
                                "Singapore" = apple_brand_colors[2],
                                "Japan" = apple_brand_colors[3],
                                "Finland" = apple_brand_colors[4],
                                "France" = apple_brand_colors[5],
                                "Germany" = apple_brand_colors[6])) +
  labs(
    title = "Education Investment Trends: Greece vs Top Performers",
    subtitle = "Decade-long expenditure patterns (2008-2018)",
    x = "Year",
    y = "Education Expenditure (% of GDP)",
    color = "Country",
    caption = "Source: World Bank Data"
  ) +
  apple_design_theme() +
  guides(linetype = "none", size = "none") + # Remove unnecessary guides
  scale_x_continuous(breaks = seq(2008, 2018, 2)) + # Set specific x-axis breaks
  # Add labels at the end of each line, showing country and 2018 expenditure
  geom_label_repel(
    data = investment_trend_data %>%
      filter(Year == max(Year, na.rm = TRUE)) %>%
      left_join(expenditure_processed_data %>% select(CNT, Expenditure_2018), by = c("Country" = "CNT")),
    aes(label = paste0(Country, " (", round(Expenditure_2018, 1), "%)")),
    size = 4,
    box.padding = 0.5,
    point.padding = 0.5,
    segment.color = 'grey50',
    label.size = 0.2,
    fill = "white",
    color = "black",
    fontface = "bold",
    max.overlaps = Inf # Allow all labels to be displayed, even if they slightly overlap
  )


# Plot 10: Socioeconomic Impact on Academic Performance
# This plot explores how student performance varies based on the highest parental education level
# for Greece and a selection of comparator countries.
parental_education_impact_data <- pisa_processed_data %>%
  filter(!is.na(ST005Q01TA) & !is.na(ST007Q01TA) & !is.na(Overall_PISA_Score)) %>%
  mutate(
    # Detailed categorization of mother's education level
    Mother_Detailed_Ed_Level = case_when(
      str_detect(ST005Q01TA, "ISCED level 0|ISCED level 1") ~ "Primary or Below",
      str_detect(ST005Q01TA, "ISCED level 2") ~ "Lower Secondary",
      str_detect(ST005Q01TA, "ISCED level 3") ~ "Upper Secondary",
      str_detect(ST005Q01TA, "ISCED level 4|ISCED level 5|ISCED level 6") ~ "Tertiary",
      TRUE ~ "Other"
    ),
    # Detailed categorization of father's education level
    Father_Detailed_Ed_Level = case_when(
      str_detect(ST007Q01TA, "ISCED level 0|ISCED level 1") ~ "Primary or Below",
      str_detect(ST007Q01TA, "ISCED level 2") ~ "Lower Secondary",
      str_detect(ST007Q01TA, "ISCED level 3") ~ "Upper Secondary",
      str_detect(ST007Q01TA, "ISCED level 4|ISCED level 5|ISCED level 6") ~ "Tertiary",
      TRUE ~ "Other"
    ),
    # Determine the highest education level between parents by assigning ranks
    Max_Parent_Ed_Rank = pmax(
      match(Mother_Detailed_Ed_Level, c("Primary or Below", "Lower Secondary", "Upper Secondary", "Tertiary")),
      match(Father_Detailed_Ed_Level, c("Primary or Below", "Lower Secondary", "Upper Secondary", "Tertiary")),
      na.rm = TRUE
    ),
    # Convert ranks back to descriptive categories for the highest parental education
    Highest_Parental_Education_Category = case_when(
      Max_Parent_Ed_Rank == 1 ~ "Primary or Below",
      Max_Parent_Ed_Rank == 2 ~ "Lower Secondary",
      Max_Parent_Ed_Rank == 3 ~ "Upper Secondary",
      Max_Parent_Ed_Rank == 4 ~ "Tertiary",
      TRUE ~ "Other"
    )
  ) %>%
  filter(Highest_Parental_Education_Category != "Other") # Exclude 'Other' category for cleaner analysis

# Summarize average scores by country and highest parental education level.
socioeconomic_performance_summary <- parental_education_impact_data %>%
  group_by(CNT, Highest_Parental_Education_Category) %>%
  summarise(
    Average_PISA_Score = mean(Overall_PISA_Score, na.rm = TRUE),
    Student_Count_in_Category = n(),
    .groups = 'drop'
  ) %>%
  filter(Student_Count_in_Category >= 30) %>% # Ensure sufficient sample size per category
  mutate(Is_Greece = ifelse(CNT == "Greece", "Greece", "Other Countries"))

plot_socioeconomic_impact <- socioeconomic_performance_summary %>%
  filter(CNT %in% c("Greece", "Finland", "Singapore", "Japan", "Korea", "Germany", "Estonia", "United States")) %>%
  ggplot(aes(x = factor(Highest_Parental_Education_Category, levels = c("Primary or Below", "Lower Secondary", "Upper Secondary", "Tertiary")),
             y = Average_PISA_Score, color = CNT, group = CNT)) +
  geom_line(size = 1, alpha = 0.8) +
  geom_point(size = 4, alpha = 0.8) +
  scale_color_manual(values = c("Greece" = apple_brand_colors[2], # Red for Greece
                                "Finland" = apple_brand_colors[3],
                                "Singapore" = apple_brand_colors[4],
                                "Japan" = apple_brand_colors[5],
                                "Korea" = apple_brand_colors[6],
                                "Germany" = apple_brand_colors[7],
                                "Estonia" = apple_brand_colors[8],
                                "United States" = "#1d1d1f")) +
  labs(
    title = "Socioeconomic Impact on Academic Performance",
    subtitle = "Student performance by highest parental education level",
    x = "Highest Parental Education Level",
    y = "Average PISA Score",
    color = "Country",
    caption = "Source: OECD PISA 2018"
  ) +
  apple_design_theme() +
  guides(linetype = "none", size = "none") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  # Add non-overlapping labels with dynamic positions for average scores
  geom_text_repel(
    data = socioeconomic_performance_summary %>%
      filter(CNT %in% c("Greece", "Finland", "Singapore", "Japan", "Korea", "Germany", "Estonia", "United States")), # Filter for countries in the plot
    aes(label = round(Average_PISA_Score, 0)),
    size = 5,
    color = "black",
    box.padding = 0.6,
    point.padding = 0.6,
    segment.color = 'grey50',
    direction = "both",
    max.overlaps = Inf # Ensure all labels are displayed
  ) +
  theme(legend.position = "right")


# Plot 11: Educational Equity: PISA Score Gap by Parental Education Level
# This bar chart visualizes the PISA score gap between students with secondary-educated parents
# and those with primary/below educated parents, highlighting Greece's position.

# --- Categorize Parental Education Levels ---
equity_parent_education_data <- parental_education_impact_data %>%
  mutate(
    Parent_Ed_Category = case_when(
      str_detect(paste(ST005Q01TA, ST007Q01TA), regex("ISCED level 0|ISCED level 1|He did not complete|She did not complete", ignore_case = TRUE)) ~ "Primary or Below",
      str_detect(paste(ST005Q01TA, ST007Q01TA), regex("ISCED level 2", ignore_case = TRUE)) ~ "Lower Secondary",
      str_detect(paste(ST005Q01TA, ST007Q01TA), regex("ISCED level 3A|ISCED level 3B,3C", ignore_case = TRUE)) ~ "Upper Secondary",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(Parent_Ed_Category))

# --- Compute average score by country and education level ---
equity_avg_scores <- equity_parent_education_data %>%
  group_by(CNT, Parent_Ed_Category) %>%
  summarise(Avg_Score = mean(Overall_PISA_Score, na.rm = TRUE), .groups = 'drop')

# --- Pivot to wide format to calculate score gaps ---
gap_df <- equity_avg_scores %>%
  tidyr::pivot_wider(names_from = Parent_Ed_Category, values_from = Avg_Score) %>%
  mutate(
    Primary_vs_Lower = `Lower Secondary` - `Primary or Below`,
    Lower_vs_Upper = `Upper Secondary` - `Lower Secondary`,
    Primary_vs_Upper = `Upper Secondary` - `Primary or Below`,
    Avg_Total = rowMeans(across(c(`Primary or Below`, `Lower Secondary`, `Upper Secondary`)), na.rm = TRUE)
  )

# --- Select top/bottom 10 + Greece where applicable ---
get_valid_country_subset <- function(data, gap_column) {
  filtered <- data %>% filter(!is.na(.data[[gap_column]]))
  top10 <- filtered %>% arrange(desc(Avg_Total)) %>% slice_head(n = 10)
  bottom10 <- filtered %>% arrange(Avg_Total) %>% slice_head(n = 10)
  greece <- filtered %>% filter(CNT == "Greece")
  bind_rows(top10, bottom10, greece) %>% distinct(CNT, .keep_all = TRUE)
}

subset_primary_lower <- get_valid_country_subset(gap_df, "Primary_vs_Lower")
subset_lower_upper <- get_valid_country_subset(gap_df, "Lower_vs_Upper")
subset_primary_upper <- get_valid_country_subset(gap_df, "Primary_vs_Upper")

plot_gap_chart <- function(data, gap_col, subtitle_text, caption_text) {
  gap_values <- sym(gap_col)
  
  data <- data %>%
    mutate(
      Category = case_when(
        CNT == "Greece" ~ "Greece",
        CNT %in% (data %>% arrange(desc(Avg_Total)) %>% slice_head(n = 10))$CNT ~ "Top Performer",
        CNT %in% (data %>% arrange(Avg_Total) %>% slice_head(n = 10))$CNT ~ "Bottom Performer"
      ),
      Category = factor(Category, levels = c("Top Performer", "Bottom Performer", "Greece")),
      CNT_ordered = factor(CNT, levels = rev(CNT)),
      Label_Hjust = ifelse(!!gap_values >= 0, -0.4, 1.4)  # dynamically adjust label position
    )
  
  ggplot(data, aes(x = CNT_ordered, y = !!gap_values, color = Category)) +
    geom_segment(aes(xend = CNT_ordered, y = 0, yend = !!gap_values), size = 1.1, color = "#C0C0C0") +
    geom_point(size = 5) +
    geom_text(aes(label = round(!!gap_values, 1), hjust = Label_Hjust), size = 5, color = "#1d1d1f") +
    scale_color_manual(values = c(
      "Top Performer" = apple_brand_colors[3],
      "Bottom Performer" = apple_brand_colors[2],
      "Greece" = apple_brand_colors[1]
    )) +
    labs(
      title = "Educational Equity: PISA Score Gap by Parental Education Level",
      subtitle = subtitle_text,
      x = "Country",
      y = "PISA Score Gap",
      caption = caption_text
    ) +
    coord_flip(clip = "off") +
    theme_minimal(base_family = "Helvetica") +
    theme(
      legend.position = "bottom",
      plot.title = element_text(size = 15, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = 11, hjust = 0.5, color = "#555"),
      axis.text.y = element_text(size = 9),
      plot.caption = element_text(hjust = 0),
      plot.margin = margin(10, 30, 10, 10)
    )
}


# --- Generate the 3 Plots ---

plot11a <- plot_gap_chart(
  subset_primary_lower,
  "Primary_vs_Lower",
  "Difference in Average PISA Scores (Lower Secondary Parent Ed - Primary/Below Parent Ed).\nPositive values indicate higher performance for students whose parents completed lower secondary education.",
  "Source: OECD PISA 2018"
)

plot11b <- plot_gap_chart(
  subset_lower_upper,
  "Lower_vs_Upper",
  "Difference in Average PISA Scores (Upper Secondary Parent Ed - Lower Secondary Parent Ed).\nPositive values suggest added performance benefits from parents completing upper secondary education.",
  "Source: OECD PISA 2018"
)

plot11c <- plot_gap_chart(
  subset_primary_upper,
  "Primary_vs_Upper",
  "Difference in Average PISA Scores (Upper Secondary Parent Ed - Primary/Below Parent Ed).\nCaptures the full parental education gap; positive values reflect a strong advantage for students with highly educated parents.",
  "Source: OECD PISA 2018"
)



# --- Save all plots ---


# Plot 12: PISA Performance by Highest Parental Education Level
# This plot illustrates how PISA performance changes across different levels of parental education,
# comparing Greece with a selection of top-performing countries.

# Re-use the 'socioeconomic_performance_summary' from Plot 10, but prepare it for this specific plot.
parental_education_performance_plot_data <- socioeconomic_performance_summary %>%
  filter(CNT %in% c("Greece", "Singapore", "B-S-J-Z (China)", "Macao", "Finland", "Sweden"))

plot_socioeconomic_profiles <- parental_education_performance_plot_data %>%
  ggplot(aes(x = factor(Highest_Parental_Education_Category, levels = c("Primary or Below", "Lower Secondary", "Upper Secondary", "Tertiary")),
             y = Average_PISA_Score, group = CNT, color = CNT)) +
  geom_line(size = 1.2, alpha = 0.8) +
  geom_point(size = 4, alpha = 0.9) +
  scale_color_manual(values = c("Greece" = apple_brand_colors[1], # Blue for Greece
                                "Singapore" = apple_brand_colors[2], # red for Singapore
                                "B-S-J-Z (China)" = apple_brand_colors[3], # Green for Finland
                                "Macao" = apple_brand_colors[4], # Orange for Japan
                                "Sweden" = apple_brand_colors[5], # Purple for Korea
                                "Finland" = apple_brand_colors[6])) + # Pink for Estonia
  labs(
    title = "PISA Performance by Highest Parental Education Level",
    subtitle = "Comparing Greece with Top-Performing Countries (2018)",
    x = "Highest Parental Education Level",
    y = "Average PISA Score",
    color = "Country",
    caption = "Source: OECD PISA 2018 (Only groups with >=30 students shown)"
  ) +
  apple_design_theme() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  # Add non-overlapping labels with dynamic positions for scores on the lines
  geom_text_repel(aes(label = round(Average_PISA_Score, 0)),
                  size = 5, color = "#1d1d1f", fontface = "bold",
                  box.padding = 0.5, point.padding = 0.5,
                  segment.color = 'grey50',
                  max.overlaps = Inf, direction = "both") + # Ensure all labels are displayed
  theme(legend.position = "bottom")


# Plot 13: Gender Performance: Greece vs. OECD Average
# This bar chart provides a direct comparison of average male and female PISA scores
# in Mathematics, Reading, and Science for Greece against the overall OECD average.

# Calculate OECD average scores by gender and subject.
oecd_gender_average_scores <- pisa_processed_data %>%
  filter(Gender %in% c("Male", "Female")) %>%
  group_by(Gender) %>%
  summarise(
    Avg_Math = mean(MATH, na.rm = TRUE),
    Avg_Read = mean(READ, na.rm = TRUE),
    Avg_Scie = mean(SCIE, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  mutate(Country_Type = "OECD Average")

# Calculate Greece's average scores by gender and subject.
greece_gender_average_scores <- pisa_processed_data %>%
  filter(CNT == "Greece" & Gender %in% c("Male", "Female")) %>%
  group_by(Gender) %>%
  summarise(
    Avg_Math = mean(MATH, na.rm = TRUE),
    Avg_Read = mean(READ, na.rm = TRUE),
    Avg_Scie = mean(SCIE, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  mutate(Country_Type = "Greece")

# Combine both datasets for plotting.
combined_gender_comparison_data <- bind_rows(greece_gender_average_scores, oecd_gender_average_scores) %>%
  pivot_longer(cols = c(Avg_Math, Avg_Read, Avg_Scie),
               names_to = "Subject_Area", values_to = "Score") %>%
  mutate(Subject_Area = recode(Subject_Area, "Avg_Math" = "Mathematics", "Avg_Read" = "Reading", "Avg_Scie" = "Science"),
         Country_Type = factor(Country_Type, levels = c("Greece", "OECD Average"))) # Ensure consistent order

plot_gender_performance_comparison <- combined_gender_comparison_data %>%
  ggplot(aes(x = Subject_Area, y = Score, fill = Gender)) +
  geom_col(position = position_dodge(width = 0.8), alpha = 0.9) +
  facet_wrap(~Country_Type, ncol = 2) + # Separate panels for Greece and OECD Average
  scale_fill_manual(values = c("Male" = apple_brand_colors[1], "Female" = apple_brand_colors[2])) +
  labs(
    title = "Gender Performance: Greece vs. OECD Average",
    subtitle = "Average PISA scores by gender across subjects",
    x = "Subject Area",
    y = "Average PISA Score",
    fill = "Gender",
    caption = "Source: OECD PISA 2018"
  ) +
  apple_design_theme() +
  theme(legend.position = "bottom") +
  # Add score labels directly on the bars
  geom_text(aes(label = round(Score, 0)),
            position = position_dodge(width = 0.8),
            vjust = -0.5, size = 4, color = "#1d1d1f")


# Plot 14: Overall PISA Performance: Top, Bottom, and Greece
# This bar chart offers a concise comparison of the overall average PISA scores
# for the highest-performing country, the lowest-performing country, and Greece.

# Identify the top and bottom performing countries based on overall PISA average.
top_performing_country <- combined_education_data %>% arrange(desc(Overall_PISA_Avg)) %>% slice(1)
bottom_performing_country <- combined_education_data %>% arrange(Overall_PISA_Avg) %>% slice(1)
greece_overall_data <- combined_education_data %>% filter(CNT == "Greece")

# Combine these specific countries for the comparison plot.
key_country_comparison_data <- bind_rows(
  top_performing_country %>% mutate(Comparison_Type = "Top Performer"),
  bottom_performing_country %>% mutate(Comparison_Type = "Bottom Performer"),
  greece_overall_data %>% mutate(Comparison_Type = "Greece")
) %>%
  mutate(
    # Create a label that includes both country name and score
    Display_Label = paste0(CNT, " (", round(Overall_PISA_Avg, 0), ")"),
    # Order the categories for consistent plotting
    Comparison_Type = factor(Comparison_Type, levels = c("Top Performer", "Greece", "Bottom Performer"))
  )

plot_overall_performance_comparison <- key_country_comparison_data %>%
  ggplot(aes(x = Comparison_Type, y = Overall_PISA_Avg, fill = Comparison_Type)) +
  geom_col(width = 0.7, alpha = 0.9) +
  scale_fill_manual(values = c("Top Performer" = apple_brand_colors[3], # Green for top
                               "Greece" = apple_brand_colors[1], # Blue for Greece
                               "Bottom Performer" = apple_brand_colors[2])) + #Red   for bottom
  labs(
    title = "Overall PISA Performance: Top, Bottom, and Greece",
    subtitle = "Comparison of average PISA scores (Mathematics, Reading, Science)",
    x = "Country Group",
    y = "Average PISA Score",
    fill = "Country Category",
    caption = "Source: OECD PISA 2018"
  ) +
  apple_design_theme() +
  theme(legend.position = "none") + # Hide legend as labels are directly on bars
  # Add labels with country name and score above each bar
  geom_text(aes(label = Display_Label), vjust = -0.5, size = 7, color = "#1d1d1f", fontface = "bold")


# Plot 15: Efficiency Quadrant Analysis: Spotlight on Key Countries
# This plot visually categorizes countries into four quadrants based on their PISA performance
# and education investment, highlighting those in "High Performance, Low Investment" and
# "Low Performance, High Investment" zones.

# Prepare the data for the quadrant analysis, calculating efficiency metrics.
policy_metrics_for_quadrants <- combined_education_data %>%
  filter(Has_Expenditure_Info) %>% # Only include countries with full data
  mutate(
    # Calculate investment efficiency as a ratio
    Investment_Efficiency_Ratio = Overall_PISA_Avg / Avg_Expenditure_GDP,
    # Rank countries by performance and investment for relative comparison
    Performance_Rank = dense_rank(desc(Overall_PISA_Avg)),
    Investment_Rank = dense_rank(desc(Avg_Expenditure_GDP)),
    Efficiency_Rank = dense_rank(desc(Investment_Efficiency_Ratio)),
    # Create an overall quality metric for sorting
    Overall_Quality_Metric = (Performance_Rank + Efficiency_Rank) / 2
  ) %>%
  arrange(Overall_Quality_Metric)

# Assign countries to their respective policy quadrants based on medians.
policy_quadrants_data <- policy_metrics_for_quadrants %>%
  mutate(
    High_Performance = Overall_PISA_Avg > median(Overall_PISA_Avg, na.rm = TRUE),
    High_Investment = Avg_Expenditure_GDP > median(Avg_Expenditure_GDP, na.rm = TRUE),
    Quadrant_Category = case_when(
      High_Performance & High_Investment ~ "High Performance,\nHigh Investment",
      High_Performance & !High_Investment ~ "High Performance,\nLow Investment",
      !High_Performance & High_Investment ~ "Low Performance,\nHigh Investment",
      !High_Performance & !High_Investment ~ "Low Performance,\nLow Investment"
    )
  )

plot_efficiency_quadrant_spotlight <- policy_quadrants_data %>%
  ggplot(aes(x = Avg_Expenditure_GDP, y = Overall_PISA_Avg)) +
  geom_point(aes(color = Quadrant_Category, size = Investment_Efficiency_Ratio), alpha = 0.7) +
  scale_color_manual(values = c(
    "High Performance,\nLow Investment" = apple_brand_colors[3], # Green for efficient quadrant
    "High Performance,\nHigh Investment" = apple_brand_colors[1], # Blue
    "Low Performance,\nLow Investment" = apple_brand_colors[5], # Purple
    "Low Performance,\nHigh Investment" = apple_brand_colors[2]  # Red for inefficient quadrant
  )) +
  scale_size_continuous(range = c(2, 8), name = "Efficiency\nRatio") +
  # Add dashed lines to mark the median performance and investment
  geom_hline(yintercept = median(policy_quadrants_data$Overall_PISA_Avg, na.rm = TRUE),
             linetype = "dashed", alpha = 0.7, color = "#86868b") +
  geom_vline(xintercept = median(policy_quadrants_data$Avg_Expenditure_GDP, na.rm = TRUE),
             linetype = "dashed", alpha = 0.7, color = "#86868b") +
  labs(
    title = "Education Investment Efficiency: Strategic Quadrant Spotlight",
    subtitle = "Identifying efficient vs. inefficient education systems",
    x = "Average Education Investment 2008-2018 (% of GDP)",
    y = "PISA 2018 Average Performance",
    color = "Policy Quadrant",
    caption = "Optimal position: Upper-left quadrant (High Performance, Low Investment)\nEfficiency Ratio = Average PISA Score / Average Education Expenditure (% of GDP)\nSources: OECD PISA 2018, World Bank Data"
  ) +
  apple_design_theme() +
  theme(legend.position = "bottom",
        legend.box.spacing = unit(0.5, "cm")) +
  # Annotate each quadrant with its descriptive label, positioned in the corners
  annotate("text",
           x = min(policy_quadrants_data$Avg_Expenditure_GDP, na.rm = TRUE) - 0.3 * (median(policy_quadrants_data$Avg_Expenditure_GDP, na.rm = TRUE) - min(policy_quadrants_data$Avg_Expenditure_GDP, na.rm = TRUE)),
           y = max(policy_quadrants_data$Overall_PISA_Avg, na.rm = TRUE) - 0.1 * (max(policy_quadrants_data$Overall_PISA_Avg, na.rm = TRUE) - median(policy_quadrants_data$Overall_PISA_Avg, na.rm = TRUE)),
           label = "High Performance,\nLow Investment",
           size = 5, color = "#86868b", fontface = "bold", hjust = 0) +
  annotate("text",
           x = max(policy_quadrants_data$Avg_Expenditure_GDP, na.rm = TRUE) + 0.3 * (max(policy_quadrants_data$Avg_Expenditure_GDP, na.rm = TRUE) - median(policy_quadrants_data$Avg_Expenditure_GDP, na.rm = TRUE)),
           y = max(policy_quadrants_data$Overall_PISA_Avg, na.rm = TRUE) - 0.1 * (max(policy_quadrants_data$Overall_PISA_Avg, na.rm = TRUE) - median(policy_quadrants_data$Overall_PISA_Avg, na.rm = TRUE)),
           label = "High Performance,\nHigh Investment",
           size = 5, color = "#86868b", fontface = "bold", hjust = 1) +
  annotate("text",
           x = min(policy_quadrants_data$Avg_Expenditure_GDP, na.rm = TRUE) - 0.3 * (median(policy_quadrants_data$Avg_Expenditure_GDP, na.rm = TRUE) - min(policy_quadrants_data$Avg_Expenditure_GDP, na.rm = TRUE)),
           y = min(policy_quadrants_data$Overall_PISA_Avg, na.rm = TRUE) + 0.1 * (median(policy_quadrants_data$Overall_PISA_Avg, na.rm = TRUE) - min(policy_quadrants_data$Overall_PISA_Avg, na.rm = TRUE)),
           label = "Low Performance,\nLow Investment",
           size = 5, color = "#86868b", fontface = "bold", hjust = 0) +
  annotate("text",
           x = max(policy_quadrants_data$Avg_Expenditure_GDP, na.rm = TRUE) + 0.3 * (max(policy_quadrants_data$Avg_Expenditure_GDP, na.rm = TRUE) - median(policy_quadrants_data$Avg_Expenditure_GDP, na.rm = TRUE)),
           y = min(policy_quadrants_data$Overall_PISA_Avg, na.rm = TRUE) + 0.1 * (median(policy_quadrants_data$Overall_PISA_Avg, na.rm = TRUE) - min(policy_quadrants_data$Overall_PISA_Avg, na.rm = TRUE)),
           label = "Low Performance,\nHigh Investment",
           size = 5, color = "#86868b", fontface = "bold", hjust = 1) +
  # Label specific key countries for easy identification within the quadrants
  geom_label_repel(
    data = policy_quadrants_data %>%
      filter(Is_Greece == "Greece" |
               CNT %in% c("Singapore", "Finland", "Korea", "Japan", "Germany", "United States", "Italy", "Spain")),
    aes(label = CNT),
    size = 4,
    box.padding = 0.5,
    point.padding = 0.5,
    segment.color = 'grey50',
    label.size = 0.2,
    fill = "white",
    color = "black",
    fontface = "bold"
  )





cat("All visualizations have been successfully generated and saved to your working directory.\n")

# --- Standard Export Function for All Plots ---
save_apple_plot <- function(plot, filename) {
  ggsave(filename, plot = plot, width = 20, height = 10, dpi = 300, bg = "white")
}

# --- Apply Theme and Save for All Plots (1–16) ---

# Plot 1
plot_global_performance <- plot_global_performance + apple_design_theme()
save_apple_plot(plot_global_performance, "01_global_performance_overview.png")

# Plot 2
plot_gender_distribution <- plot_gender_distribution + apple_design_theme()
save_apple_plot(plot_gender_distribution, "02_gender_score_distribution.png")

# Plot 3
plot_subject_excellence <- plot_subject_excellence + apple_design_theme()
save_apple_plot(plot_subject_excellence, "03_subject_performance.png")

# Plot 4
plot_global_ranking <- plot_global_ranking + apple_design_theme()
save_apple_plot(plot_global_ranking, "04_greece_global_ranking.png")

# Plot 5
plot_gender_gap_analysis <- plot_gender_gap_analysis + apple_design_theme()
save_apple_plot(plot_gender_gap_analysis, "05_gender_gap_analysis.png")


# Plot 6
plot_investment_trends <- plot_investment_trends + apple_design_theme()
save_apple_plot(plot_investment_trends, "06_investment_trends.png")


# Plot 08a–c
plot11a <- plot11a + apple_design_theme()
save_apple_plot(plot11a, "08_a_gap_primary_lower.png")

plot11b <- plot11b + apple_design_theme()
save_apple_plot(plot11b, "08_b_gap_lower_upper.png")

plot11c <- plot11c + apple_design_theme()
save_apple_plot(plot11c, "08_c_gap_primary_upper.png")

# Plot 09
plot_socioeconomic_profiles <- plot_socioeconomic_profiles + apple_design_theme()
save_apple_plot(plot_socioeconomic_profiles, "09_socioeconomic_performance_profiles.png")

# Plot 10
plot_gender_performance_comparison <- plot_gender_performance_comparison + apple_design_theme()
save_apple_plot(plot_gender_performance_comparison, "10_gender_performance_comparison.png")

# Plot 11
plot_overall_performance_comparison <- plot_overall_performance_comparison + apple_design_theme()
save_apple_plot(plot_overall_performance_comparison, "11_overall_performance_comparison.png")


# Plot 12
plot_efficiency_quadrant_spotlight <- plot_efficiency_quadrant_spotlight + apple_design_theme()
save_apple_plot(plot_efficiency_quadrant_spotlight, "12_efficiency_quadrant_spotlight.png")





