import hashlib
import json
import os

import requests
from requests.exceptions import HTTPError


def read_token(token_file):
    '''
    We read the access token from a file.
    
    You can generate a token from https://nih.figshare.com/account/applications
    and save it to a safe place (like /home/users/ytanigaw/.figshare.token.NIH.txt)    
    '''
    with open(token_file) as f:
        k = f.read()
    return k


# We copied the example Python file from 
# https://docs.figshare.com/#upload_files_example_upload_on_figshare
# and save its functions as a separate file


def raw_issue_request(method, url, token, data=None, binary=False):
    headers = {'Authorization': 'token ' + token}
    if data is not None and not binary:
        data = json.dumps(data)
    response = requests.request(method, url, headers=headers, data=data)
    try:
        response.raise_for_status()
        try:
            data = json.loads(response.content)
        except ValueError:
            data = response.content
    except HTTPError as error:
        print('Caught an HTTPError: {}'.format(error.message))
        print('Body:\n', response.content)
        raise

    return data


def issue_request(method, base_URL, endpoint, token, *args, **kwargs):
    return raw_issue_request(method, base_URL.format(endpoint=endpoint), token, *args, **kwargs)


def list_articles(base_URL, token):
    result = issue_request('GET', base_URL, 'account/articles', token)
    print('Listing current articles:')
    if result:
        for item in result:
            print(u'  {url} - {title}'.format(**item))
    else:
        print('  No articles.')
    print('')

def create_article(title, base_URL, token):
    data = {
        'title': title  # You may add any other information about the article here as you wish.
    }
    result = issue_request('POST', base_URL, 'account/articles', token, data=data)
    print('Created article:', result['location'], '\n')

    result = raw_issue_request('GET', result['location'], token)

    return result['id']


def list_files_of_article(base_URL, article_id, token):
    result = issue_request('GET', base_URL, 'account/articles/{}/files'.format(article_id), token)
    print('Listing files for article {}:'.format(article_id))
    if result:
        for item in result:
            print('  {id} - {name}'.format(**item))
    else:
        print('  No files.')
    print('')


def get_file_check_data(file_name, chunk_size):
    with open(file_name, 'rb') as fin:
        md5 = hashlib.md5()
        size = 0
        data = fin.read(chunk_size)
        while data:
            size += len(data)
            md5.update(data)
            data = fin.read(chunk_size)
        return md5.hexdigest(), size


def initiate_new_upload(base_URL, article_id, file_name, token, chunk_size=1048576):
    endpoint = 'account/articles/{}/files'
    endpoint = endpoint.format(article_id)

    md5, size = get_file_check_data(file_name, chunk_size)
    data = {'name': os.path.basename(file_name),
            'md5': md5,
            'size': size}

    result = issue_request('POST', base_URL, endpoint, token, data=data)
    print('Initiated file upload:', result['location'], '\n')

    result = raw_issue_request('GET', result['location'], token)

    return result


def complete_upload(base_URL, article_id, file_id, token):
    issue_request('POST', base_URL, 'account/articles/{}/files/{}'.format(article_id, file_id), token)


def upload_parts(file_info, file_name, token):
    url = '{upload_url}'.format(**file_info)
    result = raw_issue_request('GET', url, token)

    print('Uploading parts:')
    with open(file_name, 'rb') as fin:
        for part in result['parts']:
            upload_part(file_info, fin, part, token)
    print('')


def upload_part(file_info, stream, part, token):
    udata = file_info.copy()
    udata.update(part)
    url = '{upload_url}/{partNo}'.format(**udata)

    stream.seek(part['startOffset'])
    data = stream.read(part['endOffset'] - part['startOffset'] + 1)

    raw_issue_request('PUT', url, token, data=data, binary=True)
    print('  Uploaded part {partNo} from {startOffset} to {endOffset}'.format(**part))
