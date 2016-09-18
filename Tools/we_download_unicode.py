#
# excised from makeunicodedata.py from ucdn project
#
# orignal file written by Fredrik Lundh (fredrik@pythonware.com)
#

import os
import sys

if sys.version_info[0] < 3:
    from urllib import urlretrieve
else:
    from urllib.request import urlretrieve

SCRIPT = sys.argv[0]

# which unicode file to download
if len(sys.argv) > 1:
    GENFILE = sys.argv[1]
else:
    print("usage: ./we_download_unicode.py [file] [version]")
    sys.exit(1)

# which unicode version to use
if len(sys.argv) > 2:
    UNIDATA_VERSION = sys.argv[2]
else:
    UNIDATA_VERSION = "9.0.0"

def download_data(template, version):
    local = template % ('-'+version,)
    if not os.path.exists(local):
        if version == '3.2.0':
            # irregular url structure
            url = 'http://www.unicode.org/Public/3.2-Update/' + local
        else:
            url = ('http://www.unicode.org/Public/%s/ucd/'+template) % (version, '')
        urlretrieve(url, filename=local)

if GENFILE.count("%s") < 1:
    GENFILE = GENFILE.replace(".", "%s.")

download_data(GENFILE, UNIDATA_VERSION)
sys.exit(0)

