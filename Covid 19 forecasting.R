# libraries
library(forecast)
library(lubridate)
library(dplyr)
library(prophet)
library(ggplot2)
library(aTSA)
library(zoo)
library(scales)


# read csv file
covid_data<- read.csv("COVID_19_DATA.csv")
# check the first 5 observations
head(covid_data)


# Missing data
sum(is.na(covid_data))
#summary
summary(covid_data$cases)

# Format date 
covid_data$date<- ymd(covid_data$date)
class(covid_data$date)


## Time series
# checking for start and end data
head(covid_data$date) 
# check for day
yday("2020-01-21") 
# Tail
tail(covid_data$date) 
yday("2022-02-11")

# Time series
covid.ts<-ts(covid_data$cases, start = c(2020, 21), end = c(2022, 42), freq=365)

# Plot the time series
options(scipen=10000)
ggplot(data = covid_data, aes(x = date, y = cases))+
  geom_line(color = "#00AFBB", size = 2) +
  ggtitle("Time series plot of Covid 19 cases in the US")+
  scale_x_date(date_labels = "%b %Y") +
  scale_y_continuous(labels = scales::comma) 



## DESCOMPOSING TIME SERIES
covid19Components<-decompose(covid.ts)
covid19Components<-decompose(diff(covid.ts, differences = 1))
# plot
plot(covid19Components)


# split the data
train.ts<- window(covid.ts, start= c(2020, 21), end= c(2021, 181))
test.ts<- window(covid.ts, start= c(2021, 182), end= c(2022, 42))



#####################
# Linear regression 
#####################
# Forecasting using linear model
# Fit linear trend model to training set and create forecast
train.lm<- tslm(train.ts~trend)
summary(train.lm)
# trend +seasn
train.lm.s<- tslm(train.ts~trend+ season)
summary(train.lm.s)

# Forecast
forecast.fit <- forecast::forecast(train.lm.s, h=224, level=c(80,90))

# plot
plot(forecast.fit, ylab = "covid 19 cases", xlab="Time")

# accuracy
accuracy(forecast.fit, test.ts)




##########
# ARIMA
##########
# plot the train time series
plot(train.ts)  # non-stationary

### Stationary test
# autocorrelation 
acf(train.ts)#
# partial autocorrelation
pacf(train.ts) 
# adf.test
adf.test(train.ts) # p-value is greater than 0.05, so the data is non-stationary

# Differencing
train.ts.diff<- diff(train.ts, differences = 1)
plot(train.ts.diff) # now ts is stationary
# difference of 2
train.ts.diff2<- diff(train.ts, differences = 2)
plot(train.ts.diff2)


# ARIMA MODEL
covid_model <- auto.arima(train.ts, ic="aic", trace = TRUE)
covid_model
# ARIMA(0,2,1) based on the auto.arima

# using ARIMA(0,2,1)
covid_model<-Arima(train.ts, order=c(0,2,1)) 
covid_model
# check for stationarity
acf(ts(covid_model$residuals)) # few spike are still outside the blue line
pacf(ts(covid_model$residuals))
# Forecast
arima.covid.forecasts <- forecast::forecast(covid_model, h=224)
arima.covid.forecasts

# Trying another arima
covid_model1<-Arima(train.ts, order=c(1,2,19)) 
covid_model1
# check for stationarity
acf(ts(covid_model1$residuals)) # all spikes within the blue lines
pacf(ts(covid_model1$residuals))
# Forecast
arima.covid.forecasts1 <- forecast::forecast(covid_model1, h=224)
arima.covid.forecasts1

# plot
autoplot(arima.covid.forecasts1)+ 
  xlab("Date") +
  ylab("Cases") +
  scale_x_yearmon(format="%Y %m") +
  scale_y_continuous(labels = scales::comma) 

# residuals
plot.ts(arima.covid.forecasts1$residuals) 

# Validate forecast
Box.test(arima.covid.forecasts1$residuals, lag=20, type="Ljung-Box")

# Accuracy
accuracy(arima.covid.forecasts, test.ts)
accuracy(arima.covid.forecasts1, test.ts)



#################
# Holt-Winter's 
#################
train_Holt<-HoltWinters(train.ts, beta = FALSE, gamma = FALSE)
# plot
plot(train_Holt) 
# forecast
holt_forecast<-forecast::forecast(train_Holt, h=224)
plot(holt_forecast, ylab = "Covid 19 cases", xlab="Time")

# accuracy
accuracy(holt_forecast, test.ts)

# autocorrelation
acf(holt_forecast$residuals, lag.max=10, na.action = na.omit) 
# Box.test
Box.test(holt_forecast$residuals, lag=10, type="Ljung-Box")   
#Check for constant variance over time:
plot.ts(holt_forecast$residuals)


##################
# comparing models
##################
plot(forecast.fit, plot.conf=F, main = "")
lines(arima.covid.forecasts$mean, col=2, lty=1)
lines(arima.covid.forecasts1$mean, col=6, lty=1)
lines(holt_forecast$mean, col=3, lty=1)
lines(test.ts, col=7, lty=1, lwd=3)
legend("topleft", lty = 1, col=c(1,2,6,3,7),
       legend=c("linear Method", "arima", "arima1", "holt", "Test"))
