#!/usr/bin/env python

import sys

from figshare_API_misc import *

####################
# argv
file_name = sys.argv[1]

####################
# constants
token_file = '/home/users/ytanigaw/.figshare.token.NIH.txt'
base_URL = 'https://api.figshare.com/v2/{endpoint}'
article_id = 12355424 # multi-PRS

####################
# API auth
token = read_token(token_file)
list_files_of_article(base_URL, article_id, token)

# Then we upload the file.
file_info = initiate_new_upload(base_URL, article_id, file_name, token)

# Until here we used the figshare API; following lines use the figshare upload service API.
upload_parts(file_info, file_name, token)

# We return to the figshare API to complete the file upload process.
complete_upload(base_URL, article_id, file_info['id'], token)
