//
//  ViewController.swift
//  ClickPhoto
//
//  Created by Shakti on 06/06/22.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    let camera = UIImagePickerController()
    var cutomCameraView: UIView!
    
    @IBOutlet weak var imagView: UIImageView!
    @IBOutlet weak var clickPhoto: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        clickPhoto.layer.cornerRadius = 5
        do{
         let photoArray = try PersistenceService.sharedIns.context.fetch(UserPhoto.fetchRequest())
            if photoArray.count != 0{
                if let img = UIImage(data: (photoArray.first?.photo)!){
                    self.imagView.image = img
                }
            }
        }catch{
            print(error)
        }
        // Do any additional setup after loading the view.
    }
    @IBAction func clickPhoto(_ sender: Any) {
        cutomCameraView = UIView()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            
            camera.delegate = self
            camera.sourceType = UIImagePickerController.SourceType.camera;
            camera.allowsEditing = true
            camera.cameraDevice = .front
            camera.cameraOverlayView = self.addCustomLayer()
            
            self.present(camera, animated: true, completion: nil)
        }
    }
    func addCustomLayer() -> UIView? {
        
        cutomCameraView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height-500)
        self.addLayer(cutomCameraView)
        
        cutomCameraView.tag = 101
        return cutomCameraView
    }
    
    func addLayer(_ cameraView: UIView){
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height), cornerRadius: 0)
        let circle = UIBezierPath(arcCenter: CGPoint(x: self.view.center.x, y: self.view.center.y-100), radius: 200.0, startAngle: CGFloat(0 * Double.pi/180), endAngle: CGFloat(180 * Double.pi/180), clockwise: false)
        let curve = UIBezierPath()
        curve.move(to: CGPoint(x: self.view.center.x - 200, y: self.view.center.y-100))
        curve.addCurve(to: CGPoint(x: self.view.center.x + 200, y: self.view.center.y-100), controlPoint1: CGPoint(x: self.view.center.x - 180, y: self.view.center.y + 300), controlPoint2: CGPoint(x: self.view.center.x + 180, y: self.view.center.y + 300))
        path.append(circle)
        path.append(curve)
        path.usesEvenOddFillRule = true
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillRule = .evenOdd
        layer.opacity = 0.8
        cameraView.layer.addSublayer(layer)
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            let alert = UIAlertController(title: "Failure", message: "\(error!.localizedDescription)", preferredStyle: .alert)
               let action = UIAlertAction(title: "OK", style: .default)
               alert.addAction(action)
               self.present(alert, animated: true)
           } else {
               let alert = UIAlertController(title: "Success", message: "Image save successfully in your photo library!", preferredStyle: .alert)
               let action = UIAlertAction(title: "OK", style: .default)
               alert.addAction(action)
               self.present(alert, animated: true)
           }
       }
}
extension ViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        self.imagView.image = image
        guard let pngData = image.pngData() else {return}
          UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        PersistenceService.sharedIns.deleteAllData("UserPhoto")
        let context = UserPhoto(context: PersistenceService.sharedIns.context)
        context.photo = pngData
        PersistenceService.sharedIns.saveContext { status in
            print("save")
        }
        self.dismiss(animated: true) {
            
        }
        
    }
}


