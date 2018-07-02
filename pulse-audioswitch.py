#!/usr/bin/env python3
'''
dependencies = pactl
'''

from sh import pactl

def parse_pactl(cmd):
    ''' >_ pactl $cmd -> array '''
    array = [i.split('\t') for i in pactl(cmd).splitlines()]
    return array

def get_streams():
    return parse_pactl(['list', 'short', 'sink-inputs'])

def get_devices():
    return parse_pactl(['list', 'short', 'sinks'])

def change_device(stream_id, target_device_id):
    pactl(['move-sink-input', stream_id, target_device_id])

def toggle():
    ''' >_ pactl move-sink-input $stream_id $device_id '''
    devices = get_devices()
    streams = get_streams()
    device_ids = []
    stream_ids = []
    active_device = streams[0][1]
    for device in devices:
        device_ids.append(device[0])
    for stream in streams:
        stream_ids.append(stream[0])
    for device_id in device_ids:
        if active_device != device_id:
            target_device_id = device_id
    for stream_id in stream_ids:
        change_device(stream_id, target_device_id)


if __name__ == '__main__':
    toggle()
