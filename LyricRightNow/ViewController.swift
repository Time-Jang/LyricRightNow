//
//  ViewController.swift
//  LyricRightNow
//
//  Created by 장원우 on 2017. 12. 31..
//  Copyright © 2017년 장원우. All rights reserved.
//

import UIKit
import MediaPlayer


class ViewController: UIViewController {
    @IBOutlet var Refresh_button: UIButton!
    @IBOutlet weak var song_name: UILabel!
    @IBOutlet weak var Lyric: UITextView!
    let host = "lyrics.alsong.co.kr"
    let player = MPNowPlayingInfoCenter.default()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Refresh_button.layer.borderColor = UIColor.gray.cgColor
        Refresh_button.layer.borderWidth = 1
        Lyric.layer.borderColor = UIColor.gray.cgColor
        Lyric.layer.borderWidth = 2
        Lyric.scrollRangeToVisible(NSMakeRange(0, 0))
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func getLyric(sender: UIButton)
    {
        let mediaitem = player.nowPlayingInfo
        if mediaitem == nil
        {
            print(1)
            return
        }
        let song_title: String = mediaitem![MPMediaItemPropertyTitle] as! String//"yesterday"
        let song_singer: String = mediaitem![MPMediaItemPropertyArtist] as! String//"The Beatles"
        song_name.text = song_title
        let msg_2: String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:SOAP-ENC=\"http://www.w3.org/2003/05/soap-encoding\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:ns2=\"ALSongWebServer/Service1Soap\" xmlns:ns1=\"ALSongWebServer\" xmlns:ns3=\"ALSongWebServer/Service1Soap12\"><SOAP-ENV:Body><ns1:GetResembleLyric2><ns1:stQuery><ns1:strTitle>"
        let msg_3: String = "</ns1:strTitle><ns1:strArtistName>"
        let msg_4: String = "</ns1:strArtistName><ns1:nCurPage>0</ns1:nCurPage></ns1:stQuery></ns1:GetResembleLyric2></SOAP-ENV:Body></SOAP-ENV:Envelope>"
        let total_len: Int = msg_2.count + msg_3.count + msg_4.count + song_title.count + song_singer.count
        let message : String = msg_2+song_title+msg_3+song_singer+msg_4
        // getting Lyric from alsong with socket programming
        let url = URL(string: "http://"+host+"/alsongwebservice/service1.asmx")!
        var request = URLRequest(url: url)
        request.setValue("lyrics.alsong.co.kr", forHTTPHeaderField: "Host")
        request.addValue("gSOAP/2.7", forHTTPHeaderField: "User-Agent")
        request.addValue("application/soap+xml;charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(String(total_len), forHTTPHeaderField: "Content-Length")
        request.addValue("\"ALSongWebServer/GetLyric5\"", forHTTPHeaderField: "SOAPAction")
        request.httpMethod = "POST"
        request.httpBody = message.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request){data, response, error in guard let data = data,error == nil else {
            print("error=\(error ?? "0" as! Error)")
            return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode : \(httpStatus.statusCode)")
                print("response = \(String(describing: response ?? nil))")
            }
            let responseString = String(data: data, encoding: .utf8)
            if responseString?.range(of: "<strLyric>") != nil
            {
                var lyric_arr = responseString?.components(separatedBy: "<strLyric>")
                lyric_arr = lyric_arr![1].components(separatedBy: "</strLyric>")
                var str_lyric : String = lyric_arr![0]
//                print(lyric_arr![0])
                str_lyric = str_lyric.replacingOccurrences(of: "&lt;br&gt;", with: "\n")
                //var lyric_timestamp : [Int] = []
                let lyric_chars = Array(str_lyric)
                var i : Int = 0
                str_lyric = ""
                while i < lyric_chars.count {
                    if lyric_chars[i] == "["
                    {
                        i = i + 10
                    }
                    else
                    {
                        str_lyric.append(lyric_chars[i])
  //                    print(str_lyric)
                        i = i + 1
                    }
                }
                DispatchQueue.main.async { // Correct
                    self.Lyric.text = str_lyric
                }
            }
            else
            {
                print("responseString = \(String(describing: responseString ?? nil))")

            }
        }
        task.resume()
        
    }
}

