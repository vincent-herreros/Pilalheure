//
//  Prescription.swift
//  Pilalheure
//
//  Created by Sheena Maucuer on 20/03/2018.
//  Copyright © 2018 Vincent HERREROS. All rights reserved.
//

import Foundation
class Prescription {
    
    
    internal let daoPrescription : PrescriptionDTO
    internal let daoEvent : EventDTO
    internal let daoRappel : RappelDTO
    var medicament   : MedicamentDTO{
        return self.daoPrescription.medicaments!
    }
    var dateDebut : Date{
        return self.daoPrescription.dateDebut! as Date
    }
    var dateFin  : Date{
        return self.daoPrescription.dateFin! as Date
    }
    var heureDebut  : Date?{
        return self.daoPrescription.heureDebut! as Date
    }
    var heureFin : Date?{
        return self.daoPrescription.heureFin! as Date
    }
    var interval : Int64?{
        return self.daoPrescription.intervalle
    }
    var heurePrecise : Date?{
        return self.daoPrescription.heurePrecise! as Date
    }
    
    init(medicament: MedicamentDTO, dateDebut: Date, dateFin: Date, heureDebut: Date?, heureFin: Date?, intervalle: Int64?, heurePrecise: Date?){
        guard let daoP = PrescriptionDTO.createDTO() else{
            fatalError("unuable to get dao for medicament")
        }
        guard let daoR = RappelDTO.createDTO() else{
            fatalError("unuable to get dao for medicament")
        }
        guard let daoE = EventDTO.createDTO() else{
            fatalError("unuable to get dao for medicament")
        }
        self.daoPrescription = daoP
        self.daoEvent = daoE
        self.daoRappel = daoR
        self.daoPrescription.medicaments = medicament
        self.daoPrescription.dateDebut = dateDebut as NSDate
        self.daoPrescription.dateFin = dateFin as NSDate
        self.daoPrescription.heureDebut = heureDebut as NSDate?
        self.daoPrescription.heureFin = heureFin as NSDate?
        if let interval = intervalle{
            self.daoPrescription.intervalle = interval
        }
        self.daoPrescription.heurePrecise = heurePrecise as NSDate?
        if let hdeb = heureDebut, let hfin = heureFin{
            // convert Date to TimeInterval (typealias for Double)
            let rappels = createRappels(heureDebut: hdeb, heureFin: hfin, intervalle: intervalle)
        }
        else{
            if let hP = heurePrecise{
               let rappels = createRappels(heurePrecise: hP)
            }
        }
    }
    
    func createRappels(heureDebut hdeb : Date, heureFin hfin : Date, intervalle inter : Int64?) -> [Date]{
        //intervalle de temps entre 2 dates
        let timeInterval = hfin.timeIntervalSince(hdeb)
        // conversion en Int
        let dif = Int64(timeInterval)
        //Si intervalle > 0 -> in faut ajouter autant de rappel que necessaire
        
        //création du tableau de rappels
        var rappels = [Date]()
        let gregorian = Calendar(identifier: .gregorian)
        //création des composants pour effectuer les changement de dates -> Jour date Debut + heure de heure Debut
        let componentsDD = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dateDebut)
        var componentsHD = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: hdeb)
        
        //change the time
        var date = gregorian.date(from: componentsDD)!
        var x = false
        var ecart : Int = 0
        if let inter2 = inter{
            x = true
            ecart=Int(dif/(inter2+1))
        }
        var dDay = calendar.component(.day, from: date)
        let dEnd = calendar.component(.day, from: dateFin)
        while dDay <= dEnd {
            var componentsD = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            componentsD.hour = componentsHD.hour
            componentsD.minute = componentsHD.minute
            date = gregorian.date(from: componentsD)!
            rappels.append(date)
            if(x){
                for _ in 0...inter!{
                    date = date + ecart.seconds
                    rappels.append(date)
                    print(ecart)

                }
            }
            else{
                date = date + Int(dif).seconds
                rappels.append(date)
            }
            date = date + 1.days
            dDay = calendar.component(.day, from: date)
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy 'at' HH:mm"
        for d in rappels {
            let stringDate = dateFormatter.string(from: d as Date)
            print(stringDate)
        }
        
        
        //let timeInterval = Double(myInt)
        
        // create NSDate from Double (NSTimeInterval)
        //let myNSDate = Date(timeIntervalSince1970: timeInterval)
        return rappels
    }
    
    func createRappels(heurePrecise hP : Date) -> [Date]{
        //création du tableau de rappels
        var rappels = [Date]()
        let gregorian = Calendar(identifier: .gregorian)
        //création des composants pour effectuer les changement de dates -> Jour date Debut + heure de heure Debut
        var componentsDD = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dateDebut)
        let componentsHP = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: hP)
        componentsDD.hour = componentsHP.hour
        componentsDD.minute = componentsHP.minute
        //change the time
        var date = gregorian.date(from: componentsDD)!
        var dDay = calendar.component(.day, from: date)
        let dEnd = calendar.component(.day, from: dateFin)
        while dDay <= dEnd {
            rappels.append(date)
            date = date + 1.days
            dDay = calendar.component(.day, from: date)
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy 'at' HH:mm"
        for d in rappels {
            let stringDate = dateFormatter.string(from: d as Date)
            print(stringDate)
        }
        return rappels
    }
}

