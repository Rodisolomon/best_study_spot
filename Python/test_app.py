import unittest
import json
from app import app, location_data  # Import the app and location_data

class FlaskTestCase(unittest.TestCase):

    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    def test_get_location(self):
        response = self.app.post('/api/location', data=json.dumps({
            'latitude': 37.7749,
            'longitude': -122.4194
        }), content_type='application/json')
        self.assertEqual(response.status_code, 200)
        self.assertIn('success', response.json['status'])
        # Check the global location_data variable
        global location_data
        self.assertEqual(location_data['latitude'], 37.7749)
        self.assertEqual(location_data['longitude'], -122.4194)

    # def test_process_and_return_data_no_location(self):
    #     global location_data
    #     location_data = {}  # Reset location_data
    #     response = self.app.post('/api/ranking', data=json.dumps({
    #         'input_data': 'sample input'
    #     }), content_type='application/json')
    #     self.assertEqual(response.status_code, 200)
    #     self.assertIn('error', response.json['status'])

    def test_process_and_return_data_with_location(self):
        global location_data
        location_data = {'latitude': 37.7749, 'longitude': -122.4194}
        response = self.app.post('/api/ranking', data=json.dumps({
            'input_data': 'sample input'
        }), content_type='application/json')
        self.assertEqual(response.status_code, 200)
        self.assertIn('success', response.json['status'])
        self.assertIn('ranking', response.json)

    def test_process_accelerometer_data(self):
        response = self.app.post('/api/location/accelerometer', data=json.dumps({}), content_type='application/json')
        self.assertEqual(response.status_code, 200)
        self.assertIn('status', response.json)
        self.assertEqual(response.json['status'], 'processed')
        self.assertIn('settled', response.json)
        self.assertTrue(response.json['settled'])

    def test_process_noise_data(self):
        response = self.app.post('/api/environment/noise', data=json.dumps({
            'average_level': 55,
            'highest_level': 70,
            'lowest_level': 40
        }), content_type='application/json')
        self.assertEqual(response.status_code, 200)
        self.assertIn('status', response.json)
        self.assertEqual(response.json['status'], 'received')
        self.assertEqual(response.json['average_level'], 55)
        self.assertEqual(response.json['highest_level'], 70)
        self.assertEqual(response.json['lowest_level'], 40)

    def test_get_crowd_density(self):
        response = self.app.get('/api/environment/crowd-density')
        self.assertEqual(response.status_code, 200)
        self.assertIn('status', response.json)
        self.assertEqual(response.json['status'], 'success')
        self.assertIn('crowd_density', response.json)
        self.assertIn('level', response.json['crowd_density'])
        self.assertIn('count', response.json['crowd_density'])

    def test_ranking_data(self):
        global location_data
        location_data = {'latitude': 37.7749, 'longitude': -122.4194}
        response = self.app.post('/api/ranking', data=json.dumps({
            'input_data': 'sample input'
        }), content_type='application/json')
        self.assertEqual(response.status_code, 200)
        self.assertIn('success', response.json['status'])
        self.assertIn('ranking', response.json)
        ranking_data = response.json['ranking']
        self.assertIsInstance(ranking_data, list)  # Assuming ranking is a list
        self.assertGreater(len(ranking_data), 0)  # Check that there is at least one ranking result
        # Further checks can be added based on the expected structure of the ranking data

    # def test_submit_feedback(self):
    #     response = self.app.post('/api/user/feedback', data=json.dumps({
    #         'rating': 5,
    #         'comments': 'Great place!'
    #     }), content_type='application/json')
    #     self.assertEqual(response.status_code, 200)
    #     self.assertIn('status', response.json)
    #     self.assertEqual(response.json['status'], 'success')
    #     self.assertIn('rating', response.json)
    #     self.assertEqual(response.json['rating'], 5)
    #     self.assertIn('comments', response.json)
    #     self.assertEqual(response.json['comments'], 'Great place!')

if __name__ == '__main__':
    unittest.main()
