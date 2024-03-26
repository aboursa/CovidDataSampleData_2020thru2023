# import libraries

library(tidyverse)
library(readr)
library(dplyr)


# import csv file to clean
covid_data <- read.csv('C:/Users/Adj/Downloads/owid-covid-data.csv')
View(covid_data)


# check column names and select needed columns to create a data frame for covid deaths
colnames(covid_data)

coviddeaths <- (select(covid_data, iso_code, continent, location,date, population, total_cases, new_cases, new_cases_smoothed, 
                       total_deaths, new_deaths, total_cases_per_million,new_cases_per_million, new_cases_smoothed_per_million,
                       total_deaths_per_million, new_deaths_per_million, new_deaths_smoothed_per_million, reproduction_rate, 
                       icu_patients, icu_patients_per_million, hosp_patients, hosp_patients_per_million, weekly_icu_admissions,
                      weekly_icu_admissions_per_million, weekly_hosp_admissions, weekly_hosp_admissions_per_million))
view(coviddeaths)


# export new data frame for covid deaths to csv
write.csv(coviddeaths, 'C:/Users/Adj/Downloads/coviddeaths.csv', na = "", row.names = FALSE)


#create another data frame for covid vaccinations
covidvaccinations <- (select(covid_data, iso_code, continent, location,date, total_tests, new_tests,new_tests_per_thousand,
                             new_tests_smoothed, new_tests_smoothed_per_thousand, positive_rate, tests_per_case, tests_units,
                             total_vaccinations, people_vaccinated, people_fully_vaccinated, total_boosters, new_vaccinations, 
                             new_vaccinations_smoothed, total_vaccinations_per_hundred, people_vaccinated_per_hundred, 
                             people_fully_vaccinated_per_hundred, total_boosters_per_hundred, new_vaccinations_smoothed_per_million,
                             new_people_vaccinated_smoothed, new_people_vaccinated_smoothed_per_hundred, stringency_index,
                             population_density, median_age, aged_65_older, aged_70_older, gdp_per_capita, extreme_poverty, 
                             cardiovasc_death_rate, diabetes_prevalence, female_smokers, male_smokers, 
                             handwashing_facilities, hospital_beds_per_thousand, life_expectancy, human_development_index,
                             excess_mortality_cumulative, excess_mortality, excess_mortality_cumulative_per_million))

View(covidvaccinations)


# export new data frame for covid vaccinations to csv
write.csv(covidvaccinations, 'C:/Users/Adj/Downloads/covidvaccinations.csv', na = "", row.names = FALSE)