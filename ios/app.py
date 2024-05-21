from flask import Flask, request, jsonify
import json

app = Flask(__name__)

@app.route('/api/location', methods=['POST'])
def get_location():
    data = request.get_json()
    latitude = data.get('latitude')
    longitude = data.get('longitude')

    print(latitude, longitude)
    return jsonify({'status': 'success', 'message': 'Location received', 'latitude': latitude, 'longitude': longitude})

@app.route('/api/location/accelerometer', methods=['POST'])
def process_accelerometer_data():
    data = request.get_json()
    # Placeholder: Process accelerometer data to determine if the user has settled
    settled = True  
    return jsonify({'status': 'processed', 'settled': settled})

@app.route('/api/environment/noise', methods=['POST'])
def process_noise_data():
    noise_data = request.get_json()
    average_level = noise_data.get('average_level', 0)
    highest_level = noise_data.get('highest_level', 0)
    lowest_level = noise_data.get('lowest_level', 0)
    
    with open('noise_data.json', 'a') as f:
        json.dump({
            'average_level': average_level,
            'highest_level': highest_level,
            'lowest_level': lowest_level
        }, f)
        f.write("\n")
    
    print(f"Received noise levels: Average: {average_level}, Highest: {highest_level}, Lowest: {lowest_level}")
    return jsonify({
        'status': 'received',
        'average_level': average_level,
        'highest_level': highest_level,
        'lowest_level': lowest_level
    })

@app.route('/api/environment/crowd-density', methods=['GET'])
def get_crowd_density():
    # Placeholder: Estimate crowd density using local Wi-Fi and Bluetooth signals
    crowd_density = {
        "level": "high", 
        "count": 50  
    }
    return jsonify({'status': 'success', 'crowd_density': crowd_density})

@app.route('/api/user/feedback', methods=['POST'])
def submit_feedback():
    feedback_data = request.get_json()
    # Placeholder: Save feedback data to the database
    rating = feedback_data.get('rating')
    comments = feedback_data.get('comments', '')
    return jsonify({'status': 'success', 'message': 'Feedback received', 'rating': rating, 'comments': comments})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
