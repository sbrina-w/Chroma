from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
import os
import cv2
import numpy as np
import logging

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = 'uploads'

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

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

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
