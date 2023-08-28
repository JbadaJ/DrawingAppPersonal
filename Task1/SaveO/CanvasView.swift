//
//  CanvasView.swift
//  SaveO
//
//  Created by 장하다 on 2023/08/10.
//

import UIKit
import PencilKit
import PhotosUI
import Photos

class CView: UIViewController {
    // 그림판이 있을 위치 이름: Page
    @IBOutlet weak var Page: UIView!
    //이미지 가져오는 버튼
    @IBAction func tapPickup(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    //그린거 파일로 저장
    @IBAction func tap_Save(_ sender: Any) {
        
        let sheet = UIAlertController(title: "choose action", message: nil, preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "save drawing", style: .default, handler: {_ in self.saveDrawing()}))
        sheet.addAction(UIAlertAction(title: "save in album", style: .default, handler: {_ in self.savePng()}))
        present(sheet,animated: true)

    }
    
    @IBAction func tap_Reset(_ sender: Any) {
        //그림판 reset
        canvasView.drawing = PKDrawing()
    }
    
    @IBAction func layer(_ sender: Any) {
        layerDelete()
    }
    
    @IBAction func tap_Load(_ sender: Any) {
        let docuDir = FileManager.SearchPathDirectory.documentDirectory
        let uMask = FileManager.SearchPathDomainMask.userDomainMask
        let upath = NSSearchPathForDirectoriesInDomains(docuDir, uMask, true)
        
        if let dirPath = upath.first{
            let dataUrl = URL(fileURLWithPath: dirPath).appendingPathComponent("test.png")

            let loadDrawing = try! Data.init(contentsOf: dataUrl)
            let resultLoad = try! PKDrawing(data: loadDrawing)
            canvasView.drawing.append(resultLoad)
            
       }
        
    }
    
    var drawing = PKDrawing()
    let toolPicker = PKToolPicker()
    //빈 캔버스
    var canvasView: PKCanvasView = {
        var canvas = PKCanvasView()
        //컴퓨터에서 테스트때만 쓸것
        canvas.backgroundColor = UIColor.clear
        canvas.drawingPolicy = .anyInput
        return canvas
    }()
    
    override func viewDidLoad() {
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool){

    }
    //그림판 구현하는 기능
    func setup() {
        //canvasView = PKCanvasView(frame: Page.bounds)
        super.viewDidLoad()
        canvasView.drawing = drawing
        canvasView.frame.size = Page.frame.size
        canvasView.isOpaque = true
        
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        Page.addSubview(canvasView)
    }
    
    func saveDrawing(){
        let drawingSave = canvasView.drawing.dataRepresentation()
        let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileUrl = documentUrl.appendingPathComponent("test.png")
        do {
            try drawingSave.write(to: fileUrl)
        }catch {
        }
    }
    
    func savePng(){
        //image를 이용한 저장
        PHPhotoLibrary.authorizationStatus(for: .addOnly)
        let saveImg = canvasView.drawing.image(from: Page.frame, scale: CGFloat(1.0))
        UIImageWriteToSavedPhotosAlbum(saveImg, nil, nil, nil)
    }
    func layerDelete(){
        let dataNum = canvasView.drawing.strokes.count
        canvasView.drawing.strokes.remove(at: dataNum-1)
    }
    func layerChange(){
        //미완
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "buck y"
    }
}
//갤러리에서 그림가져오기
extension CView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            
            let toSend = UIImageView(image: image)
            toSend.contentMode = .scaleAspectFit
            toSend.clipsToBounds = true
            Page.insertSubview(toSend, at: 0)
            
            
// 가져온 이미지를 데이터로 바꾸어서 drawing에 추가할려고했는데 실패
//            do{
//                let finalData = image.pngData()
//                let resultFinal = try PKDrawing(data: finalData!)
//                canvasView.drawing.append(resultFinal)
//            }catch{
//                print("eror dodk sibal")
//            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
