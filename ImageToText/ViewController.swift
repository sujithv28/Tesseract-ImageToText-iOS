//
//  ViewController.swift
//  ImageToText
//
//  Created by Sujith Vishwajith on 2/1/16.
//  Copyright © 2016 Sujith Vishwajith. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate {
    var image: UIImage!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var picker:UIImagePickerController?=UIImagePickerController()
    var popover:UIPopoverController?=nil
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker!.delegate=self
    }

    @IBAction func imageButton(sender: AnyObject) {
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openCamera()
                
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
            {
                UIAlertAction in
                
        }
        
        // Add the actions
        picker?.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        // Present the controller
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            popover=UIPopoverController(contentViewController: alert)
            popover!.presentPopoverFromRect(imageButton.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            picker!.sourceType = UIImagePickerControllerSourceType.Camera
            self .presentViewController(picker!, animated: true, completion: nil)
        }
        else
        {
            openGallery()
        }
    }
    
    func openGallery()
    {
        picker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(picker!, animated: true, completion: nil)
        }
        else
        {
            popover=UIPopoverController(contentViewController: picker!)
            popover!.presentPopoverFromRect(imageButton.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        image = info[UIImagePickerControllerOriginalImage] as? UIImage
        addActivityIndicator()
        
        picker.dismissViewControllerAnimated(true, completion: {
            self.analyzePicture()
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        print("picker cancel.")
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    func analyzePicture()
    {
        let scaledImage = scaleImage(image, maxDimension: 640)
        print("Recognizing Image")
        
        let tesseract = G8Tesseract()
        tesseract.language = "eng"
        tesseract.engineMode = .TesseractCubeCombined
        tesseract.pageSegmentationMode = .Auto
        tesseract.maximumRecognitionTime = 60.0
        tesseract.image = scaledImage.g8_blackAndWhite()
        tesseract.recognize()
        
        textView.text = tesseract.recognizedText
        
        removeActivityIndicator()
    }

    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        var scaleFactor: CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    func addActivityIndicator() {
        activityIndicator.startAnimating()
    }
    
    func removeActivityIndicator() {
        activityIndicator.stopAnimating()
    }
    
}

