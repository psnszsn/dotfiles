#!/bin/python

import sys
from gi.repository import Gio
Gio.DesktopAppInfo.new_from_filename(sys.argv[1]).launch_uris(sys.argv[2:])
