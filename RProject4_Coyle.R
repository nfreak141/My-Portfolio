# R Mini-Project 4
# Christian Coyle

# Remember to set your working directory to wherever you saved the CSV files!
setwd("~/R/graveyard_data")

# Load the required libraries
library(tidyverse) # To read the csv and manipulate strings
library(lubridate) # To manipulate dates

# Make a few decision about your final dataset.
# Document your decisions in the code.
# 1. Decide what features (variables) you want in your dataset (e.g. FirstName, LastName, DoB, 
#  DoD, Sex)
#   Do you want to have MiddleName or not?
# 2. Do you want to represent Sex as 'male'/'female' or 'm'/'f'?
# 3. Decide what you will do with missing values.
#   Do you want to keep observations with no DOB? No DOD? Obviously wrong dates?
#   If you keep them, how will you handle them?
#   If you delete them, are you introducing a bias?
# Note: Document all of your code so that a reader knows what you are doing on each line.

# Read the first csv file named halloween2019a.csv
h1 <- read_csv('halloween2019a.csv')
h1new <- h1
# The first dataset has a MiddleName but no column for Sex

# ** Decide if you want to keep MiddleName or not.
#     If you are not keeping MiddleName, delete the column

# ** Convert DOB and DOD to date fields
h1new$DOB <- parse_date_time(h1$DOB, c("mdy", "y"))
h1new$DOD <- parse_date_time(h1$DOD, c("mdy", "y"))

h1new <- h1new %>% mutate(DOB = parse_date_time(DOB, c("mdy", "y")), 
                          DOD = parse_date_time(DOD, c("mdy", "y")))

# ** Add a column for Sex with every observation set to NA
h1new$Sex <- NA

# Read the first csv file named halloween2019a.csv
h2 <- read_csv('halloween2019b.csv')

# The second dataset has no MiddleName

# ** If you decided to keep MiddleName, create a column in h2 for MiddleName, 
h2new <- add_column(h2, MiddleName = NA, .after = "FirstName")

# # ** Convert the observations of Sex to your format (i.e. male/female or m/f)

h2new$Sex <- str_to_lower(str_sub(h2new$Sex,1,1))

h2new <- h2new %>% mutate(DOB = parse_date_time(DOB, c("mdy", "y")), 
                          DOD = parse_date_time(DOD, c("mdy", "y")))

# Read the first csv file named halloween2019a.csv
h3 <- read_csv('halloween2019c.csv')

# The third dataset has Name as one field instead of three (or two)
# Some of the dates may cause problems

h3new <- separate(h3, Name, c("FirstName", "MiddleName", "LastName"))

# ** Correct the DOB and DOD to appropriate dates

h3new <- h3new %>% mutate(DOB = parse_date_time(DOB, c("mdy", "y")),
                          DOD = parse_date_time(DOD, c("mdy", "y")))

# ** If necessary, convert the observations of Sex to your format (i.e. male/female or 
#   m/f)

h3new$Sex <- str_to_lower(str_sub(h3new$Sex,1,1))

# ** Combine your three corrected datasets into one master dataset
# Your three corrected datasets SHOULD have the exact same column names
# You might have to rename columns in h1, h2, or h3 
#  e.g, "FirstName", "MiddleName" (optional), "LastName", "DOB", "DOD", "Sex" 
# If one dataset has First_Name and another one has FirstName, R will assume they are 
#  different!
# ** Replace h1, h2, h3 with the names you use for your corrected datasets
lifespan <- bind_rows(mutate_all(h1new, as.character), 
                      mutate_all(h2new, as.character), 
                      mutate_all(h3new, as.character))

# the middle name is messing with our data a bit. going to need to isolate it and delete 
#  it.
# this line of code cleans the dataset of duplicates, gets rid of the middlenames of,
# ensures that we have no middle names in our dataset, and ensures that the first letter
# of the first and last names are capitalized

lifespan <- lifespan %>% 
  separate(FirstName, c("FirstName","MiddleName")) %>%
  select(-MiddleName) %>%
  mutate(FirstName = str_to_title(FirstName), 
         LastName = str_to_title(LastName)) %>%
  distinct() %>% 
  mutate(DOB = as.Date(DOB), DOD = as.Date(DOD)) %>%
  subset(DOB < DOD) %>%
  na.omit()

# use this data to find who on average lives longer
i <- interval(ymd(lifespan$DOB), ymd(lifespan$DOD))
lifespan$age <- time_length(i, "year") 
lifespan <- lifespan %>% filter(age <= 100)

# now I will work to get the mean and median
aggregate(lifespan$age, list(lifespan$Sex), mean)
aggregate(lifespan$age, list(lifespan$Sex), median)

# it seems that given these values, women DO tend to live longer than men

# plot to see average age over time
ggplot(lifespan, aes(DOD, age)) + 
  geom_point() + 
  geom_smooth()

# I read somewhere that those who were married tend to live longer then unmarried people
# testing to see if the data corresponds to that

# typically, married couples share the same plot. I am going under the assumption
# that is the case here,
# to help with this, I am going to go the overly simplistic route and assume that those 
# with the same last name are most likely to be married
aggregate(lifespan$age, 
          list(lifespan$Sex, Married = duplicated(lifespan$LastName)), 
          mean)
aggregate(lifespan$age, 
          list(lifespan$Sex, Married = duplicated(lifespan$LastName)), 
          median)
aggregate(lifespan$age, 
          list(lifespan$Sex, Married = duplicated(lifespan$LastName)), 
          min)
aggregate(lifespan$age, 
          list(lifespan$Sex, Married = duplicated(lifespan$LastName)), 
          max)

# plots all of the data we have

ggplot(lifespan, aes(DOD, age, color = Sex, group = Sex)) + 
  facet_wrap(~duplicated(LastName)) +
  geom_point() +
  geom_smooth()

# ...Huh. this seems odd. The lifspan of married men seems to be going down, which is not
# indicative of any trends in data. This coudl be because of the arguably small sample 
# size and my own method of determining marriage, since, as I have previously stated,
# it could be the case that children are buried in the same grave of their parents, if
# some awful tragedy happened to cause that. I will investigate this further:

ggplot(lifespan[duplicated(lifespan$LastName),], aes(age, fill=Sex)) + 
  geom_histogram(position="dodge") + labs(title = "Lifespan Frequency of Married People")


# looking at the histogram, it appears that the lifespan of males are more spread out
# then females. This could very well skew the results of my analysis. One's adult child
# could be sharing the same plot as their parents. However, it is interesting to note
# that male life expectancy is spread out as opposed to female life expectancy, which
# is closer together. THe only explanation I have for that is the simple fact that women
# life longer than men. Now as for married people living longer than single? The numbers
# themselves seem to suggest it.