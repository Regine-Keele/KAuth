# -*- coding: utf-8 -*-
"""Model Testing

Automatically generated by Colab.

Original file is located at
    https://colab.research.google.com/drive/1-EcuQK0B4mJsXSIonBzk6Sw845hM00eN
"""

import os
import cv2
import shutil
import numpy as np
from pathlib import Path
import random
import itertools
from PIL import Image
import matplotlib.pyplot as plt

from sklearn.metrics import confusion_matrix, accuracy_score, precision_score, recall_score, f1_score
from tensorflow.keras.preprocessing.image import ImageDataGenerator, load_img, img_to_array
from tensorflow.keras.models import load_model

from google.colab import drive
drive.mount('/content/drive')

"""RESIZES AND CROPS THE IMAGES"""

def resize_and_crop_image(input_path, output_path, roi, target_size):
    with Image.open(input_path) as img:
        # Resize the image
        img_resized = img.resize(target_size, Image.LANCZOS)

        # Crop the resized image
        x, y, w, h = roi
        cropped_img = img_resized.crop((x, y, x+w, y+h))

        cropped_img.save(output_path)

roi = (465, 633, 516, 559)

# ROI 1 = Concealed Value (471, 0, 475, 555)
# ROI 2 = OVD (465, 633, 516, 559)

# Define the target size for resizing
target_size = (3844, 1575)

input_directory = "/content/drive/MyDrive/CS Study 2/Main Model Training/Main Model 6/0_Genuine"
output_directory = "/content/drive/MyDrive/CS Study 2/Main Model Training/Main Model 6/1_Genuine_OVD"

os.makedirs(output_directory, exist_ok=True)

for filename in os.listdir(input_directory):
    if filename.endswith((".JPG", ".jpg", ".jpeg", ".png")):
        input_path = os.path.join(input_directory, filename)
        output_path = os.path.join(output_directory, f"resized_cropped_{filename}")
        resize_and_crop_image(input_path, output_path, roi, target_size)

print("Resizing and cropping completed!")

"""PRE PROCESS THE IMAGES"""

import cv2
import os

def process_image(input_path, output_path):
    # Read the image
    img = cv2.imread(input_path)
    # Resize to 299x299
    img_resized = cv2.resize(img, (299, 299))
    # Convert to grayscale
    img_gray = cv2.cvtColor(img_resized, cv2.COLOR_BGR2GRAY)
    # Apply Canny edge detection
    edges = cv2.Canny(img_gray, 100, 200)
    # Convert back to RGB (actually BGR for cv2)
    img_rgb = cv2.cvtColor(edges, cv2.COLOR_GRAY2BGR)
    # Save the processed image
    cv2.imwrite(output_path, img_rgb)

# Directory containing your images
input_directory = "/path/to/dataset/"
# Base directory to save processed images
output_base_directory = "/path/to/dataset/"

# Create the output directory if it doesn't exist
os.makedirs(output_base_directory, exist_ok=True)

# Process all images
for filename in os.listdir(input_directory):
    if filename.lower().endswith((".jpg", ".jpeg", ".png")):
        input_path = os.path.join(input_directory, filename)
        output_path = os.path.join(output_base_directory, f"processed_{filename}")
        process_image(input_path, output_path)

print("Image processing completed!")
print(f"Processed images saved in: {output_base_directory}")

"""MODEL TESTING"""

testing_preprocessed_dataset_path = "/path/to/dataset/"

# Load the pre-trained model
model_path = '/path/to/the/trained/model/'
model = load_model(model_path)
print(f"Loading pre-trained model from: {model_path}")

# Define the preprocessing function
def preprocess_image(image_path):
    img = load_img(image_path, target_size=(299, 299))
    img_array = img_to_array(img)
    img_array = np.expand_dims(img_array, axis=0)
    img_array /= 255.0  # Normalize the image
    return img_array

# Create an ImageDataGenerator for the testing set
test_datagen = ImageDataGenerator(rescale=1./255)

# Get a list of all image files in the testing directory and its subdirectories
image_files = []
for root, dirs, files in os.walk(testing_preprocessed_dataset_path):
    for file in files:
        if file.endswith((".JPG", ".jpg", ".jpeg", ".png")):
            image_files.append(os.path.join(root, file))

# Check if any images were found
if not image_files:
    print("No images found in the specified directory.")
else:
    print(f"Found {len(image_files)} images in the testing directory.")

    # List to store prediction probabilities
    prediction_probabilities = []

    # Make predictions for each image
    predictions = []
    true_labels = []
    for image_file in image_files:
        img_array = preprocess_image(image_file)
        prediction_score = model.predict(img_array)[0][0]

        # Store the prediction probability
        prediction_probabilities.append(prediction_score)

        # Classify the image as "Genuine" or "Fake"
        if prediction_score >= 0.8:
            prediction = 'Genuine'
        else:
            prediction = 'Fake'

        # Assuming the true label is encoded in the file name
        # (e.g., 'genuine_image.jpg' or 'fake_image.jpg')
        true_label = 'Genuine' if 'genuine' in os.path.basename(image_file).lower() else 'Fake'

        predictions.append(prediction)
        true_labels.append(true_label)

        # Print the prediction and score
        print(f"{os.path.basename(image_file)}: {prediction} (Score: {prediction_score:.4f})")

    # Convert labels to numerical format for evaluation
    label_map = {'Genuine': 1, 'Fake': 0}
    true_labels_numeric = [label_map[label] for label in true_labels]
    predictions_numeric = [label_map[pred] for pred in predictions]

"""MODEL EVALUATION"""

# Plotting the histogram of prediction probabilities
plt.figure(figsize=(8, 6))
plt.hist(prediction_probabilities, bins=20, color='#337FB5', edgecolor='white')
plt.xlabel('Predicted Probability')
plt.ylabel('Frequency')
plt.title('Histogram of Predicted Probabilities')
plt.show()

# Plotting the confusion matrix
def plot_confusion_matrix(cm, classes, normalize=False, title='Confusion Matrix', cmap=plt.cm.Blues):
    plt.figure(figsize=(8, 6))
    plt.imshow(cm, interpolation='nearest', cmap=cmap)
    plt.title(title)
    plt.colorbar()
    tick_marks = np.arange(len(classes))
    plt.xticks(tick_marks, classes, rotation=45)
    plt.yticks(tick_marks, classes)

    fmt = '.2f' if normalize else 'd'
    thresh = cm.max() / 2.
    for i, j in itertools.product(range(cm.shape[0]), range(cm.shape[1])):
        plt.text(j, i, format(cm[i, j], fmt),
                 horizontalalignment="center",
                 color="white" if cm[i, j] > thresh else "black")

    plt.tight_layout()
    plt.ylabel('Actual Label')
    plt.xlabel('Predicted Label')
    plt.show()

conf_matrix = confusion_matrix(true_labels_numeric, predictions_numeric)
plot_confusion_matrix(conf_matrix, classes=['Counterfeit', 'Genuine'], title='Confusion Matrix')

# Calculating the accuracy, precision, recall, f1_score

# True Positives
true_positive = conf_matrix[0, 0]
print(f'True Positive: {true_positive}')

# True Negatives
true_negative = conf_matrix[1, 1]
print(f'True Negative: {true_negative}')

# False Positives
false_positive = conf_matrix[1, 0]
print(f'False Positive: {false_positive}')

# False Negatives
false_negative = conf_matrix[0, 1]
print(f'False Negative: {false_negative}')

# Accuracy
print("\nAccuracy:")
print((true_positive + true_negative) / float(true_positive + true_negative + false_positive + false_negative))
print(accuracy_score(true_labels_numeric, predictions_numeric))

# Precision
print("\nPrecision:")
precision_calculation = true_positive / float(true_positive + false_positive)
print(precision_calculation)
print(precision_score(true_labels_numeric, predictions_numeric, pos_label=0))

# Recall
print("\nRecall:")
recall_calculation = true_positive / float(true_positive + false_negative)
print(recall_calculation)
print(recall_score(true_labels_numeric, predictions_numeric, pos_label=0))

# F1 Score
print("\nF1 Score:")
f1_score_calculation = 2 * float(precision_calculation * recall_calculation) / float(precision_calculation + recall_calculation)
print(f1_score_calculation)
print(f1_score(true_labels_numeric, predictions_numeric, pos_label=0))

# Plotting the accuracy, precision, recall, f1_score

# Metrics: accuracy, precision, recall, and F1-score
accuracy = accuracy_score(true_labels_numeric, predictions_numeric)
precision = precision_score(true_labels_numeric, predictions_numeric, pos_label=0)
recall = recall_score(true_labels_numeric, predictions_numeric, pos_label=0)
f1 = f1_score(true_labels_numeric, predictions_numeric, pos_label=0)

# Metric names and values
metrics = ['Accuracy', 'Precision', 'Recall', 'F1 Score']
values = [accuracy * 100, precision * 100, recall * 100, f1 * 100]

# Create the bar chart
plt.figure(figsize=(8, 6))
bars = plt.bar(metrics, values, color=['#96A493', '#264F78', '#4E8168', '#337FB6'])

# Add labels and title
plt.ylabel('Percentage (%)')
plt.title('Model Evaluation Metrics')
plt.ylim(0, 100)

# Display the values inside the bars
for bar in bars:
    yval = bar.get_height()
    plt.text(bar.get_x() + bar.get_width() / 2, yval - 10, f'{yval:.2f}%', ha='center', va='center', fontsize=10, color='white')

# Show the plot
plt.show()

import matplotlib.pyplot as plt
import math
import os

# Define the number of columns in the grid
num_cols = 10  # You can adjust this number to change the layout

# Calculate the number of rows needed
num_rows = math.ceil(len(image_files) / num_cols)

# Create a new figure with a size that accommodates the grid
plt.figure(figsize=(20, 5 * num_rows))  # Adjust the figure size as needed

for idx, (image_file, prediction, prediction_score) in enumerate(zip(image_files, predictions, prediction_probabilities)):
    # Create a subplot for each image
    plt.subplot(num_rows, num_cols, idx + 1)

    # Read and display the image
    img = plt.imread(image_file)
    plt.imshow(img)

    # Set the color based on the condition:
    # - Red if "genuine" in filename and result is "Fake"
    # - Red if "counterfeit" in filename and result is "Genuine"
    file_name = os.path.basename(image_file).lower()
    if ('genuine' in file_name and prediction == 'Fake') or ('fake' in file_name and prediction == 'Genuine'):
        color = 'red'
    else:
        color = 'green'

    # Set the title with filename, prediction, and score
    plt.title(f"{file_name}\n{prediction}\n(Score: {prediction_score:.4f})", color=color, fontsize=8)

    # Remove axes
    plt.axis('off')

# Adjust the layout and display the plot
plt.tight_layout()
plt.show()