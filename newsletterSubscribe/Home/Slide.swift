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
            
        let bundlePath1 = Bundle.main.path(forResource: "tea-video-1", ofType: "mp4")
        let bundlePath2 = Bundle.main.path(forResource: "tea-video-2", ofType: "mp4")
        let bundlePath3 = Bundle.main.path(forResource: "tea-video-3", ofType: "mp4")
        let bundlePath4 = Bundle.main.path(forResource: "tea-video-1", ofType: "mp4")

        let url1 = URL(fileURLWithPath: bundlePath1!)
        let url2 = URL(fileURLWithPath: bundlePath2!)
        let url3 = URL(fileURLWithPath: bundlePath3!)
        let url4 = URL(fileURLWithPath: bundlePath4!)
        
        let slide1: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide1.textLabel.text = "Inscrivez-vous à notre newsletter et gagnez 15% tout de suite sur votre achat en magasin"
        slide1.textLabel.textColor = .white
        slide1.textLabel.font = Constant.font.font17
        slide1.contentView.backgroundColor = .clear
        
        let slide2: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide2.textLabel.text = "Entrez dans notre communau-thé ! Suivez-nous sur les réseaux sociaux et gagner plein de cadeaux sur Instagram"
        slide2.textLabel.textColor = .white
        slide2.textLabel.font = Constant.font.font17
        slide2.contentView.backgroundColor = .clear
        
        let slide3: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide3.textLabel.text = "Obtenez 15% sur votre première commande en ligne"
        slide3.textLabel.textColor = .white
        slide3.textLabel.font = Constant.font.font17
        slide3.contentView.backgroundColor = .clear
        
        let slide4: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide4.textLabel.text = "Profitez de 10% chaque mois et découvrez nos nouveautés en restant inscris à notre newsletter"
        slide4.textLabel.textColor = .white
        slide4.textLabel.font = Constant.font.font17
        slide4.contentView.backgroundColor = .clear
        
        return [slide1: url1, slide2: url2, slide3: url3, slide4: url4]
    }

}
