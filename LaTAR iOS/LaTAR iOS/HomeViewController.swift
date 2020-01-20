//
//  ViewController.swift
//  LaTAR iOS
//
//  Created by Michael Votaw on 1/20/20.
//  Copyright © 2020 healthyMedium. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var textLog: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String;
        
        self.versionLabel.text = "Ver \(version)";
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        NotificationCenter.default.addObserver(self, selector: #selector(displayLog(notification:)), name: LALogging.loggedNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(setupTapLatency(notification:)), name: tapLatenceySetupNotification, object: nil);
        
        LaTARSocket.initializeShared();

    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        NotificationCenter.default.removeObserver(self);
    }

    
    @objc func setupTapLatency(notification:Notification)
    {
        self.performSegue(withIdentifier: "showTapLatency", sender: nil);
    }
    

    @objc func displayLog(notification:Notification)
    {
        guard let log:String = notification.userInfo?["log"] as? String else { return;}
        DispatchQueue.main.async{
            self.textLog.text += log + "\n";
        }
    }
    
    
    @IBSegueAction func showTapLatency(_ coder: NSCoder) -> TapLatencyViewController? {
        let vc = TapLatencyViewController(coder: coder);
        vc?.modalPresentationStyle = .fullScreen;
        
        return vc;
    }
    
}

