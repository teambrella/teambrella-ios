//
//  ViewController.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 28.03.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
let server = ServerService()
    var timestamp: Int64?
    
    @IBOutlet var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestTimestamp {}
    }
    
    func requestTimestamp(completion: @escaping () -> Void) {
        guard timestamp == nil else {
            completion()
            return
        }
        
        let request = AmbrellaRequest(type: .timestamp, success: { [weak self] response in
            if case .timestamp(let timestamp) = response {
                self?.textField.text = String(timestamp)
                self?.timestamp = timestamp
                completion()
            }
        })
        request.start()
    }

    @IBAction func tapInitClient() {
        requestTimestamp {
            
        }
        /*
         if (TryInitTimestamp())
         {
         var modelIn = new ApiQuery();
         modelIn.AddSignature(_timestamp, bitcoinPrivateKey);
         var request = new RestRequest("me/InitClient", Method.POST);
         request.RequestFormat = DataFormat.Json;
         request.AddBody(modelIn);
         var responseInit = _restClient.Execute<ApiResult>(request);
         
         ApiResult result = responseInit.Data;
         if (result != null)
         {
         _timestamp = result.Timestamp;
         return result;
         }
         }
         
         return null;
         */
    }
    
    @IBAction func tapTeammates() {
        textField.text = "Getting teammates"
        let body = RequestBodyFactory.fakeTeammatesBody()
        let request = AmbrellaRequest(type: .teammatesList, body: body, success: { [weak self] response in
            if case .teammatesList = response {
                self?.textField.text = "got teammates"
            }
        })
        request.start()
    }
    
}
