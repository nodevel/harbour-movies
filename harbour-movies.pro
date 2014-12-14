# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-movies

CONFIG += sailfishapp

SOURCES += src/harbour-movies.cpp

OTHER_FILES += qml/harbour-movies.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-movies.changes.in \
    rpm/harbour-movies.spec \
    rpm/harbour-movies.yaml \
    translations/*.ts \
    harbour-movies.desktop \
    qml/pages/WelcomeView.qml \
    qml/pages/TvView.qml \
    qml/pages/TheatersView.qml \
    qml/pages/ShowtimesView.qml \
    qml/pages/SettingsView.qml \
    qml/pages/SearchView.qml \
    qml/pages/PersonView.qml \
    qml/pages/MultipleMoviesView.qml \
    qml/pages/MovieView.qml \
    qml/pages/MediaGalleryView.qml \
    qml/pages/ListsView.qml \
    qml/pages/GenresView.qml \
    qml/pages/FilmographyView.qml \
    qml/pages/FavoritesView.qml \
    qml/pages/CastView.qml \
    qml/pages/AboutView.qml \
    qml/resources/view-header-fixed-inverted.png \
    qml/resources/tmdb-logo.png \
    qml/resources/round-corners.png \
    qml/resources/person-placeholder.svg \
    qml/resources/movie-placeholder.svg \
    qml/resources/indicator-rating-inverted-star.svg \
    qml/resources/icon-m-common-video-playback.png \
    qml/resources/icon-bg-cinema.png \
    qml/resources/movies.svg \
    qml/py/gmovies.py \
    qml/components/ZoomableImage.qml \
    qml/components/Storage.qml \
    qml/components/NoContentItem.qml \
    qml/components/MyTextExpander.qml \
    qml/components/MyRatingIndicator.qml \
    qml/components/MyMoreIndicator.qml \
    qml/components/MyModelPreviewer.qml \
    qml/components/MyModelFlowPreviewer.qml \
    qml/components/MyListDelegate.qml \
    qml/components/MyGridDelegate.qml \
    qml/components/MyGalleryPreviewer.qml \
    qml/components/MyEntryHeader.qml \
    qml/components/MultipleMoviesDelegate.qml \
    qml/components/ListSectionDelegate.qml \
    qml/components/JSONListModel.qml \
    qml/components/FavoriteDelegate.qml \
    qml/js/storage.js \
    qml/js/moviedbwrapper.js \
    qml/js/jsonpath.js \
    qml/js/constants.js \
    qml/js/moviesutils.js \
    qml/js/youtube.js \
    qml/components/Data.qml \
    qml/pages/TmdbTest.qml \
    qml/js/themoviedb.js \
    qml/py/tmdbsimple/__init__.py \
    qml/py/tmdbsimple/account.py \
    qml/py/tmdbsimple/base.py \
    qml/py/tmdbsimple/changes.py \
    qml/py/tmdbsimple/configuration.py \
    qml/py/tmdbsimple/discover.py \
    qml/py/tmdbsimple/find.py \
    qml/py/tmdbsimple/genres.py \
    qml/py/tmdbsimple/movies.py \
    qml/py/tmdbsimple/people.py \
    qml/py/tmdbsimple/search.py \
    qml/py/tmdbsimple/tv.py \
    qml/py/tmdblib.py \
    qml/py/requests/cacert.pem \
    qml/py/requests/__init__.py \
    qml/py/requests/adapters.py \
    qml/py/requests/api.py \
    qml/py/requests/auth.py \
    qml/py/requests/certs.py \
    qml/py/requests/compat.py \
    qml/py/requests/cookies.py \
    qml/py/requests/exceptions.py \
    qml/py/requests/hooks.py \
    qml/py/requests/models.py \
    qml/py/requests/sessions.py \
    qml/py/requests/status_codes.py \
    qml/py/requests/structures.py \
    qml/py/requests/utils.py \
    qml/py/requests/packages/__init__.py \
    qml/py/requests/packages/chardet/__init__.py \
    qml/py/requests/packages/chardet/big5freq.py \
    qml/py/requests/packages/chardet/big5prober.py \
    qml/py/requests/packages/chardet/chardetect.py \
    qml/py/requests/packages/chardet/chardistribution.py \
    qml/py/requests/packages/chardet/charsetgroupprober.py \
    qml/py/requests/packages/chardet/charsetprober.py \
    qml/py/requests/packages/chardet/codingstatemachine.py \
    qml/py/requests/packages/chardet/compat.py \
    qml/py/requests/packages/chardet/constants.py \
    qml/py/requests/packages/chardet/cp949prober.py \
    qml/py/requests/packages/chardet/escprober.py \
    qml/py/requests/packages/chardet/escsm.py \
    qml/py/requests/packages/chardet/eucjpprober.py \
    qml/py/requests/packages/chardet/euckrfreq.py \
    qml/py/requests/packages/chardet/euckrprober.py \
    qml/py/requests/packages/chardet/euctwfreq.py \
    qml/py/requests/packages/chardet/euctwprober.py \
    qml/py/requests/packages/chardet/gb2312freq.py \
    qml/py/requests/packages/chardet/gb2312prober.py \
    qml/py/requests/packages/chardet/hebrewprober.py \
    qml/py/requests/packages/chardet/jisfreq.py \
    qml/py/requests/packages/chardet/jpcntx.py \
    qml/py/requests/packages/chardet/langbulgarianmodel.py \
    qml/py/requests/packages/chardet/langcyrillicmodel.py \
    qml/py/requests/packages/chardet/langgreekmodel.py \
    qml/py/requests/packages/chardet/langhebrewmodel.py \
    qml/py/requests/packages/chardet/langhungarianmodel.py \
    qml/py/requests/packages/chardet/langthaimodel.py \
    qml/py/requests/packages/chardet/latin1prober.py \
    qml/py/requests/packages/chardet/mbcharsetprober.py \
    qml/py/requests/packages/chardet/mbcsgroupprober.py \
    qml/py/requests/packages/chardet/mbcssm.py \
    qml/py/requests/packages/chardet/sbcharsetprober.py \
    qml/py/requests/packages/chardet/sbcsgroupprober.py \
    qml/py/requests/packages/chardet/sjisprober.py \
    qml/py/requests/packages/chardet/universaldetector.py \
    qml/py/requests/packages/chardet/utf8prober.py \
    qml/py/requests/packages/urllib3/__init__.py \
    qml/py/requests/packages/urllib3/_collections.py \
    qml/py/requests/packages/urllib3/connection.py \
    qml/py/requests/packages/urllib3/connectionpool.py \
    qml/py/requests/packages/urllib3/exceptions.py \
    qml/py/requests/packages/urllib3/fields.py \
    qml/py/requests/packages/urllib3/filepost.py \
    qml/py/requests/packages/urllib3/poolmanager.py \
    qml/py/requests/packages/urllib3/request.py \
    qml/py/requests/packages/urllib3/response.py \
    qml/py/requests/packages/urllib3/util.py \
    qml/py/requests/packages/urllib3/contrib/__init__.py \
    qml/py/requests/packages/urllib3/contrib/ntlmpool.py \
    qml/py/requests/packages/urllib3/contrib/pyopenssl.py \
    qml/py/requests/packages/urllib3/packages/__init__.py \
    qml/py/requests/packages/urllib3/packages/ordered_dict.py \
    qml/py/requests/packages/urllib3/packages/six.py \
    qml/py/requests/packages/urllib3/packages/ssl_match_hostname/__init__.py \
    qml/py/requests/packages/urllib3/packages/ssl_match_hostname/_implementation.py \
    qml/pages/ShareDialog.qml \
    qml/components/InfoBanner.qml \
    qml/components/InfoHeader.qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-movies-de.ts

QT += dbus
