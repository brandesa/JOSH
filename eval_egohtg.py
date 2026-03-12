EVAL_XHALL = [
    "exo-standing_s1_xhall_01",
    "exo-standing_s4_xhall_01",
    "exo-standing_s5_xhall_01",
    "exo-standing_s6_xhall_01",
    "exo-walking_s1_xhall_01",
    "exo-walking_s4_xhall_01",
    "exo-walking_s5_xhall_01",
    "exo-high-object_s4_xhall_01",
    "exo-high-object_s5_xhall_01",
    "exo-high-object_s6_xhall_01",
    "exo-cliff-stones_s4_xhall_01",
    "exo-cliff-stones_s5_xhall_01",
    "exo-parkour_s1_xhall_01",
    "exo-parkour_s4_xhall_01",
    "exo-parkour_s5_xhall_01",
    "exo-parkour_s6_xhall_01",
]

EXOMC_XHALL = [
    "exomc-parkour_xhall_01",
    "exomc-parkour_xhall_02",
    "exomc-parkour_xhall_03",
    "exomc-parkour_xhall_04",
    "exomc-parkour_xhall_05",
    "exomc-parkour_xhall_06",
]

LEE = [
    "double-stairs_lee_01",
    "double-stairs_lee_02",
]

XHALL1 = [
    "stepping-stones_xhall_01",
    "high-object_xhall_01",
    "double-high-object_xhall_01",
    "narrow-path_xhall_01",
    "cliff-path_xhall_01",
    "crawling_xhall_01",
]

XHALL2 = [
    "exomc-parkour_xhall_01",
    "exomc-parkour_xhall_02",
    "exomc-parkour_xhall_03",
    "exomc-parkour_xhall_04",
    "exomc-parkour_xhall_05",
    "exomc-parkour_xhall_06",
]

XHALL3 = [
    "exo-standing_s1_xhall_01",
    "exo-standing_s4_xhall_01",
    "exo-standing_s5_xhall_01",
    "exo-standing_s6_xhall_01",
    "exo-walking_s1_xhall_01",
    "exo-walking_s4_xhall_01",
    "exo-walking_s5_xhall_01",
    "exo-high-object_s4_xhall_01",
    "exo-high-object_s5_xhall_01",
    "exo-high-object_s6_xhall_01",
    "exo-cliff-stones_s4_xhall_01",
    "exo-cliff-stones_s5_xhall_01",
    "exo-parkour_s4_xhall_01",
    "exo-parkour_s5_xhall_01",
]

GYM = [
    "climbing_s3_gym_01",
    "crawling_s3_gym_01",
    "double-high-object_s2_gym_01",
    "overhang-object_s2_gym_03",
    "parkour_s1_gym_01",
    "parkour_s1_gym_02",
    "parkour_s1_gym_03",
    "parkour_s3_gym_01",
    "walking_s2_gym_01",
]

GYM2 = [
    "parkour_s1_gym_04",
    "parkour_s1_gym_05",
    "parkour_s1_gym_06",
    "parkour_s1_gym_07",
    "parkour_s1_gym_08"
]

BZB = [
    "crawling_s1_bzb_01",
    "crawling_s1_bzb_02",
    "crawling_s1_bzb_03",       
    "cliff_s4_bzb_01",
    "cliff_s4_bzb_02",
    "cliff-jump_s4_bzb_01",
    "cliff-jump_s4_bzb_02",
    "window_s4_bzb_01",
    "rescue_s4_bzb_01",
    "rocky-path_s7_bzb_01",
    "rocky-path_s7_bzb_02",
    "window-rocky_s7_bzb_01",
    "window-rocky_s7_bzb_02",
    "walking_s7_bzb_01",
    "walking_rocky_s7_bzb_01",
    "walking_rocky_s7_bzb_02",
    "cliff-jump_s7_bzb_01",
    "cliff_s8_bzb_01",
    "cliff-jump_s8_bzb_01",
    "window_s8_bzb_01",
    "rescue_s8_bzb_01",
    "rocky-path_s8_bzb_01",
]

EVAL = XHALL2 + XHALL3
ALL = EVAL + LEE + XHALL1 + GYM + GYM2 + BZB
JOSH = [ 
    "walking_s2_gym_01",
] + GYM2 + BZB + XHALL3

import subprocess
from pathlib import Path

import argparse
import traceback
import numpy as np
import argparse


def log_error(path: Path, seq_name: str, exc: BaseException) -> None:
    """Append an error with traceback to the error log file."""
    log_path = path
    log_path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a") as f:
        f.write(f"\n=== Error: {seq_name} ===\n")
        traceback.print_exception(type(exc), exc, exc.__traceback__, file=f)
        f.write("\n")

def get_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="JOSH EVAL on Human Terrain Data Generation.")
    parser.add_argument("--sequence", type=str, default='', help="Specific sequence to process.")
    return parser.parse_args()


if __name__ == "__main__":
    args = get_args()

    seq_root = Path("/home/brandesa/mt/human_terrain_generation/data/sequences")
    logs_root = Path("/home/brandesa/mt/JOSH/logs")

    if args.sequence != '':
        sequences = [args.sequence]
    else:
        sequences = JOSH
        
        
    for seq in sequences:
        # Create SequenceContext
        data_dir = seq_root / seq

        #get data length
        data = np.load(data_dir / "full_sequence.npz", allow_pickle=True)
        images_array = data['aria_obs_rgb_imgs']
        length = images_array.shape[0]
        
        #iterate over chunks of 600 frames (20 seconds at 30 fps)
        chunk_size = 600
        start_index = 150
        end_index = 0
        
        for i in range(start_index, length, chunk_size):
            relative_start_index = i - start_index
            relative_end_index = relative_start_index + chunk_size
            if i + chunk_size > length:
                end_index = i
                break
            
            print(f"[INFO]: Processing sequence {seq}, frames {i} to {i + chunk_size}")
            input_folder = f"data/runs/{seq}/{seq}_{relative_start_index:05d}"
            command_run = ["bash", "josh_run.sh", str(data_dir), input_folder, str(relative_start_index), str(relative_end_index)]
            try:
                raise NotImplementedError("JOSH run script is not implemented yet.")
                # subprocess.run(command_run)
            except Exception as e:
                print(f"Error occurred while processing sequence {seq}: {e}")
                log_error(logs_root / seq / f"run_{relative_start_index:05d}.log", seq, e)
        
        base_folder = f"data/runs/{seq}/{seq}"  
        command_aggregate = ["bash", "josh_aggregate.sh", base_folder, str(start_index), str(end_index)]
        try:
            subprocess.run(command_aggregate)
        except Exception as e:
            print(f"Error occurred while aggregating results for sequence {seq}: {e}")
            log_error(logs_root / seq / f"agg.log"  , seq, e)