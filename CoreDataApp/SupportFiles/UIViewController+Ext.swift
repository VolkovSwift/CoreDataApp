import UIKit

extension UIViewController {
    func presentTextFieldAlert(title: String, message: String = "", textFieldPlaceholder: String, completion: @escaping (String?)->()) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { _ -> Void in
            let urlTextField = alertController.textFields![0] as UITextField
            completion(urlTextField.text)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alertController.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = textFieldPlaceholder
            completion(nil)
        }
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
