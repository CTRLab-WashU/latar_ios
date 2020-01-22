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
    
    public var logText:String = "";
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String;
        
        self.versionLabel.text = "Ver \(version)";
        
        NotificationCenter.default.addObserver(self, selector: #selector(displayLog(notification:)),
                                               name: LALogging.loggedNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(setupTapLatency(notification:)),
                                               name: tapLatenceySetupNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(teardownTapLatency(notification:)),
                                               name: tapLatenceyTeardownNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(setupDisplayLatency(notification:)),
                                               name: displayLatenceySetupNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(teardownDisplayLatency(notification:)),
                                               name: displayLatenceyTeardownNotification, object: nil);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
    }
    
    @objc func setupTapLatency(notification:Notification)
    {
        
        let vc = TapLatencyViewController.init(nibName: "TapLatencyViewController", bundle: nil);
        
        vc.modalPresentationStyle = .fullScreen;
        self.present(vc, animated: true) {
            LaTARSocket.shared.acknowledgeCommand(.TAP_SETUP);
        }
    }
    
    
    @objc func setupDisplayLatency(notification:Notification)
    {
        
        let vc = DisplayLatencyViewController.init(nibName: "DisplayLatencyViewController", bundle: nil);
        
        vc.modalPresentationStyle = .fullScreen;
        self.present(vc, animated: true) {
            LaTARSocket.shared.acknowledgeCommand(.DISPLAY_SETUP);
        }
    }
    
    
    @objc func teardownTapLatency(notification:Notification)
    {
        self.dismiss(animated: true) {
            LaTARSocket.shared.acknowledgeCommand(.TAP_TEARDOWN);
        }
    }
    
    
    @objc func teardownDisplayLatency(notification:Notification)
    {
        
        self.dismiss(animated: true) {
            LaTARSocket.shared.acknowledgeCommand(.DISPLAY_TEARDOWN);
        }
    }
    

    @objc func displayLog(notification:Notification)
    {
        guard let log:String = notification.userInfo?["log"] as? String else { return;}
        self.logText += log + "\n";
        DispatchQueue.main.async{
            if !(self.viewIfLoaded?.isHidden ?? true)
            {
                self.textLog.text += log + "\n";
            }
        }
    }
    
}

