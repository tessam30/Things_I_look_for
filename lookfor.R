# Random snippets of code I'm looking for at various times -- consolidated in a single place.

# Useful resources: 
# https://www.listendata.com/2016/08/dplyr-tutorial.html
# 

# Akin to Stata's isid command inside dplyr
# Checking for uniqueness using var1 and var2

#------------------------------- Dplyr chunks  -------------------
x2 = distinct(df, var1, var2, .keep_all= TRUE)

# Count the number of distinct values taken by a set of variables
df %>% group_by(var1, var2) %>% n_groups()

# Create a unique ID based on a grouping - two step process
# Akin to Stata egen = group(var1, var2)
shk_df %>% 
   mutate(id_tmp = interaction(clid, hhid)) %>% 
   mutate(id = group_indices(., id_tmp))

# Create a sequential id based on a order in dataset
df %>% arrange(id1, id2) %>% mutate(id = row_number())

# Equivalent of inrange in Stata inrange(var, 3, 5)
df %>% filter(between(var2, 3, 5))

# dropping vars from a data frop (like drop)
select(df, -var1, var2)

drop_vars <- c("var1", "var2")
select(df, -one_of())

#Reorder variables in a data frame
df2 <- select(df, var1, var2, everything())

# rename syntax
rename(data , new_name = old_name)

# filter with negations
mydata10 = filter(df, !var1 %in% c("A", "C"))

# using grepl - look for records where the State varaible contains "Ar"
mydata10 = filter(df, grepl("Ar", State))

# Summarise over variables - creating 3 new calcuations for each variable
summarise_at(df, vars(var1, var2), funs(n(), mean, median))

# Summarise if removing NAs
starwars %>% summarise_if(is.numeric, mean, na.rm = TRUE)


# Convert values to na
k <- c("a", "b", "", "d")
na_if(k, "")

# Print a list of names to the screen in a 
dput(names(shocks))

# Lags and Leads
df %>%
  mutate(prv_year_absorb = lag(Variable_to_lag, n = 1, order_by = year), 
         absorb_delta = Variable_to_lag - prv_year_absorb)

#------------------------------- Purrr chunks  -------------------
# https://www.hvitfeldt.me/2018/01/purrr-tips-and-tricks/

# Convert each element of a list into objects
list2env(my_list ,envir=.GlobalEnv)

##### Subsetting elements in a list
# Convert an element from a list to a data.frame, retaining names
geo_cw <- map_df(df_wash[6], `[`)

# can also use pluck
test <- df_wash %>% pluck(6)

# Batch load excel sheets
# First, set the read path of the where spreadsheet lives
read_path <- file.path(datapath, "KEN_WASH_2018_tables.xlsx")

# Write everything into a list
df_wash <- excel_sheets(read_path) %>%
  set_names() %>%
  map(read_excel, path = read_path)

# Or, write everything to separate objects
read_path %>%
  excel_sheets() %>% 
 # Use basename with the file_path_sans_ext to strip extra info; Not NEEDED
 # set_names(nm = (basename(.) %>% tools::file_path_sans_ext())) %>%
  set_names() %>%
  map(~read_excel(path = read_path, sheet = .x), .id = "sheet") %>%
  
  # Use the list2env command to convert the list of dataframes to separate dfs using 
  # the name provided by the set_names(command). Necessary b/c not all the sheets are the same size
  list2env(., envir = .GlobalEnv)


# Using fs and purrr to read in directory of files
res <- path(pathname) %>% dir_ls(regexp = "texttoregex.csv") %>% map_df(read_csv, .id = "filename")

# Read all files in a folder, place in a single dataframe
fd <- list.files("folder", pattern = "*.csv", full.names = TRUE) %>%
       purrr:map_df(f, readr::read_csv, .id = "id")


# Loop over columns and summarise stuff
df %>% 
  select(`Education Strategy Area(s)`:`Research Approach`) %>% 
  map(tab_that)

# ----------------- Writing list to multiple files ----------------------

# Put a pattern of objects into a single list
graph_list <- mget(ls(pattern = "gph"))


datalist <- list(impr_sanit  = impr_sanit, 
               unimp_sanit   = unimp_sanit,
               impr_h20      = impr_h20,
               unimpr_h20    = unimpr_h20, 
               waste         = waste) 

datalist %>%  
  names() %>% 
  map(., ~ write_csv(datalist[[.]], file.path(washpath, str_c(., ".csv"))))




#------------------------------- Tidy Eval  -------------------
# https://dplyr.tidyverse.org/articles/programming.html
# https://edwinth.github.io/blog/dplyr-recipes/ - recipes for basic use

# quo returns a quosure
# First quo, then !!
my_var <- quo(a)
summarise(df, mean = mean(!! my_var), sum = sum(!! my_var), n = n())

# For functions, use enquo and !! within
my_summarise2 <- function(df, expr) {
  expr <- enquo(expr)

  summarise(df,
    mean = mean(!! expr),
    sum = sum(!! expr),
    n = n()
  )
}

# Create new variable names bsed on expr
my_mutate <- function(df, expr) {
  expr <- enquo(expr)
  mean_name <- paste0("mean_", quo_name(expr))
  sum_name <- paste0("sum_", quo_name(expr))

  mutate(df,
    !! mean_name := mean(!! expr),
    !! sum_name := sum(!! expr)
  )
}

# Need three things to capture multiple variables for group_by
# 1. use the ... in the function definition to capture any number of arguments
# 2. use quos(...) to capture the ... as a list of formulas
# 3. use !!! to splice the arguments into the group_by command


# New format example {{ }}

bplot_sort <- function(df, x = County, y = value, wrap = type, ctitle = "NA", rows = 2) {

  cpt <- df %>% select(source) %>% unique()
  
  df %>%
    mutate(indicator_sort = fct_reorder( {{ wrap }}, {{ y }}, .desc = TRUE),
           County_sort = reorder_within( {{ x }}, {{ y }}, {{ wrap }} )) %>% 
    ggplot(aes(y = {{ y }}, x = County_sort)) +
    geom_col(fill = "#949494") + 
    coord_flip() +  
    scale_x_reordered() +
    scale_y_continuous(label = percent_format(accuracy = 1)) +
    facet_wrap(vars(indicator_sort), scales = "free_y", nrow = rows) +
    theme_minimal() +
    labs(x = "", y = "",
         title = ctitle, 
         caption = str_c("Source: ", cpt)) +
    theme(strip.text = element_text(hjust = 0),
          axis.text.y = element_text(size = 8))
}


#------------------------------- Case When  -------------------

df %>% mutate(age = case_when(
    age_range == "population"      ~ "All",
    age_range == "population_0_17" ~ "0_17",
    age_range == "population_0_5"  ~ "0_5",
    age_range == "population_6_13" ~ "6_13",  
  TRUE ~ "14_17" # -- sets any other value as 14_17
  ))

# With GREP

case_when(
  grepl("Windows", os) ~ "Windows-ish",
  grepl("Red Hat|CentOS|Fedora", os) ~ "Fedora-ish",
  grepl("Ubuntu|Debian", os) ~ "Debian-ish",
  grepl("CoreOS|Amazon", os) ~ "Amazon-ish",
  is.na(os) ~ "Unknown",
  ELSE ~ "Other"
) 

# standard example
 case_when(
  x %% 35 == 0 ~ "fizz buzz",
  x %% 5 == 0 ~ "fizz",
  x %% 7 == 0 ~ "buzz",
  TRUE ~ as.character(x)
)
       
#------------------------------- ggplot colors and plots ------------------- 
# Use scale_fill_gradientn when you want to set a balanced divergent palette

# Define your max value in an object (here called shock_dev_max)
shock_dev_max = unlist(shock_stats_county %>% summarise(max_dev = max(abs(shock_dev))))

 df_spatial %>% ggplot() +
    geom_sf(aes(fill = shock_dev), colour = "white", size = 0.5) +
    scale_fill_gradientn(colours = RColorBrewer::brewer.pal(11, 'PiYG'),
                         limits = c(-1 * shock_dev_max, shock_dev_max), 
                         labels = scales::percent) + ...

# For color brewer scale_fill_brewer and scale_colour_brewer are for categorical data
# Use scale_fill_distiller or scale_color_distiller for continuous data. 
# If the aesthetics are fill = x then use former, if colour = x, then latter

# Scales -- show only major numbers on percentage scale
# add chunk below to ggplot call
scale_y_continuous(labels = scales::percent_format(accuracy = 1))

# To generate new colors
colorRampPalette(RColorBrewer::brewer.pal(11,"Spectral"))(30) %>% knitr::kable(format = "rst")
# in Atom command+D will do cursor highlighting down

# To preview palettes
palette(colorRampPalette(brewer.pal(11,"Spectral"))(30))
plot(1:30, 1:30, col = 1:30, pch = 19, cex = 5)

# Plotting reference bars
# When plotting geom_rect (reference bars), ggplot will plot a copy of each bar for each row in a dataframe
# This is incredibly annoying when you want to decrease the opacity or edit the reference bars in inkscape / AI
# To get around this problem, pipe in the first row the data frame you are plotting to the geom_rect call
# link: https://stackoverflow.com/questions/17521438/geom-rect-and-alpha-does-this-work-with-hard-coded-values; 
# Example below from the Kenya Middle and Upper Arm Circumference data at the county level
muac_malnut %>% 
  filter(county %in% c("Turkana", "Marsabit", "Isiolo", "Samburu")) %>% 
  group_by(county) %>% 
  mutate(mean = mean(value, na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(county_sort = fct_reorder(county, mean, .desc = TRUE)) %>%
  ggplot(aes(x = date, y = value)) +
  geom_ribbon(aes(ymin = 0.15, ymax = 0.4), 
              data = , fill = "#d6604d", alpha = 0.20) +
  geom_ribbon(aes(ymin = 0, ymax = 0.15), 
              data = , fill = "#4393c3" , alpha = 0.20) +
  geom_rect(data = muac_malnut[1, ], ymin = 0, ymax = .4,
            xmin = as.Date("2009-01-01"), xmax = as.Date("2010-01-01"),
            fill = "#fdfbec", alpha = 0.33) +
  geom_rect(data = muac_malnut[1, ], ymin = 0, ymax = .4,
            xmin = as.Date("2011-01-01"), xmax = as.Date("2012-01-01"),
            fill = "#fdfbec", alpha = 0.33) +
  geom_rect(data = muac_malnut[1, ], ymin = 0, ymax = .4,
            xmin = as.Date("2017-01-01"), xmax = as.Date("2018-01-01"),
            fill = "#", alpha = 0.33) +
  geom_smooth(colour = "#", span = span, alpha = 0.5, size = 0.25) +
  geom_line(colour = grey70K) +

#Sort each facet within a facet wrapped graph. Need tidytext.
fertility_plot <- gha_df$Fertility_Region %>% 
  mutate(Region_sort = fct_reorder(Region, `adolescent birth rate`),
         reg_color = ifelse(Region == "National", '#80cdc1', grey30K)) %>% 
  gather("indicator", "value", `adolescent birth rate`:`demand for family planning`) %>% 
  mutate(indicator_sort = fct_reorder(indicator, value, .desc = TRUE),
         region_sort2 = reorder_within(Region, value, indicator)) %>% 
  ggplot(aes(y = value, x = region_sort2, fill = reg_color)) +
  coord_flip() + geom_col() +
  scale_x_reordered() +
  facet_wrap(~indicator_sort, scales = "free") +
  scale_fill_identity() +
  theme_line +
  theme(panel.spacing = unit(1, "lines")) +
  y_axix_pct + 
  labs(title = "Family planning and birth rates by region",
       subtitle = "Note free scales to accomodate indicator ranges",
       x = "", y = "",
       caption = "Source: 2017 Multiple Indicator Cluster Survey (MICS)")


# move facets left
theme(strip.text = element_text(hjust = 0, size = 10)

# Filter a single dataframe multiple times within a function
 parity_plot <- function(df, sub_filt = "Mathmatics", yearfilt = "2018-2019") {
  df %>% 
    filter(Subject == {{sub_filt}} & year == {{yearfilt}}) %>% 
    filter(Subgroup != "White") %>% 
    #filter(option_flag == 1) %>% 
    mutate(school_sort = reorder_within(school_name, -op_gap, Subgroup)) %>% 
    {# By wrapping ggplot call in brackets we can control where the pipe flow enters (df)
      # This allows us to use filters within the ggplot call
      ggplot() +
        geom_abline(intercept = 0, slope = 1, color = non_ats, linetype = "dotted") +
        #geom_polygon(data = df_poly, aes(-x, -y), fill="#fde0ef", alpha=0.25) +
        geom_point(data = dplyr::filter(., school_name != "Arlington Traditional"),
                   aes(y = value, x = benchmark, fill = ats_flag_color),
                   size = 4, shape = 21, alpha = 0.75, colour = "white") +
        geom_point(data = dplyr::filter(., school_name == "Arlington Traditional"),
                   aes(y = value, x = benchmark, fill = ats_flag_color),
                   size = 4, shape = 21, alpha = 0.80, colour = "white") +
        facet_wrap(~Subgroup,
                   labeller = labeller(groupwrap = label_wrap_gen(10))) +
        coord_fixed(ratio = 1, xlim = c(40, 100), ylim = c(40, 100)) +
        scale_fill_identity() +
        theme_minimal() +
        labs(x = "benchmark test value", y = "Subgroup test value",
             title = str_c(sub_filt, " opportunity gap across subgroups (ATS in blue) for ", yearfilt),
             subtitle = "Each point is a school -- points below the 45 degree line indicate an opportunity gap") +
        theme(strip.text = element_text(hjust = 0))
    }
}
     

# Creating plots in a nested data frame and writing them to a file
# Loop over plots by category, saving resulting plots in a grouped / nested dataframe
# extract the nested plots by calling the appropriate position of the nested plot
plots <- 
  gov %>% 
  group_by(Category) %>% 
  nest() %>% 
  mutate(plots = map2(data, Category, 
                      ~gov_plot(.) + labs(x = "", y = "",
                      title = str_c("Category ", Category, ": Governance scores for community fish refuges"),                      
        caption = "Source: 2016 Rice Field Fishery Enhancement Project Database: Governance Scores Module")))
         
plots$plots[2]

map2(file.path(imagepath, paste0("Category ", plots$Category,  
                                 ": Governance scores for community fish refuges.pdf")), 
     plots$plots,
     height = 8.5, 
     width = 11,
     dpi = 300, 
     ggsave)


#-------------------------------- Plot specific -----------------------------

# When plotting a heatmap, you can pass the label option through the scale_X_XX part. This allow
# for formatting of percentages on the scale
... + scale_fill_viridis_c(direction = -1, alpha = 0.90, option = "A", label = percent_format(accuracy = 2)) + ...

# Change the width of the legend
... + theme(legend.position = "top",
        legend.key.width = unit(2, "cm")) +

# Add captions
... + labs(caption = "text to add") +...

# Add titles to plots based on text/vars passed through tidy eval
 xvar = enquo(x) ...
...      labs(caption = "GeoCenter Calculations from MSME 2016 Report",
           title = (gsub("`", "", {rlang::quo_text(xvar)})))
 



#------------------------------- listing things ------------------- 
# List all the functions in a package
ls(package:stringr)

# Listing everything in the workspace
mget(ls())
ls.str()

# Get a list of attached packages and paths
search()
searchpaths()

#------------------------------- Searching strings ------------------- 
# Use str_detect to quickly search through strings for key words
str_detect(var, "string to detect")

# For filtering (can also use for binary mutates)
df %>% filter(str_detect(var, "string"))

# Remove paratheses (from Tidy Tuesday w/ DROB - https://github.com/dgrtwo/data-screencasts/blob/master/nyc-restaurants.Rmd)
cuisine_conf_ints %>%
  mutate(cuisine = str_remove(cuisine, " \\(.*"),
         cuisine = fct_reorder(cuisine, estimate))

str_remove("text (with some markes here)", "\\(*")

#------------------------------- Dates  ------------------- 
# https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2018-10-23/movie_profit.csv
# https://github.com/dgrtwo/data-screencasts/blob/master/movie-profit.Rmd
mutate(release_date = as.Date(parse_date_time(release_date, "%m!/%d/%Y")))


#------------------------------- Counts ------------------- 
df %>% count(var1, var2, sort = TRUE)T



#------------------------------- BROOMING & Models ------------------- 
# TT snippet -- same as above.
library(broom)
cuisine_conf_ints <- by_dba %>%
  add_count(cuisine) %>%
  filter(n > 100) %>%
  nest(-cuisine) %>%
  mutate(model = map(data, ~ t.test(.$avg_score))) %>%
  unnest(map(model, tidy))


# Fitting a natural spline - from Bridges Tidy Tuesday
model <- bridges %>%
         mutate(good = bridge_condition == "Good") %>% 
glm(y ~ ns(x, 4) + indicator_var, data = ., family = "binomial")

# Widening data and PCA -- see the widyr package - https://github.com/dgrtwo/widyr

#------------------------------- Regular Expression ------------------- 
# https://www.jumpingrivers.com/blog/regular-expressions-every-r-programmer-should-know/
library(stringr)
# \ (backslash) is a metacharacter, have to escape it to search for it --> "\\"
str_subset(dir(file.path(datapath)), "\\.csv")

# ^ and the $
# Use the ^ to indicate the start of line and $ to indicate the end of a line
rm(list = ls(pattern = "*_in$")) # - removing dataframes/objects that end in "_in"

# remove everything after a string
df %>% mutate(school_name = str_to_title(school_name) %>% str_remove_all(., "Elem.*"))


#------------------------------- Purrr'ing ------------------- 
# Split on a group, peform action across all subgroups
mtcars %>% 
  split(.$cyl) %>% 
  map(., ~ggplot(., aes(mpg, hp)) + geom_point())
      
 
# Read a batch of files in and give them names      
access_files <- list.files(file.path(datapath, "RFFI_Data"), pattern = ".xlsx")
access_path <- "Data/RFFI_Data"


fish <- map(as.list(access_files), ~read_excel(file.path(access_path, .)))
names(fish) <- as.list(access_files) %>% set_names()      
      
      
      

# ----------------------------- multi-line cursor --------------
# `control` + `option` plus up or down

# ----------------------------- System or packages loaded --------
 sessionInfo()
(.packages())

# ----------------------------- Working with dates --------
# Create a date from year, month and day
flights %>% mutate(date = make_date(year, month, day))
flights %>% mutate(wday = wday(date, label = TRUE))

# Create a decade variable using the 10 * *(X %/% Y) code 
 economics %>% mutate(year = year(date), decade = 10 * (year %/% 10)) %>% count(year, decade) %>% print(n = Inf)


# ----------------------------- Models -------- 
mod <- MASS::rlm(n ~ wday * ns(date, 5), data = daily) # for natural splines
