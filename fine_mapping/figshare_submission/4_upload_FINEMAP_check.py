#!/usr/bin/env python

import sys

from figshare_API_misc import *

####################
# constants
token_file = '/home/users/ytanigaw/.figshare.token.NIH.txt'
base_URL = 'https://api.figshare.com/v2/{endpoint}'

####################
# list the files in the FINEMAP dataset
list_files_of_article(base_URL, article_id=12344351, token=read_token(token_file))
