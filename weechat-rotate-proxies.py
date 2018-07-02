#!/usr/bin/env python3
# -*- coding: utf-8 -*-


#TODO: Test, Debug, Refactor, Extend functionality

SCRIPT_NAME = 'ProxyRotator'
SCRIPT_AUTHOR = 'JackofSpades707'
SCRIPT_VERSION = '1.0'
SCRIPT_LICENSE = 'MIT'
SCRIPT_DESC = 'Hide public IP on IRC servers with rotating proxies'
SCRIPT_COMMAND = 'ProxyRotator'
SCRIPT_BUFFER = 'ProxyRotator'

try:
    import weechat
    IMPORT_OK = True
except ImportError:
    IMPORT_OK = False
    print("Please run this using weechat")

try:
    import re
    import os
    import time
    import requests
except ImportError as err:
    print("Missing Required Package for {}: {}".format(SCRIPT_NAME, err))

def setup_proxy(proxy):
    return {'http': 'http://{}'.format(proxy), 'https': 'https://{}'.format(proxy)}

def check(proxy, timeout=settings['timeout'][0]):
    '''
    :param proxy: proxy to check
    :param timeout: max time in seconds for connect/read
    :return bool: True if valid proxy, False if failed to connect proxy
    '''
    reqproxy = setup_proxy(proxy)
    ip = proxy.split(':')[0]
    url = 'http://icanhazip.com'
    r = requests.get(url, proxies=reqproxy, timeout=timeout)
    if url in r.url and r.status_code == 200 or ip in r.text:
        return True
    return False

def fetch_proxies(proxy_source, mode=None):
    '''
    :param proxy_source: URL or filename to fetch proxies from
    :param mode: mode for fetching proxies
    :return proxies: list of proxies
    mode='file' -> specifies proxy_source as filename of proxies
    mode='url' -> specifies proxy_source as url of proxies
    mode=None -> intelligently resolves proxy_source as either filename or url
    '''
    # modes ['smart', 'file', 'url']
    def read_proxies_from_file(filename):
        try:
            with open(proxy_source) as f:
                proxies = f.readlines()
        except FileNotFoundError:
            print("File {} not found".format(proxy_source))
        return proxies

    def read_proxies_from_url(url):
        r = requests.get(url)
        proxies = re.findall(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d{1,5}', r.text)
        return proxies

    def read_proxies(source):
        if mode.lower() == 'url' or 'http://' in proxy_source or 'https://' in proxy_source or 'ftp://' in proxy_source or 'sftp://' in proxy_source:
            return read_proxies_from_url(proxy_source)
        elif mode.lower() == 'file' or os.path.isfile(proxy_source):
            return read_proxies_from_file(proxy_source)

    proxies = []
    if type(proxy_source) == list:
        for source in proxy_source:
            proxies.append(read_proxies(source))
    else:
        return read_proxies(proxy_source)

def rotate_proxy(proxies, proxy_position, interval):
    '''
    rotates to next proxy in proxylist
    '''
    try:
        proxy_position += 1
        proxy = proxies[proxy_position]
    except IndexError:
        proxy_position = 0
        proxy = proxies[proxy_position]
    return proxy, proxy_position, interval + 1

def next_proxy(proxies, proxy_position, interval):
    proxy = proxies[proxy_position]
    while check(proxy) is False:
        proxy, proxy_position, interval = rotate_proxy(proxies, proxy_position, interval)
    return proxy, proxy_position, interval

def clean_proxies(proxies):
    new_proxies = []
    for proxy in proxies:
        if check(proxy) is True:
            new_proxies.append(proxy)
    return new_proxies

def default_settings():
    global settings
    settings = {
        'timeout': [5, "timeout for checking proxy validity"],
        'timer': [300, "time to wait between changing proxy"], # 5 mins
        'proxy_source': ['proxies.txt', "location of proxies, can be a single URL/filename or a list of URLs/Filenames"],
        'autoclean': [True, "Filter invalid proxies periodically"],
        'autoclean_interval': [None, "How many iterations shall be processed before filtering invalid proxies from the proxylist? This should be an integer"],
        'autostart': [False, "Automatically start ProxyRotator"]}

    
def ProxyRotator():
    #TODO: define -> filename, timeout, timer
    proxies = fetch_proxies(settings['proxy_source'][0])
    proxy_position = 0
    proxy = proxies[proxy_position]
    interval = 0
    default_settings()
    settings['autoclean_interval'][0] = len(proxies)
    while True:
        proxy, proxy_position, interval = next_proxy(proxies, proxy_position, interval)
        # set weechat proxy here
        if interval >= settings['autoclean_interval'][0]:
            proxies = clean_proxies(proxies)
        time.sleep(settings['timer'][0])


if __name__ == '__main__':
    if weechat.register(SCRIPT_NAME, SCRIPT_AUTHOR, SCRIPT_VERSION, SCRIPT_LICENSE, SCRIPT_DESC, "ProxyRotator_end", ''):
        version = weechat.info_get('version_number', '') or 0
        for option, value in settings.items():
            if weechat.config_is_set_plugin(option):
                settings[option] = weechat.config_get_plugin(option)
            else:
                weechat.config_set_plugin(option, value[0])
            if int(version) >= 0x00030500:
                weechat.config_set_desc_plugin(option, '{} (default: {})'.format(value[1], value[0]))
        # Detect Config Changes
        weechat.hook_config('plugins.var.python.{}'.format(SCRIPT_NAME), 'ProxyRotator_config_cb', '')
        # Add command
        weechat.hook_command(SCRIPT_COMMAND, SCRIPT_DESC, 
            "start|stop|restart|update|buffer",
            "start: starts ProxyRotator",
            "stop: stops ProxyRotator & restores default proxy setting",
            "restart: restarts ProxyRotator",
            "update: updates setting",
            "buffer: creates buffer for logging output too")
        if settings['autostart'][0] is True:
            ProxyRotator()
        # Buffer
        weechat.hook_print('', '', '://', 1, 'ProxyRotator_config_cb', '')

