//
//  DiffusionInfoXPC
//
//  Created by Anastasiy on 11/8/22.
//

import Foundation


// Create the delegate for the service.
let delegate = DiffusionInfoXPCDelegate()
let listener = NSXPCListener.service()
listener.delegate = delegate
listener.resume()

