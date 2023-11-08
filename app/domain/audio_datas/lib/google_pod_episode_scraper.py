import requests
from bs4 import BeautifulSoup
import wget # to download files
import pandas as pd
import os


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


stack_overflow_pod_url = 'https://podcasts.google.com/feed/aHR0cHM6Ly9mZWVkcy5zaW1wbGVjYXN0LmNvbS9YQV84NTFrMw?sa=X&ved=0CAkQlvsGahcKEwjwqt2f9u3vAhUAAAAAHQAAAAAQAQ'
japanese_pod_url = 'https://podcasts.google.com/search/YUYU%E3%81%AE%E6%97%A5%E6%9C%AC%E8%AA%9EPodcast%20Vol.233%20%E3%80%90%E4%BB%95%E4%BA%8B%E3%81%AE%E3%81%93%E3%81%A8%E3%80%91%E3%81%9D%E3%82%8C%E3%81%AF%E4%BB%95%E4%BA%8B%EF%BC%9F%E4%BB%95%E4%BA%8B%E3%81%94%E3%81%A3%E3%81%93%EF%BC%9F(YUYU%20Japanese%20Podcast)'
TW_pod_url = 'https://podcasts.google.com/search/The%20KK%20Show%20-%20223%20小酷人-路易'
URLs = [TW_pod_url]
info_list = []
for url in URLs:
    soup = BeautifulSoup(requests.get(url).text, features="lxml")
    # This is the name of the show
    title = 'test' #soup.find('a', {'class':'jJ8Epb'}).text
    # print(soup)

    # make a new folder to contain podcasts from the same show
    if not os.path.exists(f'app/domain/audio_datas/data_storage/{title}'):
        os.mkdir(f'app/domain/audio_datas/data_storage/{title}')
    else:
        # print(f"The folder '{title}' already exists.")
        pass

    episode_url = get_episode_query_url(soup, title)
    episode_name, audio_data_url = scrape_audio_data(episode_url)
    info_list.append([episode_name, audio_data_url])

# info_all_podcasts = pd.concat(info_list)
episode_name, audio_data_url = info_list[0][0], info_list[0][1]
print(episode_name)
print(audio_data_url)
