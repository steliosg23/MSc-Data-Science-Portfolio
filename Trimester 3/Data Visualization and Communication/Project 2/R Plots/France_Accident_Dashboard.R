# --- France Road Accidents Dashboard (2009–2012) ---

# --- Setup ---
# Load necessary libraries for data manipulation, visualization, and animation.
library(tidyverse)    # Core tidyverse packages for data manipulation and visualization
library(lubridate)    # For easy manipulation of date-time objects
library(forcats)      # For handling categorical variables (factors)
library(ggthemes)     # Additional ggplot2 themes
library(ggrepel)      # For non-overlapping text labels in ggplot2
library(ggridges)     # For creating ridgeline plots
library(patchwork)    # For combining multiple ggplot2 plots
library(hrbrthemes)   # Another set of ggplot2 themes
library(RColorBrewer) # For color palettes
library(waffle)       # For creating waffle charts
library(treemapify)   # For creating treemaps
library(sf)           # For handling spatial data
library(maptiles)     # For fetching map tiles
library(tidyterra)    # Tidy methods for terra objects (spatial rasters)
library(ggpubr)       # For enhancing ggplot2 publications

# Set working directory. This should be adjusted based on the user's file structure.
setwd("C:/Users/steli/Stelios/Data Science AUEB/Course Material/Trimester 3/Data Visualization/Project 2/FranceRoadAccidents/Data")

# --- Define Global Design Theme ---
# A consistent theme for all static plots to ensure professional aesthetics.
design_theme <- function() {
  theme_minimal(base_family = "Helvetica") + # Use a clean, sans-serif font
    theme(
      text = element_text(color = "#1d1d1f"), # Dark grey text for readability
      plot.title = element_text(size = 28, face = "bold", hjust = 0, margin = margin(b = 24)), # Large, bold title, left-aligned
      plot.subtitle = element_text(size = 20, hjust = 0, color = "#86868b", margin = margin(b = 18)), # Subtitle in lighter grey
      axis.title = element_text(size = 18, face = "bold"), # Bold axis titles
      axis.text = element_text(size = 15), # Larger axis text
      axis.text.x = element_text(hjust = 1, vjust = 1), # Adjust x-axis text position
      panel.grid.major = element_line(color = "#f5f5f7"), # Light grey major grid lines
      panel.grid.minor = element_blank(), # Remove minor grid lines for cleaner look
      legend.title = element_text(size = 16, face = "bold"), # Bold legend title
      legend.text = element_text(size = 14), # Larger legend text
      legend.position = "bottom", # Place legend at the bottom
      plot.background = element_rect(fill = "white", color = NA), # White plot background
      panel.background = element_rect(fill = "white", color = NA), # White panel background
      strip.text = element_text(size = 16, face = "bold") # Facet strip text styling
    )
}

# --- Define Custom Color Palettes ---
# A comprehensive set of pastel-like colors for consistent visualization.
colors <- c(
  "#6FAFEF",  # Refined pastel blue
  "#EF5E5E",  # Pastel but serious red
  "#6ED6A2",  # Mint green with clarity
  "#FFD966",  # Warm yellow, still pastel
  "#CBA8EB",  # Softer orchid purple
  "#B7E3BC",  # Gentle teal
  "#FFB266",  # Balanced tangerine
  "#FF99AA",  # Gentle pink-red
  "#89CFF0",  # Clear pastel aqua
  "#7ED6A4",  # Leafy pastel lime
  "#A0AFFF",  # Consistent soft indigo
  "#F98DA0",  # Slightly deeper rosé
  "#CBB690",  # Neutral sand pastel
  "#BCA6E0",  # Calm lavender violet
  "#70AFFF",  # Cooler azure pastel
  "#F6B6C8",  # Refined blush pink
  "#A5E5DA",  # Soft mint foam
  "#FFE48D",  # Gold pastel with purpose
  "#C891EA",  # Pastel plum
  "#8FAFCF",  # Muted navy pastel
  "#CACACE",  # Gentle pastel gray
  "#FFBE91",  # Pastel peach
  "#B0E5FF",  # Sky bluebell pastel
  "#E5CCF5",  # Light lilac
  "#FFF3B8"   # Buttery pastel cream
)

# Specific colors for injury severity levels for easy identification.
injury_colors <- c(
  "Killed" = colors[2],             # Red for "Killed"
  "Hospitalized Injury" = colors[7], # Tangerine for "Hospitalized Injury"
  "Minor Injury" = colors[4],       # Yellow for "Minor Injury"
  "Unharmed" = colors[3]            # Mint green for "Unharmed"
)

# --- Plot Save Function ---
# Directory for saving plots; created if it doesn't exist.
output_dir <- "C:/Users/steli/Stelios/Data Science AUEB/Course Material/Trimester 3/Data Visualization/Project 2/FranceRoadAccidents/plots"
dir.create(output_dir, showWarnings = FALSE)

save_plot <- function(plot, filename, width = 14, height = 8, units = "in", subtitle = "", 
                      remove_x_labels = FALSE, remove_y_labels = FALSE) {
  source_caption <- "Source: French National Road Accidents Database (BAAC), data.gouv.fr, 2005–2023"
  
  # Build dynamic theme with optional axis label removal
  theme_mod <- theme(
    plot.caption = element_text(size = 12, color = "#a1a1a6", hjust = 1, margin = margin(t = 12)),
    plot.title = element_text(size = 24, face = "bold", hjust = 0),
    plot.subtitle = element_text(size = 18, hjust = 0, color = "#86868b"),
    axis.title = element_text(size = 18, face = "bold"),
    axis.text.x = if (remove_x_labels) element_blank() else element_text(size = 14, hjust = 0.5),
    axis.text.y = if (remove_y_labels) element_blank() else element_text(size = 14),
    legend.text = element_text(size = 14),
    legend.title = element_text(size = 16, face = "bold")
  )
  
  # Apply design theme and custom labels
  plot <- plot +
    design_theme() +
    labs(subtitle = subtitle, caption = source_caption) +
    theme_mod
  
  # Auto-format axes if numeric
  built_plot <- ggplot_build(plot)
  if (inherits(built_plot$layout$panel_scales_x[[1]]$range, "numeric")) {
    plot <- plot + scale_x_continuous(labels = scales::label_number(accuracy = 1, big.mark = ","))
  }
  if (inherits(built_plot$layout$panel_scales_y[[1]]$range, "numeric")) {
    plot <- plot + scale_y_continuous(labels = scales::label_number(accuracy = 1, big.mark = ","))
  }
  
  # Save final plot
  ggsave(
    filename = file.path(output_dir, filename),
    plot = plot,
    width = width,
    height = height,
    units = units,
    dpi = 300,
    limitsize = FALSE
  )
}



# --- Load and Prepare Data ---
# Load the main dataset and perform initial data cleaning and feature engineering.
df <- read_csv("road_accidents_2009_2012_merged.csv") %>%
  mutate(
    Date = as.Date(Date, format = "%m/%d/%Y"), # Convert Date to Date object
    DayOfWeek = factor(weekdays(Date), levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")), # Extract Day of Week as ordered factor
    Hour = as.numeric(substr(sprintf("%04d", Hour), 1, 2)), # Extract hour from time, format as two digits
    Month = month(Date, label = TRUE), # Extract Month as labeled factor
    Year = year(Date), # Extract Year
    Age = Year - `Birth Year`, # Calculate Age
    lat = as.numeric(lat) / 1e5, # Convert latitude to correct numeric format
    long = as.numeric(long) / 1e5, # Convert longitude to correct numeric format
    holiday = factor(holiday) # Convert holiday to factor
  ) %>%
  # Clean character columns by removing non-ASCII characters.
  mutate(
    across(where(is.character), ~ gsub(".?[^\x20-\x7E].?", " ", .))
  ) %>%
  # Recode injury severity levels for consistency.
  mutate(
    `Injury Severity` = recode(`Injury Severity`,
                               "Minor injury" = "Minor Injury",
                               "Hospitalized injury" = "Hospitalized Injury"
    )
  )

# --- Deprecated Static Plot Generation Code ---
# The following code block contains functions for generating static plots.
# These have been superseded by animated plot versions to provide a more dynamic
# and insightful visualization experience. Therefore, this code is no longer
# actively used and has been commented out.

# # 1. Accidents by Day of Week
# # Bar chart displaying the total number of accidents for each day of the week.
# save_plot(df %>%
#             distinct(Accident_ID, DayOfWeek) %>%
#             count(DayOfWeek) %>%
#             ggplot(aes(x = DayOfWeek, y = n)) +
#             geom_segment(aes(xend = DayOfWeek, yend = 0), color = colors[1], size = 1.2) +
#             geom_point(color = colors[1], size = 5) +
#             labs(title = "Accidents by Day of Week", x = "Day", y = "Number of Accidents"),
#           "01_temporal_dayofweek.jpg",
#           subtitle = "Distribution of accidents across weekdays"
# )

# # 2. Hourly Distribution of Accidents
# # Line plot illustrating the number of accidents per hour, including a LOESS trend line.
# hour_breaks <- 0:23
# hour_labels <- sprintf("%02dh", hour_breaks)

# save_plot(
#   df %>%
#     distinct(Accident_ID, Hour) %>%
#     count(Hour) %>%
#     ggplot(aes(x = Hour, y = n)) +
#     geom_line(aes(color = "Accidents"), size = 1.2) +
#     geom_point(aes(color = "Accidents"), size = 2) +
#     geom_smooth(aes(color = "Trend"), method = "loess", se = FALSE, linetype = "dashed", size = 1) +
#     scale_x_continuous(breaks = hour_breaks, labels = hour_labels) +
#     scale_color_manual(
#       name = NULL,
#       values = c("Accidents" = colors[2], "Trend" = "#86868b")
#     ) +
#     labs(
#       title = "Hourly Distribution of Accidents",
#       x = "Hour of Day",
#       y = "Accidents"
#     ) +
#     theme(legend.position = "bottom"),
#   "02_temporal_hourly.jpg",
#   subtitle = "Number of accidents by hour (00:00–23:00)"
# )

# # 3. Monthly Trend of Accidents with Peaks
# # Line plot showing monthly accident counts with highlighted yearly peaks.

# # Prepare monthly counts
# monthly_data <- df %>%
#   distinct(Accident_ID, Date) %>%
#   mutate(MonthYear = floor_date(Date, "month")) %>%
#   count(MonthYear) %>%
#   mutate(
#     year_val = year(MonthYear),
#     month_val = month(MonthYear),
#     month_label = ifelse(month_val == 1,
#                           paste0("1\n", year_val),
#                           as.character(month_val))
#   )

# # Identify peak months for each year
# peak_months <- df %>%
#   distinct(Accident_ID, Date) %>%
#   mutate(Year = year(Date), MonthYear = floor_date(Date, "month")) %>%
#   count(Year, MonthYear) %>%
#   group_by(Year) %>%
#   filter(n == max(n)) %>%
#   ungroup() %>%
#   mutate(
#     MonthName = format(MonthYear, "%B"),
#     label = paste0(MonthName, " ", Year, "\nPeak: ", n)
#   )

# # Calculate max y-value for plot padding
# ymax <- max(monthly_data$n) * 1.12

# # Generate and save the plot
# save_plot(
#   ggplot(monthly_data, aes(x = MonthYear, y = n)) +
#     geom_line(aes(color = "Accidents"), size = 1.2) +
#     geom_point(aes(color = "Accidents"), size = 2) +
#     geom_smooth(aes(color = "Trend"), method = "loess", se = FALSE,
#                 linetype = "dashed", size = 1) +
#     geom_point(data = peak_months, aes(x = MonthYear, y = n), color = "#8B0000", size = 3) +
#     geom_text(
#       data = peak_months,
#       aes(x = MonthYear, y = n, label = label),
#       vjust = -1.1, color = "#8B0000", size = 5, fontface = "bold"
#     ) +
#     scale_color_manual(
#       name = NULL,
#       values = c("Accidents" = colors[2], "Trend" = "#86868b")
#     ) +
#     expand_limits(y = ymax) +
#     scale_x_date(
#       breaks = monthly_data$MonthYear,
#       labels = monthly_data$month_label,
#       expand = c(0.01, 0.01),
#       guide = guide_axis(angle = 0)
#     ) +
#     labs(
#       title = "Monthly Trend of Accidents (2009–2012)",
#       x = "Month",
#       y = "Accidents"
#     ) +
#     theme_minimal(base_family = "Helvetica") +
#     theme(
#       text = element_text(color = "#1d1d1f"),
#       plot.title = element_text(size = 18, face = "bold", hjust = 0.5, margin = margin(b = 15)),
#       plot.subtitle = element_text(size = 14, hjust = 0.5, color = "#86868b", margin = margin(b = 15)),
#       axis.title = element_text(size = 14, face = "bold"),
#       axis.text = element_text(size = 12),
#       axis.text.x = element_text(size = 10, vjust = 0.6),
#       panel.grid.minor.x = element_blank(),
#       legend.position = "bottom",
#       legend.text = element_text(size = 12)
#     ),
#   filename = "03_temporal_monthly_peaks.jpg",
#   subtitle = "Monthly evolution of accidents with peaks"
# )

# # 4. Accident Density Heatmap: Hour vs Day
# # Heatmap visualizing accident density across hours and days of the week.
# hour_breaks <- seq(0, 22, by = 2)

# save_plot(
#   df %>%
#     distinct(Accident_ID, DayOfWeek, Hour) %>%
#     count(DayOfWeek, Hour) %>%
#     ggplot(aes(x = Hour, y = fct_rev(DayOfWeek), fill = n)) +
#     geom_tile(color = "white") +
#     scale_x_continuous(
#       breaks = hour_breaks,
#       labels = sprintf("%02d:00", hour_breaks)
#     ) +
#     scale_fill_gradient(low = "white", high = colors[2]) +
#     labs(
#       title = "Accident Density: Hour vs Day",
#       x = "Hour",
#       y = "Day of Week",
#       fill = "Accidents"
#     ) +
#     guides(fill = guide_colorbar(barwidth = 10, barheight = 2)) +
#     theme(
#       axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
#       legend.title = element_text(size = 16),
#       legend.text = element_text(size = 10)
#     ),
#   "04_temporal_heatmap.jpg",
#   subtitle = "Timeslots during the week when most accidents occur"
# )


# # 5. Geographic Distribution of Accidents (Density Map)
# # A density map of accident locations, faceted by urban/rural setting, with a basemap.

# # Prepare spatial data: unique accidents only, filtering out NA and out-of-France coordinates.
# plot20_data <- df %>%
#   distinct(Accident_ID, lat, long, Location) %>%
#   filter(!is.na(lat), !is.na(long), between(lat, 41, 52), between(long, -5, 10))

# if (nrow(plot20_data) > 0) {
#   plot20_sf <- st_as_sf(plot20_data, coords = c("long", "lat"), crs = 4326)

#   # Fetch basemap tiles from CartoDB Positron.
#   france_map_tiles <- get_tiles(st_bbox(plot20_sf), provider = "CartoDB.Positron", zoom = 7)

#   # Create the map plot
#   france_map_plot <- ggplot(plot20_data, aes(x = long, y = lat)) +
#     geom_spatraster_rgb(data = france_map_tiles) +
#     stat_density_2d(
#       aes(fill = after_stat(level)),
#       geom = "polygon",
#       alpha = 0.6,
#       bins = 30
#     ) +
#     scale_fill_gradientn(
#       colors = c("#FF6F61", "#E53935", "#C62828", "#A80000", "#8B0000"),
#       name = "Accident Density"
#     ) +
#     guides(fill = guide_colorbar(
#       barwidth = 10,
#       barheight = 2
#     )) +
#     facet_wrap(~ Location) +
#     labs(
#       title = "Geographic Distribution of Accidents",
#       subtitle = "Density map of accident locations by urban/rural setting",
#       x = "Longitude\n",
#       y = "\nLatitude"
#     ) +
#     theme(
#       legend.position = "right",
#       strip.text = element_text(size = 13, face = "bold")
#     )

#   # Save the plot using the standardized save_plot function
#   save_plot(
#     france_map_plot,
#     "05_temporal_map.jpg",
#     width = 14,
#     height = 8,
#     subtitle = "Density map of accident locations by urban/rural setting"
#   )
# }

# --- Actively Used Static Plot Generation Code ---
# This section is reserved for code that generates static plots currently in use.
# 

# 6. Accidents by Gender and Category
save_plot(
  df %>%
    filter(!is.na(Sex), !is.na(Category)) %>%  # Ensure no NA values
    count(Category, Sex) %>%
    ggplot(aes(x = Category, y = n, fill = Sex)) +
    geom_bar(stat = "identity", position = position_dodge(width = 0.7), width = 0.6) +
    geom_text(aes(label = scales::comma(n)), 
              position = position_dodge(width = 0.7), vjust = -0.5, 
              color = "gray30", size = 4.5) +
    scale_fill_manual(values = colors[c(16, 9)]) +
    labs(
      title = "Accidents by Gender and Category",
      x = "\nVictim Category",
      y = "",
      fill = "Gender"
    ) +
    design_theme() +
    theme(axis.text.x = element_text(angle = 30, hjust = 1)),
  "06_demo_gender_category.jpg",
  subtitle = "Gender distribution of accident participants per category",
  remove_y_labels = TRUE
)


# 7. Driver Age Distribution by Category and Gender
save_plot(
  df %>%
    filter(between(Age,0,100),!is.na(Category), !is.na(Sex)) %>%
    ggplot(aes(x = Age, fill = Sex)) +
    geom_histogram(binwidth = 5, position = "identity", alpha = 0.6, color = "white") +
    facet_wrap(~ Category, scales = "free_y") +
    scale_fill_manual(values = colors[c(16, 9)]) +
    labs(
      title = "Driver Age Distribution by Category and Gender",
      x = "\nDriver Age",
      y = "",
      fill = "Gender"
    ) +
    design_theme(),
  "07_demo_age_hist_by_category_sex.jpg",
  subtitle = "Age distribution of accident participants by gender and category",
)



# 8. Age by Day of Week (Violin Plot)
# Violin plot showing the distribution of ages across different days of the week.
save_plot(
  df %>% filter(between(Age, 0, 100), !is.na(Age)) %>%
    ggplot(aes(x = DayOfWeek, y = Age, fill = DayOfWeek)) +
    geom_violin(trim = TRUE, alpha = 0.7) + # Violin plot showing density
    geom_boxplot(width = 0.1, outlier.shape = NA, alpha = 0.6, color = "black") + # Overlay boxplot (no outliers)
    scale_fill_manual(values = colors[1:7]) + # Fill colors for each day
    labs(title = "Age by Day of Week", x = "", y = "Age", fill = "Day of Week") +
    theme(axis.text.x = element_blank()), # Remove x-axis text labels
  "08_demo_violin_age_day.jpg",
  subtitle = "How age varies across different weekdays",
  remove_x_labels = TRUE
)


# --- Waffle Plot Save Function ---
# Custom function for saving waffle plots, applying a similar theme.
save_waffle <- function(waffle_plot, filename, title = "", subtitle = "", width = 10, height = 6) {
  source_caption <- "Source: French National Road Accidents Database (BAAC), data.gouv.fr, 2005–2023"
  
  # Convert waffle object to ggplot if not already.
  if (!inherits(waffle_plot, "ggplot")) {
    plot <- as.ggplot(waffle_plot)
  } else {
    plot <- waffle_plot
  }
  
  # Apply theme and labels.
  plot <- plot +
    labs(
      title = title,
      subtitle = subtitle,
      caption = source_caption
    ) +
    theme_minimal(base_family = "Helvetica") +
    theme(
      text = element_text(color = "#1d1d1f"),
      plot.title = element_text(size = 18, face = "bold", hjust = 0.5, margin = margin(b = 10)), # Centered title
      plot.subtitle = element_text(size = 14, hjust = 0.5, color = "#86868b", margin = margin(b = 10)), # Centered subtitle
      plot.caption = element_text(size = 10, color = "gray30", hjust = 1, margin = margin(t = 15)),
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA)
    )
  
  # Ensure output directory exists.
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # Save the waffle plot.
  ggsave(
    filename = file.path(output_dir, filename),
    plot = plot,
    width = width,
    height = height,
    dpi = 300
  )
}

# 10. Weather Conditions (Waffle Chart)
# Waffle chart showing the percentage distribution of accidents across different weather conditions.

# Prepare weather data summary (distinct accidents only).
weather <- df %>%
  distinct(Accident_ID, `Weather Conditions`) %>%
  count(`Weather Conditions`) %>%
  mutate(pct = round(100 * n / sum(n))) # Calculate percentage

# Create the waffle plot.
waffle_weather <- waffle::waffle(
  setNames(weather$pct, paste0(weather$`Weather Conditions`, " (", weather$pct, "%)")),
  rows = 10,
  colors = colors[1:nrow(weather)]
)

# Save the waffle plot.
save_waffle(
  waffle_plot = waffle_weather,
  title = "Weather During Accidents",
  subtitle = "1 square = 1% of total accidents",
  filename = "10_cond_weather_waffle.jpg"
)

# 11. Lighting Conditions
# Dot plot showing the count of accidents under various lighting conditions.
save_plot(
  df %>%
    distinct(Accident_ID, `Lighting Conditions`) %>%
    count(`Lighting Conditions`) %>%
    ggplot(aes(x = n, y = fct_reorder(`Lighting Conditions`, n))) + # Reorder by count
    geom_segment(aes(xend = 0, yend = `Lighting Conditions`), color = colors[5], size = 1.2) + # Segments from y-axis
    geom_point(color = colors[5], size = 5) + # Points at the end of segments
    geom_text(aes(label = scales::comma(n)), vjust = -1.2, color = "gray30", size = 5.5) + # Count labels
    labs(title = "Lighting in Accidents", x = "", y = ""),
  "11_cond_lighting.jpg",
  subtitle = "Accidents under various lighting conditions",
  remove_x_labels = TRUE
)

# Helper to move NA last and label as 'Missing'
# Sort by count (ascending) but push "Missing" (NA) last
prepare_factor_sorted_asc <- function(df, col, n_col = n) {
  col_sym <- rlang::ensym(col)
  n_sym <- rlang::ensym(n_col)
  
  df <- df %>%
    mutate(!!col_sym := fct_na_value_to_level(!!col_sym, level = "Missing"))
  
  # Separate missing and non-missing values
  df_missing <- df %>% filter(!!col_sym == "Missing")
  df_non_missing <- df %>%
    filter(!!col_sym != "Missing") %>%
    mutate(!!col_sym := fct_reorder(!!col_sym, !!n_sym, .desc = FALSE))
  
  # Recombine, with 'Missing' added last
  bind_rows(df_non_missing, df_missing) %>%
    mutate(!!col_sym := fct_relevel(!!col_sym, "Missing", after = Inf))
}




# 12. Surface Conditions
# Dot plot showing the count of accidents on different road surface conditions.
save_plot(
  df %>%
    distinct(Accident_ID, `Surface Condition`) %>%
    mutate(`Surface Condition` = replace_na(`Surface Condition`, "Missing")) %>%
    count(`Surface Condition`) %>%
    arrange(n) %>%
    mutate(`Surface Condition` = factor(`Surface Condition`, levels = `Surface Condition`)) %>%
    ggplot(aes(x = n, y = `Surface Condition`)) +
    geom_segment(aes(xend = 0, yend = `Surface Condition`), color = colors[3], size = 1.2) +
    geom_point(color = colors[3], size = 5) +
    geom_text(aes(label = scales::comma(n)), vjust = -1.2, color = "gray30", size = 5.5) +
    labs(title = "Surface Conditions", x = "", y = "")+
    theme(axis.text.x = element_blank()),
  "12_cond_surface.jpg",
  subtitle = "Distribution of road surface states",
  remove_x_labels = TRUE
)






# 13. Holiday Accidents
# Bar chart showing accident counts during various public holidays.

# Prepare holiday counts, excluding NA and "None" values.
holiday_counts <- df %>%
  filter(!is.na(holiday)) %>%
  filter(holiday != "None") %>%
  distinct(Accident_ID, holiday) %>%
  count(holiday) %>%
  arrange(desc(n))

# Assign unique colors to each holiday.
holiday_colors <- setNames(colors[seq_len(nrow(holiday_counts))], holiday_counts$holiday)

save_plot(
  holiday_counts %>%
    ggplot(aes(x = n, y = fct_reorder(holiday, n), fill = holiday)) + # Reorder by count, fill by holiday
    geom_bar(stat = "identity", width = 0.6) + # Horizontal bar plot
    geom_text(aes(label = scales::comma(n)),
              hjust = -0.15, color = "gray30", size = 5.5) + # Count labels
    scale_fill_manual(values = holiday_colors) + # Custom fill colors
    labs(
      title = "Holiday Accidents",
      x = "",
      y = "",
      fill = "Holiday"
    ) +
    theme(legend.position = "none") + # No legend
    expand_limits(x = max(holiday_counts$n) * 1.08),  # Prevent label cutoff
  "13_cond_holiday.jpg",
  subtitle = "Accidents reported during public holidays",
  remove_x_labels = TRUE,
)

# 14. Infrastructure Involvement
# Dot plot showing accident counts by infrastructure type.
save_plot(
  df %>%
    distinct(Accident_ID, Infrastructure) %>%
    mutate(Infrastructure = replace_na(Infrastructure, "Missing")) %>%
    count(Infrastructure) %>%
    arrange(n) %>%
    mutate(Infrastructure = factor(Infrastructure, levels = Infrastructure)) %>%
    ggplot(aes(x = n, y = Infrastructure)) +
    geom_segment(aes(xend = 0, yend = Infrastructure), color = colors[6], size = 1.2) +
    geom_point(color = colors[6], size = 5) +
    geom_text(aes(label = scales::comma(n)), vjust = -1.2, color = "gray30", size = 5.5) +
    labs(title = "Infrastructure Involvement", x = "", y = "")
  ,
  "14_cond_infra.jpg",
  subtitle = "Accidents involving different infrastructure types",
  remove_x_labels = TRUE
)



# 15. Accidents by Road Type (Treemap)
# Treemap visualizing the relative share of accidents for different road categories.
save_plot(
  df %>%
    distinct(Accident_ID, `Road Category`) %>%
    count(`Road Category`) %>%
    mutate(percentage = n / sum(n) * 100) %>%
    ggplot(aes(
      area = n,
      label = paste0(`Road Category`, "\n(", round(percentage, 1), "%)"),
      fill = `Road Category`)
    ) +
    geom_treemap() +
    geom_treemap_text(color = "white", place = "centre", grow = TRUE, reflow = TRUE) +
    scale_fill_manual(values = rep(colors, length.out = length(unique(df$`Road Category`)))) +
    labs(
      title = "Accidents by Road Type (Treemap)",
      fill = "Road Type"
    ),
  "15_cond_road_type_treemap.jpg",
  subtitle = "Relative share of accidents by road type"
)

severity_order <- c("Unharmed", "Minor Injury", "Hospitalized Injury", "Killed")


# 16. Injury Severity Distribution
# Dot plot showing the count of accidents for each injury severity level.
save_plot(
  df %>%
    count(`Injury Severity`) %>%
    mutate(`Injury Severity` = factor(`Injury Severity`, levels = rev(severity_order))) %>%
    ggplot(aes(x = n, y = `Injury Severity`, color = `Injury Severity`)) + # now no need for fct_reorder
    geom_segment(aes(xend = 0, yend = `Injury Severity`), size = 1.2) +
    geom_point(size = 5) +
    geom_text(aes(label = scales::comma(n)), vjust = -1.2, color = "gray30", size = 5.5) +
    scale_color_manual(values = injury_colors, breaks = severity_order) + # force legend order
    labs(title = "Injury Severity Distribution", x = "", y = "", color = "Injury Severity"),
  "16_outcomes_severity.jpg",
  subtitle = "Severity levels recorded in accident reports",
  remove_x_labels = TRUE
)


# --- 17a. Severity by Lighting Condition (Final Bubble Plot with Labels) ---
# Bubble plot showing injury severity under surface conditions.
# Bubble size and number label denote incident count.

save_plot(
  ggplot(df %>%
           filter(!is.na(`Lighting Conditions`), !is.na(`Injury Severity`)) %>%
           count(`Lighting Conditions`, `Injury Severity`) %>%
           mutate(`Injury Severity` = factor(`Injury Severity`, levels = rev(severity_order))),
         aes(x = fct_infreq(`Lighting Conditions`), y = `Injury Severity`, size = n, color = `Injury Severity`)) +
    geom_point(alpha = 0.7) +  # Bubbles
    geom_text(aes(label = n), size = 5, color = "gray50", vjust = -3) +  # Labels above bubbles
    scale_color_manual(values = injury_colors, breaks = severity_order) +  # Custom color + enforced legend order
    scale_size_continuous(range = c(5, 25), guide = "none") +  # Bigger bubbles, no size legend
    labs(
      title = "Severity by Lighting Conditions",
      x = "",
      y = "",
      color = "Injury Severity"
    ) +
    theme_minimal(base_family = "Helvetica") +
    theme(
      axis.text.x = element_text(angle = 30, hjust = 1),
      legend.position = "right"
    ),
  
  "17a_outcomes_bubble_lighting_labeled.jpg",
  subtitle = "Bubble size and number label denote number of incidents"
)




# --- 17b. Severity by Surface Condition (Final Bubble Plot with Labels) ---
# Bubble plot showing injury severity under surface conditions.
# Bubble size and number label denote incident count.

save_plot(
  ggplot(df %>%
           filter(!is.na(`Surface Condition`), !is.na(`Injury Severity`)) %>%
           count(`Surface Condition`, `Injury Severity`) %>%
           mutate(`Injury Severity` = factor(`Injury Severity`, levels = rev(severity_order))),
         aes(x = fct_infreq(`Surface Condition`), y = `Injury Severity`, size = n, color = `Injury Severity`)) +
    geom_point(alpha = 0.7) +  # Bubbles
    geom_text(aes(label = n), size = 5, color = "gray50", vjust = -3) +  # Labels above bubbles
    scale_color_manual(values = injury_colors, breaks = severity_order) +  # Force legend order
    scale_size_continuous(range = c(5, 25), guide = "none") +  # Bigger bubbles, no size legend
    labs(
      title = "Severity by Surface Condition",
      x = "",
      y = "",
      color = "Injury Severity"
    ) +
    theme_minimal(base_family = "Helvetica") +
    theme(
      axis.text.x = element_text(angle = 30, hjust = 1),
      legend.position = "right"
    ),
  
  "17b_outcomes_bubble_surface_labeled.jpg",
  subtitle = "Bubble size and number label denote number of incidents"
)


# 18. Age by Injury Severity (Ridgeline Plot)
# Ridgeline plot showing age distributions for each injury severity level.
save_plot(
  df %>%
    filter(between(Age, 0, 100), !is.na(Age), !is.na(`Injury Severity`)) %>%
    mutate(`Injury Severity` = factor(`Injury Severity`, levels = rev(severity_order))) %>%
    ggplot(aes(x = Age, y = `Injury Severity`, fill = `Injury Severity`)) +
    geom_density_ridges(scale = 2, alpha = 0.7, color = "white", size = 0.3) +  # Ridgeline density plot
    scale_fill_manual(values = injury_colors, breaks = severity_order) +       # Ordered legend
    labs(
      title = "Age by Injury Severity",
      x = "",
      y = "",
      fill = "Injury Severity"
    ),
  "18_outcomes_ridge_age.jpg",
  subtitle = "Distribution of injury types across ages"
)


# 19. Severity by Vehicle Category (Stacked Bar Chart)
# Stacked bar chart showing the proportion of different injury severities per vehicle type.
save_plot(
  df %>%
    filter(!is.na(`Vehicle Category`), !is.na(`Injury Severity`)) %>%
    count(`Vehicle Category`, `Injury Severity`) %>%
    mutate(`Injury Severity` = factor(`Injury Severity`, levels = rev(severity_order))) %>%
    group_by(`Vehicle Category`) %>%
    mutate(prop = n / sum(n)) %>%
    ggplot(aes(x = `Vehicle Category`, y = prop, fill = `Injury Severity`)) +
    geom_bar(stat = "identity", position = "fill") +
    scale_fill_manual(values = injury_colors, breaks = severity_order) +  # enforce legend order
    labs(
      title = "Severity by Vehicle Category",
      x = "",
      y = "",
      fill = "Injury Severity"
    ) +
    scale_x_discrete(
      labels = function(x) stringr::str_wrap(x, width = 25),
      guide = guide_axis(angle = 45)
    ),
  filename = "19_outcomes_vehicle_severity.jpg",
  subtitle = "Stacked bar plot showing the proportion of severity per vehicle type"
)

# 20. Equipment Usage
# Dot plot showing the frequency of different safety equipment usage types in accidents.
save_plot(
  df %>%
    mutate(`Equipment Usage` = replace_na(`Equipment Usage`, "Missing")) %>%
    count(`Equipment Usage`) %>%
    arrange(n) %>%
    mutate(`Equipment Usage` = factor(`Equipment Usage`, levels = `Equipment Usage`)) %>%
    ggplot(aes(x = n, y = `Equipment Usage`)) +
    geom_segment(aes(xend = 0, yend = `Equipment Usage`), color = colors[5], size = 1.2) +
    geom_point(color = colors[5], size = 5) +
    geom_text(aes(label = scales::comma(n)), vjust = -1.2, color = "gray30", size = 5.5) +
    labs(title = "Safety Equipment Usage", x = "", y = ""),
  "20_behavior_equipment.jpg",
  subtitle = "Frequency of safety equipment usage",
  remove_x_labels = TRUE
)


# 21. Travel Purpose
# Dot plot showing accident counts by reported reason for travel.
save_plot(
  df %>%
    mutate(`Travel Reason` = replace_na(`Travel Reason`, "Missing")) %>%
    count(`Travel Reason`) %>%
    arrange(n) %>%
    mutate(`Travel Reason` = factor(`Travel Reason`, levels = `Travel Reason`)) %>%
    ggplot(aes(x = n, y = `Travel Reason`)) +
    geom_segment(aes(x = 0, xend = n, y = `Travel Reason`, yend = `Travel Reason`),
                 color = colors[4], size = 1.2) +
    geom_point(color = colors[4], size = 5) +
    geom_text(aes(label = scales::comma(n)), vjust = -1.2, color = "gray30", size = 5.5) +
    labs(title = "Travel Purpose", x = "", y = ""),
  "21_behavior_travel.jpg",
  subtitle = "Reported reason for travel during accident",
  remove_x_labels = TRUE
)



# 22. Collision Types
# Dot plot showing the distribution of different types of collisions.
save_plot(
  df %>%
    distinct(Accident_ID, `Type of collision`) %>%
    mutate(`Type of collision` = replace_na(`Type of collision`, "Missing")) %>%
    count(`Type of collision`) %>%
    arrange(n) %>%
    mutate(`Type of collision` = factor(`Type of collision`, levels = `Type of collision`)) %>%
    ggplot(aes(x = n, y = `Type of collision`)) +
    geom_segment(aes(xend = 0, yend = `Type of collision`), color = colors[6], size = 1.2) +
    geom_point(color = colors[6], size = 5) +
    geom_text(aes(label = scales::comma(n)), vjust = -1.2, color = "gray30", size = 5.5) +
    labs(title = "Collision Types", x = "", y = ""),
  "22_behavior_collision.jpg",
  subtitle = "Distribution of collision types",
  remove_x_labels = TRUE
)



# 23. Vehicles Involved
# Bar chart showing the counts of different vehicle types involved in accidents.
save_plot(
  df %>%
    distinct(Accident_ID, `Vehicle Category`) %>%
    mutate(`Vehicle Category` = replace_na(`Vehicle Category`, "Missing")) %>%
    count(`Vehicle Category`) %>%
    arrange(n) %>%
    mutate(`Vehicle Category` = factor(`Vehicle Category`, levels = `Vehicle Category`)) %>%
    ggplot(aes(x = n, y = `Vehicle Category`)) +
    geom_col(fill = colors[1]) +
    geom_text(aes(label = scales::comma(n)), hjust = -0.08, color = "gray30", size = 3.5) +
    labs(title = "Vehicles Involved", x = "", y = ""),
  "23_behavior_vehicle.jpg",
  subtitle = "Types of vehicles involved in incidents",
  remove_x_labels = TRUE
)



# 24. Injury Severity by Safety Equipment Usage (Stacked Bar Chart)
# Stacked bar chart showing the proportion of injury levels across different safety equipment usage categories.
save_plot(
  df %>%
    filter(!is.na(`Injury Severity`), !is.na(`Equipment Usage`)) %>%
    count(`Equipment Usage`, `Injury Severity`) %>%
    mutate(`Injury Severity` = factor(`Injury Severity`, levels = rev(severity_order))) %>%  # Set factor levels
    group_by(`Equipment Usage`) %>%
    mutate(prop = n / sum(n)) %>%
    ggplot(aes(x = `Equipment Usage`, y = prop, fill = `Injury Severity`)) +
    geom_bar(stat = "identity", position = "fill") + # Stacked bar
    scale_fill_manual(values = injury_colors, breaks = severity_order) +  # Ordered fill
    labs(
      title = "Injury Severity by Safety Equipment Usage",
      x = "",
      y = "",
      fill = "Injury Severity"
    ),
  "24_equipment_vs_severity.jpg",
  subtitle = "Proportion of injury levels across usage categories"
)

message("All static plots generated.")

# --- Animated Plot Section ---

# --- Animated Plot Section (Adjusted for Unique Accident IDs) ---

# Load required libraries for data manipulation, visualization, and animations.

# Core Tidyverse packages
library(ggplot2)    # For creating static and animated plots
library(dplyr)      # For data manipulation (e.g., %>% for piping, distinct, count, mutate, filter)
library(lubridate)  # For easy manipulation of date-time objects (e.g., floor_date, year, month)
library(forcats)    # For handling factor variables (e.g., fct_rev)

# Animation specific packages
library(gganimate)  # Extends ggplot2 for creating animations
library(gifski)     # GIF renderer for gganimate
library(av)         # Video renderer for gganimate

# Spatial data packages
library(sf)         # Simple Features for spatial data
library(stars)      # Spatiotemporal Arrays, Raster, and Vector data cubes (required for spatial raster data handling)
library(terra)      # Modern R package for spatial data analysis (often used with stars or as an alternative to raster)
library(ggspatial)  # Provides 'geom_spatial_*' functions for adding spatial elements and basemaps to ggplot2

# --- Global Animation Settings ---
fps <- 30         # Frames per second for animations
end_pause <- 15   # Duration (in seconds) to pause at the final frame
width <- 14       # Width of the animation output
height <- 8       # Height of the animation output
res <- 300        # Resolution (DPI) for the animation
gif_dir <- "C:/Users/steli/Stelios/Data Science AUEB/Course Material/Trimester 3/Data Visualization/Project 2/FranceRoadAccidents/R Plots/gifs"
dir.create(gif_dir, showWarnings = FALSE) # Create GIF directory if it doesn't exist

# --- Source Caption for Animations ---
source_caption <- "Source: French National Road Accidents Database (BAAC), data.gouv.fr, 2005–2023"

# --- Theme for High-Definition Animation ---
design_theme <- function() {
  theme_minimal(base_family = "Helvetica") +
    theme(
      text = element_text(color = "#1d1d1f"),
      plot.title = element_text(size = 24, face = "bold", hjust = 0, margin = margin(b = 12)),
      plot.subtitle = element_text(size = 18, hjust = 0, color = "#86868b", margin = margin(b = 10)),
      plot.caption = element_text(size = 12, hjust = 1, color = "#a1a1a6", margin = margin(t = 12)),
      axis.title = element_text(size = 18, face = "bold"),
      axis.text = element_text(size = 14),
      axis.text.x = element_text(hjust = 1),
      panel.grid.major = element_line(color = "#f5f5f7"),
      panel.grid.minor = element_blank(),
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),
      strip.text = element_text(size = 14, face = "bold"),
      legend.position = "bottom",
      legend.title = element_text(size = 16, face = "bold"),
      legend.text = element_text(size = 14)
    )
}

# --- 1. Day of Week Growth Animation ---
day_order <- c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
day_data <- df %>%
  distinct(Accident_ID, DayOfWeek) %>%
  count(DayOfWeek) %>%
  mutate(DayOfWeek = factor(DayOfWeek, levels = day_order, ordered = TRUE))

expanded_data <- data.frame()
for (i in 1:nrow(day_data)) {
  growth_frames <- seq(0, day_data$n[i], length.out = fps * 0.7)
  for (y_val in growth_frames) {
    temp <- day_data[1:i, ]
    temp[i, "n_animated"] <- y_val
    temp$frame_id <- paste0("day_", i, "_grow_", round(y_val, 2))
    expanded_data <- bind_rows(expanded_data, temp)
  }
  for (h in 1:(fps * 0.5)) {
    temp <- day_data[1:i, ]
    temp$n_animated <- temp$n
    temp$frame_id <- paste0("day_", i, "_hold_", h)
    expanded_data <- bind_rows(expanded_data, temp)
  }
}

expanded_data <- expanded_data %>%
  group_by(frame_id, DayOfWeek) %>%
  mutate(n_animated = ifelse(is.na(n_animated), n, n_animated)) %>%
  ungroup() %>%
  mutate(frame_num = as.numeric(factor(frame_id, levels = unique(frame_id))))

final_frame <- max(expanded_data$frame_num)
freeze_rows <- map_dfr(seq_len(fps * end_pause), function(i) {
  expanded_data %>%
    filter(frame_num == final_frame) %>%
    mutate(frame_num = final_frame + i)
})
expanded_data <- bind_rows(expanded_data, freeze_rows)

p_day <- ggplot(expanded_data, aes(x = DayOfWeek, y = n_animated)) +
  geom_segment(aes(xend = DayOfWeek, y = 0, yend = n_animated), color = colors[1], size = 1.8) +
  geom_point(color = colors[1], size = 5) +
  ylim(0, max(day_data$n) * 1.1) +
  labs(
    title = "Accidents by Day of Week",
    subtitle = "Distribution of road accidents across weekdays",
    caption = source_caption,
    x = "Day", y = "Number of Accidents"
  ) +
  design_theme() +
  transition_manual(frame_num)

animate(
  p_day,
  fps = fps,
  nframes = max(expanded_data$frame_num),
  width = width * res,
  height = height * res,
  res = res,
  renderer = gifski_renderer(file.path(gif_dir, "01_temporal_dayofweek_animated_growth.gif"))
)

# --- 2. Hourly Trend Animation ---
hour_data <- df %>%
  distinct(Accident_ID, Hour) %>%
  count(Hour)
hour_data$trend <- predict(loess(n ~ Hour, data = hour_data))

freeze_rows <- map_dfr(seq_len(fps * end_pause), function(i) {
  hour_data %>% filter(Hour == 23) %>% mutate(Hour = 23 + i / 1000)
})
hour_data_frozen <- bind_rows(hour_data, freeze_rows)

hour_breaks <- 0:23
hour_labels <- sprintf("%02dh", hour_breaks)

p_hour <- ggplot(hour_data_frozen, aes(x = Hour, y = n)) +
  geom_line(aes(color = "Accidents"), size = 1.8) +
  geom_point(aes(color = "Accidents"), size = 5) +
  geom_line(aes(y = trend, color = "Trend"), linetype = "dashed", size = 1.8) +
  scale_x_continuous(breaks = hour_breaks, labels = hour_labels) +
  scale_y_continuous(
    breaks = seq(0, max(hour_data$n) * 1.1, by = 5000), 
    limits = c(0, max(hour_data$n) * 1.1)
  ) +
  scale_color_manual(name = NULL, values = c("Accidents" = colors[2], "Trend" = "#86868b")) +
  labs(
    title = "Hourly Distribution of Accidents",
    subtitle = "Evolution of road accidents by hour (00:00–23:00)",
    caption = source_caption,
    x = "Hour", y = "Accidents"
  ) +
  design_theme() +
  transition_reveal(Hour)

animate(
  p_hour,
  fps = fps,
  nframes = nrow(hour_data_frozen),
  width = width * res,
  height = height * res,
  res = res,
  renderer = gifski_renderer(file.path(gif_dir, "02_temporal_hourly_animated.gif"))
)

# --- 3. Monthly Trend Animation (Line Plot with Revealing Line and Peaks) ---
# Animates the monthly trend of accidents, highlighting peaks as the data reveals.

# Monthly Data and Trend using distinct Accident_ID
monthly_data <- df %>%
  distinct(Accident_ID, Date) %>%
  mutate(MonthYear = floor_date(Date, "month")) %>%
  count(MonthYear) %>%
  mutate(
    Year = year(MonthYear),
    Month = month(MonthYear),
    year_val = year(MonthYear),
    month_val = month(MonthYear),
    month_label = ifelse(month_val == 1, paste0(month_val, "\n", year_val), as.character(month_val)),
    frame_time = as.numeric(MonthYear)
  )

monthly_data$trend <- predict(loess(n ~ as.numeric(MonthYear), data = monthly_data)) # LOESS trend

# Peak Labels using distinct Accident_ID
peak_months <- df %>%
  distinct(Accident_ID, Date) %>%
  mutate(MonthYear = floor_date(Date, "month"), Year = year(Date)) %>%
  count(Year, MonthYear) %>%
  group_by(Year) %>%
  filter(n == max(n)) %>%
  ungroup() %>%
  mutate(
    label = paste0(format(MonthYear, "%b %Y"), "\nAccidents: \n", n),
    frame_time = as.numeric(MonthYear)
  )

# Freeze Final MonthYear by Repeating with Advancing Frame Time
# This creates a pause at the end of the animation.
last_date <- max(monthly_data$MonthYear)
last_numeric <- as.numeric(last_date)

freeze_data <- map_dfr(seq_len(fps * end_pause), function(i) {
  monthly_data %>%
    filter(MonthYear == last_date) %>%
    mutate(frame_time = last_numeric + i) # Increment frame_time
})

monthly_data_frozen <- bind_rows(monthly_data, freeze_data)

freeze_peaks <- map_dfr(seq_len(fps * end_pause), function(i) {
  peak_months %>%
    filter(MonthYear == last_date) %>%
    mutate(frame_time = last_numeric + i) # Increment frame_time for peaks too
})

peak_months_frozen <- bind_rows(peak_months, freeze_peaks)

# --- Create a distinct set of MonthYear and month_label for axis breaks and labels ---
# This ensures that 'breaks' and 'labels' have the same length and correspond correctly.
monthly_data_for_axes <- monthly_data_frozen %>%
  distinct(MonthYear, .keep_all = TRUE) %>% # Get unique MonthYear entries
  arrange(MonthYear) # Ensure they are in chronological order

# Create the animated plot.
p_month <- ggplot() +
  geom_line(data = monthly_data_frozen, aes(x = MonthYear, y = n, color = "Accidents"), color = colors[2],size = 1.8) +
  geom_point(data = monthly_data_frozen, aes(x = MonthYear, y = n, color = "Accidents"), size = 5) +
  geom_line(data = monthly_data_frozen, aes(x = MonthYear, y = trend, color = "Trend"), linetype = "dashed", size = 1.8) +
  geom_point(data = peak_months_frozen, aes(x = MonthYear, y = n, group = MonthYear), color = "#8B0000", size = 5) + # Peak points
  geom_text(data = peak_months_frozen, aes(x = MonthYear, y = n, label = label, group = MonthYear),
            vjust = -0.5, color = "#8B0000", size = 5, fontface = "bold") + # Peak labels
  scale_color_manual(name = NULL, values = c("Accidents" = colors[2], "Trend" = "#86868b")) +
  labs(
    title = "Monthly Trend of Accidents (2009–2012)",
    subtitle = "Monthly evolution of road accidents per year",
    caption = source_caption,
    x = "Month", y = "Accidents"
  ) +
  coord_cartesian(ylim = c(0, max(monthly_data$n, peak_months$n) * 1.25)) + # Set y-axis limits with padding
  design_theme() +
  # --- MODIFIED: Use the newly created 'monthly_data_for_axes' for consistent breaks and labels ---
  scale_x_date(
    breaks = monthly_data_for_axes$MonthYear, # Use unique MonthYear as breaks
    labels = monthly_data_for_axes$month_label, # Use corresponding month_label as labels
    expand = c(0.01, 0.01),
    guide = guide_axis(angle = 0) 
  ) +
  transition_reveal(along = frame_time) + # Animate by revealing along the frame_time
  shadow_mark(past = TRUE, future = FALSE) # Keep past data visible

# Render the animation.
animate(
  p_month,
  fps = fps,
  nframes = length(unique(monthly_data_frozen$frame_time)),
  width = width*res,
  height = height*res,
  res = res,
  renderer = gifski_renderer(file.path(gif_dir, "03_temporal_monthly_animated.gif"))
)

# --- 4. Heatmap Animation (Hour vs Day) ---
# Animates the density of accidents across hours of the day and days of the week, revealing data incrementally.
day_levels <- c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
hour_breaks <- seq(0, 22, by = 2)

heat_data <- df %>%
  distinct(Accident_ID, DayOfWeek, Hour) %>%
  count(DayOfWeek, Hour) %>%
  complete(DayOfWeek = day_levels, Hour = 0:23, fill = list(n = 0)) %>%
  mutate(DayOfWeek = factor(DayOfWeek, levels = day_levels, ordered = TRUE)) %>%
  arrange(DayOfWeek, Hour) %>%
  mutate(frame = row_number())

heat_expanded <- map_dfr(unique(heat_data$frame), function(f) {
  heat_data %>% filter(frame <= f) %>% mutate(frame_group = f)
})

final_frame <- max(heat_data$frame)
freeze_frames <- fps * end_pause
heat_frozen <- map_dfr(seq_len(freeze_frames), function(i) {
  heat_data %>% mutate(frame_group = final_frame + i)
})

heat_final <- bind_rows(heat_expanded, heat_frozen)

p_heat <- ggplot(heat_final, aes(x = Hour, y = fct_rev(DayOfWeek), fill = n)) +
  geom_tile(color = "white") +
  scale_x_continuous(breaks = hour_breaks, labels = sprintf("%02d:00", hour_breaks)) +
  scale_fill_gradient(low = "white", high = colors[2]) +
  labs(
    title = "Accident Density: Hour vs Day",
    subtitle = "Timeslots of road accidents during the week",
    caption = source_caption,
    x = "Hour", y = "Day of Week", fill = "Accidents"
  ) +
  guides(fill = guide_colorbar(barwidth = 10, barheight = 1)) +
  design_theme() +
  transition_manual(frame_group)

animate(
  p_heat,
  fps = fps,
  nframes = max(heat_final$frame_group),
  width = width * res,
  height = height * res,
  res = res,
  renderer = gifski_renderer(file.path(gif_dir, "04_temporal_heatmap_animated.gif"))
)

# --- 5. Geographic Distribution Animation (Prepare Data) ---
# It animates the monthly geographic density of accidents.
# --- Prepare Data ---
plot20_data <- df %>%
  distinct(Accident_ID, lat, long, Location, Date) %>%
  filter(!is.na(lat), !is.na(long), between(lat, 41, 52), between(long, -5, 10)) %>%
  mutate(MonthYear = floor_date(Date, "month")) %>%  # keep Date format
  arrange(MonthYear) %>%
  mutate(MonthYear = factor(MonthYear, levels = unique(MonthYear)))  # ensure correct chronological order

# Convert to sf for spatial base
plot20_sf <- st_as_sf(plot20_data, coords = c("long", "lat"), crs = 4326)

# Download basemap tiles
france_map_tiles <- get_tiles(st_bbox(plot20_sf), provider = "CartoDB.Positron", zoom = 7)

# --- Create Animated Plot ---
density_anim <- ggplot(plot20_data, aes(x = long, y = lat)) +
  geom_spatraster_rgb(data = france_map_tiles) +  # Basemap
  stat_density_2d(
    aes(fill = after_stat(level)),
    geom = "polygon",
    bins = 30,
    alpha = 0.6
  ) +
  scale_fill_gradientn(
    colors = c("#FF6F61", "#E53935", "#C62828", "#A80000", "#8B0000"),
    name = "Accident Density"
  ) +
  facet_wrap(~ Location) +
  labs(
    title = "Geographic Distribution of Accidents",
    subtitle = "Monthly accident density by location — {format(as.Date(current_frame), '%b %Y')}",
    caption = source_caption,
    x = "Longitude\n",
    y = "\nLatitude"
  ) +
  design_theme() +  # your custom theme
  transition_manual(MonthYear) +  # Animate frame by MonthYear
  ease_aes('cubic-in-out')

# --- Animate and Save ---
fps <- 3        # Slow enough for clarity
end_pause <- 10  # Hold final frame
width <- 14      # Inches
height <- 8
res <- 300       # DPI

gganimate::animate(
  density_anim,
  fps = fps,
  nframes = length(unique(plot20_data$MonthYear)) + end_pause,
  width = width * res,
  height = height * res,
  res = res,
  renderer = gganimate::gifski_renderer(file.path(gif_dir, "20_geographic_density_monthly.gif"))
)
message("All animated plots generated.")
