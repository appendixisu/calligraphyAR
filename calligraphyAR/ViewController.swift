//
//  ViewController.swift
//  calligraphyAR
//
//  Created by 藍偉 on 2020/9/3.
//  Copyright © 2020 Tooxen. All rights reserved.
//

import UIKit
import ARKit


class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var toolbar: UIToolbar!
    
    let fadeDuration: TimeInterval = 0.3
    let rotateDuration: TimeInterval = 3
    let waitDuration: TimeInterval = 0.5
    
    func resetTrackingConfiguration() {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        sceneView.session.run(configuration, options: options)
        label.text = "Move camera around to detect images"
    }
    
    @IBAction func resetButtonDidTouch(_ sender: UIBarButtonItem) {
        resetTrackingConfiguration()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        UIApplication.shared.isIdleTimerDisabled = true
        
        sceneView.delegate = self
//        sceneView.session.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetTrackingConfiguration()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            super.viewWillTransition(to: size, with: coordinator)
            if UIDevice.current.orientation.isLandscape {
                print("Landscape")
                label.isHidden = true
                toolbar.isHidden = true
            } else {
                print("Portrait")
                label.isHidden = false
                toolbar.isHidden = false
            }
        }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

}

extension ViewController: ARSCNViewDelegate {
    
    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOut(duration: 0.5),
            .removeFromParentNode()
        ])
    }
    
    func createZi(name: String, width: CGFloat, position: SCNVector3) -> SCNNode {
        let plane = SCNPlane(width: width,
                             height: width)
        let planeNode = SCNNode(geometry: plane)
        planeNode.opacity = 1
        planeNode.eulerAngles.x = -.pi / 2

//        planeNode.runAction(imageHighlightAction)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let image = UIImage(named: name)
//            planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 30.0 / 255.0,
//                                                          green: 150.0 / 255.0,
//                                                          blue: 30.0 / 255.0,
//                                                          alpha: 1)
            planeNode.geometry?.firstMaterial?.diffuse.contents = image
        }
        planeNode.position = position
        return planeNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
//        node.childNodes.forEach({ $0.removeFromParentNode() })
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        print(node.position)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        let imageName = referenceImage.name ?? "no name"

        let minMa = CGFloat.minimum(referenceImage.physicalSize.width, referenceImage.physicalSize.height)

        print(node.position)
        if imageName == "CopyPaper" {
            node.addChildNode(createZi(name: "人",
                                       width: minMa * 0.15,
                                       position: SCNVector3(-0.18, 0, -0.1)))
            node.addChildNode(createZi(name: "工",
                                       width: minMa * 0.15,
                                       position: SCNVector3(-0.105, 0, -0.1)))
            node.addChildNode(createZi(name: "智",
                                       width: minMa * 0.15,
                                       position: SCNVector3(-0.035, 0, -0.1)))
            node.addChildNode(createZi(name: "慧",
                                       width: minMa * 0.15,
                                       position: SCNVector3(0.04, 0, -0.1)))
            node.addChildNode(createZi(name: "學",
                                       width: minMa * 0.15,
                                       position: SCNVector3(0.105, 0, -0.1)))
            node.addChildNode(createZi(name: "校",
                                       width: minMa * 0.15,
                                       position: SCNVector3(0.18, 0, -0.1)))
        } else {
            node.addChildNode(createZi(name: "人",
                                       width: minMa * 0.25,
                                       position: SCNVector3(-0.13, 0, -0.08)))
            node.addChildNode(createZi(name: "工",
                                       width: minMa * 0.25,
                                       position: SCNVector3(-0.05, 0, -0.08)))
            node.addChildNode(createZi(name: "智",
                                       width: minMa * 0.25,
                                       position: SCNVector3(0.03, 0, -0.08)))
            node.addChildNode(createZi(name: "慧",
                                       width: minMa * 0.25,
                                       position: SCNVector3(0.11, 0, -0.08)))
        }
        
        DispatchQueue.main.async {
            self.label.text = "Image detected: \"\(imageName)\""
        }
        
//        if let planeAnchor = anchor as? ARPlaneAnchor, node.childNodes.count < 1 {
//            print("捕捉到平地")
//            //2.创建一个平面    （系统捕捉到的平地是一个不规则大小的长方形，这里笔者将其变成一个长方形）
//            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
//            //3.使用Material渲染3D模型（默认模型是白色的，这里笔者改成红色）
//            plane.firstMaterial?.diffuse.contents = UIColor.red
//            //4.创建一个基于3D物体模型的节点
//            let planeNode = SCNNode(geometry: plane)
//            //5.设置节点的位置为捕捉到的平地的锚点的中心位置  SceneKit框架中节点的位置position是一个基于3D坐标系的矢量坐标SCNVector3Make
//            planeNode.simdPosition = simd_float3(planeAnchor.center.x, 0, planeAnchor.center.z)
//            //6.`SCNPlane`默认是竖着的,所以旋转一下以匹配水平的`ARPlaneAnchor`
//            planeNode.eulerAngles.x = -.pi / 2
//
//            //7.更改透明度
//            planeNode.opacity = 0.25
//            //8.添加到父节点中
//            node.addChildNode(planeNode)
//
//            //9.上面的planeNode节点,大小/位置会随着检测到的平面而不断变化,方便起见,再添加一个相对固定的基准平面,用来放置游戏场景
//            let base = SCNBox(width: 0.5, height: 0, length: 0.5, chamferRadius: 0)
//            base.firstMaterial?.diffuse.contents = UIColor.gray
//            let baseNode = SCNNode(geometry:base)
//            baseNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
//
//            node.addChildNode(baseNode)
//        }
    }
    
}

extension ViewController: ARSessionDelegate {

}
