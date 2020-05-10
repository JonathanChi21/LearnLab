
import UIKit

class IntroViewController: UIViewController {
    
    @IBOutlet weak var holaLbl: UILabel!
    @IBOutlet weak var aprendeLbl: UILabel!
    @IBOutlet weak var comenzarBtn: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        comenzarBtn.layer.cornerRadius = 15
        
    }
    
}
