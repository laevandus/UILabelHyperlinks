//
//  HyperlinkLabel.swift
//  UILabelHyperlinks
//
//  Created by Toomas Vahter on 14.12.2020.
//

import UIKit

final class HyperlinkLabel: UILabel {
    
    // MARK: Creating the Label
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        numberOfLines = 0
        isUserInteractionEnabled = true
    }
    
    override var attributedText: NSAttributedString? {
        get {
            return super.attributedText
        }
        set {
            super.attributedText = {
                guard let newValue = newValue else { return nil }
                // Apply custom hyperlink attributes
                let text = NSMutableAttributedString(attributedString: newValue)
                text.enumerateAttribute(.hyperlink, in: NSRange(location: 0, length: text.length), options: .longestEffectiveRangeNotRequired) { (value, subrange, _) in
                    guard let value = value else { return }
                    assert(value is URL)
                    text.addAttributes(hyperlinkAttributes, range: subrange)
                }
                // Fill in font attributes when not set
                text.enumerateAttribute(.font, in: NSRange(location: 0, length: text.length), options: .longestEffectiveRangeNotRequired) { (value, subrange, _) in
                    guard value == nil, let font = font else { return }
                    text.addAttribute(.font, value: font, range: subrange)
                }
                return text
            }()
        }
    }
    
    // MARK: Finding Hyperlink Under Touch
    
    var hyperlinkAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemBlue]
    
    var didTapOnURL: (URL) -> Void = { url in
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: { success in
                if success {
                    print("Opened URL \(url) successfully")
                }
                else {
                    print("Failed to open URL \(url)")
                }
            })
        }
        else {
            print("Can't open the URL: \(url)")
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let url = self.url(at: touches) {
            didTapOnURL(url)
        }
        else {
            super.touchesEnded(touches, with: event)
        }
    }
    
    private func url(at touches: Set<UITouch>) -> URL? {
        guard let attributedText = attributedText, attributedText.length > 0 else { return nil }
        guard let touchLocation = touches.sorted(by: { $0.timestamp < $1.timestamp } ).last?.location(in: self) else { return nil }
        guard let textStorage = preparedTextStorage() else { return nil }
        let layoutManager = textStorage.layoutManagers[0]
        let textContainer = layoutManager.textContainers[0]
        
        let characterIndex = layoutManager.characterIndex(for: touchLocation, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        guard characterIndex >= 0, characterIndex != NSNotFound else { return nil }

        // Glyph index is the closest to the touch, therefore also validate if we actually tapped on the glyph rect
        let glyphRange = layoutManager.glyphRange(forCharacterRange: NSRange(location: characterIndex, length: 1), actualCharacterRange: nil)
        let characterRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        guard characterRect.contains(touchLocation) else { return nil }
        
        // Link styled by Apple
        if let url = textStorage.attribute(.link, at: characterIndex, effectiveRange: nil) as? URL {
            return url
        }
        // Custom link style
        return textStorage.attribute(.hyperlink, at: characterIndex, effectiveRange: nil) as? URL
    }
    
    private func preparedTextStorage() -> NSTextStorage? {
        guard let attributedText = attributedText, attributedText.length > 0 else { return nil }
        
        // Creates and configures a text storage which matches with the UILabel's configuration.
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0
        let textStorage = NSTextStorage(string: "")
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineBreakMode = lineBreakMode
        textContainer.size = textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines).size
        textStorage.setAttributedString(attributedText)
        
        return textStorage
    }
}

extension NSAttributedString.Key {
    static let hyperlink = NSAttributedString.Key("hyperlink")
}
