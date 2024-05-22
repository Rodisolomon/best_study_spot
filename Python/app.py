from flask import Flask, request, jsonify
import json
import ranking  # Make sure this module is properly imported
location_data = {}
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
    pass
    # #TODO: change passed back data to the style of {'general_score': 0~5 int, 'noise_level' 0~5 int, "spaciousness" 0~5 int}

    # feedback_data = request.get_json()
    # # Placeholder: Save feedback data to the database
    # rating = feedback_data.get('rating')
    # comments = feedback_data.get('comments', '')
    
    # # Update the ranking based on feedback
    # ranking.update_ranking_with_feedback(feedback_data)
    
    # # Generate new ranking
    # global location_data
    # if 'latitude' not in location_data or 'longitude' not in location_data:
    #     return jsonify({'status': 'error', 'message': 'Location data not available'})
    
    # new_ranking = ranking.generate_ranking((location_data['latitude'], location_data['longitude']), file_name)
    
    # return jsonify({'status': 'success', 'message': 'Feedback received and ranking updated', 'rating': rating, 'comments': comments, 'new_ranking': new_ranking})


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
    data = request.get_json()
    address = data.get('address')

    print(f"Received address: {address}")
    return address


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
