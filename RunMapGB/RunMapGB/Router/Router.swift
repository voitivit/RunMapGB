//
//  Router.swift
//  RunMapGB
//
//  Created by emil kurbanov on 02.05.2022.
//

import Foundation
import UIKit

import UIKit

class Router: NSObject {
    var controller: UIViewController
    
    init(controller: UIViewController) {
        self.controller = controller
    }
    
    func perform<Controller: UIViewController>(segue: String, performAction: ((Controller) -> Void)? = nil) {
        let performAction = performAction.map { action in { (controller: UIViewController) in
            guard let controller = controller as? Controller else { return }
            action(controller)}
        }
        controller.performSegue(withIdentifier: segue, sender: performAction)
    }
    
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let action = sender as? ((UIViewController) -> Void) else { return }
        action(segue.destination)
    }
}

