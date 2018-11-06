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

# Convert values to na
k <- c("a", "b", "", "d")
na_if(k, "")

# Print a list of names to the screen in a 
dput(names(shocks))

#------------------------------- Purrr chunks  -------------------
# https://www.hvitfeldt.me/2018/01/purrr-tips-and-tricks/

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


#------------------------------- Data Table chunks  -------------------






