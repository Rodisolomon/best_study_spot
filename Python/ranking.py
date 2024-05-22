import pandas as pd
import math
import json
import numpy as np
import copy

def haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Convert longitude and latitude distance to km
    """
    # Convert latitude and longitude from degrees to radians
    lat1 = math.radians(lat1)
    lon1 = math.radians(lon1)
    lat2 = math.radians(lat2)
    lon2 = math.radians(lon2)

    # Haversine formula
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = math.sin(dlat / 2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon / 2)**2
    c = 2 * math.asin(math.sqrt(a))
    
    # Radius of Earth in kilometers. Use 3956 for miles
    r = 6371

    # Calculate the distance
    distance = c * r
    
    return distance

# Function to calculate the score for each destination
def calculate_score(location: tuple, place_info: dict, property_weights:dict) -> float:
    """
    based on property weights and user location, calcualte the score for users
    """
    property_presence = copy.deepcopy(place_info['label'])
    if 'user_score' in property_presence:
        property_presence.pop('user_score')
    # Calculate property score
    property_score = sum(property_weights[prop] for prop, present in property_presence.items() if present)

    # Apply distance penalty
    distance = haversine_distance(location[0], location[1], place_info['latitude'], place_info['longitude'])
    distance_penalty = -0.1 * distance

    # Calculate final score
    final_score = property_score + distance_penalty

    return final_score
def filter_destination(user_location: tuple, user_preference:dict, destinations: list[dict]) -> list[dict]:
    """
    filter the destination based on user preference
    """
    filtered_destinations = []
    for destination in destinations:
        if destination['label'] is None:
            continue

        # Check user preferences
        if user_preference.get('Noise Level'):
            noise_level = user_preference['Noise Level']
            if noise_level == 'Low' and destination['label'].get('noisy', 0) > 1:
                continue
            if noise_level == 'Medium' and not (2 <= destination['label'].get('noisy', 0) <= 3):
                continue
            if noise_level == 'High' and destination['label'].get('noisy', 0) < 4:
                continue

        if user_preference.get('Space Size'):
            space_size = user_preference['Space Size']
            if space_size == 'Small' and destination['label'].get('spacious', 0) > 1:
                continue
            if space_size == 'Medium' and not (2 <= destination['label'].get('spacious', 0) <= 3):
                continue
            if space_size == 'Large' and destination['label'].get('spacious', 0) < 4:
                continue

        if user_preference.get('Exclusive to Student') and not destination['label'].get('exclusive to student', False):
            continue

        if user_preference.get('I want to collaborate') and not destination['label'].get('collaborate', False):
            continue

        if user_preference.get('Must have wi-fi') and not destination['label'].get('wi-fi', False):
            continue

        max_distance = user_preference.get('Maximum Distance', float('inf'))
        distance = haversine_distance(user_location[0], user_location[1], destination['latitude'], destination['longitude'])
        if distance > max_distance:
            continue

        filtered_destinations.append(destination)
    return filtered_destinations

def generate_ranking(user_location: tuple, file_name:str, number: int = 5, user_preference:dict = None) -> list[dict]:
    """
    generate ranking based on user preference and current objective score
    """
    with open(f'ranking_data/property_weights.json', 'r') as file:
        property_weights = json.load(file)
    with open(f'ranking_data/{file_name}', 'r') as file:
        destinations = json.load(file)
    to_be_remove = []

    if user_preference:
        filtered_destinations = filter_destination(user_location, user_preference, destinations)
    else:
        filtered_destinations = destinations

    for i, destination in enumerate(filtered_destinations):
        if destination['label'] == None:
            to_be_remove.append(i)
            continue
        score = calculate_score(user_location, destination, property_weights)
        if 'user_score' in  destination['label']:
            user_score = destination['label']['user_score']
            score += (user_score-2)*4
        destination["score"] = score
    filtered_destinations = [item for idx, item in enumerate(filtered_destinations) if idx not in to_be_remove]

    # Rank destinations by score
    ranked_destinations = sorted(filtered_destinations, key=lambda x: x["score"], reverse=True)
    return ranked_destinations[:number]


def update_personal_ranking(address: str, 
                            user_feedback: dict, 
                            file_name: str, 
                            original_weight: float = 2, 
                            new_weight: float = 1,
                            storage_file_name = None
                            ):
    """
    based on user feedback, update the ranking with weighted averaging method
    user_feedback_structure: {
        general_score: int from 0-5, 
        noise_level: int from 0-5, 
        spaciousness/crowdeness: int from 0-5
        }
    """
    with open(f'ranking_data/{file_name}', 'r') as file:
        destinations = json.load(file)
    print(address)
    for i in range(len(destinations)):
        if destinations[i]['address'] == address:
            destinations[i]['label']['noisy'] = ((destinations[i]['label']['noisy']*original_weight + user_feedback['noise_level']*new_weight)/(original_weight+new_weight))
            destinations[i]['label']['spacious'] = ((destinations[i]['label']['spacious']*original_weight + user_feedback['spaciousness']*new_weight)/(original_weight+new_weight))
            destinations[i]['label']['user_score'] = user_feedback['general_score']
            break
    if storage_file_name:
        with open(f'ranking_data/{storage_file_name}', 'w') as file:
            json.dump(destinations, file)
    else:
        with open(f'ranking_data/{file_name}', 'w') as file:
            json.dump(destinations, file)

    