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

# ----------------- Writing list to multiple files ----------------------

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
       
#------------------------------- ggplot colors  ------------------- 
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



#------------------------------- BROOMING ------------------- 
# TT snippet -- same as above.
library(broom)
cuisine_conf_ints <- by_dba %>%
  add_count(cuisine) %>%
  filter(n > 100) %>%
  nest(-cuisine) %>%
  mutate(model = map(data, ~ t.test(.$avg_score))) %>%
  unnest(map(model, tidy))


# Widening data and PCA -- see the widyr package - https://github.com/dgrtwo/widyr

#------------------------------- Regular Expressio ------------------- 
# https://www.jumpingrivers.com/blog/regular-expressions-every-r-programmer-should-know/
library(stringr)
# \ (backslash) is a metacharacter, have to escape it to search for it --> "\\"
str_subset(dir(file.path(datapath)), "\\.csv")

# ^ and the $
# Use the ^ to indicate the start of line and $ to indicate the end of a line
rm(list = ls(pattern = "*_in$")) # - removing dataframes/objects that end in "_in"



