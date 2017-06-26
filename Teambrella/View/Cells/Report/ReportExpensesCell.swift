//
//  ReportExpensesCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 24.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class ReportExpensesCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var headerLabel: InfoLabel!
    @IBOutlet var expensesTextField: UITextField!
    @IBOutlet var currencyTextField: UITextField!
    @IBOutlet var numberBar: NumberBar!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
