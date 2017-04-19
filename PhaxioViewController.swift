//
//  PhaxioViewController.swift
//  MySampleApp
//
//  Created by Shachy Rivas on 4/18/17.
//
//

import UIKit

class PhaxioViewController: UIViewController {
    // example url needed for access base_url + "/" + path + "/?" + "api_key=" + key + "&api_secret=" + secret
    var base_url = "https://api.phaxio.com/v2"
    var path = "faxes/"
    var test_key = "f1104bb29b050e3e58282cdb71bcbfd3b2573ce7"
    var test_secret = "f6398a472db707f6ee2cfe299fc20584dcb78613"
    var api_key = "2f6c613cb4b1f52ce145aac6720779298f05ade2"
    var api_secret = "41b71944ad7165b95da82878e7e828cdadae2e5f"
    var fax_id:Int = -1
    
    var rep: Rep = Rep()
    
    @IBOutlet weak var sendFaxButton: UIButton!
    @IBOutlet weak var sendFaxInput: UITextField!
    @IBOutlet weak var faxioLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        faxioLabel.text = "Click to edit: "
        sendFaxInput.text = rep.fax
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendFaxButtonAction(_ sender: Any) {
        //get parameters i.e. (to, callback_url) from DB here
        let to = "+18558871688"
        let content_url = "http://www.lipsum.com/"
        let url = "\(base_url)/\(path)?api_key=\(test_key)&api_secret=\(test_secret)"
        let body = "to=\(to)&content_url=\(content_url)"
        
        let response: [String: Any] = send(url: url as NSString, body: body as NSString) as! [String : Any]
        let data: [String: Any] = response["data"] as! [String: Any]
        self.fax_id = (data["id"] as? Int)!
        let success = (response["success"] as? Bool)!
        if response["success"] != nil {
            sendFaxHandler(success: success, message: response["message"] as! String, url: url as NSString, body: body as NSString)
        }
    }
    
    func sendFaxHandler(success: Bool, message: String, url:NSString, body:NSString) {
        if success {
            let alertController = UIAlertController(title: message, message: "Your fax is on the way!", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                // ... do nothing
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true)
        } else if !success {
            let alertController = UIAlertController(title: message, message: "There was a problem. Please retry sending.", preferredStyle: .alert)
            let ResendAction = UIAlertAction(title: "Resend", style: .default) { action in
                // ... call reset function
                var retry_res:[String: Any] = self.send(url: url as NSString, body: body as NSString) as! [String: Any]
                let retry_data: [String: Any] = retry_res["data"] as! [String: Any]
                self.fax_id = (retry_data["id"] as? Int)!
                let retry_succ = (retry_res["success"] as? Bool)!
                if retry_res["success"] != nil {
                    self.sendFaxHandler(success: retry_succ, message: retry_res["message"] as! String, url: url as NSString, body: body as NSString)
                }
            }
            alertController.addAction(ResendAction)
            let CancelAction = UIAlertAction(title: "Cancel", style: .default) { action in
                // ... do nothing
            }
            alertController.addAction(CancelAction)
            self.present(alertController, animated: true)
        }
    }
    
    
    func send(url:NSString, body:NSString) -> NSDictionary{
        
        let request = NSMutableURLRequest(url: NSURL(string: url as String) as! URL)
        request.httpBody = body.data(using: String.Encoding.utf8.rawValue)
        request.httpMethod = "POST"
        
        var response: URLResponse?
        
        do {
            let data = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response)
            
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print("Synchronous\(jsonResult)")
                    return(jsonResult)
                }
            }catch let error as NSError {
                print(error.localizedDescription)
                
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return [:]
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}