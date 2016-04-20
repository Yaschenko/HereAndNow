////
////  CameraViewController.swift
////  HereAndNow
////
////  Created by Yurii on 4/15/16.
////  Copyright © 2016 Nostris. All rights reserved.
////
//
//import UIKit
//import AVFoundation
//
//class CameraViewController: UIViewController {
//    var cameraPosition = AVCaptureDevicePosition.Front
//    let captureSession = AVCaptureSession()
//    
//    var currentInput:AVCaptureInput?
//    var currentOutPut:AVCaptureOutput?
//    
//    var stillImageOutput:AVCaptureStillImageOutput?
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    private func initCamera() {
//        guard self.cameraAvaiable() == true else {
//            return
//        }
//        if let captureDevice = self.getDevice(self.cameraPosition)  {
//            do {
//                let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
//                captureSession.addInput(deviceInput)
//            } catch {
//                return
//            }
//            
//            captureSession.sessionPreset = AVCaptureSessionPresetHigh
//            captureSession.startRunning()
//            
//            let output = AVCaptureStillImageOutput()
//            self.stillImageOutput = output
//            if captureSession.canAddOutput(<#T##output: AVCaptureOutput!##AVCaptureOutput!#>)
//            captureSession.addOutput(output)
//        }
//    }
//    func addInput(position:AVCaptureDevicePosition) -> Bool {
//        
//    }
//    func cameraAvaiable() -> Bool {
//        let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaTypeVideo)}
//        return devices.count > 0 ? true : false
//    }
//    func getDevice(position:AVCaptureDevicePosition) -> AVCaptureDevice? {
//        let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaTypeVideo) && $0.position == position }
//        if devices.count > 0 {
//            return devices.first as? AVCaptureDevice
//        }
//        return nil
//    }
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
