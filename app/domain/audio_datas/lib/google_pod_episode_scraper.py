import requests
from bs4 import BeautifulSoup
import wget # to download files
import pandas as pd
import os
import sys


def get_episode_query_url(soup, title):
    podcast = soup.find('a', {'class':'jJ8Epb'})
    # print(podcast)
    episode_url = podcast.get('href')
    episode_url = f'https://podcasts.google.com{episode_url[1:]}'
    # print(episode_url)

    return episode_url

def scrape_audio_data(episode_url):
    soup = BeautifulSoup(requests.get(episode_url).text, features="lxml")
    podcast = soup.find('div', {'class':'l80I9c'})
    # print(podcast)

    episode_name = soup.find('div', {'class':'wv3SK'}).text
    audio_data_url = podcast.get('jsdata').split(';')[1]
    return episode_name, audio_data_url

# Automatically download mp3 to local
def download_audio_data(episode_name, audio_data_url):
    # Assign the local file path
    local_file_path = f'podcast_mp3_store/{episode_name}.mp3'
    # HTTP GET Request for downloading mp3
    response = requests.get(audio_data_url)
    # Check for the HTTP status code
    if os.path.isfile(local_file_path):
        # print(f"{local_file_path}已經存在!")
        return
    elif response.status_code == 200:
        # binary-write in file
        with open(local_file_path, 'wb') as f:
            f.write(response.content)
        # print(f"下載完成: {episode_name}.mp3")
    else:
        # print(f"下載失敗: HTTP 狀態碼 {response.status_code}")
        pass

# <<<url tests>>>
# stack_overflow_pod_url = 'https://podcasts.google.com/feed/aHR0cHM6Ly9mZWVkcy5zaW1wbGVjYXN0LmNvbS9YQV84NTFrMw?sa=X&ved=0CAkQlvsGahcKEwjwqt2f9u3vAhUAAAAAHQAAAAAQAQ'
# japanese_pod_url = 'https://podcasts.google.com/search/YUYU%E3%81%AE%E6%97%A5%E6%9C%AC%E8%AA%9EPodcast%20Vol.233%20%E3%80%90%E4%BB%95%E4%BA%8B%E3%81%AE%E3%81%93%E3%81%A8%E3%80%91%E3%81%9D%E3%82%8C%E3%81%AF%E4%BB%95%E4%BA%8B%EF%BC%9F%E4%BB%95%E4%BA%8B%E3%81%94%E3%81%A3%E3%81%93%EF%BC%9F(YUYU%20Japanese%20Podcast)'
# TW_pod_url = 'https://podcasts.google.com/search/The%20KK%20Show%20-%20223%20小酷人-路易'

# Read the stdin from ruby
podcast_query_url = sys.stdin.read()
soup = BeautifulSoup(requests.get(podcast_query_url).text, features="lxml")
# This is the name of the episode
title = 'test' # soup.find('a', {'class':'jJ8Epb'}).text

# Create a new folder to contain podcasts from the same show
if not os.path.exists(f'app/domain/audio_datas/data_storage/{title}'):
    os.mkdir(f'app/domain/audio_datas/data_storage/{title}')
else:
    # print(f"The folder '{title}' already exists.")
    pass

# main
episode_url = get_episode_query_url(soup, title)
episode_name, audio_data_url = scrape_audio_data(episode_url)
download_audio_data(episode_name, audio_data_url)

# Print out value can return value for Ruby(audio_data.rb)
print(audio_data_url)