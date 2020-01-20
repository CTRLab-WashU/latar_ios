//
//  TapLatencyViewController.swift
//  LaTAR iOS
//
//  Created by Michael Votaw on 1/20/20.
//  Copyright © 2020 healthyMedium. All rights reserved.
//

import UIKit

class TapLatencyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }



    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let e = event
        {
            self.processEvent(e);
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let e = event
        {
            self.processEvent(e);
        }
    }
    
    func processEvent(_ event:UIEvent)
    {
        let eventTime = event.timestamp;
        
        guard let touch = event.allTouches?.first else { return; }
        
        let t = LATouch(timestamp: eventTime, touchPhase: touch.phase, touchLocation: touch.location(in: self.view), touchRadius: touch.majorRadius, touchRadiusTolerance: touch.majorRadiusTolerance);
        
        
        HMLog("\(t)");
    }
}
