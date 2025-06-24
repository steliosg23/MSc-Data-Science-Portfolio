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
setwd("C:/Users/steli/Stelios/DS AUEB/Trimester 3/Data Visualization/Project 2/FranceRoadAccidents/Data")

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
  "#5FD6BE",  # Gentle teal
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
output_dir <- "C:/Users/steli/Stelios/DS AUEB/Trimester 3/Data Visualization/Project 2/FranceRoadAccidents/Data/plots"
dir.create(output_dir, showWarnings = FALSE)

# Enhanced function to save ggplot objects with consistent styling and formatting.
save_plot <- function(plot, filename, width = 14, height = 8, units = "in", subtitle = "") {
  source_caption <- "Source: French National Road Accidents Database (BAAC), data.gouv.fr, 2005–2023"
  
  # Apply the design theme and add labs (title, subtitle, caption).
  plot <- plot +
    design_theme() +
    labs(subtitle = subtitle, caption = source_caption) +
    theme(
      plot.caption = element_text(size = 12, color = "#a1a1a6", hjust = 1, margin = margin(t = 12)), # Styling for source caption
      plot.title = element_text(size = 24, face = "bold", hjust = 0),              # Larger plot title
      plot.subtitle = element_text(size = 18, hjust = 0, color = "#86868b"),       # Larger plot subtitle
      axis.title = element_text(size = 18, face = "bold"),                         # Bigger axis titles
      axis.text = element_text(size = 14),                                         # Bigger tick labels
      axis.text.x = element_text(hjust = 0.5),                                     # Centered x-axis labels
      legend.text = element_text(size = 14),                                       # Clear legend text
      legend.title = element_text(size = 16, face = "bold")                        # Clear legend title
    )
  
  # Smart axis formatting for large numbers using `scales::label_number`.
  # This dynamically applies comma formatting to numeric axes.
  built_plot <- ggplot_build(plot)
  
  if (inherits(built_plot$layout$panel_scales_x[[1]]$range, "numeric")) {
    plot <- plot + scale_x_continuous(labels = scales::label_number(accuracy = 1, big.mark = ","))
  }
  if (inherits(built_plot$layout$panel_scales_y[[1]]$range, "numeric")) {
    plot <- plot + scale_y_continuous(labels = scales::label_number(accuracy = 1, big.mark = ","))
  }
  
  # Save the plot with specified dimensions and DPI.
  ggsave(
    filename = file.path(output_dir, filename),
    plot = plot,
    width = width,
    height = height,
    units = units,
    dpi = 300,
    limitsize = FALSE # Allow plots to exceed typical graphic device limits if needed
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

# --- Standardized Plot Generation and Save Calls with Subtitles ---
# 1. Accidents by Day of Week
# Bar chart showing the total number of accidents for each day of the week.
save_plot(df %>% 
            distinct(Accident_ID, DayOfWeek) %>%
            count(DayOfWeek) %>%
            ggplot(aes(x = DayOfWeek, y = n)) +
            geom_segment(aes(xend = DayOfWeek, yend = 0), color = colors[1], size = 1.2) + # Vertical lines from 0 to count
            geom_point(color = colors[1], size = 5) + # Points at the top of the lines
            labs(title = "Accidents by Day of Week", x = "Day", y = "Number of Accidents"),
          "01_temporal_dayofweek.jpg",
          subtitle = "Distribution of accidents across weekdays"
)

# 2. Hourly Distribution of Accidents
# Line plot showing the number of accidents per hour of the day, with a LOESS trend line.
hour_breaks <- 0:23
hour_labels <- sprintf("%02dh", hour_breaks) # Format hour labels (e.g., "00h", "01h")

save_plot(
  df %>%
    distinct(Accident_ID, Hour) %>%
    count(Hour) %>%
    ggplot(aes(x = Hour, y = n)) +
    geom_line(aes(color = "Accidents"), size = 1.2) + # Line for accident counts
    geom_point(aes(color = "Accidents"), size = 2) + # Points for each hour
    geom_smooth(aes(color = "Trend"), method = "loess", se = FALSE, linetype = "dashed", size = 1) + # LOESS trend line
    scale_x_continuous(breaks = hour_breaks, labels = hour_labels) +
    scale_color_manual( # Custom colors for lines
      name = NULL,
      values = c("Accidents" = colors[2], "Trend" = "#86868b")
    ) +
    labs(
      title = "Hourly Distribution of Accidents",
      x = "Hour of Day",
      y = "Accidents"
    ) +
    theme(legend.position = "bottom"), # Legend at the bottom
  "02_temporal_hourly.jpg",
  subtitle = "Number of accidents by hour (00:00–23:00)"
)

# 3. Monthly Trend of Accidents with Peaks
# Line plot showing monthly accident counts with highlighted peaks for each year.

# Prepare monthly counts
monthly_data <- df %>%
  distinct(Accident_ID, Date) %>%
  mutate(MonthYear = floor_date(Date, "month")) %>% # Group by month and year
  count(MonthYear) %>%
  mutate(
    year_val = year(MonthYear),
    month_val = month(MonthYear),
    month_label = ifelse(month_val == 1, # Label January with year for context
                         paste0("1\n", year_val),
                         as.character(month_val))
  )

# Identify peak months for each year
peak_months <- df %>%
  distinct(Accident_ID, Date) %>%
  mutate(Year = year(Date), MonthYear = floor_date(Date, "month")) %>%
  count(Year, MonthYear) %>%
  group_by(Year) %>%
  filter(n == max(n)) %>% # Filter for the month with max accidents per year
  ungroup() %>%
  mutate(
    MonthName = format(MonthYear, "%B"), # Full month name
    label = paste0(MonthName, " ", Year, "\nPeak: ", n) # Label for peaks
  )

# Calculate max y-value for plot padding
ymax <- max(monthly_data$n) * 1.12

# Generate and save the plot
save_plot(
  ggplot(monthly_data, aes(x = MonthYear, y = n)) +
    geom_line(aes(color = "Accidents"), size = 1.2) + # Line for monthly counts
    geom_point(aes(color = "Accidents"), size = 2) + # Points for monthly counts
    geom_smooth(aes(color = "Trend"), method = "loess", se = FALSE, # LOESS trend line
                linetype = "dashed", size = 1) +
    geom_point(data = peak_months, aes(x = MonthYear, y = n), color = "#8B0000", size = 3) + # Highlight peak points
    geom_text( # Label peak points
      data = peak_months,
      aes(x = MonthYear, y = n, label = label),
      vjust = -1.1, color = "#8B0000", size = 5, fontface = "bold"
    ) +
    scale_color_manual( # Custom colors for lines
      name = NULL,
      values = c("Accidents" = colors[2], "Trend" = "#86868b")
    ) +
    expand_limits(y = ymax) +  # Ensure top labels are not clipped
    scale_x_date( # Custom x-axis for dates
      breaks = monthly_data$MonthYear,
      labels = monthly_data$month_label,
      expand = c(0.01, 0.01),
      guide = guide_axis(angle = 0)
    ) +
    labs(
      title = "Monthly Trend of Accidents (2009–2012)",
      x = "Month",
      y = "Accidents"
    ) +
    theme_minimal(base_family = "Helvetica") + # Use minimal theme specifically for this plot
    theme(
      text = element_text(color = "#1d1d1f"),
      plot.title = element_text(size = 18, face = "bold", hjust = 0.5, margin = margin(b = 15)), # Centered title
      plot.subtitle = element_text(size = 14, hjust = 0.5, color = "#86868b", margin = margin(b = 15)), # Centered subtitle
      axis.title = element_text(size = 14, face = "bold"),
      axis.text = element_text(size = 12),
      axis.text.x = element_text(size = 10, vjust = 0.6),
      panel.grid.minor.x = element_blank(),
      legend.position = "bottom",
      legend.text = element_text(size = 12)
    ),
  filename = "03_temporal_monthly_peaks.jpg",
  subtitle = "Monthly evolution of accidents with peaks"
)

# 4. Accident Density Heatmap: Hour vs Day
# Heatmap visualizing the density of accidents across hours of the day and days of the week.
hour_breaks <- seq(0, 22, by = 2)  # Define breaks for every two hours

save_plot(
  df %>%
    distinct(Accident_ID, DayOfWeek, Hour) %>%
    count(DayOfWeek, Hour) %>%
    ggplot(aes(x = Hour, y = fct_rev(DayOfWeek), fill = n)) + # fct_rev to order days correctly
    geom_tile(color = "white") + # Create tiles, with white borders
    scale_x_continuous( # Custom x-axis for hours
      breaks = hour_breaks,
      labels = sprintf("%02d:00", hour_breaks) # Format as HH:00
    ) +
    scale_fill_gradient(low = "white", high = colors[2]) + # Color gradient for density
    labs(
      title = "Accident Density: Hour vs Day",
      x = "Hour",
      y = "Day of Week",
      fill = "Accidents"
    ) +
    guides(fill = guide_colorbar(barwidth = 10, barheight = 2)) + # Horizontal color bar
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1, size = 10), # Rotate x-axis labels
      legend.title = element_text(size = 16),
      legend.text = element_text(size = 10)
    ),
  "04_temporal_heatmap.jpg",
  subtitle = "Timeslots during the week when most accidents occur"
)


# 5. Geographic Distribution of Accidents (Density Map)
# A density map of accident locations, faceted by urban/rural setting, with a basemap.

# Prepare spatial data: unique accidents only, filter out NA and outside-France coordinates.
plot20_data <- df %>%
  distinct(Accident_ID, lat, long, Location) %>%
  filter(!is.na(lat), !is.na(long), between(lat, 41, 52), between(long, -5, 10))

if (nrow(plot20_data) > 0) { # Proceed only if there's data to plot
  plot20_sf <- st_as_sf(plot20_data, coords = c("long", "lat"), crs = 4326) # Convert to sf object
  
  # Fetch elegant basemap tiles from CartoDB Positron.
  france_map_tiles <- get_tiles(st_bbox(plot20_sf), provider = "CartoDB.Positron", zoom = 7)
  
  # Create the map plot
  france_map_plot <- ggplot(plot20_data, aes(x = long, y = lat)) +
    geom_spatraster_rgb(data = france_map_tiles) + # Add basemap tiles
    stat_density_2d( # 2D density estimation for accident hotspots
      aes(fill = after_stat(level)),
      geom = "polygon",
      alpha = 0.6,
      bins = 30
    ) +
    scale_fill_gradientn( # Color gradient for density, from light to dark red
      colors = c("#FF6F61", "#E53935", "#C62828", "#A80000", "#8B0000"),
      name = "Accident Density"
    ) +
    guides(fill = guide_colorbar( # Color bar for density
      barwidth = 10,
      barheight = 2
    )) +
    facet_wrap(~ Location) + # Facet by urban/rural location
    labs(
      title = "Geographic Distribution of Accidents",
      subtitle = "Density map of accident locations by urban/rural setting",
      x = "Longitude",
      y = "Latitude"
    ) +
    theme(
      legend.position = "right",
      strip.text = element_text(size = 13, face = "bold")
    )
  
  # Save the plot using the standardized save_plot function
  save_plot(
    france_map_plot,
    "05_temporal_map.jpg",
    width = 14,
    height = 8,
    subtitle = "Density map of accident locations by urban/rural setting"
  )
}


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
      x = "Accident Category",
      y = "Accident Count",
      fill = "Gender"
    ) +
    design_theme() +
    theme(axis.text.x = element_text(angle = 30, hjust = 1)),
  "06_demo_gender_category.jpg",
  subtitle = "Gender distribution of accident participants per category"
)


# 7. Driver Age Distribution by Category and Sex
save_plot(
  df %>%
    filter(between(Age,0,100),!is.na(Category), !is.na(Sex)) %>%
    ggplot(aes(x = Age, fill = Sex)) +
    geom_histogram(binwidth = 5, position = "identity", alpha = 0.6, color = "white") +
    facet_wrap(~ Category, scales = "free_y") +
    scale_fill_manual(values = colors[c(16, 9)]) +
    labs(
      title = "Driver Age Distribution by Category and Sex",
      x = "Driver Age",
      y = "Count",
      fill = "Gender"
    ) +
    design_theme(),
  "07_demo_age_hist_by_category_sex.jpg",
  subtitle = "Age distribution of accident participants by gender and category"
)



# 8. Age by Day of Week (Violin Plot)
# Violin plot showing the distribution of ages across different days of the week.
save_plot(
  df %>% filter(between(Age,0,100),!is.na(Age)) %>%
    ggplot(aes(x = DayOfWeek, y = Age, fill = DayOfWeek)) +
    geom_violin(trim = TRUE, alpha = 0.7) + # Violin plot showing density
    geom_boxplot(width = 0.1, outlier.shape = NA, alpha = 0.6, color = "black") + # Overlay boxplot (no outliers)
    scale_fill_manual(values = colors[1:7]) + # Fill colors for each day
    labs(title = "Age by Day of Week", x = "Day of Week", y = "Age", fill = "Day"),
  "08_demo_violin_age_day.jpg",
  subtitle = "How age varies across different weekdays"
)

# 9. Age by Hour of Day (Ridgeline Plot)
# Ridgeline plot illustrating the distribution of driver ages at each hour of the day.
save_plot(
  df %>% filter(between(Age,0,100),!is.na(Age)) %>%
    ggplot(aes(Age, factor(Hour), fill = stat(x))) + # Fill based on age value
    geom_density_ridges_gradient(scale = 3, rel_min_height = 0.01, alpha = 0.8) + # Ridgeline density plot
    scale_fill_gradient(low = colors[2], high = colors[1]) + # Gradient fill from red to blue
    labs(title = "Age by Hour of Day", x = "Age", y = "Hour", fill = "Density"),
  "09_demo_ridgeline_age_hour.jpg",
  subtitle = "Driver age distributions at each hour"
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
    labs(title = "Lighting in Accidents", x = "Count", y = "Lighting Type"),
  "11_cond_lighting.jpg",
  subtitle = "Accidents under various lighting conditions"
)


# 12. Surface Conditions
# Dot plot showing the count of accidents on different road surface conditions.
save_plot(
  df %>%
    distinct(Accident_ID, `Surface Condition`) %>%
    count(`Surface Condition`) %>%
    ggplot(aes(x = n, y = fct_reorder(`Surface Condition`, n))) + # Reorder by count
    geom_segment(aes(xend = 0, yend = `Surface Condition`), color = colors[3], size = 1.2) +
    geom_point(color = colors[3], size = 5) +
    geom_text(aes(label = scales::comma(n)), vjust = -1.2, color = "gray30", size = 5.5) +
    labs(title = "Surface Conditions", x = "Count", y = "Condition"),
  "12_cond_surface.jpg",
  subtitle = "Distribution of road surface states"
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
      x = "Count",
      y = "Holiday"
    ) +
    theme(legend.position = "none") + # No legend
    expand_limits(x = max(holiday_counts$n) * 1.08),  # Prevent label cutoff
  "13_cond_holiday.jpg",
  subtitle = "Accidents reported during public holidays"
)

# 14. Infrastructure Involvement
# Dot plot showing accident counts by infrastructure type.
save_plot(
  df %>%
    distinct(Accident_ID, Infrastructure) %>%
    count(Infrastructure) %>%
    ggplot(aes(x = n, y = fct_reorder(Infrastructure, n))) +
    geom_segment(aes(xend = 0, yend = fct_reorder(Infrastructure, n)), color = colors[6], size = 1.2) +
    geom_point(color = colors[6], size = 5) +
    geom_text(aes(label = scales::comma(n)), vjust = -1.2, color = "gray30", size = 5.5) +
    labs(
      title = "Infrastructure Involvement",
      x = "Accident Count",
      y = "Type"
    ),
  "14_cond_infra.jpg",
  subtitle = "Accidents involving different infrastructure types"
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


# 16. Injury Severity Distribution
# Dot plot showing the count of accidents for each injury severity level.
save_plot(
  df %>% count(`Injury Severity`) %>%
    ggplot(aes(x = n, y = fct_reorder(`Injury Severity`, n), color = `Injury Severity`)) + # Reorder and color by severity
    geom_segment(aes(xend = 0, yend = fct_reorder(`Injury Severity`, n)), size = 1.2) +
    geom_point(size = 5) +
    geom_text(aes(label = scales::comma(n)), vjust = -1.2, color = "gray30", size = 5.5) +
    scale_color_manual(values = injury_colors) + # Use predefined injury colors
    labs(title = "Injury Severity Distribution", x = "Count", y = "Severity", color = "Injury Severity"),
  "16_outcomes_severity.jpg",
  subtitle = "Severity levels recorded in accident reports"
)

# --- 17a. Severity by Lighting Condition (Final Bubble Plot with Labels) ---
# Bubble plot showing injury severity under surface conditions.
# Bubble size and number label denote incident count.

save_plot(
  ggplot(df %>%
           filter(!is.na(`Lighting Conditions`), !is.na(`Injury Severity`)) %>%
           count(`Lighting Conditions`, `Injury Severity`),
         aes(x = fct_infreq(`Lighting Conditions`), y = `Injury Severity`, size = n, color = `Injury Severity`)) +
    geom_point(alpha = 0.7) +  # Bubbles
    geom_text(aes(label = n), size = 5, color = "gray50", vjust = -3) +  # Labels above bubbles
    scale_color_manual(values = injury_colors) +  # Custom color for severity
    scale_size_continuous(range = c(5, 25), guide = "none") +  # Bigger bubbles, no size legend
    labs(
      title = "Severity by Lighting Conditions",
      x = "Lighting Conditions",
      y = "Injury Severity",
      color = "Severity"
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
           count(`Surface Condition`, `Injury Severity`),
         aes(x = fct_infreq(`Surface Condition`), y = `Injury Severity`, size = n, color = `Injury Severity`)) +
    geom_point(alpha = 0.7) +  # Bubbles
    geom_text(aes(label = n), size = 5, color = "gray50", vjust = -3) +  # Labels above bubbles
    scale_color_manual(values = injury_colors) +  # Custom color for severity
    scale_size_continuous(range = c(5, 25), guide = "none") +  # Bigger bubbles, no size legend
    labs(
      title = "Severity by Surface Condition",
      x = "Surface Condition",
      y = "Injury Severity",
      color = "Severity"
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
  df %>% filter(between(Age,0,100),!is.na(Age), !is.na(`Injury Severity`)) %>%
    ggplot(aes(x = Age, y = `Injury Severity`, fill = `Injury Severity`)) +
    geom_density_ridges(scale = 2, alpha = 0.7, color = "white", size = 0.3) + # Ridgeline density plot
    scale_fill_manual(values = injury_colors) + # Use predefined injury colors for fill
    labs(title = "Age by Injury Severity", x = "Age", y = "Severity", fill = "Injury Severity"),
  "18_outcomes_ridge_age.jpg",
  subtitle = "Distribution of injury types across ages"
)

# 19. Severity by Vehicle Category (Stacked Bar Chart)
# Stacked bar chart showing the proportion of different injury severities per vehicle type.
save_plot(
  df %>%
    filter(!is.na(`Vehicle Category`), !is.na(`Injury Severity`)) %>%
    count(`Vehicle Category`, `Injury Severity`) %>%
    group_by(`Vehicle Category`) %>%
    mutate(prop = n / sum(n)) %>% # Calculate proportion within each vehicle category
    ggplot(aes(x = `Vehicle Category`, y = prop, fill = `Injury Severity`)) +
    geom_bar(stat = "identity", position = "fill") + # Stacked bar, normalized to 1 (proportion)
    scale_fill_manual(values = injury_colors) + # Use predefined injury colors
    labs(
      title = "Severity by Vehicle Category",
      x = "Vehicle Type",
      y = "Proportion",
      fill = "Injury Severity"
    ) +
    scale_x_discrete( # Wrap long vehicle category labels and angle them
      labels = function(x) stringr::str_wrap(x, width = 25),
      guide = guide_axis(angle = 45)
    ),
  filename = "19_outcomes_vehicle_severity.jpg",
  subtitle = "Proportion of severity per vehicle type"
)

# 20. Equipment Usage
# Dot plot showing the frequency of different safety equipment usage types in accidents.
save_plot(
  df %>% count(`Equipment Usage`) %>%
    ggplot(aes(x = n, y = fct_reorder(`Equipment Usage`, n))) +
    geom_segment(aes(xend = 0, yend = `Equipment Usage`), color = colors[5], size = 1.2) +
    geom_point(color = colors[5], size = 5) +
    geom_text(aes(label = scales::comma(n)), vjust = -1.2, color = "gray30", size = 5.5) +
    labs(title = "Safety Equipment Usage", x = "Count", y = "Usage Type"),
  "20_behavior_equipment.jpg",
  subtitle = "Frequency of safety equipment usage"
)

# 21. Travel Purpose
# Dot plot showing accident counts by reported reason for travel.
save_plot(
  df %>% count(`Travel Reason`) %>%
    ggplot(aes(x = n, y = fct_reorder(`Travel Reason`, n))) +
    geom_segment(aes(x = 0, xend = n, y = `Travel Reason`, yend = `Travel Reason`),
                 color = colors[4], size = 1.2) +
    geom_point(color = colors[4], size = 5) +
    geom_text(aes(label = scales::comma(n)), vjust = -1.2, color = "gray30", size = 5.5) +
    labs(title = "Travel Purpose", x = "Count", y = "Reason"),
  "21_behavior_travel.jpg",
  subtitle = "Reported reason for travel during accident"
)

# 22. Collision Types
# Dot plot showing the distribution of different types of collisions.
save_plot(
  df %>%
    distinct(Accident_ID, `Type of collision`) %>%
    count(`Type of collision`) %>%
    ggplot(aes(x = n, y = fct_reorder(`Type of collision`, n))) +
    geom_segment(aes(xend = 0, yend = `Type of collision`), color = colors[6], size = 1.2) +
    geom_point(color = colors[6], size = 5) +
    geom_text(aes(label = scales::comma(n)), vjust = -1.2, color = "gray30", size = 5.5) +
    labs(
      title = "Collision Types",
      x = "Accident Count",
      y = "Type"
    ),
  "22_behavior_collision.jpg",
  subtitle = "Distribution of collision types"
)


# 23. Vehicles Involved
# Bar chart showing the counts of different vehicle types involved in accidents.
save_plot(
  df %>%
    distinct(Accident_ID, `Vehicle Category`) %>%
    count(`Vehicle Category`) %>%
    ggplot(aes(x = n, y = fct_reorder(`Vehicle Category`, n))) +
    geom_col(fill = colors[1]) + # Column chart
    geom_text(aes(label = scales::comma(n)), hjust = -0.08, color = "gray30", size = 3.5) + # Count labels
    labs(title = "Vehicles Involved", x = "Count", y = "Vehicle Type"),
  "23_behavior_vehicle.jpg",
  subtitle = "Types of vehicles involved in incidents"
)


# 24. Injury Severity by Safety Equipment Usage (Stacked Bar Chart)
# Stacked bar chart showing the proportion of injury levels across different safety equipment usage categories.
save_plot(
  df %>%
    filter(!is.na(`Injury Severity`), !is.na(`Equipment Usage`)) %>%
    count(`Equipment Usage`, `Injury Severity`) %>%
    group_by(`Equipment Usage`) %>%
    mutate(prop = n / sum(n)) %>% # Calculate proportion within each equipment usage category
    ggplot(aes(x = `Equipment Usage`, y = prop, fill = `Injury Severity`)) +
    geom_bar(stat = "identity", position = "fill") + # Stacked bar, normalized to 1
    scale_fill_manual(values = injury_colors) + # Use predefined injury colors
    labs(
      title = "Injury Severity by Safety Equipment Usage",
      x = "Equipment Usage",
      y = "Proportion of Accidents",
      fill = "Injury Severity"
    ),
  "24_equipment_vs_severity.jpg",
  subtitle = "Proportion of injury levels across usage categories"
)

message("All static plots generated.")

# --- Animated Plot Section ---

# --- Animated Plot Section (Adjusted for Unique Accident IDs) ---

# Load required libraries for animations.
library(gganimate) # For creating animations with ggplot2
library(gifski)    # A GIF renderer for gganimate
library(av)        # An alternative video renderer for gganimate

# --- Global Animation Settings ---
fps <- 30         # Frames per second for animations
end_pause <- 15   # Duration (in seconds) to pause at the final frame
width <- 14       # Width of the animation output
height <- 8       # Height of the animation output
res <- 300        # Resolution (DPI) for the animation
gif_dir <-"C:/Users/steli/Stelios/DS AUEB/Trimester 3/Data Visualization/Project 2/FranceRoadAccidents/R plots/gifs"# Directory to save GIF outputs
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

# --- NEW: Create a distinct set of MonthYear and month_label for axis breaks and labels ---
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

# --- 4. Heatmap Animation ---
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

message("All animated plots generated.")

