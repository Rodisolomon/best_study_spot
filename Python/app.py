from flask import Flask, request, jsonify
import json
import ranking  # Make sure this module is properly imported
location_data = {}
current_address = None
feedback = {}
file_name = "all_places_chicago.json"

app = Flask(__name__)

@app.route('/api/location', methods=['POST'])
def get_location():
    global location_data  # Access the global variable
    data = request.get_json()
    latitude = data.get('latitude')
    longitude = data.get('longitude')
    location_data['latitude'] = latitude
    location_data['longitude'] = longitude
    return jsonify({'status': 'success', 'message': 'Location received', 'latitude': latitude, 'longitude': longitude})

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

@app.route('/api/feedback', methods=['POST'])
def submit_feedback():
    global current_address
    global feedback
    feedback_data = request.get_json()
    try:
        general_score = int(feedback_data.get('generalScore'))
        noise_level = int(feedback_data.get('noiseLevel'))
        spaciousness = int(feedback_data.get('spaciousness'))
    except (TypeError, ValueError):
        return jsonify({'status': 'error', 'message': 'Invalid feedback data'}), 400

    feedback = {
        'general_score': general_score,
        'noise_level': noise_level,
        'spaciousness': spaciousness
    }
    print(feedback)
    ranking.update_personal_ranking(current_address, 
                                feedback, 
                                file_name 
                                )
    return feedback


@app.route('/api/preference', methods=['POST'])
def submit_preference():
    preference = request.get_json()
    
    print(preference)
    return preference


@app.route('/api/ranking', methods=['GET'])
def generate_ranking():
    global location_data
    if 'latitude' not in location_data or 'longitude' not in location_data:
        return jsonify({'status': 'error', 'message': 'Location data not available'})
    
    # Pass the location data to the ranking function
    raw_ranking_result = ranking.generate_ranking((location_data['latitude'], location_data['longitude']), file_name)
    ranking_result = []
    maximum_score = raw_ranking_result[0]['score']
    for destination in raw_ranking_result:
        percentage_score = destination['score']/maximum_score*100
        ranking_result.append({'name':destination['name'], 'address':destination['address'], 'fitness':f"{percentage_score:.2f}"})

    return jsonify({'status': 'success', 'ranking': ranking_result})

@app.route('/api/choosen-address', methods=['POST'])
def chosen_address():
    global current_address
    data = request.get_json()
    current_name = data.get('name')
    current_address = data.get('address')

    print(f"Received name: {current_name}, address: {current_address}")
    return jsonify({'status': 'success', 'name': current_name, 'address': current_address}), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
