

//  VARIABLES
int signalPin = 0;       //  Input dari rangkaian penguat                
int ledPin = 13;         //  Pin led       
int buzzPin = 49;        //  Pin buzze                    
volatile int BPM;        //  Variabel volatil penyimpan nilai BPM          
volatile int Signal;     //  Variabel volatil penyimpan nilai ADC          
volatile int beatInterval = 450;    // dengan asumsi bahwa setiap detik(paling banyak) melakkan detak 220bpm sehingga 1 beat memakan waktu 0,27s atau 270mS (beat interval paling pendek) Hanya sebagai nilai awal!!!
volatile boolean pulseArea = false; // flag area detak     
volatile boolean findBeat = false;  // flag untuk meandakan bawa beat ditemukan     

void setup(){
  pinMode(ledPin,OUTPUT); // mode output pada pin
  pinMode(buzzPin,OUTPUT);// mode output pada pin           
  Serial.begin(115200);   // baud rate          
  interruptSetup();       // start up setting fungsi interupt         
}



void loop(){
  sendDataToProcessing('S', Signal);      // secara default mengirimkan data dengan header "S". Hali ini digunakan untuk visualisasi bentuk gelombang pada software processing    
  if (findBeat == true){                  // Jika detak ditemukan                                    
        sendDataToProcessing('B',BPM);    // data BPM akan disisipkan pada pengiriman data serial.  
        sendDataToProcessing('Q',beatInterval);  //data interval detak juga akan disisipkan
        findBeat = false;                 // reset flag                      
     }
  delay(20);                              // delay 
}


void sendDataToProcessing(char symbol, int data ){ //fungsi untuk mengemas data serial
    Serial.print(symbol);           //dengan hirari pengiriman simbol header diikuti nilai    
    Serial.println(data);                
  }







