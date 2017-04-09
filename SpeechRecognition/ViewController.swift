//
//  ViewController.swift
//  SpeechRecognition
//
//  Created by Nikita Timonin on 09/04/2017.
//  Copyright © 2017 Palatov. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController {
    
    @IBOutlet weak var output: UILabel!
    var recordOn = false
    @IBOutlet weak var recordButton: UIButton!
    
    /*
    Используется для обработки потока аудио.
    Реагирует на получение микрофоном аудио сигнала.
    */
    let audioEngine = AVAudioEngine()
    
    /*
    Здесь опшнл, потому что при инициализации если локале не опознана может вернуться nil. 
    По дефолту берет текущую локаль у пользователя, но ее так же можно задавать в ручную.
    
    Пример - распознователь английского языка
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    */
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "ru-RU"))
    
    /*
    Подхватывает речь пользователя в реальном времени и контролирует буфер(?)
    Наследник SFSpeechRecognitionReauest (в нем много всяких интересных настроек)
     
    open var taskHint: SFSpeechRecognitionTaskHint
    
    //  Hints on kind of speech recognition being performed
     
    case unspecified // Unspecified recognition
     
    case dictation // General dictation/keyboard-style
     
    case search // Search-style requests
     
    case confirmation // Short, confirmation-style requests ("Yes", "No", "Maybe")
     
    }

    // If true, partial (non-final) results for each utterance will be reported.
    // Default is true
    open var shouldReportPartialResults: Bool
     
    // Phrases which should be recognized even if they are not in the system vocabulary
    open var contextualStrings: [String]
     
     
    // String which can be used to identify the receiver by the developer
    open var interactionIdentifier: String?
     
    */
    let request = SFSpeechAudioBufferRecognitionRequest()
    
    /*
    Используется для управлеения задачей распознования
    Хранит стейт.
    Можно отменить и завершить. 
    При отмене - разспозование заканчивается, но запись может не закончится. 
    При завершении - запись заканчивается, но весь материал отправленный на рапсознование продолжает обрабатываться.
    */
    var recognitionTask: SFSpeechRecognitionTask?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func didTouchRecordButton(_ sender: Any) {
        
        if recordOn {
            recordOn = false
            stop()
            recordButton.setTitle("Записать", for: .normal)
        } else {
            recordOn = true
            recordAndRecognizeSpeech()
            recordButton.setTitle("Остановить", for: .normal)
        }
    }

    func stop() {
        guard let node = audioEngine.inputNode else { return }
        
        /*
        Не забыть убрать здесь tap. Иначе получим ошибку
        Terminating app due to uncaught exception 'com.apple.coreaudio.avfaudio', reason: 'required condition is false: _recordingTap == nil'
        */
        
        audioEngine.stop()
        node.removeTap(onBus: 0)
        
        /// Показать здесь что будет если включить finish вместо cancel - лейбл на минуту вернется в дефолт и затем заново переключится 
        
        recognitionTask?.cancel()
        output.text = "Включите распознование"
    }
    
    func recordAndRecognizeSpeech() {
        
        /// Вот эту часть поподробне - что делает
        
        guard let node = audioEngine.inputNode else { return }
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            return print(error)
        }
        
        /// Проверяем если рекогнайзер доступен в текущей локале
        guard let myRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ru-RU")) else { return }
        
        if !myRecognizer.isAvailable {
            return
        }
        
        recognitionTask = myRecognizer.recognitionTask(with: request, resultHandler: { (result, error) in
            if let result = result {
                /// здесь используем лучшую транскприпцию, но можно посомтреть и другие варианты
                let bestString = result.bestTranscription.formattedString
                self.output.text = bestString
            } else if let error = error {
                print(error)
            }
        })
    }
}


extension ViewController: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        // TODO: - проверять здесь рекогнайзер на доступность
    }
}

extension ViewController: SFSpeechRecognitionTaskDelegate {
    
}

