#our backend is deployed with aws so there is no need to run this locally, code is just here for reference
from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
import os
import cv2
import numpy as np
import logging
from scipy.optimize import minimize

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = 'uploads'

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.route('/')
def hello_world():
    return 'Hello, server running!'

#ensure the upload folder exists
if not os.path.exists(app.config['UPLOAD_FOLDER']):
    os.makedirs(app.config['UPLOAD_FOLDER'])

def extract_colors(image_path, min_contour_area=100):
    image = cv2.imread(image_path)
    image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    gray = cv2.cvtColor(image_rgb, cv2.COLOR_RGB2GRAY)

    #apply adaptive thresholding to minimize shadow effects
    binary = cv2.adaptiveThreshold(gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY_INV, 11, 2)

    #morphological operations to clean up the mask
    kernel = np.ones((3,3), np.uint8)
    binary = cv2.morphologyEx(binary, cv2.MORPH_CLOSE, kernel)

    #find contours/color swatches
    contours, _ = cv2.findContours(binary, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    def get_average_color(image, contour):
        mask = np.zeros((image.shape[0], image.shape[1]), dtype=np.uint8) 
        cv2.drawContours(mask, [contour], -1, color=255, thickness=-1)
        mean = cv2.mean(image, mask=mask)[:3]
        return mean

    #extract colors from the contours/color swatches
    colors = []
    for contour in contours:
        if cv2.contourArea(contour) > min_contour_area:  # filter out small contours
            avg_color = get_average_color(image_rgb, contour)
            colors.append([int(c) for c in avg_color])

    hex_colors = ['#' + ''.join(f'{c:02X}' for c in color) for color in colors]
    return hex_colors

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    if file:
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)

        logger.info('Received image upload request')
        logger.info('Filename: %s', file.filename)
        colors = extract_colors(filepath)
        return jsonify({'colors': colors})

#used idea from https://math.stackexchange.com/questions/4335003/how-to-calculate-a-physical-ratio-of-colors-to-achieve-a-target-color
@app.route('/calculatemix', methods=['POST'])
def calculate_mix():
    data = request.json
    if not data or 'available_hex_colors' not in data or 'target_hex_color' not in data:
        return jsonify({'error': 'Invalid input'}), 400
    available_hex_colors = data['available_hex_colors']
    target_hex_color = data['target_hex_color']
    # convert to RGB
    available_rgb_colors = np.array([np.array([int(hex_color[i:i+2], 16) for i in (1, 3, 5)]) for hex_color in available_hex_colors])
    target_rgb_color = np.array([int(target_hex_color[i:i+2], 16) for i in (1, 3, 5)])
    def objective_function(ratios):
        mixed_color_rgb = np.sum(ratios[:, np.newaxis] * available_rgb_colors, axis=0)
        return np.linalg.norm(mixed_color_rgb - target_rgb_color)
    constraints = [
        {'type': 'ineq', 'fun': lambda ratios: ratios},
        {'type': 'eq', 'fun': lambda ratios: np.sum(ratios) - 1}
    ]
    initial_guess = np.ones(len(available_rgb_colors)) / len(available_rgb_colors)
    bounds = [(0, 1) for _ in range(len(available_rgb_colors))]
    result = minimize(objective_function, initial_guess, bounds=bounds, constraints=constraints)
    optimal_ratios = result.x
    # calculate the color obtained by mixing with optimal ratios
    optimal_mixed_color_rgb = np.sum(optimal_ratios[:, np.newaxis] * available_rgb_colors, axis=0)
    total_ratio = np.sum(optimal_ratios)
    output = {
        "optimal_mixing_ratios": [
            {"hex_color": hex_code, "ratio": round((ratio / total_ratio) * 100)}
            for ratio, hex_code in zip(optimal_ratios, available_hex_colors)
        ],
        "optimal_mixed_color_rgb": optimal_mixed_color_rgb.tolist(),
        "target_color_rgb": target_rgb_color.tolist(),
        "difference_l2_norm": np.linalg.norm(optimal_mixed_color_rgb - target_rgb_color)
    }
    return jsonify(output)

if __name__ == '__main__':
    app.run(debug=True)