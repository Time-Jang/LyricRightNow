//
//  ViewController.swift
//  LyricRightNow
//
//  Created by 장원우 on 2017. 12. 31..
//  Copyright © 2017년 장원우. All rights reserved.
//

import UIKit
import SwiftSocket

class ViewController: UIViewController {
    @IBOutlet var Refresh_button: UIButton!
    @IBOutlet weak var song_name: UILabel!
    @IBOutlet weak var Lyric: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Refresh_button.layer.borderColor = UIColor.gray.cgColor
        Refresh_button.layer.borderWidth = 1
        Lyric.layer.borderColor = UIColor.gray.cgColor
        Lyric.layer.borderWidth = 2
        Lyric.scrollRangeToVisible(NSMakeRange(0, 0))
    }
    
    @IBAction func Refresh(sender: UIButton){
        song_name.text = "Love Me Do"
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func getLyric(sender: UIButton)
    {
        let song_title: String = "yesterday"
        let song_singer: String = "The Beatles"
        let msg_1: String = "POST /alsongwebservice/service1.asmx HTTP/1.1\r\nHost: lyrics.alsong.co.kr\r\nContent-Type:text/xml;charset=utf-8\r\nContent-Length:"
        let msg_2: String = "\r\n\r\n<?xml version=\"1.0\" encoding=\"UTF-8\"?><SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:SOAP-ENC=\"http://www.w3.org/2003/05/soap-encoding\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:ns2=\"ALSongWebServer/Service1Soap\" xmlns:ns1=\"ALSongWebServer\" xmlns:ns3=\"ALSongWebServer/Service1Soap12\"><SOAP-ENV:Body><ns1:GetResembleLyric2><ns1:stQuery><ns1:strTitle>"
        let msg_3: String = "</ns1:strTitle><ns1:strArtistName>"
        let msg_4: String = "</ns1:strArtistName><ns1:nCurPage>0</ns1:nCurPage></ns1:stQuery></ns1:GetResembleLyric2></SOAP-ENV:Body></SOAP-ENV:Envelope>"
        // getting Lyric from alsong with socket programming
        let client = TCPClient(address: "lyrics.alsong.co.kr", port: 80)
        switch client.connect(timeout:10){
            case .success:
                let total_len: Int = msg_2.count + msg_3.count + msg_4.count + song_title.count + song_singer.count
                let message : String = msg_1+String(total_len)+msg_2+song_title+msg_3+song_singer+msg_4
                switch client.send(string: message){
                    case .success:
                        print(8)
                        guard let data = client.read(1024*10, timeout:100)
                            else { return }
                        print(9)
                        if let response = String(bytes: data, encoding: .utf8){
                            Lyric.text = response
                            print(10)
                        }
                    case .failure(let error):
                        print(error)
                        print(-2)
                    }
            case .failure(let error):
                print(error)
                print(-3)
        }
        client.close()
    }

}

