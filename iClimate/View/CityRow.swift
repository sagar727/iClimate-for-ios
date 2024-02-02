//
//  CityRow.swift
//  iClimate
//
//  Created by Sagar Modi on 20/01/2024.
//

import SwiftUI

struct CityRow: View {
    let cityText: String
    let isDefault: Bool
    var body: some View {
        HStack(alignment:.center){
            Text(cityText)
                .font(.system(size: 20))
            Spacer()
            Text(isDefault ? "Default" : "")
                .font(.system(size: 16))
                .italic()
                .foregroundStyle(Color.gray)
        }
    }
}

#Preview {
    CityRow(cityText: "Surat", isDefault: true)
}
