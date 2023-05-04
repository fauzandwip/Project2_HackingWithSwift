//
//  ViewController.swift
//  Project2
//
//  Created by Fauzan Dwi Prasetyo on 19/04/23.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var liveScore: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    var tap = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
        
        askQuestion()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(tap), style: .plain, target: .none, action: .none)
    }

    func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()
        
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        correctAnswer = Int.random(in: 0...2)
        title = countries[correctAnswer].uppercased()
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String

        tap += 1
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(tap), style: .plain, target: .none, action: .none)
        
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
        } else {
            title = "Wrong! That's the flag of \(countries[sender.tag].uppercased())"
            score -= 1
        }
        
        liveScore.text = "Score : \(score)"
        
        var msg = "Your score is \(score)"
        
        if tap == 10 {
            msg = "Your final score is \(score)"
        }
        
        let ac = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
        
        present(ac, animated: true)
        
        if tap == 10 {
            button1.isEnabled = false
            button2.isEnabled = false
            button3.isEnabled = false
        }
    }
    
    @IBAction func resetTapped(_ sender: UIButton) {
        tap = 0
        score = 0
        
        askQuestion()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(tap), style: .plain, target: .none, action: .none)
        
        liveScore.text = "Score : \(score)"
        
        button1.isEnabled = true
        button2.isEnabled = true
        button3.isEnabled = true
    }
}

