//
//  LaunchRouter.swift
//  RunMapGB
//
//  Created by emil kurbanov on 02.05.2022.
//

import Foundation
import UIKit

class LaunchRouter: Router {
    init(viewController: UIViewController) {
        super.init(controller: viewController)
    }
    
    func toMapViewController() {
        perform(segue: "show")
    }
}
