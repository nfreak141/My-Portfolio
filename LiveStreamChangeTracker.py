# -*- coding: utf-8 -*-
"""
Created on Wed Apr 29 17:04:45 2020.

@author: ctjc1
"""

from bs4 import BeautifulSoup  # for scraping
import requests                # required for reading the file
from datetime import datetime
import time


def getVideoDetails():
    """
    Get the video details.

    Returns
    -------
    Vid : Dictionary
        Gives the video information needed.

    """
    Vid = {}
    url = 'https://www.youtube.com/watch?v=PLLi_EIWou4'
    Link = url
    source = requests.get(url).text
    soup = BeautifulSoup(source, 'lxml')
    Vid['Title'] = soup.find("span", attrs={"class": "watch-title"})
    Vid['Link'] = Link
    Vid['Description'] = soup.find("p", attrs={"id": "eow-description"})
    Vid['Tag'] = soup.find('meta', attrs={'name': 'keywords'})
    return Vid


current_video_details = getVideoDetails()

# while this is true (it is true by default),
while True:

    new_video_details = getVideoDetails()
    now = datetime.now()
    current_time = now.strftime("%H:%M:%S")

    # checks to see if the video details have changed
    if new_video_details == current_video_details:
        print('no change', current_time)
    else:
        # Print the email's contents
        print(new_video_details, current_time)
        f = open("videochanges.txt", "a")
        f.write(str(new_video_details))
        f.write(str(current_time))
        f.close()
        current_video_details = new_video_details
    time.sleep(60)