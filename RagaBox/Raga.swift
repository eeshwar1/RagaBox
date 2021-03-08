//
//  Raga.swift
//  RagaBox
//
//  Created by Venkateswaran Venkatakrishnan on 3/6/21.
//

import Foundation

struct Raga: Codable {
    
    let name: String
    let mela_raga: String
    let mela_num: String
    let link: String
    let arohana: String
    let avarohana: String
    
}

func loadJson(fileName: String) -> [Raga]? {
   let decoder = JSONDecoder()
   guard
        let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
        let data = try? Data(contentsOf: url),
        let ragas = try? decoder.decode([Raga].self, from: data)
   else {
        return nil
   }

   return ragas
}
