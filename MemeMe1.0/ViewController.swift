//
//  ViewController.swift
//  MemeMe1.0
//
//  Created by ابرار on ٢٢ ربيع١، ١٤٤٠ هـ.
//  Copyright © ١٤٤٠ هـ Udacity. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UIImagePickerControllerDelegate,
UINavigationControllerDelegate , UITextFieldDelegate{
    @IBOutlet weak var imagePickerView: UIImageView!
    
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var libraryButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bootomTextField: UITextField!
    var memeTextAttributes : [NSAttributedString.Key: Any] = [:]
    @IBOutlet weak var Sharebutton: UIBarButtonItem!
    @IBOutlet weak var topToolbar: UIToolbar!
   // let textDelegates = textsD
    var image = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
     //   topTextField.delegate = self
       // bootomTextField.delegate = self
       // topTextField.placeholder = "TOP"
       // topTextField.text = "TOP"
      //  bootomTextField.text = "BOTTOM"
        Sharebutton.isEnabled = false
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = .center
         memeTextAttributes = [
            NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeColor.rawValue): UIColor.black ,
            NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white,
            NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeWidth.rawValue): 4.0
        ,NSAttributedString.Key.paragraphStyle: titleParagraphStyle]
       
        
    configureMemeTextField(textField: topTextField, text: "TOP")
        configureMemeTextField(textField: bootomTextField, text: "Bottom")
      //  topTextField.delegate = self as? UITextFieldDelegate
      //  bootomTextField.delegate = (self as! UITextFieldDelegate)
       // topTextField.textAlignment = .center
        //bootomTextField.textAlignment = .center
       // topTextField.defaultTextAttributes = memeTextAttributes
      //  bootomTextField.defaultTextAttributes = memeTextAttributes
        imagePickerView.contentMode = .scaleAspectFit
    
        // Do any additional setup after loading the view, typically from a nib.
    }
    
        func configureMemeTextField(textField: UITextField, text: String) {
        textField.text = text
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
    }
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UnsubscribeFromKeyboardNotifications()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func pickAnImage(_ sender: Any) {
        let nextController = UIImagePickerController()
        self.present(nextController, animated: true, completion: nil)
     
        
    
    }
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
          pickAnImage(sourceType: .photoLibrary)
       
    }
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickAnImage(sourceType: .camera)
        
    }
    func pickAnImage(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        present(imagePickerController, animated: true, completion: nil)
    }

    @IBAction func share(_ sender: Any) {
        
        let meme = generateMemedImage()
        
        let controller = UIActivityViewController(activityItems: [meme], applicationActivities: nil)
        
        controller.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                // User canceled
                print("user canceled ")
                return
            }
            // User completed activity
            print("User completed activity")
            
            _ = self.save()
            
            self.dismiss(animated: true, completion: nil)
            
            
        }
        present(controller, animated: true, completion: nil)

    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
       textField.text = ""
        print("text1")
    }
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
            Sharebutton.isEnabled = true

        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bootomTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
        
    }
    @objc func keyboardWillHide(_ notification:Notification){
        view.frame.origin.y = 0
        
    }
    func save() {
        // Create the meme
        let memedImage = generateMemedImage()
        let meme = Meme(topText: topTextField.text!, bottomText: bootomTextField.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
    }
    func generateMemedImage() -> UIImage {
        topToolbar.isHidden = true
        bottomToolbar.isHidden = true        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        topToolbar.isHidden = false
        bottomToolbar.isHidden = false
        Sharebutton.isEnabled = true
        return memedImage
    }
   
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
   func subscribeToKeyboardNotifications()
    {
 NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    func UnsubscribeFromKeyboardNotifications()   {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    
    
}
}
