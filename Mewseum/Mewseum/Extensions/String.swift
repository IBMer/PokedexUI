//
//  String.swift
//  Mewseum
//
//  Created by Vincent WANG on 2025/11/15.
//
import Foundation

extension String {
    var pretty: String {
        self
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "é", with: "e")
            .replacingOccurrences(of: "\n:", with: ": ")
            .replacingOccurrences(of: "   ", with: "")
            .replacingOccurrences(of: "    ", with: "")
            .capitalized
    }
}

extension StringProtocol {
    var normalize: String {
        folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
          .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
