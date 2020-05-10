//  
//  Copyright © 2020 Jeff Watkins. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var button: Button!
    @IBOutlet var buttonTypeSelector: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showContentLayout(.horizontal)

        self.button.addTarget(self, action: #selector(doSomething), for: UIControl.Event.primaryActionTriggered)
    }

    func showContentLayout(_ contentLayout: Button.ContentLayout) {
        let previousButtonIndex = self.button.contentLayout.rawValue
        self.buttonTypeSelector.arrangedSubviews[previousButtonIndex].tintColor = self.view.tintColor
        let newButtonIndex = contentLayout.rawValue
        self.buttonTypeSelector.arrangedSubviews[newButtonIndex].tintColor = UIColor.label
        self.button.contentLayout = contentLayout
    }

    func contentLayoutFromButtonSelector(_ button: UIButton) -> Button.ContentLayout {
        guard let buttonIndex = self.buttonTypeSelector.arrangedSubviews.firstIndex(of: button) else { return .horizontal }
        if let contentLayout = Button.ContentLayout(rawValue: buttonIndex) {
            return contentLayout
        }
        return .horizontal
    }

    @IBAction func changeButtonType(_ sender: UIButton) {
        let contentLayout = self.contentLayoutFromButtonSelector(sender)
        self.showContentLayout(contentLayout)
    }

    @IBAction func doSomething(_ sender: AnyObject) {
        print("WOOP")
    }

}
