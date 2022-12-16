//
//  CreateEventView.swift
//  EventKit-Event
//
//  Created by Ryo on 2022/12/16.
//

import SwiftUI

struct CreateEventView: View {
    @ObservedObject var eventManager = EventManager()
    // ContentViewのsheetのフラグ
    @Environment(\.dismiss) var dismiss
    // eventのタイトル
    @State var title = ""
    // eventの開始日時
    @State var start = Date()
    // eventの終了日時
    @State var end = Date()
    
    var body: some View {
        NavigationStack{
            List {
                TextField("タイトル", text: $title)
                DatePicker("開始", selection: $start)
                //in: start...はstartより前が選択できないように
                DatePicker("終了", selection: $end, in: start...)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                            eventManager.createEvent(title: title, startDate: start, endDate: end)
                        // sheetを閉じる
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル", role: .destructive) {
                        // sheetを閉じる
                        dismiss()
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
    }
}

struct CreateEventView_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventView()
    }
}
