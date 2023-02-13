# Forecasting-COVID-19-cases-in-the-US

The World Health Organization declared COVID-19 a pandemic on March 11th, 2020. Subsequently, various guidelines were put in place to curb the spread of this virus. The aim of this project was to forecast the number of Covid-19 cases in the US. The dataset was retrieved from the John Hopkins’ Covid-19 data repository. The data contained information from January 21st, 2020, to February 11th, 2022.




![Rplot02](https://user-images.githubusercontent.com/65930304/153794846-1c0e1ee3-688c-4a62-a0cb-743ccd7ec77e.png)




### Forecasting
<img width="580" alt="Screenshot 2023-02-13 at 10 20 00 AM" src="https://user-images.githubusercontent.com/65930304/218498597-e9b4b7b7-5ca9-4a35-a177-61cbc705b7f0.png">


### Accuracy

<img width="408" alt="Screenshot 2023-02-13 at 10 35 49 AM" src="https://user-images.githubusercontent.com/65930304/218502067-4a3fe861-c082-4f5a-9153-951fe781f891.png">

Interpretation:
Based on the MAPE:
•	Linear regression model is worst at forecasting in data train and data test
•	HoltWinters method had a training set error of 2.97% and test set error of 24.73%.
•	Model ARIMA (0,2,1) had a training set error of 1.46% and test set error of 21.83%.
•	Model ARIMA (1,2,19) is the best at forecasting in both the train set with 1.32% of error and test set with 21.77% error
![image](https://user-images.githubusercontent.com/65930304/218502906-7477bf11-c82e-4771-b986-00387ad5712a.png)

