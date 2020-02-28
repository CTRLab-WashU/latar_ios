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
                                               name: tapLatenceyStartNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(teardownTapLatency(notification:)),
                                               name: tapLatenceyStopNotification, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupDisplayLatency(notification:)),
                                               name: displayLatenceyStartNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(teardownDisplayLatency(notification:)),
                                               name: displayLatenceyStopNotification, object: nil);
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
    }
    
    @objc func setupTapLatency(notification:Notification)
    {
        DispatchQueue.main.async {
            let vc = TapLatencyViewController.init(nibName: "TapLatencyViewController", bundle: nil);
            
            vc.modalPresentationStyle = .fullScreen;
            self.present(vc, animated: true) {
                
            }
        }
    }
    
    
    @objc func setupDisplayLatency(notification:Notification)
    {
        DispatchQueue.main.async {
            guard let displayParams:Dictionary<String, Int> = notification.object as! Dictionary<String, Int>,
                let count:Int = displayParams["count"],
                let interval:Int = displayParams["interval"]
                else { return; }
            
            let vc = DisplayLatencyViewController.init(nibName: "DisplayLatencyViewController", bundle: nil);
            vc.count = count;
            vc.interval = interval;
            
            vc.modalPresentationStyle = .fullScreen;
            self.present(vc, animated: true) {
                
            }
        }
    }
    
    
    @objc func teardownTapLatency(notification:Notification)
    {
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                LaTARSocket.shared.acknowledgeCommand(.TAP_STOP);
            }
        }
    }
    
    
    @objc func teardownDisplayLatency(notification:Notification)
    {
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                LaTARSocket.shared.acknowledgeCommand(.DISPLAY_STOP);
            }
        }
    }
    

    @objc func displayLog(notification:Notification)
    {
        guard var log:String = notification.userInfo?["log"] as? String else { return;}
            log = log.replacingOccurrences(of: "\\n", with: "\n");
        self.logText += log + "\n";
        DispatchQueue.main.async{
            if !(self.viewIfLoaded?.isHidden ?? true)
            {
                self.textLog.text = self.logText;
            }
        }
    }
    
    @IBAction func ConnectPressed(_ sender: UIButton) {
        
        if LaTARSocket.shared.isConnected
        {
            LaTARSocket.shared.closeSocket();
            sender.setTitle("Connect", for: .normal);
        }
        else
        {
            LaTARSocket.shared.initSocket(host: "192.168.191.153");
            sender.setTitle("Disconnect", for: .normal);
        }
    
    }
}

