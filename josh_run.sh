data_folder=$1
input_folder=$2
conda activate josh

echo "Extracting frames from: $data_folder -> $input_folder"
python josh/load_img.py --input_folder $data_folder --output_folder $input_folder --range $3 $4
# write zero-padded 6-digit filenames starting at 000000.jpg
python -m preprocess.run_sam3 --input_folder $input_folder  
python -m preprocess.run_tram --input_folder $input_folder  
python -m preprocess.run_deco --input_folder $input_folder  

# -----------------------------
# check number of extracted images
# -----------------------------
num_imgs=$(find "$rgb_dir" -maxdepth 1 -type f -name "*.jpg" | wc -l)

if [ "$num_imgs" -ge 200 ]; then
    echo "Found $num_imgs images (>= 200). Running chunk processing..."
    python josh/inference_long_video.py --input_folder "$input_folder"
    python josh/aggregate_results.py  --input_folder "$input_folder" --visualize
else
    python josh/inference.py --input_folder "$input_folder" --visualize --range $3 $4
fi