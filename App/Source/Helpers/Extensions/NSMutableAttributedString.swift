//
/* Copyright(C) 2017 Teambrella, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License(version 3) as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see<http://www.gnu.org/licenses/>.
 */

import Foundation

enum StringDecorationType {
    case boldAmount
    case currency
    case integerPart
    case fractionalPart
}

extension NSMutableAttributedString {
    @discardableResult
    func decorate(substring: String,
                  type: StringDecorationType) -> NSMutableAttributedString {
        let range = (self.string as NSString).range(of: substring)
        addAttributes(decorationAttributes(for: type), range: range)
        return self
    }
    
    func add(font: UIFont, range: NSRange?) -> NSMutableAttributedString {
        let range = range ?? NSRange(location: 0, length: self.length)
        addAttribute(.font, value: font, range: range)
        return self
    }
    
    func add(alignment: NSTextAlignment) -> NSMutableAttributedString {
        let range = NSRange(location: 0, length: self.length)
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        addAttribute(.paragraphStyle, value: style, range: range)
        return self
    }
    
    func add(fontColor: UIColor, range: NSRange?) -> NSMutableAttributedString {
        let range = range ?? NSRange(location: 0, length: self.length)
        addAttribute(.foregroundColor, value: fontColor, range: range)
        return self
    }
    
    func add(lineInterval: CGFloat, range: NSRange?) -> NSMutableAttributedString {
        let range = range ?? NSRange(location: 0, length: self.length)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineInterval
        addAttribute(.paragraphStyle, value: style, range: range)
        return self
    }
    
    private func decorationAttributes(for type: StringDecorationType) -> [NSAttributedString.Key: Any] {
        switch type {
        case .boldAmount:
            return [.foregroundColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),
                    .font: UIFont.teambrellaBold(size: 14)]
        case .currency:
            return [.foregroundColor: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1),
                    .font: UIFont.teambrellaBold(size: 10),
                    .baselineOffset: 5]
        case .integerPart:
            return [.foregroundColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),
                    .font: UIFont.teambrellaBold(size: 23)]
        case .fractionalPart:
            return [.foregroundColor: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1),
                    .font: UIFont.teambrellaBold(size: 18),
                    .baselineOffset: 3]
        }
    }
}
