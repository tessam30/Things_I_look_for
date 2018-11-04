# Random snippets of code I'm looking for at various times -- consolidated in a single place.

# Useful resources: 
# https://www.listendata.com/2016/08/dplyr-tutorial.html
# 

# Akin to Stata's isid command inside dplyr
# Checking for uniqueness using var1 and var2
x2 = distinct(df, var1, var2, .keep_all= TRUE)

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









