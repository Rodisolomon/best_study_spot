from flask import Flask, request, jsonify

app = Flask(__name__)


@app.route('/api/location', methods=['GET'])
def get_location():

    data = request.get_json()
    latitude = data.get('latitude')
    longitude = data.get('longitude')

    print(latitude, longitude)
    return jsonify({'status': 'success', 'message': 'Location received'})


@app.route('/api/location/accelerometer', methods=['POST'])
def process_accelerometer_data():
    data = request.get_json()
    # Placeholder: Process accelerometer data to determine if the user has settled
    settled = True  
    return jsonify({'status': 'processed', 'settled': settled})


@app.route('/api/environment/noise', methods=['POST'])
def process_noise_data():
    noise_data = request.get_json()
    # Placeholder: Process noise level data
    noise_level = noise_data.get('level', 0)  
    return jsonify({'status': 'received', 'noise_level': noise_level})


@app.route('/api/environment/crowd-density', methods=['GET'])
def get_crowd_density():
    # Placeholder: Estimate crowd density using local Wi-Fi and Bluetooth signals
    crowd_density = {
        "level": "high", 
        "count": 50  
    }
    return jsonify(crowd_density)


@app.route('/api/user/feedback', methods=['POST'])
def submit_feedback():
    feedback_data = request.get_json()
    # Placeholder: Save feedback data to the database
    rating = feedback_data.get('rating')
    comments = feedback_data.get('comments', '')
    return jsonify({'status': 'success', 'message': 'Feedback received', 'rating': rating, 'comments': comments})

if __name__ == '__main__':
    app.run(debug=True)
