//
//  ViewController.swift
//  EasyDraw
//
//  Created by Longyi Li on 17/08/17.
//  Copyright © 2017 Longyi Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //select color and shape
    var selectedColor = UIColor.transparentBlue
    var selectedShape = Shapes.freeStyle
    
    var drawView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 100))
    
    //everything for drawing
    var startPoint: CGPoint = CGPoint.zero
    var endPoint : CGPoint = CGPoint.zero
    var customPath : UIBezierPath?
    var layer : CAShapeLayer?
    var lineCap : String = kCALineCapRound
    var lineWid : CGFloat = 1.0
    let shapeArray = [Shapes.freeStyle, Shapes.line, Shapes.oval, Shapes.rectangle, Shapes.triangle,
                      Shapes.star]
    let colorArray = [UIColor.transparentYellow, UIColor.transparentGreen, UIColor.transparentBlue, UIColor.transparentRed, UIColor.transparentPurple, UIColor.white]
    

    //colorbtn array and shapebtn array
    var colorBtn = [UIButton]()
    var shapeBtn = [UIButton]()
    
    // all buttons
    @IBOutlet weak var btnYellow: UIButton!
    @IBOutlet weak var btnGreen: UIButton!
    @IBOutlet weak var btnBlue: UIButton!
    @IBOutlet weak var btnRed: UIButton!
    @IBOutlet weak var btnPurple: UIButton!
    @IBOutlet weak var btnWhite: UIButton!

    @IBOutlet weak var freeBtn: UIButton!
    @IBOutlet weak var lineBtn: UIButton!
    @IBOutlet weak var ovalBtn: UIButton!
    @IBOutlet weak var rectBtn: UIButton!
    @IBOutlet weak var triBtn: UIButton!
    @IBOutlet weak var starBtn: UIButton!

    //line width slider
    @IBOutlet weak var lineSlider: UISlider!

    @IBAction func lineWidth(_ sender: UISlider) {
        lineWid = CGFloat(lineSlider.value)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // set two view's background color
        self.view.addSubview(drawView)
        
        //create pangesture
        let panGesture = UIPanGestureRecognizer(target: self, action: (#selector(ViewController.handlePan(_:))))
        drawView.addGestureRecognizer(panGesture)
        
        
        //init status for btn
        btnBlue.layer.borderColor = UIColor.black.cgColor
        btnBlue.layer.borderWidth = 3
        freeBtn.layer.borderColor = UIColor.black.cgColor
        freeBtn.layer.borderWidth = 3
        
        
        // set border color for clicked button
        colorBtn.append(btnYellow)
        colorBtn.append(btnGreen)
        colorBtn.append(btnBlue)
        colorBtn.append(btnRed)
        colorBtn.append(btnPurple)
        
        shapeBtn.append(freeBtn)
        shapeBtn.append(lineBtn)
        shapeBtn.append(ovalBtn)
        shapeBtn.append(triBtn)
        shapeBtn.append(rectBtn)
        shapeBtn.append(starBtn)
        
        
        for btn in colorBtn {
            btn.addTarget(self, action: #selector(colorHighlight), for: .touchDown)
        }
        
        for btn in shapeBtn {
            btn.addTarget(self, action: #selector(shapeHighlight), for: .touchDown)
        }

    }
    
    func colorHighlight(sender: UIButton) {
        for btn in colorBtn {
            btn.layer.borderWidth = 0
        }
        sender.layer.borderColor = UIColor.black.cgColor
        sender.layer.borderWidth = 3
    }
    
    func shapeHighlight(sender: UIButton) {
        for btn in shapeBtn {
            btn.layer.borderWidth = 0
        }
        btnWhite.layer.borderWidth = 0
        sender.layer.borderColor = UIColor.black.cgColor
        sender.layer.borderWidth = 3
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func shapeDidSelect(_ sender: UIButton)
    {
        selectedShape = shapeArray[sender.tag - 10]
    }
    
    @IBAction func colorDidSelect(_ sender: UIButton)
    {
        selectedColor = colorArray[sender.tag]
    }
    
    //eraser
    @IBAction func eraser(_ sender: UIButton) {
        selectedColor = UIColor.white
        selectedShape = Shapes.freeStyle
        for btn in shapeBtn {
            btn.layer.borderWidth = 0
        }
        colorHighlight(sender: btnWhite)
    }
    //save image to local album
    @IBAction func saveToAlbum(_ sender: UIButton) {
        let height:CGFloat = self.view.bounds.size.height - 100
        let imageSize :CGSize = CGSize(width: self.view.bounds.size.width, height: height)
        UIGraphicsBeginImageContext(imageSize)
        drawView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(img, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        var resultTitle:String?
        var resultMessage:String?
        if error != nil {
            resultTitle = "Error"
            resultMessage = "Please check authority"
        } else {
            resultTitle = "Confirm"
            resultMessage = "Save successfully"
        }
        let alert:UIAlertController = UIAlertController.init(title: resultTitle, message:resultMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    

    
    //clear all images
    @IBAction func clearView(_ sender: UIButton) {
        let alert = UIAlertController(title: "Alert", message: "Delete All", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        

        alert.addAction(UIAlertAction(title: "Confirm", style: .cancel, handler: { action in
                self.drawView.removeFromSuperview();
                self.drawView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 100))
                self.view.addSubview(self.drawView)
            
            
            let panGesture = UIPanGestureRecognizer(target: self, action: (#selector(ViewController.handlePan(_:))))
            self.drawView.addGestureRecognizer(panGesture)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    

    func handlePan(_ sender: UIPanGestureRecognizer)
    {
        
        if sender.state == .began
        {
            customPath = UIBezierPath()
            startPoint = sender.location(in: sender.view)
            layer = CAShapeLayer()
            layer?.fillColor = selectedColor.cgColor
            layer?.lineWidth = lineWid
            layer?.lineCap = lineCap
            self.drawView.layer.addSublayer(layer!)
        }
        else if sender.state == .changed
        {
            if(drawView.bounds.contains(sender.location(in: sender.view))){
                switch selectedShape
                {
                case Shapes.freeStyle:
                    layer?.strokeColor = selectedColor.cgColor
                    endPoint = sender.location(in: sender.view)
                    customPath?.move(to: startPoint)
                    customPath?.addLine(to: endPoint)
                    startPoint = endPoint
                    customPath?.close()
                    layer?.path = customPath?.cgPath
                    
                case Shapes.oval:
                    let translation = sender.translation(in: sender.view)
                    layer?.path = ShapePath().oval(startPoint: startPoint, translationPoint: translation).cgPath
                    
                case Shapes.rectangle:
                    let translation = sender.translation(in: sender.view)
                    layer?.path = ShapePath().rectangle(startPoint: startPoint, translationPoint: translation).cgPath
                    
                case Shapes.line:
                    layer?.strokeColor = selectedColor.cgColor
                    endPoint = sender.location(in: sender.view)
                    layer?.path = ShapePath().line(startPoint: startPoint, endPoint: endPoint).cgPath
                    
                case Shapes.triangle:
                    endPoint = sender.location(in: sender.view)
                    layer?.path = ShapePath().triangle(startPoint: startPoint, endPoint: endPoint).cgPath
                    
                case Shapes.star:
                    let translation = sender.translation(in: sender.view)
                    layer?.path = ShapePath().star(startPoint: startPoint, translationPoint: translation).cgPath
                }
            }
           
        }
    }

}

