//
//  SearchResult.swift
//  StoreSearch
//
//  Created by MyMacbook on 3/14/16.
//  Copyright © 2016 Oleksandr. All rights reserved.
//
import Foundation

class SearchResult {
    var name = ""
    var artistName = ""
    var artworkURL60 = ""//for a 60×60 pixel image
    var artworkURL100 = ""//for a 100×100 pixel image
    var storeURL = ""
    var kind = ""
    var currency = ""
    var price = 0.0
    var genre = ""
    
    func kindForDisplay() -> String {
        switch kind {
        case "album": return NSLocalizedString("Album", comment: "Localized kind: Album")
        case "audiobook": return NSLocalizedString("Audio Book", comment: "Localized kind: Audio Book")
        case "book": return NSLocalizedString("Book", comment: "Localized kind: Book")
        case "ebook": return NSLocalizedString("E-Book", comment: "Localized kind: E-Book")
        case "feature-movie": return NSLocalizedString("Movie", comment: "Localized kind: Feature Movie")
        case "music-video": return NSLocalizedString("Music Video", comment: "Localized kind: Music Video")
        case "podcast": return NSLocalizedString("Podcast", comment: "Localized kind: Podcast")
        case "software": return NSLocalizedString("App", comment: "Localized kind: Software")
        case "song": return NSLocalizedString("Song", comment: "Localized kind: Song")
        case "tv-episode": return NSLocalizedString("TV Episode", comment: "Localized kind: TV Episode")
        default: return kind
        }
    }
    }   