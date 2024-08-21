//
//  PatientIDViewController.swift
//  Fetal_health_V1.0
//
//  Created by School on 1/5/24.
//

import UIKit

class PatientIDViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var PatientIDTxt: UITextField!
    
//    public var completionHandler: ((String?) -> Void)?
    @IBOutlet weak var groundTruthTxt: UITextField!
    
//    @IBOutlet weak var gestationPeriodTxt: UITextField!
//    
    @IBOutlet weak var gestationPeriodTxt: UITextField!
    
    @IBOutlet weak var startButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the delegate
            PatientIDTxt.delegate = self
            groundTruthTxt.delegate = self
            gestationPeriodTxt.delegate = self
            
            // Initially disable the Start button
            startButton.isEnabled = false
            
            // Add target to text fields
            PatientIDTxt.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
            groundTruthTxt.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
            gestationPeriodTxt.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(tapGesture)
        
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func textFieldsDidChange() {
        let isFilled = !(PatientIDTxt.text?.isEmpty ?? true) &&
                       !(groundTruthTxt.text?.isEmpty ?? true) &&
                       !(gestationPeriodTxt.text?.isEmpty ?? true)
        
        startButton.isEnabled = isFilled
    }
    
    @IBAction func BtnStart(_ sender: Any) {
        self.performSegue(withIdentifier: "mainVC", sender: self)
//        completionHandler?(PatientIDTxt.text)
//        dismiss(animated: true,completion: nil)
    }
    
    func resetInitialState() {
            // Reset any state or clear input fields on the initial screen
            // For example, if you have a text field named 'inputTextField':
        PatientIDTxt.text = ""
        groundTruthTxt.text = ""
        gestationPeriodTxt.text = ""
        }

    // Deactivate START if not filled
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mainVC"{
            if let vc = segue.destination as? ViewController{
                vc.patientID = PatientIDTxt.text!
                vc.groundTruth = groundTruthTxt.text!
                vc.gestationPeriod = gestationPeriodTxt.text!
                
            }
        }
    }

}
