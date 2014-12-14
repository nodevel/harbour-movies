import QtQuick 2.0
import QtQuick.LocalStorage 2.0

Item {


    /**
     * Get the application's database connection
     */
    function getDatabase() {
        return LocalStorage.openDatabaseSync("harbour-movies", "0.1", "Movies Storage", 100000)
    }


    /**
     * Initialize the tables if needed
     */
    function initialize() {
        try {
            var db = getDatabase();
            db.transaction(
                function(tx) {
                    tx.executeSql('CREATE TABLE IF NOT EXISTS favorites' +
                                  '(favoriteId TEXT, title TEXT, iconSource TEXT, favoriteType TINYINT)')
                })
            db.transaction(
                function(tx) {
                    tx.executeSql('CREATE TABLE IF NOT EXISTS watchlist' +
                                  '(movieId TEXT, name TEXT, year TEXT, iconSource TEXT, rating DOUBLE, votes INT)')
                })
            db.transaction(
                function(tx) {
                    tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT UNIQUE, value TEXT)')
                })
        } catch (ex) {
            console.debug('initialize:', ex)
        }
    }

    /**
     * Saves a favorite into the database
     * @param favorite The favorite to save: (id, title, icon, type)
     *
     * @return The insertion index
     */
    function saveFavorite(favorite) {
        var insertIndex = -1
        try {
            var db = getDatabase()
            db.transaction(function(tx) {
                var rs = tx.executeSql('INSERT OR REPLACE INTO favorites VALUES (?,?,?,?);',
                                       [favorite.id,favorite.title,favorite.icon,favorite.type])
                insertIndex = rs.insertId
            })
        } catch (ex) {
            console.debug('saveFavorite:', ex)
        }
        return insertIndex
    }

    /**
     * Removes a favorite from the database
     * @param index The index to remove
     *
     * @return true if the operation is successful, Error if it failed
     */
    function removeFavorite(index) {
        var success = false
        try {
            var db = getDatabase()
            db.transaction(function(tx) {
                var rs = tx.executeSql('DELETE FROM favorites WHERE ROWID = ?;',
                                       [index])
                success = rs.rowsAffected > 0
            })
        } catch (ex) {
            console.debug('removeFavorite:', ex)
        }
        return success
    }

    /**
     * Gets the favorites from the database
     *
     * @return The collection of favorites stored or an empty list
     */
    function getFavorites() {
        var res= []
        try {
            var db = getDatabase()
            db.transaction(function(tx) {
                var rs = tx.executeSql('SELECT rowid,favoriteId,title,iconSource,favoriteType FROM favorites;')
                if (rs.rows.length > 0) {
                    for(var i = 0; i < rs.rows.length; i++) {
                        var currentItem = rs.rows.item(i)
                        res.push({'id': currentItem.favoriteId,
                                  'title': currentItem.title,
                                  'icon': currentItem.iconSource,
                                  'type': currentItem.favoriteType,
                                  'rowId': currentItem.rowid})
                    }
                }
            })
        } catch (ex) {
            console.debug('getFavorites:', ex)
        }
        return res
    }

    /**
     * Saves a movie into the watchlist
     * @param movie The movie to save: (id, name, year, iconSource, rating, votes)
     */
    function addToWatchlist(movie) {
        try {
            var db = getDatabase()
            db.transaction(function(tx) {
                               tx.executeSql('INSERT OR REPLACE INTO watchlist '+
                                             'VALUES (?, ?, ?, ?, ?, ?);',
                                             [movie.id, movie.name,
                                              movie.year, movie.iconSource,
                                              movie.rating, movie.votes])
                           })
        } catch (ex) {
            console.debug('addToWatchlist:', ex)
        }
    }

    /**
     * Deletes a movie from the watchlist
     * @param movie The movie to remove: (id)
     */
    function removeFromWatchlist(movie) {
        try {
            var db = getDatabase()
            db.transaction(function(tx) {
                               tx.executeSql('DELETE FROM watchlist '+
                                             'WHERE movieId = ?;',
                                             [movie.id])
                           })
        } catch (ex) {
            console.debug('removeFromWatchlist:', ex)
        }
    }

    /**
     * Gets the watchlist from the database
     *
     * @return The collection of movies in the watchlist or an empty list
     */
    function getWatchlist() {
        var res = []
        try {
            var db = getDatabase()
            db.transaction(function(tx) {
                               var rs = tx.executeSql('SELECT movieId, name, year, iconSource, rating, votes FROM watchlist;')
                               for (var i = 0; i < rs.rows.length; i ++) {
                                   var currentItem = rs.rows.item(i)
                                   res.push({
                                                'id': currentItem.movieId,
                                                'title': currentItem.name,
                                                'year': currentItem.year,
                                                'icon': currentItem.iconSource,
                                                'rating': currentItem.rating,
                                                'votes': currentItem.votes,
                                            })
                               }
                           })
        } catch (ex) {
            console.debug('getWatchlist:', ex)
        }
        return res
    }

    /**
     * Checks if a movie is in the watchlist
     * @param movie The movie to check
     * @return TRUE if the movie is in the watchlist, FALSE otherwise
     */
    function inWatchlist(movie) {
        var res = false
        try {
            var db = getDatabase()
            db.transaction(function(tx) {
                               var rs = tx.executeSql('SELECT movieId FROM watchlist '+
                                                      'WHERE movieId = ?;',
                                                      [movie.id])
                               res = rs.rows.length > 0
                           })
        } catch (ex) {
            console.debug('removeFromWatchlist:', ex)
        }
        return res
    }

    /**
     * Saves a setting into the database
     * @param setting The setting to save
     * @param value The value for the setting to save
     *
     * @return true if the operation is successfull, false otherwise
     */
    function setSetting(setting, value) {
        var success = false
        try {
            var db = getDatabase()
            db.transaction(function(tx) {
                var rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', [setting,value])
                success = rs.rowsAffected > 0
            })
        } catch (ex) {
            console.debug('setSetting:', ex)
        }
        return success
    }

    /**
     * Retrieves a setting from the database
     * @param setting The setting to retrieve
     * @param defaultValue The default value if no value was found
     *
     * @return The value for the setting
     */
    function getSetting(setting, defaultValue) {
        var res = defaultValue
        try {
            var db = getDatabase();
            db.transaction(function(tx) {
                var rs = tx.executeSql('SELECT value FROM settings WHERE setting=?;', [setting]);
                if (rs.rows.length > 0) {
                    res = rs.rows.item(0).value;
                }
            })
        } catch (ex) {
            console.debug('getSetting:', ex)
        }
        return res
    }

}
