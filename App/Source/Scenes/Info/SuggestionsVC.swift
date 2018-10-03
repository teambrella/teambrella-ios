//
/* Copyright(C) 2016-2018 Teambrella, Inc.
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
 * along with this program.  If not, see http://www.gnu.org/licenses/
 */

import UIKit

private let identifier = "Suggestions cell"

protocol SuggestionsVCDelegate: class {
    func suggestions(vc: SuggestionsVC, textChanged: String)
    func suggestionsVCWillClose(vc: SuggestionsVC)
}

class SuggestionsVC: UIViewController, Routable {
    static let storyboardName = "Info"

    @IBOutlet var topContainerView: UIView!
    @IBOutlet var textField: TextField!
    @IBOutlet var confirmButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    var suggestions: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    weak var delegate: SuggestionsVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    @IBAction func tapConfirmButton(_ sender: Any) {
        delegate?.suggestionsVCWillClose(vc: self)
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func textChanged(sender: TextField) {
        delegate?.suggestions(vc: self, textChanged: sender.text ?? "")
    }

}

extension SuggestionsVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        return cell
    }
    
}

extension SuggestionsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.text = suggestions[indexPath.row]
    }
}
