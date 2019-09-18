# Chunks of regex that seem useful or have been useful in the past.

library(stringr)

# Notes - case matters when searching for names. Use the ignore case option w/ str_detect.  

# Search for four consecutive numbers
str_extract(string = string_object, "[0-9][0-9][0-9][0-9]")

# "\\d" can be used as a shortcut
str_extract(string = string_object, "\\d|4")

# Search for AAAS OR a hyphen; paratheses act as a grouping and are not searched; To search them they need to be escaped \\(
str_extract(string = string_object, pattern = "(AAAS)|-") 

# Anchors ("^") - beginning of the line; ("$") end of a line. First you get the power, then you get the money.

# extract first four digits at the beginning of a line
str_extract(string = string_object, "^\\d|{4}")

# extract last four digits at end of text
str_extract(string = string_object, "\\d|{4}$")

# Search both beginning and end
str_extract(string = string_object, "^\\d|{4}$")

# Can use str_replace_all to replace all numbers w/ a value
str_replace_all(string = string_object, pattern = "\\d", replacement = "desired value")
