import argparse
import os
from josh.utils.image_utils import save_images_to_folder, clear_folder



if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Load images from a .npz file and save them to a folder.")
    parser.add_argument("--input_folder_path", type=str, required=True, help="Path to the input .npz file containing images.")
    parser.add_argument("--output_folder_path", type=str, required=True, help="Path to the output folder where images will be saved.")
    parser.add_argument("--range", type=int, nargs=2, default=[0, 100], help="Range of images to save (e.g., 0 100 for the first 100 images).")

    args = parser.parse_args()

    #create img folder if it doesn't exist
    img_folder = args.output_folder_path + "/rgb"
    if not os.path.exists(img_folder):
        os.makedirs(img_folder)
        
    clear_folder(args.output_folder_path + "/mask")
    clear_folder(args.output_folder_path + "/vis")
    save_images_to_folder(args.input_folder_path, img_folder, args.range)