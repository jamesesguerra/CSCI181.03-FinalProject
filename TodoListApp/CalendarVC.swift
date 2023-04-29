//
//  CalendarVC.swift
//  TodoListApp
//
//  Created by James Esguerra on 4/17/23.
//

import UIKit


class CalendarVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource
{

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let userDefaults = UserDefaults.standard
    var selectedDate = Date()
    var totalSquares = [String]()
    var savedEmojis = [Emoji]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        savedEmojis = getData()
        print(savedEmojis)
        print(UserDefaults.standard.dictionaryRepresentation())
        setCellsView()
        setMonthView()
        
    }
    
    func getData() -> [Emoji] {
        if let objects = UserDefaults.standard.value(forKey: "savedEmojis") as? Data {
            let decoder = JSONDecoder()
            if let decodedObjects = try? decoder.decode(Array.self, from: objects)as [Emoji] {
                return decodedObjects
            } else {
                return [Emoji]()
            }
        } else {
            return [Emoji]()
        }
    }
    
    func setCellsView()
    {
        let width = (collectionView.frame.size.width - 2) / 8
        let height = (collectionView.frame.size.height - 2) / 6
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
     }
    
    func setMonthView() {
        totalSquares.removeAll()
        
        let daysInMonth = CalendarHelper().daysInMonth(date: selectedDate)
        let firstDayOfMonth = CalendarHelper().firstOfMonth(date: selectedDate)
        let startingSpaces = CalendarHelper().weekDay(date: firstDayOfMonth)
        
        var count: Int = 1
        
        while(count <= 42) {
            if (count <= startingSpaces || count - startingSpaces > daysInMonth) {
                totalSquares.append("")
            } else {
                totalSquares.append(String(count - startingSpaces))
            }
            count += 1
        }
        
        monthLabel.text = CalendarHelper().monthString(date: selectedDate) + " " + CalendarHelper().yearString(date: selectedDate)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calCell", for: indexPath) as! CalendarCell
        
        let currentMonth = CalendarHelper().monthString(date: self.selectedDate)
        let currentDay = self.totalSquares[indexPath.item]
        let currentYear = CalendarHelper().yearString(date: self.selectedDate)
        
        cell.dayOfMonth.text = totalSquares[indexPath.item]
        
        for emoji in savedEmojis {
            if emoji.month == currentMonth && emoji.day == currentDay && emoji.year == currentYear {
                cell.emojiLabel.text = emoji.emoji
            } else {
                cell.emojiLabel.text = ""
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "New Emoji", message: "How do you feel about this day?", preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "Enter emoji..."
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler:{ [weak self] (_) in
            if let field = alert.textFields?.first {
                if let text = field.text, !text.isEmpty {
                    DispatchQueue.main.async { [self] in
                        let currentMonth = CalendarHelper().monthString(date: self!.selectedDate)
                        let currentDay = self?.totalSquares[indexPath.item]
                        let currentYear = CalendarHelper().yearString(date: self!.selectedDate)
                        
                        var currentEmojis = self?.getData()
                        currentEmojis?.append(Emoji(month: currentMonth, day: currentDay!, year: currentYear, emoji: text))
                        self?.savedEmojis.append(Emoji(month: currentMonth, day: currentDay!, year: currentYear, emoji: text))
                        if let encodedData = try? JSONEncoder().encode(self?.savedEmojis) {
                            UserDefaults.standard.set(encodedData, forKey: "savedEmojis")
                        }
                        self?.collectionView.reloadData()
                    }
                }
            }
        }))
        present(alert, animated: true)
    }

    @IBAction func previousMonth(_ sender: Any) {
        selectedDate = CalendarHelper().minusMonth(date: selectedDate)
        setMonthView()
    }
    
    @IBAction func nextMonth(_ sender: Any) {
        selectedDate = CalendarHelper().plusMonth(date: selectedDate)
        setMonthView()
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
}


struct Emoji: Codable {
    let month: String
    let day: String
    let year: String
    let emoji: String
}
