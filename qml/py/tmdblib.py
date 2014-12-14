# -*- coding: utf-8 -*-

"""
search.py
~~~~~~~~~~~~~~

This test suite checks the methods of the Search class of tmdbsimple.

Created by Celia Oakley on 2013-11-05
Modified by Jakub Kozisek

:copyright: (c) 2013-2014 by Celia Oakley.
:license: GPLv3, see LICENSE for more details.
"""

import tmdbsimple as tmdb
import json

def set_keys(api_key):
    tmdb.API_KEY = api_key

# Searching

def search_movies(query):
    search = tmdb.Search()
    response = search.movie(query=query)
    return json.dumps(response)

def search_collection(query):
    search = tmdb.Search()
    response = search.collection(query=query)
    return response

def search_tv(query):
    search = tmdb.Search()
    response = search.tv(query=query)
    return json.dumps(response)

def search_person(query):
    search = tmdb.Search()
    response = search.person(query=query)
    return json.dumps(response)

def search_list(query):
    search = tmdb.Search()
    response = search.list(query=query)
    return response

def search_company(query):
    search = tmdb.Search()
    response = search.company(query=query)
    return response

def search_keyword(query):
    search = tmdb.Search()
    response = search.keyword(query=query)
    return response

def search_multi(query):
    search = tmdb.Search()
    response = search.multi(query=query)
    return response

# GENRES
def genres_list():
    genre = tmdb.Genres()
    response = genre.list()
    return json.dumps(response)

def genres_movies(id):
    genre = tmdb.Genres(id)
    response = genre.movies()
    return json.dumps(response)

# MOVIES
def movies_info(id):
    movie = tmdb.Movies(id)
    response = movie.info()
    return response

def movies_credits(id):
    movie = tmdb.Movies(id)
    response = movie.credits()
    return(response)

def movies_images(id):
    movie = tmdb.Movies(id)
    response = movie.images()
    return(response)

def movies_alternative_titles(id):
    movie = tmdb.Movies(id)
    response = movie.alternative_titles()
    return(response)

def movies_releases(id):
    movie = tmdb.Movies(id)
    response = movie.releases()
    return(response)

# PEOPLE
def people_info(id):
    person = tmdb.People(id)
    response = person.info()
    return(response)

def people_movie_credits(id):
    person = tmdb.People(id)
    response = person.movie_credits()
    return(response)

def people_tv_credits(id):
    person = tmdb.People(id)
    response = person.tv_credits()
    return(response)

def people_images(id):
    person = tmdb.People(id)
    response = person.images()
    return(response)

#print(json.dumps(genres_list()))
##print(genres_movies(18))
#print("OK")
#print(search_movies('Hobbit'))
#print(movies_credits(103332)['cast'])
