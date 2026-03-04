data_folder=$1
input_folder=$2
conda activate josh

echo "Extracting frames from: $data_folder -> $input_folder"
python josh/load_img.py --input_folder $data_folder --output_folder $input_folder --range $3 $4
# write zero-padded 6-digit filenames starting at 000000.jpg
python -m preprocess.run_sam3 --input_folder $input_folder  
python -m preprocess.run_tram --input_folder $input_folder  
python -m preprocess.run_deco --input_folder $input_folder  

-----------------------------
check number of extracted images
-----------------------------
num_imgs=$(find "$input_folder/rgb" -maxdepth 1 -type f -name "*.jpg" | wc -l)
echo "Found $num_imgs images in $input_folder"

if [ "$num_imgs" -ge 200 ]; then
    echo "Found $num_imgs images (>= 200). Running chunk processing..."
    python josh/inference_long_video.py --input_folder "$input_folder" --interval_length 60
    python josh/aggregate_results.py  --input_folder "$input_folder" --visualize --range $3 $4
else
    python josh/inference.py --input_folder "$input_folder" --visualize --range $3 $4
fi

# -----------------------------
# Copy all .pkl results to a central folder
# -----------------------------
# LOGS_FOLDER="$input_folder/josh"
# offset=${3:-0} # Use the third argument as an offset, default to 0 if not provided

# # Ensure the offset is a valid integer
# if ! [[ "$offset" =~ ^[0-9]+$ ]]; then
#     echo "Error: The third argument (offset) must be an integer. Got: '$offset'"
#     exit 1
# fi

# echo "Searching for .pkl files in '$input_folder/josh_*'..."
# # Find all files named *.pkl inside any directory matching josh_*
# files_to_copy=$(find "$input_folder" -type d -name "josh_*" -print0 | xargs -0 -I {} find {} -type f -name "*.pkl")

# if [ -z "$files_to_copy" ]; then
#     echo "No .pkl files found to copy."
# else
#     echo "Copying found .pkl files to '$LOGS_FOLDER' with an offset of $offset..."
#     for file in $files_to_copy; do
#         # Get just the filename, e.g., "scene_0_60.pkl"
#         base_name=$(basename "$file")
        
#         # Extract the numbers from the filename using a regex
#         if [[ $base_name =~ scene_([0-9]+)_([0-9]+)\.pkl ]]; then
#             start_num=${BASH_REMATCH[1]}
#             end_num=${BASH_REMATCH[2]}
            
#             # Calculate the new numbers by adding the offset
#             new_start=$((start_num + offset))
#             new_end=$((end_num + offset))
            
#             # Construct the new filename
#             new_name="scene_${new_start}_${new_end}.pkl"
            
#             # Copy the file with the new name
#             cp "$file" "$LOGS_FOLDER/$new_name"
#         else
#             # If the filename doesn't match, copy it as is
#             echo "Warning: Filename '$base_name' does not match expected pattern 'scene_start_end.pkl'. Copying without renaming."
#             cp "$file" "$LOGS_FOLDER/"
#         fi
#     done
# fi
# echo "Done. All found .pkl files have been copied to $LOGS_FOLDER"