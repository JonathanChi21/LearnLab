
import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var infoLbl: UILabel!
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do{
            let model = try  VNCoreMLModel(for: ImageClassifier().model)
            let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
                self.processClasifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop // Nos centrara nuestra imagen dentro de un cuadrado (limites)
            return request
        }catch{
            fatalError("Error al cargar el modelo \(error)")
        }
    }()
    
    // Retorna en String lo que el modelo cree que es:
    
    func processClasifications(for request: VNRequest, error: Error?){
        guard let classifications = request.results as? [VNClassificationObservation] else {
        self.infoLbl.text = "No es posible clasificar la imagen\n\(error?.localizedDescription ?? "Error")"
        return
    }
        
        if classifications.isEmpty{
                   self.infoLbl.text = "No se puede reconocer. \nPor favor intente de nuevo"
               }else{
                   let topClassifications = classifications.prefix(2)
                   let descriptions = topClassifications.map{classification in
                       return classification.identifier
                   }
                   
                   self.infoLbl.text = descriptions.joined(separator: "\n")
                   
               }
    }
    
    func updateClassifications(for image: UIImage){
        infoLbl.text = "Clasificando..."
        
    // Cambiamos la orientacion de manera que el modelo pueda leerlo de una mejor manera aun
        
        guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)),
            let ciImage = CIImage(image: image) else {
                print("Ups! Algo salio mal, intenta de nuevo")
                return
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
        
        do{
            try handler.perform([classificationRequest])
        }catch{
            print("Error en la clasificacion: \(error.localizedDescription)")
        }
        
    }
    
    
    override func viewDidLoad() {
        
        imgView.layer.cornerRadius = 15
        imgView.layer.borderWidth = 5
        imgView.layer.borderColor = UIColor(red:0.34, green:0.35, blue:0.85, alpha:1.0).cgColor
        
        infoLbl.layer.cornerRadius = 15
        infoLbl.layer.borderWidth = 5
        infoLbl.layer.borderColor = UIColor(red:0.37, green:0.82, blue:0.97, alpha:1.0).cgColor

        super.viewDidLoad()
        
    }

    @IBAction func camaraBtn(_ sender: Any) {
        // Funcion en caso de que el usuario no tenga camara en el dispositivo
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary) // Se elige una foto de la galeria
            return
        }
        
        // Funciones que nos permiten usar la camara para tomar una foto:
        
        let photoSourcePicker = UIAlertController()
        
        let takePhotoAction = UIAlertAction(title: "Tomar foto", style: .default) { (_) in
            self.presentPhotoPicker(sourceType: .camera)
        }
        
        // Funcion que permite seleccionar una foto del carrete
        
        let choosePhotoAction = UIAlertAction(title: "Elegir foto", style: .default) { (_) in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(takePhotoAction)
        photoSourcePicker.addAction(choosePhotoAction)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        // Muestra un cuadro de dialogo para seleccionar una de las opciones arriba declaradas en el UIAlertAction
        
        present(photoSourcePicker, animated: true, completion: nil)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true, completion: nil)
    }
    
    // Funcion que inserta imagen dentro de la aplicacion
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        imgView.image = image
        updateClassifications(for: image) // Pasamos la imagen a la aplicacion, ya sea desde carrete o directamente de la camara
    }
    
}



