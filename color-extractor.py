import cv2
import numpy as np

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

    #save to file for now, set up flask backend to connect to flutter app later
    print("Extracted colors in hexadecimal format:")
    with open('colors_extracted_hex.txt', 'w') as file:
        file.write("Extracted colors in hexadecimal format:\n")
        for idx, hex_color in enumerate(hex_colors):
            file.write(f"Color {idx+1}: {hex_color}\n")
            print(f"Color {idx+1}: {hex_color}")

image_path = 'PXL_20240622_0243558592-removebg-preview.png' #temp for testing 
extract_colors(image_path)
