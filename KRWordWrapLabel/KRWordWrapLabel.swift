//
//  KRWordWrapLabel.swift
//  KRWordWrapLabel
//
//  Created by Yoo YongHa on 2016. 3. 5..
//  Copyright © 2016년 Gen X Hippies Company. All rights reserved.
//

import UIKit

@IBDesignable public class KRWordWrapLabel: UILabel {
    
    @IBInspectable public var ellipsis: String = "..." { didSet { self.updateWords() } }
    
    override public var text: String? { didSet { self.updateWords() } }
    override public var font: UIFont! { didSet { self.updateWords() } }
    override public var textColor: UIColor! { didSet { self.updateWords() } }
    
    @IBInspectable public var lineSpace: CGFloat = 0 { didSet { self.updateWordLayout() } }
    
    override public var bounds: CGRect { didSet { self.updateWordLayout() } }
    override public var numberOfLines: Int { didSet { self.updateWordLayout() } }
    override public var textAlignment: NSTextAlignment { didSet { self.updateWordLayout() } }
    
    private var intrinsicSize: CGSize = CGSizeZero
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.updateWords()
    }
    
    override public func intrinsicContentSize() -> CGSize {
        if self.lineBreakMode == .ByWordWrapping && self.doWordWrap {
            return intrinsicSize
        } else {
            return super.intrinsicContentSize()
        }
    }
    
    // MARK: - Codes for Word Wrap
    
    private class Word {
        let text: NSAttributedString
        let size: CGSize
        let precedingSpace: CGFloat
        var origin: CGPoint = CGPointZero
        var visible: Bool = true
        
        init(text: NSAttributedString, size: CGSize, precedingSpaceWidth: CGFloat) {
            self.text = text
            self.size = size
            self.precedingSpace = precedingSpaceWidth
        }
    }
    
    private var ellipsisWord: Word!
    private var paragraphs: [[Word]]?
    private var doWordWrap = true
    
    override public func drawRect(rect: CGRect) {
        if self.lineBreakMode == .ByWordWrapping && self.doWordWrap {
            guard let paragraphs = self.paragraphs else { return }
            
            if self.ellipsisWord.visible {
                self.ellipsisWord.text.drawAtPoint(self.ellipsisWord.origin)
            }
            
            for words in paragraphs {
                for word in words {
                    if !word.visible {
                        return
                    }
                    word.text.drawAtPoint(word.origin)
                }
            }
            
            
        } else {
            super.drawRect(rect)
        }
    }
    
    private func updateWords() {
        let maxFontSize = self.font.pointSize
        let minFontSize = self.adjustsFontSizeToFitWidth || self.minimumScaleFactor > 0 ? maxFontSize * self.minimumScaleFactor : maxFontSize
        for var size = maxFontSize; size >= minFontSize; size -= 0.5 {
            if updateWords(size) {
                return
            }
        }
    }
    
    private func updateWords(fontSize: CGFloat) -> Bool {
        guard let text = self.text else { return true }
        
        let font = self.font.fontWithSize(fontSize)
        var w = 0
        self.paragraphs = text.characters
            .split(allowEmptySlices: true) { (c: Character) -> Bool in return c == "\n" || c == "\r\n" }
            .map(String.init)
            .map { (paragraph: String) -> [KRWordWrapLabel.Word] in
                return paragraph.characters.split(" ", allowEmptySlices: true)
                    .map(String.init)
                    .map { s -> NSAttributedString? in
                        return s == "" ? nil :
                            NSAttributedString(string: s,
                                attributes: [NSFontAttributeName : font, NSForegroundColorAttributeName: self.textColor])
                    }
                    .flatMap { t -> Word? in
                        if let text = t {
                            let size = text.size()
                            let spaceWidth = NSAttributedString(string: String(count: w, repeatedValue: Character(" ")), attributes: [NSFontAttributeName : font]).size().width
                            w = 1
                            return Word(
                                text: text,
                                size: CGSizeMake(ceil(size.width), ceil(size.height)),
                                precedingSpaceWidth: ceil(spaceWidth))
                        } else {
                            w += 1
                            return nil
                        }
                }
            }
            .flatMap { words -> [KRWordWrapLabel.Word] in
                if words.count > 0 {
                    return words
                } else {
                    let text = NSAttributedString(string: " ", attributes: [NSFontAttributeName : font])
                    let size = text.size()
                    return [Word(
                        text: text,
                        size: CGSizeMake(ceil(size.width), ceil(size.height)),
                        precedingSpaceWidth: 0)]
                }
        }
        
        
        do {
            let text = NSAttributedString(string: self.ellipsis,
                attributes: [NSFontAttributeName : font, NSForegroundColorAttributeName: self.textColor])
            let size = text.size()
            
            self.ellipsisWord = Word(
                text: text,
                size: CGSizeMake(ceil(size.width), ceil(size.height)),
                precedingSpaceWidth: 0)
        }
        
        return self.updateWordLayout()
    }
    
    private func updateWordLayout() -> Bool {
        guard let paragraphs = self.paragraphs else { return true }
        
        self.doWordWrap = true
        
        let width = self.bounds.width
        
        var totalSize:CGSize = CGSizeZero
        var rowSize: CGSize = CGSizeZero
        
        var rowCount = 1
        var colCount = 0
        
        var colWords: [Word] = []
        
        func newRow() {
            var x = self.textAlignment == .Center ? (width - rowSize.width) / 2 : self.textAlignment == .Right ? width - rowSize.width : 0
            
            let y = totalSize.height + rowSize.height
            
            for (index, word) in colWords.enumerate() {
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
            rowSize = CGSizeZero
            colCount = 0
            rowCount++
        }
        
        let maxLines = self.numberOfLines > 0 ? self.numberOfLines : Int.max
        var truncate = false
        
        for words in paragraphs {
            words[0].visible = false
        }
        
        loop: for (index, words) in paragraphs.enumerate() {
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
                colCount++
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