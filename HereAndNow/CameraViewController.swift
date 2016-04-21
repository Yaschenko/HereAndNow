//
//  CameraViewController.swift
//  HereAndNow
//
//  Created by Yurii on 4/15/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    var cameraPosition = AVCaptureDevicePosition.Front
    let captureSession = AVCaptureSession()
    
    var currentInput:AVCaptureInput?
    var currentOutput:AVCaptureOutput?
    
    var stillImageOutput:AVCaptureStillImageOutput?
    lazy var captureSessionQueue:dispatch_queue_t = dispatch_queue_create("capture_session_queue", DISPATCH_QUEUE_SERIAL)
    @IBOutlet weak var cameraView:UIView!
    var previewLayer:AVCaptureVideoPreviewLayer?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.initCamera()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.initPreviewLayer()
    }
    override func viewWillDisappear(animated: Bool) {
        self.captureSession.stopRunning()
    }
    private func initPreviewLayer() {
        if self.previewLayer != nil {
            return
        }
        let view = self.cameraView
        if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
            previewLayer.bounds = view.bounds
            previewLayer.position = CGPointMake(view.bounds.midX, view.bounds.midY)
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            let cameraPreview = UIView(frame: CGRectMake(0.0, 0.0, view.bounds.size.width, view.bounds.size.height))
            cameraPreview.layer.addSublayer(previewLayer)
            view.addSubview(cameraPreview)
            self.previewLayer = previewLayer
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    private func rotateCamera() {
        dispatch_async(self.captureSessionQueue) {
            let lockQueue = dispatch_queue_create("capture_queue_lockQueue", nil)
            dispatch_sync(lockQueue) {
                if self.cameraPosition == AVCaptureDevicePosition.Front {
                    self.cameraPosition = AVCaptureDevicePosition.Back
                }
                self.captureSession.beginConfiguration()
                self.setInput()
                self.captureSession.commitConfiguration()
            }
        }
    }
    private func removeAllInputs() {
        for input in captureSession.inputs {
            guard let deviceInput = input as? AVCaptureDeviceInput else {
                continue
            }
            captureSession.removeInput(deviceInput)
        }
    }
    private func setInput() {
        guard let captureDevice = self.getDevice(self.cameraPosition) else {
            return
        }
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(deviceInput) {
                self.removeAllInputs()
                captureSession.addInput(deviceInput)
            }
        } catch {
            return
        }
        if captureSession.canSetSessionPreset(AVCaptureSessionPresetHigh) {
            captureSession.sessionPreset = AVCaptureSessionPresetHigh
        }
    }
    
    private func initCamera() {
        guard self.cameraAvaiable() == true else {
            return
        }
        if self.cameraAvaiable() == true {
            self.setInput()
            captureSession.startRunning()
            
            let output = AVCaptureStillImageOutput()
            self.stillImageOutput = output
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            }
        }
    }
//    func addInput(position:AVCaptureDevicePosition) -> Bool {
//        
//    }
    func cameraAvaiable() -> Bool {
        let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaTypeVideo)}
        return devices.count > 0 ? true : false
    }
    func getDevice(position:AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaTypeVideo) && $0.position == position }
        if devices.count > 0 {
            return devices.first as? AVCaptureDevice
        }
        return nil
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
