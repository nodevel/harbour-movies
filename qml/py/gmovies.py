#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import urllib.request
from html.parser import HTMLParser
import xml.etree.cElementTree as ET

class TheatersHTMLParser(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.new_theater_name = False
        self.new_theater_info = False
        self.new_movie_name = False
        self.new_movie_info = False
        self.new_movie_times = False
        self.var_movie_times = False
        self.var_type = None
        #self.theater = {}
        #self.output = []
        #self.theater['movies'] = []
        #self.movie = {}
        #self.movies = []
        self.movie_times_str = []
        #self.xml = ET.Element("?xml")
        #self.xml.set("version", "1.0")
        #self.xml.set("encoding", "utf-8")
        self.output = ET.Element("theaters")

    def handle_starttag(self, tag, attrs):
        if (tag == 'div'):
            for name, value in attrs:
                if name == 'class' and value == 'info':
                    """ Theater info """
                    self.new_theater_info = True
                elif name == 'class' and value == 'name':
                    """ Movie name """
                    self.new_movie_name = True
                    self.var_type = 'movie'
                elif name == 'class' and value == 'times':
                    """ Movie info """
                    self.new_movie_times = True
                    self.var_movie_times = True
                    self.var_type = None
                elif name == 'id' and value == 'bottom_search':
                    """ END """
                    #self.theater['movies'] = self.movies
                    #self.output.append(self.theater)
                    pass
        elif (tag == 'h2'):
            """ Theather name """
            self.new_theater_name = True
            self.var_type = 'theater'
        elif (tag == 'a' and self.var_type == 'theater'):
            for name, value in attrs:
                if name == 'href':
                    """ Theater url """
                    if value:
                        self.theater = ET.SubElement(self.output, "theater")
                        self.theater_url = ET.SubElement(self.theater, "url")
                        self.theater_url.text = value
                elif name == 'id':
                    """ Theater info """
                    self.theater_id = ET.SubElement(self.theater, "id")
                    self.theater_id.text = value
                    #self.theater['id'] = value
        elif (tag == 'a' and self.var_type == 'movie'):
            for name, value in attrs:
                if name == 'href':
                    """ Theater info """
                    if "mid=" in value:
                        self.movie = ET.SubElement(self.theater_movies, "movie")
                        self.movie_url = ET.SubElement(self.movie, "url")
                        self.movie_url.text = value
                        value = value.split("mid=")
                        self.movie_id = ET.SubElement(self.movie, "id")
                        self.movie_id.text = value[1]
                        self.imdb_id = ET.SubElement(self.movie, "imdb")
                    else:
                        value = value.split("com/title/")[1].split("/&sa=")[0]
                        self.imdb_id.text = value


        elif (tag == 'span'):
            for name, value in attrs:
                if name == 'class' and value == 'info':
                    """ Movie info """
                    self.new_movie_info = True

    def handle_data(self, data):
        #print("Encountered some data  :", data)
        #pass
        if self.new_theater_name:
            #if self.movies:
                #self.theater['movies'] = self.movies
                #self.output.append(self.theater)
                #self.movies = []
            self.theater_name = ET.SubElement(self.theater, "name")
            self.theater_name.text = data
            self.theater_movies = ET.SubElement(self.theater, "movies")
            self.new_theater_name = False
        elif self.new_theater_info:
            self.theater_info = ET.SubElement(self.theater, "info")
            self.theater_info.text = data
            self.new_theater_info = False
        elif self.new_movie_name:
            #self.theater['movies'].append({})
            self.movie_name = ET.SubElement(self.movie, "name")
            self.movie_name.text = data
            self.new_movie_name = False
        elif self.new_movie_info:
            self.movie_info = ET.SubElement(self.movie, "info")
            self.movie_info.text = data
            self.new_movie_info = False
        elif self.new_movie_times:
            #self.movie['times'] = data //DISABLED FOR NOW
            self.new_movie_times = False
        elif self.var_movie_times:
            if (":" in data):
                self.movie_times_str.append(data)
                data = data.split(":")
                self.movie_time = ET.SubElement(self.movie, "time")
                self.movie_hour = ET.SubElement(self.movie_time, "hour")
                self.movie_hour.text = data[0]
                self.movie_minute = ET.SubElement(self.movie_time, "minute")
                self.movie_minute.text = data[1]
                
    def handle_endtag(self, tag):
        #print("Encountered an end tag :", tag)
        if (tag == 'div'):
            if self.var_movie_times:
                """ The end of movie """
                self.movie_times = ET.SubElement(self.movie, "times")
                finished_times_tmp = []
                last_times_tmp = []
                print(self.movie_times_str)
                for n,time in enumerate(self.movie_times_str):
                    if (time == "12:00am"):
                        last_times_tmp.append("23:59")
                        del self.movie_times_str[n]
                if any("am" in s for s in self.movie_times_str):
                    for n,time in enumerate(self.movie_times_str):
                        finished_times_tmp.append(time.replace("am", ""))
                        del self.movie_times_str[n]
                        if "am" in time:
                            break
                if any("pm" in s for s in self.movie_times_str):
                    for n,time in enumerate(self.movie_times_str):
                        if "12:" in time:
                            finished_times_tmp.append(time.replace("pm", ""))
                        else:
                            time = time.split(":")
                            finished_times_tmp.append( str( int( time[0] ) + 12 )+":"+time[1].replace("pm", "") )
                else:
                    for time in self.movie_times_str:
                        finished_times_tmp.append(time)
                for time in last_times_tmp:
                    finished_times_tmp.append(time)
                print(finished_times_tmp)
                self.movie_times.text = ", ".join(str(x) for x in self.movie_times_str)
                self.movie_times_str = []
                #self.movie['times'] = self.movie_times
                #self.movies.append(self.movie)
                self.var_movie_times = False

class MoviesHTMLParser(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.in_movie = False
        self.in_a = False
        #self.output = tmpinput
        self.movie_count = 0

    def handle_starttag(self, tag, attrs):
        if (tag == 'h2'):
            self.in_movie = True
            self.movie = ET.SubElement(self.output, "movie")
            self.movie_count = self.movie_count+1
        if self.in_movie:
            if (tag == 'a'):
                """ Movie link """
                self.in_a = True
                for name, value in attrs:
                    if (name == 'href'):
                        self.movie_url = ET.SubElement(self.movie, "url")
                        self.movie_url.text = value
                        value = value.split("mid=")
                        self.movie_id = ET.SubElement(self.movie, "id")
                        self.movie_id.text = value[1]

    def handle_data(self, data):
        #print("Encountered some data  :", data)
        #pass
        if self.in_a:
            self.movie_name = ET.SubElement(self.movie, "name")
            self.movie_name.text = data
            self.in_a = False
                
    def handle_endtag(self, tag):
        #print("Encountered an end tag :", tag)
        if (tag == 'h2'):
            self.in_movie = False

class MovieShowtimesHTMLParser(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.in_theater = False
        self.in_address = False
        self.in_a = False
        self.var_movie_times = False
        self.var_type = None
        self.movie_times_str = []
        #self.output = tmpinput
        self.output = ET.Element("theaters")

    def handle_starttag(self, tag, attrs):
        if (tag == 'div'):
            for name, value in attrs:
                if name == 'class' and value == 'name':
                    """ Theater name """
                    self.in_theater = True
                    self.theater = ET.SubElement(self.output, "theater")
                elif name == 'class' and value == 'address':
                    """ Theater address """
                    self.in_address = True
                elif name == 'class' and value == 'times':
                    """ Movie info """
                    self.var_movie_times = True
                    self.var_type = None
        if self.in_theater:
            if (tag == 'a'):
                """ Theater link """
                self.in_a = True
                for name, value in attrs:
                    if (name == 'href'):
                        self.theater_url = ET.SubElement(self.theater, "url")
                        self.theater_url.text = value

    def handle_data(self, data):
        #print("Encountered some data  :", data)
        #pass
        if self.in_a:
            self.theater_name = ET.SubElement(self.theater, "name")
            self.theater_name.text = data
            self.in_a = False
            self.in_theater = False
        elif self.var_movie_times:
            print("ok")
            if (":" in data):
                self.movie_times_str.append(data)
                data = data.split(":")
                self.theater_time = ET.SubElement(self.theater, "time")
                self.theater_hour = ET.SubElement(self.theater_time, "hour")
                self.theater_hour.text = data[0]
                self.theater_minute = ET.SubElement(self.theater_time, "minute")
                self.theater_minute.text = data[1]
                
    def handle_endtag(self, tag):
        #print("Encountered an end tag :", tag)
        if self.var_movie_times:
            if tag == 'div':
                """ The end of movie """
                self.movie_times = ET.SubElement(self.theater, "times")
                self.movie_times.text = ", ".join(str(x) for x in self.movie_times_str)
                self.movie_times_str = []
                #self.movie['times'] = self.movie_times
                #self.movies.append(self.movie)
                self.var_movie_times = False

def get(location, date, time, sort, lang, page, mid):
    """
    Page starts with 0.
    """
    location = location.replace(' ', '+')
    url = "http://www.google.com/movies?near="+location+"&hl="+lang+"&date="+str(date)+"&time="+str(time)+"&sort="+str(sort)+"&start="+str(page*10)+"&mid="+str(mid)
    resource = urllib.request.urlopen(url)
    content =  resource.read().decode(resource.headers.get_content_charset())
    return content
    

def parse(location, date, time, sort, lang, page, mid):
    if (sort == 0):
        content = get(location, date, time, sort, lang, page, 0)
        parser = TheatersHTMLParser()
        parser.feed(str(content))
    elif (sort == 1):
        count_tmp = 0
        tmpinput = ET.Element("movies")
        parser = MoviesHTMLParser()
        while True:
            content = get(location, date, time, sort, lang, page, 0)
            parser.output = tmpinput
            parser.feed(str(content))
            if (parser.movie_count > count_tmp):
                count_tmp = parser.movie_count
                tmpinput = parser.output
                page=page+1
            else:
                break
    elif (sort == 2):
        """
        Third type - search for all showtimes for a movie
        """
        content = get(location, date, time, 1, lang, page, mid)
        parser = MovieShowtimesHTMLParser()
        parser.feed(str(content))
    xmlstring = str(ET.tostring(parser.output, "utf-8").decode("utf-8"))
    return xmlstring
    #return ['jedna', ['dva', 'tri']]

if __name__ == '__main__':
    parse("Los Angeles", 0, 0, 0, "cs", 0, "77229247abc33b14")
