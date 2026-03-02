data_folder=$1
input_folder=$2
conda activate josh

# echo "Extracting frames from: $data_folder -> $input_folder"
# python josh/load_img.py --input_folder $data_folder --output_folder $input_folder --range $3 $4
# # write zero-padded 6-digit filenames starting at 000000.jpg
# python -m preprocess.run_sam3 --input_folder $input_folder  
# python -m preprocess.run_tram --input_folder $input_folder  
# python -m preprocess.run_deco --input_folder $input_folder  

# -----------------------------
# check number of extracted images
# -----------------------------
# num_imgs=$(find "$input_folder/rgb" -maxdepth 1 -type f -name "*.jpg" | wc -l)
# echo "Found $num_imgs images in $input_folder"

# if [ "$num_imgs" -ge 200 ]; then
#     echo "Found $num_imgs images (>= 200). Running chunk processing..."
#     python josh/inference_long_video.py --input_folder "$input_folder" --interval_length 60
#     python josh/aggregate_results.py  --input_folder "$input_folder" --visualize
# else
#     python josh/inference.py --input_folder "$input_folder" --visualize --range $3 $4
# fi

# -----------------------------
# Copy all .pkl results to a central folder
# -----------------------------
LOGS_FOLDER="$input_folder/josh"

echo "Searching for .pkl files in '$input_folder/josh_*'..."
# Find all files named *.pkl inside any directory matching josh_*
files_to_copy=$(find "$input_folder" -type d -name "josh_*" -print0 | xargs -0 -I {} find {} -type f -name "*.pkl")

if [ -z "$files_to_copy" ]; then
    echo "No .pkl files found to copy."
else
    echo "Copying found .pkl files to '$LOGS_FOLDER'..."
    for file in $files_to_copy; do
        cp "$file" "$LOGS_FOLDER"
    done
fi
echo "Done. All found .pkl files have been copied to $LOGS_FOLDER"