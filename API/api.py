import numpy as np
import pandas as pd
import statsmodels.api as sm
from flask import Flask, jsonify, request

# Define the Flask app
app = Flask(__name__)

# Load the ARIMA model
arima_model = sm.load('C:\\Users\\amgai\\OneDrive\\Desktop\\development\\projects\\flutterwithflask\\API\\arima_model.pkl')

# Define the API endpoint for making forecasts
@app.route('/forecast', methods=['POST'])
def forecast():
    # Get the request data
    request_data = request.get_json()
    input_data = request_data['data']
   # print(input_data)
    print("noting")
    print(input_data)
    
    # Convert the input data to a Pandas dataframe
    input_df = pd.DataFrame(input_data, columns=['date', 'value'])
    input_df['date'] = pd.to_datetime(input_df['date'])
    input_df.set_index('date', inplace=True)
    
    # Make the forecast using the ARIMA model
    forecast_values = arima_model.predict(steps=3)
    print(forecast_values)
    forecast_df = pd.DataFrame(forecast_values, columns=['value'], index=input_df.index)
   # print(forecast_df)
    
    # Combine the input data and the forecast data
   # output_df = pd.concat([input_df, forecast_df])
    
    # Convert the output data to a dictionary
    output_data = output_df.reset_index().to_dict(orient='records')
  #  print(output_data)
    
    # Return the output data as JSON
    return jsonify({'data': output_data})

# Run the Flask app
if __name__ == '__main__':
    app.run(debug=True)
