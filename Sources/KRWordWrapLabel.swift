//
//  KRWordWrapLabel.swift
//  KRWordWrapLabel
//
//  Created by Yoo YongHa on 2016. 3. 5..
//  Copyright © 2016년 Gen X Hippies Company. All rights reserved.
//

import UIKit

@IBDesignable open class KRWordWrapLabel: UILabel {
    
    @IBInspectable open var ellipsis: String = "..." { didSet { self.updateWords() } }
    
    override open var text: String? { didSet { self.updateWords() } }
    override open var font: UIFont! { didSet { self.updateWords() } }
    override open var textColor: UIColor! { didSet { self.updateWords() } }
    
    @IBInspectable open var lineSpace: CGFloat = 0 { didSet { _ = self.updateWordLayout() } }
    
    override open var bounds: CGRect { didSet { _ = self.updateWordLayout() } }
    override open var numberOfLines: Int { didSet { _ = self.updateWordLayout() } }
    override open var textAlignment: NSTextAlignment { didSet { _ = self.updateWordLayout() } }
    
    fileprivate var intrinsicSize: CGSize = CGSize.zero
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.updateWords()
    }
    
    override open var intrinsicContentSize : CGSize {
        if self.lineBreakMode == .byWordWrapping && self.doWordWrap {
            return intrinsicSize
        } else {
            return super.intrinsicContentSize
        }
    }
    
    // MARK: - Codes for Word Wrap
    
    fileprivate class Word {
        let text: NSAttributedString
        let size: CGSize
        let precedingSpace: CGFloat
        var origin: CGPoint = CGPoint.zero
        var visible: Bool = true
        
        init(text: NSAttributedString, size: CGSize, precedingSpaceWidth: CGFloat) {
            self.text = text
            self.size = size
            self.precedingSpace = precedingSpaceWidth
        }
    }
    
    fileprivate var ellipsisWord: Word!
    fileprivate var paragraphs: [[Word]]?
    fileprivate var doWordWrap = true
    
    override open func draw(_ rect: CGRect) {
        if self.lineBreakMode == .byWordWrapping && self.doWordWrap {
            guard let paragraphs = self.paragraphs else { return }
            
            if self.ellipsisWord.visible {
                self.ellipsisWord.text.draw(at: self.ellipsisWord.origin)
            }
            
            for words in paragraphs {
                for word in words {
                    if !word.visible {
                        return
                    }
                    word.text.draw(at: word.origin)
                }
            }
            
            
        } else {
            super.draw(rect)
        }
    }
    
    fileprivate func updateWords() {
        let maxFontSize = self.font.pointSize
        let minFontSize = self.adjustsFontSizeToFitWidth || self.minimumScaleFactor > 0 ? maxFontSize * self.minimumScaleFactor : maxFontSize
        for size in stride(from: maxFontSize, through: minFontSize, by: -0.5) {
            if updateWords(size) {
                return
            }
        }
    }
    
    fileprivate func updateWords(_ fontSize: CGFloat) -> Bool {
        guard let text = self.text else { return true }
        
        let font = self.font.withSize(fontSize)
        var w = 0
        self.paragraphs = text
            .split(omittingEmptySubsequences: false) { (c: Character) -> Bool in return c == "\n" || c == "\r\n" }
            .map(String.init)
            .map { (paragraph: String) -> [KRWordWrapLabel.Word] in
                return paragraph.split(separator: " ", omittingEmptySubsequences: false)
                    .map(String.init)
                    .map { s -> NSAttributedString? in
                        return s == "" ? nil :
                            NSAttributedString(string: s,
                                               attributes: [NSAttributedStringKey.font : font, NSAttributedStringKey.foregroundColor: self.textColor])
                    }
                    .compactMap { t -> Word? in
                        if let text = t {
                            let size = text.size()
                            let spaceWidth = NSAttributedString(string: String(repeating: " ", count: w), attributes: [NSAttributedStringKey.font : font]).size().width
                            w = 1
                            return Word(
                                text: text,
                                size: CGSize(width: ceil(size.width), height: ceil(size.height)),
                                precedingSpaceWidth: ceil(spaceWidth))
                        } else {
                            w += 1
                            return nil
                        }
                }
            }
            .compactMap { words -> [KRWordWrapLabel.Word] in
                if words.count > 0 {
                    return words
                } else {
                    let text = NSAttributedString(string: " ", attributes: [NSAttributedStringKey.font : font])
                    let size = text.size()
                    return [Word(
                        text: text,
                        size: CGSize(width: ceil(size.width), height: ceil(size.height)),
                        precedingSpaceWidth: 0)]
                }
        }
        
        
        do {
            let text = NSAttributedString(string: self.ellipsis,
                                          attributes: [NSAttributedStringKey.font : font, NSAttributedStringKey.foregroundColor: self.textColor])
            let size = text.size()
            
            self.ellipsisWord = Word(
                text: text,
                size: CGSize(width: ceil(size.width), height: ceil(size.height)),
                precedingSpaceWidth: 0)
        }
        
        return self.updateWordLayout()
    }
    
    fileprivate func updateWordLayout() -> Bool {
        guard let paragraphs = self.paragraphs else { return true }
        
        self.doWordWrap = true
        
        let width = self.bounds.width
        
        var totalSize:CGSize = CGSize.zero
        var rowSize: CGSize = CGSize.zero
        
        var rowCount = 1
        var colCount = 0
        
        var colWords: [Word] = []
        
        func newRow() {
            var x = self.textAlignment == .center ? (width - rowSize.width) / 2 : self.textAlignment == .right ? width - rowSize.width : 0
            
            let y = totalSize.height + rowSize.height
            
            for (index, word) in colWords.enumerated() {
                if index > 0 {
                    x += word.precedingSpace
                }
                word.origin.x = x
                x += word.size.width
                
                word.origin.y = y - word.size.height
            }
            
            totalSize.width = max(totalSize.width, rowSize.width);
            totalSize.height += rowSize.height
            
            colWords.removeAll()
            rowSize = CGSize.zero
            colCount = 0
            rowCount += 1
        }
        
        let maxLines = self.numberOfLines > 0 ? self.numberOfLines : Int.max
        var truncate = false
        
        for words in paragraphs {
            words[0].visible = false
        }
        
        loop: for (index, words) in paragraphs.enumerated() {
            for word in words {
                var x = rowSize.width
                if word.size.width > width {
                    self.doWordWrap = false
                    invalidateIntrinsicContentSize()
                    return true
                } else if colCount > 0 && x + word.precedingSpace + word.size.width > width { // new Row
                    if rowCount == maxLines {
                        truncate = true
                        word.visible = false
                        break loop
                    }
                    newRow()
                    x = 0
                }
                
                if colCount == 0 {
                    totalSize.height += lineSpace
                }
                word.visible = true
                colWords.append(word)
                rowSize.width += (colCount == 0 ? 0 : word.precedingSpace) + word.size.width
                rowSize.height = max(rowSize.height, word.size.height)
                colCount += 1
            }
            if rowCount == maxLines && index < paragraphs.count - 1 {
                truncate = true
                break loop
            }
            newRow()
        }
        
        self.ellipsisWord.visible = false
        
        if colCount > 0 {
            if truncate {
                if rowSize.width + self.ellipsisWord.size.width <= width {
                    colWords.append(self.ellipsisWord)
                    self.ellipsisWord.visible = true
                    rowSize.width += self.ellipsisWord.size.width
                } else if colWords.count > 1 {
                    let old = colWords[colWords.count - 1]
                    old.visible = false
                    rowSize.width -= old.size.width
                    colWords[colWords.count - 1] = self.ellipsisWord
                    rowSize.width += self.ellipsisWord.size.width
                    self.ellipsisWord.visible = true
                }
            }
            newRow()
        }
        
        let adjustY = max(0, (bounds.height - totalSize.height) / 2)
        for words in paragraphs {
            for word in words {
                word.origin.y += adjustY
            }
        }
        if self.ellipsisWord.visible {
            self.ellipsisWord.origin.y += adjustY
        }
        
        if self.intrinsicSize != totalSize {
            self.intrinsicSize = totalSize
            invalidateIntrinsicContentSize()
        }
        
        return !truncate
    }
    
}
