# Random snippets of code I'm looking for at various times -- consolidated in a single place.

# Akin to Stata's isid command inside dplyr
# Checking for uniqueness using var1 and var2
x2 = distinct(df, var1, var2, .keep_all= TRUE)

# dropping vars from a data frop (like drop)
select(df, -var1, var2)

drop_vars <- c("var1", "var2")
select(df, -one_of())










