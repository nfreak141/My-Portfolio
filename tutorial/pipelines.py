# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://docs.scrapy.org/en/latest/topics/item-pipeline.html


# useful for handling different item types with a single interface
import json

from itemadapter import ItemAdapter
from scrapy.exceptions import DropItem

#class JsonWriterPipeline:

    #def open_spider(self, spider):
        #self.file = open('issuess.jl', 'w')

#    def close_spider(self, spider):
 #       self.file.close()

  #  def process_item(self, item, spider):
   #     line = json.dumps(ItemAdapter(item).asdict()) + "\n"
    #    self.file.write(line)
     #   return item

class DuplicatesPipeline:

    def __init__(self):
        self.ids_seen = set()

    def process_item(self, item, spider):
        adapter = ItemAdapter(item)
        if adapter['comic'] in self.ids_seen:
            raise DropItem(f"Duplicate item found: {item!r}")
        else:
            self.ids_seen.add(adapter['comic'])
            return item