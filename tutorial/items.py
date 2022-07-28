# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy
from itemloaders.processors import Join, MapCompose, TakeFirst
import pandas as pd

def filter(value):
    # takes out the uneccessary tags
    return value.replace('\t', '').replace('\n', '').replace('_', '').replace('/wiki/Category:', '')


class ComicItem(scrapy.Item):
    # define the fields for your item here like:
    comic = scrapy.Field(
        input_processor=MapCompose(filter),
        output_processor=TakeFirst(),
    )
    date = scrapy.Field(
        input_processor=MapCompose(filter, pd.to_datetime),
        output_processor=TakeFirst()
    )
    
