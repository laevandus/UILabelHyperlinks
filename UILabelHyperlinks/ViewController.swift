//
//  ViewController.swift
//  UILabelHyperlinks
//
//  Created by Toomas Vahter on 14.12.2020.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    private lazy var resultLabel: UILabel = .sectionTitle("Tap on the label…")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackView.addArrangedSubview(resultLabel)
        
        stackView.addArrangedSubview(UILabel.sectionTitle("Left alignment"))
        stackView.addArrangedSubview(HyperlinkLabel.banner(withAlignment: .left, customStyling: false, tapHandler: didTap))
        stackView.addArrangedSubview(HyperlinkLabel.banner(withAlignment: .left, customStyling: true, tapHandler: didTap))

        stackView.addArrangedSubview(UILabel.sectionTitle("Center alignment"))
        stackView.addArrangedSubview(HyperlinkLabel.banner(withAlignment: .center, customStyling: false, tapHandler: didTap))
        stackView.addArrangedSubview(HyperlinkLabel.banner(withAlignment: .center, customStyling: true, tapHandler: didTap))

        stackView.addArrangedSubview(UILabel.sectionTitle("Right alignment"))
        stackView.addArrangedSubview(HyperlinkLabel.banner(withAlignment: .right, customStyling: false, tapHandler: didTap))
        stackView.addArrangedSubview(HyperlinkLabel.banner(withAlignment: .right, customStyling: true, tapHandler: didTap))
    }
    
    private func didTap(_ url: URL) {
        resultLabel.text = "Did tap on: \(url)"
    }
}

private extension HyperlinkLabel {
    static func banner(withAlignment alignment: NSTextAlignment, customStyling: Bool, tapHandler: @escaping (URL) -> Void) -> HyperlinkLabel {
        let attributedString = NSMutableAttributedString(string: "Check this webpage: %0$@. Link to %1$@ on the App Store. Finally link to %2$@.")
        let replacements = [("Augmented Code", URL(string: "https://augmentedcode.io")!),
                            ("SignalPath", URL(string: "https://geo.itunes.apple.com/us/app/signalpath/id1210488485?mt=12")!),
                            ("GitHub", URL(string: "https://github.com/laevandus")!)]
        replacements.enumerated().forEach { index, value in
            let linkAttribute: NSAttributedString.Key = customStyling ? .hyperlink : .link
            let attributes: [NSAttributedString.Key: Any] = [
                linkAttribute: value.1
            ]
            let urlAttributedString = NSAttributedString(string: value.0, attributes: attributes)
            let range = (attributedString.string as NSString).range(of: "%\(index)$@")
            attributedString.replaceCharacters(in: range, with: urlAttributedString)
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        let label = HyperlinkLabel()
        label.attributedText = attributedString
        label.translatesAutoresizingMaskIntoConstraints = false
        label.didTapOnURL = tapHandler
        return label
    }
}

private extension UILabel {
    static func sectionTitle(_ title: String) -> UILabel {
        let label = UILabel(frame: .zero)
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = title
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
