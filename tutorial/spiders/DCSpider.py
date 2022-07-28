import scrapy
# from scrapy.crawler import CrawlerProcess
from scrapy.loader import ItemLoader
from tutorial.items import ComicItem

class DCSpider(scrapy.Spider):
    name = "DCSpider"
   
    
    def start_requests(self):
        yield scrapy.Request(url = 'https://dc.fandom.com/wiki/Category:Fortas_(New_Earth)/Appearances', callback = self.parse)
    
    
    def parse(self, response):

        # this gets links
        links_to_follow = response.css('div.category-page__members').css('li.category-page__member').css('a.category-page__member-link::attr(href)')
        for url in links_to_follow.extract():
            yield response.follow(url = url, callback = self.parse_pages)

    def parse_pages(self, response):
        
        il = ItemLoader(item=ComicItem(), response=response)
        il.add_css('comic', 'h1::text')
        il.add_css('date', 'aside.portable-infobox h2 a::attr(href)', re='/wiki/Category:\d.*')
        return il.load_item()
'''        yield {
            'comic': response.css('h1::text').extract()[0],
            #'month': response.css('h2').css('a::text').extract()[1],
            #'year': response.css('p').css('a::attr(title)').extract()[5]
            'date': response.css('aside.portable-infobox').css('h2')[2].css('a::attr(href)').extract()[0],
            #'notes': 'Part of the ' + response.css('aside.portable-infobox')[0].css('div').css('div').css('a::attr(title)').extract()[0] + 'event'
        }'''