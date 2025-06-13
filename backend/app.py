from flask import Flask, request, jsonify
from model import BabyVideoValidator
import cv2
import numpy as np

# Initialize Flask app and model
app = Flask(__name__)
validator = BabyVideoValidator()

# Test route to ensure the backend is working
@app.route('/')
def index():
    return "Baby Video Validator backend is running."

# Route to analyze a single frame (image)
@app.route('/analyze-frame', methods=['POST'])
def analyze_frame():
    file = request.files.get('frame')

    if file is None:
        return jsonify({'error': 'No frame provided'}), 400

    try:
        # Decode the uploaded image file into an OpenCV image
        file_bytes = np.frombuffer(file.read(), np.uint8)
        frame = cv2.imdecode(file_bytes, cv2.IMREAD_COLOR)

        # Pass the frame to the validator for analysis
        result = validator.validate_frame(frame)

        # Structure the response
        response = {
            'lighting_ok': result.get('lighting_ok'),
            'bbox_in_frame': result.get('bbox_in_frame'),
            'visible_landmarks': result.get('visible_landmarks'),
            'frame_passed': result.get('frame_passed'),
            'status': result.get('box_status')
        }

        return jsonify(response)

    except Exception as e:
        return jsonify({'error': f'Error processing frame: {str(e)}'}), 500

# Route to handle baby data from the Flutter app
@app.route('/api/add-baby', methods=['POST'])
def add_baby():
    data = request.get_json()
    print("Received baby data:", data)

    required_fields = ['nameOrId', 'age', 'address']
    missing = [field for field in required_fields if field not in data]
    if missing:
        print(f"Missing fields: {missing}")
        return jsonify({'error': f'Missing fields: {missing}'}), 400

    return jsonify({'message': 'Baby data received successfully!'}), 200

# Run the Flask app
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)  # Accessible from phone on LAN
