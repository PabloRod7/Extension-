//
//  ActionViewController.swift
//  Extencion
//
//  Created by Pablo Rodrigues on 18/12/2022.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers



class ActionViewController: UIViewController {

    @IBOutlet weak var script: UITextView!
   
    var pageTitle = ""
    var pageURL = ""
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(examples))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyBoard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyBoard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
        
        
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
                if let itemProvider = inputItem.attachments?.first {
                    itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] (dict, error) in
                        guard let itemDictionary = dict as? NSDictionary else {return}
                        guard let javaScriptsValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else {return}
                        
                        self?.pageTitle = javaScriptsValues["title"] as? String ?? ""
                        self?.pageURL = javaScriptsValues["URL"] as? String ?? ""
                        
                        DispatchQueue.main.async {
                            self?.title = self?.pageTitle
                        }
                    }
                }
            }
    
       
    }
//    kUTTypePropertyList
    @IBAction func done() {
       
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": script.text as Any]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier : kUTTypePropertyList as String)
            item.attachments = [customJavaScript]

            extensionContext?.completeRequest(returningItems: [item])
        
        
    }
    
    @objc func adjustForKeyBoard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFram = view.convert(keyboardScreenEndFrame, to: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = .zero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFram.height, right: 0)
        }
        script.scrollIndicatorInsets = script.contentInset
        
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }
    
    @objc func examples() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Examples", style: .default){[weak self] _ in self?.examplesTapped()})
        
    }
   
    func examplesTapped() {
          let ac = UIAlertController(title: "Examples", message: nil, preferredStyle: .alert)
          ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
          
          for (title, example) in scriptExamples {
              ac.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                  self?.script.text = example
              })
          }
          
          present(ac, animated: false)
      }

}
