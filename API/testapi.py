import numpy as np
import pandas as pd
from pmdarima import ARIMA, auto_arima
import statsmodels.api as sm
from statsmodels.tsa.stattools import adfuller
from flask import Flask, jsonify, request
from statsmodels.tsa.seasonal import seasonal_decompose


# Define the Flask app
app = Flask(__name__)




# Define the API endpoint for making forecasts
@app.route('/forecast', methods=['POST'])
def forecast():
                     

                      request_data = request.get_json()
                      print(request_data)
                      input_data = request_data['data']
                      print(input_data)
         
                      input_df = pd.DataFrame(input_data, columns=['date', 'value','age'])
                    
                      
                      print(input_df)
                      
                      age=input_df['age'][0]
                     
                      
                      if(age>=20 and age<=30):
                       print("greater than 20 and less than 30")
                       data = pd.read_csv("C:\\Users\\amgai\\OneDrive\\Desktop\\flutter with flask\\API\\age22.csv")
                       data = data["average length cycle"]
 
                      elif(age>30 and age<=40):
                       print("between 30 and 40")
                       data = pd.read_csv("C:\\Users\\amgai\\OneDrive\\Desktop\\flutter with flask\\API\\age35.csv")
                       data = data["average length cycle"]
                      elif(age>40):
                       print("between 40 and 50")
                       data = pd.read_csv("C:\\Users\\amgai\\OneDrive\\Desktop\\flutter with flask\\API\\age42.csv")
                       data = data["average length cycle"]  
                      else:
                         print("invalid")
                      
                      
                      data = pd.concat([data, input_df['value']], ignore_index=True)
                      print(data)
                      
                      
        
                   
                      output_data = input_df.reset_index().to_dict(orient='records')
     
                      def check_stationarity(data):
                         result = adfuller(data)
                         pvalue = result[1]
                         if pvalue < 0.05:
                              print("The data is stationary with p-value", pvalue)
                         else:
                              print("The data is not stationary with p-value", pvalue)
    
                         return pvalue

# check for stationarity in the data
                      pvalue = check_stationarity(data)

# apply differencing to make the data stationary if necessary
                      if pvalue >= 0.05:
                         differenced_data = data.diff().dropna()
                         check_stationarity(differenced_data)
                      else:
                         differenced_data = data
    
    
    
    # spilting the dataset
                      from sklearn.model_selection import train_test_split

                      X = differenced_data # dataset

                      train_size = 0.75
                      test_size = 1 - train_size
                      X_train, X_test = train_test_split(X, train_size=train_size, test_size=test_size, shuffle=False)
                   
                      
                  
                     




                      arima_model =  auto_arima(data,start_p=0, d=0, start_q=0, 
                          max_p=5, max_d=0, max_q=5, start_P=0, 
                          D=1, start_Q=0, max_P=5, max_D=5,
                          max_Q=5, m=3, seasonal=True, 
                          error_action='warn',trace = True,
                          supress_warnings=True,stepwise = False,approximation=False,
                          random_state=20,n_fits = 50,n_jobs=8 )
                     #  arima_model=ARIMA(X_train)

                      prediction = pd.DataFrame(arima_model.predict(n_periods = 100),index=X_test.index)
                      prediction.columns = ['predicted_Cyclelength']
                      
                      
                      X_full = pd.concat([X_train, X_test])
                      arima_model.fit(X_full)
                      print("a")
                      future_predictions = arima_model.predict(n_periods=3)
                      print("b")
                      prediction_dict = dict(zip(range(len(future_predictions)), future_predictions.tolist()))
                      print(prediction_dict)
                 

                      print(prediction_dict[0])
    # Return the output data as JSON
                      return jsonify(prediction_dict[0])

# Run the Flask app
if __name__ == '__main__':
    app.run(debug=True)
