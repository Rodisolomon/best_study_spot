import nltk
from nltk.corpus import wordnet as wn
import requests
import pandas as pd
import openai
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

def generate_ranking(user_location: tuple, file_name:str, number: int = 5) -> list[dict]:
    """
    generate ranking based on user preference and current objective score
    """
    with open(f'Data/property_weights.json', 'r') as file:
        property_weights = json.load(file)
    with open(f'Data/{file_name}', 'r') as file:
        destinations = json.load(file)
    to_be_remove = []
    for i, destination in enumerate(destinations):
        if destination['label'] == None:
            to_be_remove.append(i)
            continue
        score = calculate_score(user_location, destination, property_weights)
        if 'user_score' in  destination['label']:
            user_score = destination['label']['user_score']
            score += (user_score-2)*4
        destination["score"] = score


    destinations = [item for idx, item in enumerate(destinations) if idx not in to_be_remove]

    # Rank destinations by score
    ranked_destinations = sorted(destinations, key=lambda x: x["score"], reverse=True)
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
    with open(f'Data/{file_name}', 'r') as file:
        destinations = json.load(file)
    for i in range(len(destinations)):
        if destinations[i]['address'] == address:
            destinations[i]['label']['noisy'] = ((destinations[i]['label']['noisy']*original_weight + user_feedback['noise_level']*new_weight)/(original_weight+new_weight))
            destinations[i]['label']['spacious'] = ((destinations[i]['label']['spacious']*original_weight + user_feedback['spaciousness']*new_weight)/(original_weight+new_weight))
            destinations[i]['label']['user_score'] = user_feedback['general_score']
            break
    if storage_file_name:
        with open(f'Data/{storage_file_name}', 'w') as file:
            json.dump(destinations, file)
    else:
        with open(f'Data/{file_name}', 'w') as file:
            json.dump(destinations, file)

    