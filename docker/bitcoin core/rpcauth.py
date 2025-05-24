#!/usr/bin/env python3
# Copyright (c) 2015-2023 The Bitcoin Core developers
# Distributed under the MIT software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.

import argparse
import base64
import getpass
import hashlib
import hmac
import os
import sys

def generate_salt(size):
    """Create size byte hex salt"""
    return os.urandom(size).hex()

def generate_password():
    """Create 32 byte b64 password"""
    return base64.b64encode(os.urandom(32)).decode('utf-8')

def password_to_hmac(salt, password):
    m = hmac.new(salt.encode('utf-8'), password.encode('utf-8'), hashlib.sha256)
    return m.hexdigest()

def main():
    parser = argparse.ArgumentParser(description='Create login credentials for a JSON-RPC user')
    parser.add_argument('username', help='the username for authentication')
    parser.add_argument('password', help='leave empty to generate a random password or specify "-" to prompt for password', nargs='?')
    args = parser.parse_args()

    if not args.password:
        args.password = generate_password()
    elif args.password == '-':
        args.password = getpass.getpass()

    # Create 16 byte hex salt
    salt = generate_salt(16)
    password_hmac = password_to_hmac(salt, args.password)

    print('String to be appended to bitcoin.conf:')
    print('rpcauth={0}:{1}${2}'.format(args.username, salt, password_hmac))
    print('Your password:\n{0}'.format(args.password))

if __name__ == '__main__':
    main()