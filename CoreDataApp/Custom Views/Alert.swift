import UIKit

struct Alert {
    static func errorAlert(title: String, completion: ((String) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { action in

          guard let textField = alert.textFields?.first,
            let nameToSave = textField.text else {
              return
          }
            
            completion!(nameToSave)
        }
        
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancel)
        
        alert.addTextField()
        return alert
    }
}
