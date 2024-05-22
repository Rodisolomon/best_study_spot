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


def test_wrapper():
    test_initial_ranking(user_location, file_name, 5)
    test_update_personal_rankings(user_location, file_name)

if __name__ == "__main__":
    test_wrapper()