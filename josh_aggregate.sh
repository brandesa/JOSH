# --- Configuration ---
# Check if a base folder name is provided as the first argument
if [ -z "$1" ]; then
  echo "Error: No base folder name provided."
  echo "Usage: ./josh_aggregate.sh <base_folder_name>"
  echo "Example: ./josh_aggregate.sh walking-s2-gym"
  exit 1
fi

BASE_NAME=$1
RUNS_DIR="data/runs"
AGG_FOLDER="${RUNS_DIR}/${BASE_NAME}_agg"

# --- Main Logic ---

# 1. Create the aggregation directory, cleaning it out if it already exists.
echo "Preparing aggregation directory at: $AGG_FOLDER"
rm -rf "$AGG_FOLDER"
mkdir -p "$AGG_FOLDER"
mkdir -p "$AGG_FOLDER/tram"
mkdir -p "$AGG_FOLDER/deco"
mkdir -p "$AGG_FOLDER/josh"

# 2. Find all source directories matching the base name pattern (e.g., data/runs/walking-s2-gym-*)
echo "Searching for source folders in '$RUNS_DIR' matching '${BASE_NAME}-*'..."
for source_folder in ${RUNS_DIR}/${BASE_NAME}-*; do
    # Check if the found path is actually a directory
    if [ -d "$source_folder" ]; then
        echo "Processing source folder: $source_folder"

        # 3. Extract the numeric offset from the source folder name.
        # This uses parameter expansion to get the part after the last hyphen.
        offset="${source_folder##*-}"
        if ! [[ "$offset" =~ ^[0-9]+$ ]]; then
            echo "Warning: Could not extract a valid numeric offset from '$source_folder'. Skipping."
            continue
        fi
        # Force decimal interpretation (strip leading-zero octal interpretation)
        offset_dec=$((10#$offset))
        echo "  - Found offset (raw) : $offset"
        echo "  - Using offset (dec) : $offset_dec"

        # 4. Find all 'josh_*' subdirectories within the current source folder.
        for josh_dir in "$source_folder"/josh_*; do
            if [ -d "$josh_dir" ]; then
                josh_base_name=$(basename "$josh_dir")
                
                # 5. Extract start and end numbers from the 'josh_*' directory name.
                if [[ $josh_base_name =~ josh_([0-9]+)-([0-9]+) ]]; then
                    start_num=${BASH_REMATCH[1]}
                    end_num=${BASH_REMATCH[2]}
                    
                    # 6. Calculate the new numbers by adding the offset (use decimal arithmetic)
                    new_start=$((10#$start_num + offset_dec))
                    new_end=$((10#$end_num + offset_dec))
                    
                    # 7. Construct the new directory name and copy the folder.
                    new_josh_name="josh_${new_start}-${new_end}"
                    echo "    - Copying '$josh_base_name' to '$AGG_FOLDER/$new_josh_name'"
                    cp -r "$josh_dir" "$AGG_FOLDER/$new_josh_name"
                    

                    new_josh_dir="$AGG_FOLDER/$new_josh_name"
                    original_scene_file="$new_josh_dir/scene_${start_num}_${end_num}.pkl"
                    original_hps_file="$new_josh_dir/hps_track_0.npy"
                    new_scene_file="$new_josh_dir/scene_${new_start}_${new_end}.pkl"
                    new_hps_file="$new_josh_dir/hps_track_${offset_dec}.npy"

                    if [ -f "$original_scene_file" ]; then
                        echo "      - Renaming scene file to '$new_scene_file'"
                        mv "$original_scene_file" "$new_scene_file"
                        echo "      - Renaming HPS file to '$new_hps_file'"
                        mv "$original_hps_file" "$new_hps_file"
                    else
                        echo "      - Warning: Original scene file '$original_scene_file' not found. Cannot rename."
                    fi
                else
                    echo "    - Warning: Could not parse start/end numbers from '$josh_base_name'. Skipping."
                fi
            fi
        done

        # --- Process tram directory ---
        tram_dir="$source_folder/tram"
        if [ -d "$tram_dir" ]; then
            echo "  - Processing tram files..."
            for tram_file in "$tram_dir"/hps_track_*.npy; do
                if [ -f "$tram_file" ]; then
                    base_name=$(basename "$tram_file")
                    if [[ $base_name =~ hps_track_([0-9]+)\.npy ]]; then
                        track_num=${BASH_REMATCH[1]}
                        # ensure decimal interpretation (handle leading zeros)
                        new_track_num=$((10#$track_num + offset_dec))
                        new_filename="hps_track_${new_track_num}.npy"
                        echo "    - Copying '$base_name' to '$AGG_FOLDER/tram/$new_filename'"
                        cp "$tram_file" "$AGG_FOLDER/tram/$new_filename"
                    else
                        echo "    - Warning: Could not parse track number from '$base_name'. Copying as is."
                        cp "$tram_file" "$AGG_FOLDER/tram/"
                    fi
                fi
            done
        fi

        # --- Process deco directory ---
        deco_dir="$source_folder/deco"
        if [ -d "$deco_dir" ]; then
            echo "  - Processing deco files..."
            for deco_file in "$deco_dir"/hps_track_*.npy; do
                if [ -f "$deco_file" ]; then
                    base_name=$(basename "$deco_file")
                    if [[ $base_name =~ hps_track_([0-9]+)\.npy ]]; then
                        track_num=${BASH_REMATCH[1]}
                        # ensure decimal interpretation (handle leading zeros)
                        new_track_num=$((10#$track_num + offset_dec))
                        new_filename="hps_track_${new_track_num}.npy"
                        echo "    - Copying '$base_name' to '$AGG_FOLDER/deco/$new_filename'"
                        cp "$deco_file" "$AGG_FOLDER/deco/$new_filename"
                    else
                        echo "    - Warning: Could not parse track number from '$base_name'. Copying as is."
                        cp "$deco_file" "$AGG_FOLDER/deco/"
                    fi
                fi
            done
        fi


    fi
done

# 8. Confirm completion
echo "Aggregation complete. All 'josh_*' directories have been copied and renamed in $AGG_FOLDER"


input_folder="$AGG_FOLDER"
conda activate josh

python josh/aggregate_results.py  --input_folder "$input_folder" --visualize --range $2 $3
