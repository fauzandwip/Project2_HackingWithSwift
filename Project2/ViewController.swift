//
//  ViewController.swift
//  Project2
//
//  Created by Fauzan Dwi Prasetyo on 19/04/23.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var liveScore: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    var defaults = UserDefaults.standard
    
    var tap = 10 {
        didSet {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Life: \(tap)")
        }
    }
    
    var highScore = 0 {
        didSet {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "HS: \(highScore)")
        }
    }
    
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Life: \(tap)")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "HS: \(highScore)")
        
        if let savedData = defaults.object(forKey: "highScore") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                highScore = try jsonDecoder.decode(Int.self, from: savedData)
            } catch {
                print("Failed to load highscore.")
            }
        }
        
        register()
        scheduleWeek()
    }
    
    func saveData() {
        let jsonEncoder = JSONEncoder()
        
        do {
            let savedData = try jsonEncoder.encode(highScore)
            defaults.set(savedData, forKey: "highScore")
        } catch {
            print("Failed to save highscore.")
        }
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

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 5, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        })
        
        tap -= 1
        
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
        } else {
            title = "Wrong! That's the flag of \(countries[sender.tag].uppercased())"
            
            if score > 0 {
                score -= 1
            }
        }
        
        liveScore.text = "Score : \(score)"
        
        var msg = "Your score is \(score)"
        if tap == 0 {
            msg = "Your final score is \(score)"
            
            isHighScore(score)
            
            button1.isEnabled = false
            button2.isEnabled = false
            button3.isEnabled = false
        }
        
        let ac = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
        present(ac, animated: true)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, animations: {
            sender.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
    
    func isHighScore(_ score: Int) {
        if score > highScore {
            highScore = score
            saveData()
        }
        
        let ac = UIAlertController(title: "New HighScore", message: "\(highScore)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @IBAction func resetTapped(_ sender: UIButton) {
        tap = 10
        score = 0
        liveScore.text = "Score : \(score)"
        
        askQuestion()
        
        button1.isEnabled = true
        button2.isEnabled = true
        button3.isEnabled = true
    }
}

extension ViewController: UNUserNotificationCenterDelegate {
    
    func register() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
    
    func scheduleWeek() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        for weekday in 1...7 {
            schedule(for: weekday)
        }
    }
    
    func schedule(for weekday: Int) {
        registerCategories()
        let center = UNUserNotificationCenter.current()
        
        let content = createContent(day: weekday)
        let dateComponents = setDate(hour: 0, min: 17, weekday: weekday)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request)
    }
    
    func createContent(day: Int?) -> UNMutableNotificationContent{
        let content = UNMutableNotificationContent()
        content.title = "It's flag time!"
        content.body = "Day \(day ?? 1). Your favorite game Guess Flags is missing you!"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "It's game time!"]
        content.sound = .default
        
        return content
    }
    
    func setDate(hour: Int?, min: Int?, weekday: Int?) -> DateComponents {
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = min
        dateComponents.weekday = weekday
        
        return dateComponents
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let play = UNNotificationAction(identifier: "play", title: "Yes, let's play!", options: .foreground)
        let notPlay = UNNotificationAction(identifier: "notPlay", title: "No thank you!", options: .destructive)
        let snooze = UNNotificationAction(identifier: "snooze", title: "Snooze for 5 minutes", options: .authenticationRequired)
        
        let category = UNNotificationCategory(identifier: "alarm", actions: [play, notPlay, snooze], intentIdentifiers: [])
        
        center.setNotificationCategories([category])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                showAlert(title: "Welcome Back!", msg: "Your Guess Flags have missed you! Ready to play?")
            case "play":
                showAlert(title: "Welcome Back!", msg: "Your Guess Flags have missed you! Ready to play?")
            case "notPlay":
                print("Not playing")
            case "snooze":
                response.notification.snoozeNotification(hours: 0, minutes: 1, seconds: 0)
            default:
                break
            }
        }
        
        completionHandler()
    }
    
    func showAlert(title: String, msg: String) {
        let ac = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "GO!", style: .default))
        
        present(ac, animated: true)
    }
    
}

extension UNNotification {
    func snoozeNotification(hours: Int, minutes: Int, seconds: Int) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        
        content.title = "It's flag time!"
        content.body = "We are waiting for you!"
        content.userInfo = ["customData": "It's game time!"]
        content.sound = .default
        
        let identifier = self.request.identifier
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        let minute = calendar.component(.minute, from: Date())
        let second = calendar.component(.second, from: Date())
        
        var components = DateComponents()
        components.hour = hour + hours
        components.minute = minute + minutes
        components.second = second + seconds
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if let error = error {
                debugPrint("Rescheduling failed", error.localizedDescription)
            } else {
                debugPrint("Rescheduling succeeded")
            }
        }
    }
}
