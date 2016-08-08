#!/usr/bin/python3

# coding=utf-8

'''
get_private_ip.py ::

Usage:
  get_private_ip.py <stackname> <os_output>
  get_private_ip.py (-h | --help)
  get_private_ip.py --version

Options:
  -h --help            Show this screen.
  --version            Show version.
'''

import sys
import json
import pprint
import subprocess
import re
import docopt

if __name__ == '__main__':
    '''Main application get_private_ip.py'''
    #################################################################
    # Main program
    #################################################################
    get_private_ip_version = "get_private_ip.py 1.0"

    # Parse and manage arguments
    arguments = docopt.docopt(__doc__, version=get_private_ip_version)

    # pprint.pprint(arguments)

    ips = []

    outputs = json.loads(arguments['<os_output>'])

    # pprint.pprint(outputs)

    for item in outputs:
        try:
            stdout = subprocess.check_output(["openstack",
                                              "stack",
                                              "output",
                                              "show",
                                              arguments['<stackname>'],
                                              item, "-f", "json"])
            data = json.loads(stdout.decode("utf-8"))
        except subprocess.CalledProcessError as e:
            print('Command:')
            print(' '.join(e.cmd))
            sys.exit(1)

        if re.match(r'\[.+\]', data['output_value'], re.S):
            # We have a list containing the ips, so clean it and insert items
            data['output_value'] = re.sub(r'\n', '', data['output_value'])
            data['output_value'] = re.sub(r'\s', '', data['output_value'])
            data['output_value'] = re.sub(r'"', '', data['output_value'])
            data['output_value'] = re.sub(r'\[', '', data['output_value'])
            data['output_value'] = re.sub(r'\]', '', data['output_value'])
            data['output_value'] = re.sub(r'\]', '', data['output_value'])
            for ip in data['output_value'].split(','):
                ips.append(ip)
        else:
            # We have a string containing the ip
            ips.append(data['output_value'])

    # pprint.pprint(ips)

    # Output ips line by line so Ansible could use them
    for ip in ips:
        print("{}".format(ip))

    sys.exit(0)
