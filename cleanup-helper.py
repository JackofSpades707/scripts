#!/usr/bin/python3
import os
import fnmatch

bullshit_formats_lower_case = ['*.nfo', '*.rar', '*.zip', '*.r??', '*.png', '*.jpg', '*.jpeg', '*.srt', 'sample.*', '*.idx', '*.sub', '*.sfv', '*tak', '*.jp2', '*.ass' '*.sfv', '*.cue', '*.log', '*.bmp', '*.tif', '*.txt', '.tar.??', '.tar.???', '.tar', '*.torrent', '*.html']
bullshit_formats_upper_case = ['*.NFO', '*.RAR', '*.ZIP', '*.R??', '*.PNG', '*.JPG', '*.JPEG', '*.SRT', 'SAMPLE.*', '*.IDX', '*.SUB', '*.SFV', '*TAK', '*.JP2', '*.ASS' '*.SFV', '*.CUE', '*.LOG', '*.BMP', '*.TIF', '*.TXT', '.TAR.??', '.TAR.???', '.TAR', '*.TORRENT', '*.HTML']
audio_formats = []
video_formats = []
bullshit_formats = bullshit_formats_lower_case + bullshit_formats_upper_case
delete_count = 0

def recursive_walk(folder):
    for folderName, subfolders, filenames in os.walk(folder):
        if subfolders:
            for subfolder in subfolders:
                recursive_walk(subfolder)
        for filename in filenames:
            for bullshit_format in bullshit_formats:
                if fnmatch.fnmatch(filename, bullshit_format):
                    delete(folderName, filename)

def delete(path, filename):
    try:
        global delete_count
        # global audio_count
        # global video_count
        file = "{}/{}".format(path, filename)
        print("Deleting {}".format(filename))
        os.remove(file)
        delete_count += 1
    except FileNotFoundError:
        print("ERROR: {} Not Found".format(filename))

def Main():
    print("Cleanup helper here to save the day :)")
    cwd = os.getcwd()
    folders = ['Videos', 'Music']
    for folder in folders:
        recursive_walk('{}/{}'.format(cwd, folder))
    if delete_count == 0:
        print("Everything was already cleaned up :)")
    else:
        print("Cleaned up {} files :)".format(delete_count))


if __name__ == '__main__':
    Main()

