


volatile int temp[10];                          // menyimpan jarak antar detak dan melakukan rata-rata
volatile unsigned long sampleCounter = 0;       // untuk melakukan perhtungan waktu setiap interupt berjalan
volatile unsigned long lastBeatTime = 0;        // untuk menyimpan nilai waktu antar detak
volatile int Max =415;                          // digunakan untuk menemukan puncak gelombang
volatile int Min = 415;                         // digunakan untuk menemukan lembah gelombang
volatile int thres = 415;                       // batas nilai detak
volatile int Amp = 100;                         // digunakan untuk menyimpan amplitudo gelombang
volatile boolean firstBeat = true;              // flag
volatile boolean secondBeat = true;             // flag

//clock menggunakan 16MHz maka waktu perubahan 1 clock adalah 1/16000000 = 0,0625uS
//menggunakan timer 8 bit --->0 sampai 255
//0,0625uS*256 = 1,6 x10^-5 merupakan waktu yang dibutuhkan timer mencapai nilai maksimum (overflow)
//Menggunakan prescaler 256 untuk memperlambat clock timer maka 256*1,6x10^-5 = 4,096 mS direpresentasikan dengan nilai counting 0-255, untuk waktu 2mS maka counting hanya berakhir pada nilai 124
//Untuk sampling rate  = 500Hz maka periode adalah 1/500 = 2x10^-3s atau 2mS
//periode sampling 2mS = 2x10^-3 didapatkan dengan melakukan perbandingan nilai ORC2A dengan TIMSK2 untuk mencapai counter 124.


void interruptSetup(){  
  TCCR2A = 0x02;     // menonaktifkan PWM pin 3 dan 11 serta mengaktifkan mode CTC (mode inerupt perbandingan)
  TCCR2B = 0x06;     // memilih prescaler 256 (untuk memperlambat clock)
  OCR2A = 0X7C;      // memasukan nilai 124 pada register OCR2A (1/2 kapasitas counter unuk mencapai interupt 2ms)
  TIMSK2 = 0x02;     // mengaktifkan interup untuk membandingkan nilai antara TIMER2 dan ORC2A
  sei();             // global interupt      
} 
 

ISR(TIMER2_COMPA_vect){                                 // ISR ini akan dijalankan setiap 2ms atau ketika proses counting mencapai nilai 124
    cli();                                              // Menonaktifkan interupt ketika kondisi interupsi tercapai
    Signal = analogRead(signalPin);                     // Membaca Nilai ADC pin analog 0
    sampleCounter += 2;                                 // untuk menyimpan nterupsi yang telah dilakukan kenaikan setiap 2 ms
    int N = sampleCounter - lastBeatTime;               // digunakan untuk memonitor interval beat tunda sistem

    if(Signal < thres && N > (beatInterval/5)*3){       // waktu jeda untuk menghindari noise pada rentang beat interval
        if (Signal < Min){                              // T (trough)
            Min = Signal;                               // set batas terendah sinyal
        }
    }
      
    if(Signal > thres && Signal > Max){                
        Max = Signal;                                  // set batas tertinggi sinyal
       }                                   
       
  //------------------------------------------------------------>>>>Analisis Sinyal Detak<<<<-------------------------------------------------------------
  if (N > 270){                                             // waktu rentang yang diambil untuk menghindari noise antar detak dengan asumsi detak terbanyak 220 bpm 
    if ( (Signal > thres) && (pulseArea == false) && (N > (beatInterval/5)*3) ){        
        pulseArea = true;                                   // bernilai benar ketika berada pada area yang diperkirakan terjadi detak janting
        digitalWrite(ledPin,HIGH);                          // Led pin 13 hidup
        digitalWrite(buzzPin,HIGH); 
        beatInterval = sampleCounter - lastBeatTime;        // menghitung waktu antar detak
        lastBeatTime = sampleCounter;                      
        
        if(firstBeat){                                      // bernilai benar ketika detak pertama ditemukan
             firstBeat = false;                             // reset flag
             return;                                        
        }   
        if(secondBeat){                                     // bernilai benar ketika detak kedua ditemukan
            secondBeat = false;                             // reset flag
              for(int i=0; i<=9; i++){                      // menyimpan beat interval pada array untuk dicari nilai rata-rata
                   temp[i] = beatInterval;                      
              }
        }
    word runningTotal = 0;               
    for(int i=0; i<=8; i++){                // menggeser data pada array
         temp[i] = temp[i+1];               // menghapus data beat terlama 
         runningTotal += temp[i];           // menjumlahkan 9 data beat lama kedalam variabel runningTotal
    }
    
    temp[9] = beatInterval;                 // menambahkan data beat terbaru pada array terakhir
    runningTotal += temp[9];                // menambahkan data beat terbaru pada runningTotal
    runningTotal /= 10;                     // merata-rata beat interval
    BPM = 60000/runningTotal;               // mendapatkan nilai BPM
    findBeat = true;                        // set flag untuk menandakan bahwa beat ditemukan 
    }                       
  }

  if (Signal < thres && pulseArea == true){    //Ketika signal melemah dan masih berada pada area perkiraa detak (pulseArea == true)
      digitalWrite(ledPin,LOW);                //Led pin 13 (on Boadr led) dimatikan
      digitalWrite(buzzPin,LOW);
      pulseArea = false;                       //Diasumsikan bahwasanya ketika sinyal melemah, analisis sudah berada diluar area detak
      Amp = Max - Min;                         //Mencari nilai amplitudo
      thres = Amp/2 + Min;                     //Update nilai tres (treshold) 
      Max = thres;                             //Reset Min Max untuk menyesuaikan dengan nilai maksimum dan minimum detak yang baru (sistem dinamis)
      Min = thres;
  }
  
  if (N > 2500){                              // Jika N melebihi nilai 25000 (2.5 detik) berarti pendeteksian gagal karena nilai N terus melakukan increment
      thres = 415;                            // set thresh default
      Max = 415;                              // set Max ke nilai awal
      Min = 415;                              // set Min ke nilai awal
      lastBeatTime = sampleCounter;           // Jangan biarkan sample counter increment terlalu jauh dan meninggalkan lastBeatTime tertinggal tanpa update walaupun detak tidak terdeteksi         
      firstBeat = true;                       // set flag untuk mendapatkan data realistis BPM
      secondBeat = true;                  
  }
  
  sei();                                 
}




