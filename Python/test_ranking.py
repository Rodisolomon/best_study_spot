import ranking
import os

user_location = (41.795187, -87.596741)
file_name = 'all_places_chicago.json'

def test_initial_ranking(user_location, file_name, number):
    result = ranking.generate_ranking(user_location, file_name, number)
    if len(result) != number:
        raise ValueError("wrong ranking output number")
    for i in range(1, len(result)):
        # Check if the current value is greater than or equal to the previous value
        if result[i]['score'] >= result[i-1]['score']:
            raise ValueError("wrong ranking output order")
    print("initial ranking working properly")
        
def test_single_user_update(user_location, original_ranking, user_feedback, file_name):
    storage_file_name = 'all_places_chicago_temp.json'
    ranking.update_personal_ranking(original_ranking[0]['address'], 
                            user_feedback, 
                            file_name,
                            storage_file_name=storage_file_name
                            )
    new_ranking = ranking.generate_ranking(user_location, storage_file_name)
    print(f"with user feedback {user_feedback}...")
    for destination in new_ranking:
        print(f"{destination['name']} has score {destination['score']}" )
    os.remove(f"ranking_data/{storage_file_name}")


def test_update_personal_rankings(user_location, file_name):
    score = [0, 3, 5]
    original_ranking = ranking.generate_ranking(user_location, file_name)
    for destination in original_ranking:
        print(f"{destination['name']} has score {destination['score']}" )
    for gs in score:
        for ns in score:
            for ss in score:
                keys = ['general_score', 'noise_level', "spaciousness"]
                values = [gs, ns, ss]
                user_feedback = dict(zip(keys, values))
                print(f"for user feedback with general score{gs}, noise level {ns}, spaciousness score {ss}:")
                test_single_user_update(user_location, original_ranking, user_feedback, file_name)

def test_filtering_based_on_user_preferences(user_location, file_name):
    user_preferences_list = [
        {
            "Noise Level": "Low",
            "Space Size": "Small",
            "Exclusive to Student": False,
            "I want to collaborate": False,
            "Must have wi-fi": True,
            "Maximum Distance": 5.0
        },
        {
            "Noise Level": "Medium",
            "Space Size": "Medium",
            "Exclusive to Student": True,
            "I want to collaborate": True,
            "Must have wi-fi": False,
            "Maximum Distance": 2.0
        },
        {
            "Noise Level": "High",
            "Space Size": "Large",
            "Exclusive to Student": False,
            "I want to collaborate": True,
            "Must have wi-fi": True,
            "Maximum Distance": 10.0
        }
    ]
    
    for user_preference in user_preferences_list:
        print(f"Testing with user preferences: {user_preference}")
        filtered_ranking = ranking.generate_ranking(user_location, file_name, number=5, user_preference=user_preference)
        
        for destination in filtered_ranking:
            # Check if the destination meets the noise level preference
            if user_preference["Noise Level"] == "Low" and destination['label']['noisy'] > 1:
                raise ValueError("Filtered destination does not meet the noise level preference")
            if user_preference["Noise Level"] == "Medium" and not (2 <= destination['label']['noisy'] <= 3):
                raise ValueError("Filtered destination does not meet the noise level preference")
            if user_preference["Noise Level"] == "High" and destination['label']['noisy'] < 4:
                raise ValueError("Filtered destination does not meet the noise level preference")
            
            # Check if the destination meets the space size preference
            if user_preference["Space Size"] == "Small" and destination['label']['spacious'] > 1:
                raise ValueError("Filtered destination does not meet the space size preference")
            if user_preference["Space Size"] == "Medium" and not (2 <= destination['label']['spacious'] <= 3):
                raise ValueError("Filtered destination does not meet the space size preference")
            if user_preference["Space Size"] == "Large" and destination['label']['spacious'] < 4:
                raise ValueError("Filtered destination does not meet the space size preference")
            
            # Check if the destination meets the exclusivity to students preference
            if user_preference["Exclusive to Student"] and not destination['label']['exclusive to student']:
                raise ValueError("Filtered destination does not meet the exclusivity to students preference")
            
            # Check if the destination meets the collaboration preference
            if user_preference["I want to collaborate"] and not destination['label']['collaborate']:
                raise ValueError("Filtered destination does not meet the collaboration preference")
            
            # Check if the destination meets the Wi-Fi preference
            if user_preference["Must have wi-fi"] and not destination['label']['wi-fi']:
                raise ValueError("Filtered destination does not meet the Wi-Fi preference")
            
            # Check if the destination meets the maximum distance preference
            distance = ranking.haversine_distance(user_location[0], user_location[1], destination['latitude'], destination['longitude'])
            if distance > user_preference["Maximum Distance"]:
                raise ValueError("Filtered destination does not meet the maximum distance preference")

        print("Filtering test passed for the given user preferences")


def test_wrapper():
    test_initial_ranking(user_location, file_name, 5)
    test_update_personal_rankings(user_location, file_name)
    test_filtering_based_on_user_preferences(user_location, file_name)


if __name__ == "__main__":
    test_wrapper()