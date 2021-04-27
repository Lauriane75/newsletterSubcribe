//
//  Slide.swift
//  newsletterSubscribe
//
//  Created by Lau on 03/04/2021.
//


import UIKit

class Slide: UIView {
    
    // MARK: - Outlets
        
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
        
    static func createSlides() -> [Slide: URL?] {
        var urls: [URL] = []
        var slides: [Slide] = []
        let strings = ["Inscrivez-vous à notre newsletter et gagnez 15% tout de suite sur votre achat en magasin",
                       "Entrez dans notre communau-thé ! Suivez-nous sur les réseaux sociaux et gagner plein de cadeaux sur Instagram",
                       "Obtenez 15% sur votre première commande en ligne",
                       "Profitez de 10% chaque mois et découvrez nos nouveautés en restant inscris à notre newsletter"]
        
        let videos = ["tea-video-1", "tea-video-2", "tea-video-3", "tea-video-4"]
        
        for video in videos {
            urls.append(URL(fileURLWithPath: Bundle.main.path(forResource: video, ofType: "mp4")!))
        }
        
        for _ in 1...4 {
            slides.append(Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide)
        }

        slides.enumerated().forEach { (index, item) in
            item.textLabel.textColor = .white
            item.textLabel.font = Constant.font.font20Bold
            item.contentView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
            item.textLabel.text = strings[index]
        }
    
        return [slides[0]: urls[0], slides[1]: urls[1], slides[2]: urls[2], slides[3]: urls[3]]
    }

}
