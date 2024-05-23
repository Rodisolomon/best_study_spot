from flask import Flask, request, jsonify
import json
import ranking
location_data = {}
current_address_name = {}
feedback = {}
file_name = "all_places_chicago.json"
preference = {'noiseLevel': 'High', 'canCollaborate': True, 'studentExclusive': False, 'maxDistance': 5, 'spaceSize': 'Small', 'mustHaveNetwork': False}


app = Flask(__name__)

@app.route('/api/location', methods=['POST'])
def get_location():
    global location_data  
    data = request.get_json()
    latitude = data.get('latitude')
    longitude = data.get('longitude')
    location_data['latitude'] = latitude
    location_data['longitude'] = longitude
    return jsonify({'status': 'success', 'message': 'Location received', 'latitude': latitude, 'longitude': longitude})

@app.route('/api/environment/noise', methods=['POST'])
def process_noise_data():
    noise_data = request.get_json().get('noise_data', [])
    processed_data = []

    for entry in noise_data:
        average_level = entry.get('average_level', 0)
        highest_level = entry.get('highest_level', 0)
        lowest_level = entry.get('lowest_level', 0)

        if average_level == -160 or highest_level == -160 or lowest_level == -160:
            continue
        if abs(average_level - highest_level) > 2 or abs(average_level - lowest_level) > 2:
            continue

        score = db_to_score(average_level)
        print(score)
        processed_data.append({
            'average_level': average_level,
            'highest_level': highest_level,
            'lowest_level': lowest_level,
            'score': score
        })

    return jsonify({
        'status': 'received',
        'entries': len(processed_data),
        'processed_data': processed_data
    })


def db_to_score(db_value):
    if db_value <= -45:
        return 0
    elif db_value >= -15:
        return 5
    else:
        return (db_value + 45) * 5 / 30


@app.route('/api/feedback', methods=['POST'])
def submit_feedback():
    global current_address_name
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
    ranking.update_personal_ranking(current_address_name['address'], 
                                current_address_name['name'],
                                feedback, 
                                file_name 
                                )
    return feedback


@app.route('/api/preference', methods=['POST'])
def submit_preference():
    global preference
    preference = request.get_json()
    print(preference)
    return preference


@app.route('/api/ranking', methods=['GET'])
def generate_ranking():
    global location_data
    global preference
    if 'latitude' not in location_data or 'longitude' not in location_data:
        return jsonify({'status': 'error', 'message': 'Location data not available'})
    
    # Pass the location data to the ranking function
    raw_ranking_result = ranking.generate_ranking((location_data['latitude'], location_data['longitude']), file_name, user_preference=preference)
    ranking_result = []
    maximum_score = raw_ranking_result[0]['score']
    for destination in raw_ranking_result:
        percentage_score = destination['score']/maximum_score*100
        ranking_result.append({'name':destination['name'], 'address':destination['address'], 'fitness':f"{percentage_score:.2f}"})

    return jsonify({'status': 'success', 'ranking': ranking_result})

@app.route('/api/choosen-address', methods=['POST'])
def chosen_address():
    global current_address_name
    data = request.get_json()
    current_name = data.get('name')
    current_address = data.get('address')
    current_address_name = {'name': current_name, 'address': current_address}
    print(f"Received name: {current_name}, address: {current_address}")
    return jsonify({'status': 'success', 'name': current_name, 'address': current_address}), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
