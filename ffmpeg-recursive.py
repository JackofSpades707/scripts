#!/usr/bin/python3

import os
from argparse import ArgumentParser
from paramiko import SFTPClient

parser = ArgumentParser()
parser.add_argument('--noconfirm', help='disable confirmation prompt before conversions begin', action='store_true', default=False)
parser.add_argument('-v', '--verbose', help='display verbose information', action='store_true', default=False)
parser.add_argument('-s', '--save', help='save original files', action='store_true', default=False)
#parser.add_argument('--backup', help='archive original files', default=False)
args = parser.parse_args()

video_formats = ['.mkv', '.mp4', '.webm', '.flv', '.mov', '.avi', '.wmv', '.mpg', '.mpeg', '.m2v', '.m4p']

converted_videos = []

def recursive_walk(folder):
    for folderName, subfolders, filenames in os.walk(folder):
        if subfolders:
            for subfolder in subfolders:
                recursive_walk(subfolder)
        for filename in filenames:
            for video_format in video_formats:
                if video_format in filename:
                    yield (folderName, filename)

def clean_and_sort_queue(queue):
    '''
    Removes any duplicate jobs &
    Sorts the job queue Alphabetically
    '''
    return sorted(list(set(queue)))

def create_queue():
    '''
    Queue's conversion jobs up
    '''
    def output_and_prompt():
        if args.verbose:
            for i, job in enumerate(queue):
                print('[{i}] - {f}').format(i=i, f=job[1])
        if args.noconfirm is False:
            prompt = input('Would you like to convert {} files? [Y/n] \n> '.format(len(queue))).lower()
            if 'n' in prompt:
                print("Bye!")
                raise SystemExit
    queue = []
    cwd = os.getcwd()
    while True:
        try:
            queue.append(recursive_walk(cwd))
        except IndexError:
            break
        except Exception as e:
            print('[!] Fatal Error Below [!]\n')
            print(e, e.args)
            raise SystemExit
    output_and_prompt()
    return queue


def convert(path, filename, job_num):
    '''
    Does the converting
    '''
    cmd = 'ffmpeg -i "{p}/{f}" -c:v libx264 -crf 23 -c:a aac -strict -2 "{p}/output{f}" -hide_banner -nostats -loglevel error'.format(f=filename, p=path)
    if args.verbose:
        print(cmd)
    if filename not in converted_videos:
        print("[+] Converting: {}".format(filename))
        os.system(cmd)
        try:
            replace(path, filename, job_num)
        except FileNotFoundError:
            print('[!] Error: {} Not converted!'.format(filename))
        converted_videos.append(filename)


def replace(path, filename, job_num):
    outputfile = '{p}/{jn}{f}'.format(p=path, jn=job_num, f=filename)
    inputfile = '{}/{}'.format(path, filename)
    if args.verbose:
        print("Deleting {}".format(inputfile))
    if args.save is False:
        os.remove(inputfile)
        if args.verbose:
            print("Moving {} to {}".format(inputfile, outputfile))
        os.rename(outputfile, inputfile)

def Main():
    categories = ['Anime', 'TV Shows', 'Movies']
    for i, category in enumerate(categories):
        print('[{}] - {}'.format(i, category))
    prompt = int(input('> '))

    
    queue = create_queue()
    queue = clean_and_sort_queue(queue)
    host = os.environ.get('plexpi').split('@')
    for job_num, job in enumerate(queue):
        path = job[0]
        filename = job[1]
        convert(path, filename, job_num) # job[0]=path job[1]=filename


if __name__ == '__main__':
    Main()
