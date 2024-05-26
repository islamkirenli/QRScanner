import UIKit

class TextViewController: UIViewController {
    var text: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let textView = UITextView(frame: view.bounds)
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.isEditable = false
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(textView)
        
        let copyButton = UIBarButtonItem(image: UIImage(systemName: "doc.on.doc"), style: .plain, target: self, action: #selector(copyTapped))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        navigationItem.leftBarButtonItems = [copyButton]
        navigationItem.rightBarButtonItems = [doneButton]
    }
    
    @objc func doneTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func copyTapped() {
        if let text = text {
            UIPasteboard.general.string = text
            let alert = UIAlertController(title: nil, message: "Metin kopyalandı", preferredStyle: .alert)
            present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}

