// Serial DMM protcol adapter
// Copyright (C) 2016 Theodore C. Yapo

#include <SoftwareSerial.h>

class DMM
{
public:
  DMM()
    : start_frame_seen(false)
  {
  }

  virtual 
  ~DMM()
  {
  }

  void setPort(SoftwareSerial& port, int rx_pin)
  {
    this->port = &port;
    digitalWrite(rx_pin, LOW); // turn off internal pullup - use 100k external
    this->port->begin(2400);
  }

  bool poll()
  {
    while(1){
      if (!port->available()){
        return false;
      }
      uint8_t byte = port->read();
      switch (byte & 0xf0){
      case 0x10:
        start_frame_seen = true;
        for (int i=0; i<4; ++i){
          Digit[i] = 0;
        }
        flags.AC = (byte & 0x08) != 0;
        flags.DC = (byte & 0x04) != 0;
        flags.AUTO = (byte & 0x02) != 0;
        flags.RS232 = (byte & 0x01) != 0;      
        break;
      case 0x20:
        flags.negative = (byte & 0x08) != 0;
        Digit[0] |= (byte & 0x04) ? SEG_A : 0;
        Digit[0] |= (byte & 0x02) ? SEG_B : 0;
        Digit[0] |= (byte & 0x01) ? SEG_C : 0;      
        break;
      case 0x30:
        Digit[0] |= (byte & 0x08) ? SEG_D : 0;
        Digit[0] |= (byte & 0x04) ? SEG_E : 0;
        Digit[0] |= (byte & 0x02) ? SEG_F : 0;
        Digit[0] |= (byte & 0x01) ? SEG_G : 0;      
        break;
      case 0x40:
        Digit[0] |= (byte & 0x08) ? SEG_DP : 0;
        Digit[1] |= (byte & 0x04) ? SEG_A : 0;
        Digit[1] |= (byte & 0x02) ? SEG_B : 0;
        Digit[1] |= (byte & 0x01) ? SEG_C : 0;      
        break;
      case 0x50:
        Digit[1] |= (byte & 0x08) ? SEG_D : 0;
        Digit[1] |= (byte & 0x04) ? SEG_E : 0;
        Digit[1] |= (byte & 0x02) ? SEG_F : 0;
        Digit[1] |= (byte & 0x01) ? SEG_G : 0;      
        break;
      case 0x60:
        Digit[1] |= (byte & 0x08) ? SEG_DP : 0;
        Digit[2] |= (byte & 0x04) ? SEG_A : 0;
        Digit[2] |= (byte & 0x02) ? SEG_B : 0;
        Digit[2] |= (byte & 0x01) ? SEG_C : 0;      
        break;
      case 0x70:
        Digit[2] |= (byte & 0x08) ? SEG_D : 0;
        Digit[2] |= (byte & 0x04) ? SEG_E : 0;
        Digit[2] |= (byte & 0x02) ? SEG_F : 0;
        Digit[2] |= (byte & 0x01) ? SEG_G : 0;      
        break;
      case 0x80:
        Digit[2] |= (byte & 0x08) ? SEG_DP : 0;
        Digit[3] |= (byte & 0x04) ? SEG_A : 0;
        Digit[3] |= (byte & 0x02) ? SEG_B : 0;
        Digit[3] |= (byte & 0x01) ? SEG_C : 0;      
        break;
      case 0x90:
        Digit[3] |= (byte & 0x08) ? SEG_D : 0;
        Digit[3] |= (byte & 0x04) ? SEG_E : 0;
        Digit[3] |= (byte & 0x02) ? SEG_F : 0;
        Digit[3] |= (byte & 0x01) ? SEG_G : 0;      
        break;
      case 0xA0:
        flags.micro = (byte & 0x08) != 0;
        flags.nano = (byte & 0x04) != 0;
        flags.kilo = (byte & 0x02) != 0;
        flags.diode = (byte & 0x01) != 0;      
        break;
      case 0xB0:
        flags.milli = (byte & 0x08) != 0;
        flags.duty_cycle = (byte & 0x04) != 0;
        flags.mega = (byte & 0x02) != 0;
        flags.beep = (byte & 0x01) != 0;      
        break;
      case 0xC0:
        flags.Farad = (byte & 0x08) != 0;
        flags.Ohm = (byte & 0x04) != 0;
        flags.relative = (byte & 0x02) != 0;
        flags.hold = (byte & 0x01) != 0;      
        break;
      case 0xD0:
        flags.Amp = (byte & 0x08) != 0;
        flags.Volt = (byte & 0x04) != 0;
        flags.Hz = (byte & 0x02) != 0;
        flags.low_batt = (byte & 0x01) != 0;      
        break;
      case 0xE0:
        flags.Celsius = (byte & 0x04) != 0;
        calculate_value();
        if (start_frame_seen){
          return true;
        } else {
          return false;
        }
        break;                              
      }
    }
  }

  struct {
    bool AC;
    bool DC;
    bool AUTO;
    bool RS232;
    bool negative;

    bool mega;
    bool kilo;
    bool milli;
    bool micro;
    bool nano;

    bool duty_cycle;
    bool relative;
    bool diode;
    bool beep;

    bool Farad;
    bool Ohm;
    bool Amp;
    bool Volt;
    bool Hz;
    bool Celsius;

    bool hold;
    bool low_batt;
  } flags;

  double currentValue(){
    return value;
  }

  const char* asciiValue(){
    dtostre(value, result_buffer, 3, DTOSTR_PLUS_SIGN);
    return result_buffer;
  }

  const char* units(){
    if (flags.Farad){
      return "Farad";
    }
    if (flags.Ohm){
      return "Ohm";
    }
    if (flags.Amp){
      return "Amp";
    }
    if (flags.Volt){
      return "Volt";
    }
    if (flags.Hz){
      return "Hz";
    }
    if (flags.duty_cycle){
      return "%";
    }
    if (flags.Celsius){
      return "Celsius";
    }
    return "";
  }

private:
  SoftwareSerial* port;
  enum {SEG_A = 0x01, SEG_B = 0x02, SEG_C = 0x04, SEG_D = 0x08,
        SEG_E = 0x10, SEG_F = 0x20, SEG_G = 0x40, SEG_DP = 0x80};
  int Digit[4];
  bool start_frame_seen;
  double value;
  enum {MAX_BUF_SIZE = 64};
  char result_buffer[MAX_BUF_SIZE];

  int segment_to_int(int segments)
  {
    switch(segments & 0x7f){
    case SEG_A | SEG_B | SEG_C | SEG_D | SEG_E | SEG_G:
      return 0;
    case SEG_E | SEG_G:
      return 1;
    case SEG_A | SEG_C | SEG_D | SEG_F | SEG_G:
      return 2;
    case SEG_C | SEG_D | SEG_E | SEG_F | SEG_G:
      return 3;
    case SEG_B | SEG_E | SEG_F | SEG_G:
      return 4;
    case SEG_B | SEG_C | SEG_D | SEG_E | SEG_F:
      return 5;
    case SEG_A | SEG_B | SEG_C | SEG_D | SEG_E | SEG_F:
      return 6;
    case SEG_C | SEG_E | SEG_G:
      return 7;
    case SEG_A | SEG_B | SEG_C | SEG_D | SEG_E | SEG_F | SEG_G:
      return 8;
    case SEG_B | SEG_C | SEG_D | SEG_E | SEG_F | SEG_G:
      return 9;
    default:
      start_frame_seen = false;
      return 0;
    }
  }
  
  void calculate_value()
  {
    value = ( segment_to_int(Digit[0]) * 1000. +
              segment_to_int(Digit[1]) *  100. +
              segment_to_int(Digit[2]) *   10. +
              segment_to_int(Digit[3]) *    1. );
    if (Digit[0] & SEG_DP){
      value *= 1e-3;
    }
    if (Digit[1] & SEG_DP){
      value *= 1e-2;
    }
    if (Digit[2] & SEG_DP){
      value *= 1e-1;
    }    
    if (flags.mega){
      value *= 1e6;
    }
    if (flags.kilo){
      value *= 1e3;
    }
    if (flags.milli){
      value *= 1e-3;
    }
    if (flags.micro){
      value *= 1e-6;
    }
    if (flags.nano){
      value *= 1e-9;
    }
    if (flags.negative){
      value *= -1.;
    }
  }
};

int rx_pin = 10;
SoftwareSerial dmm_port(rx_pin, 11); // RX, TX (note: TX not used)
DMM dmm;
byte sample_pending;
byte result_format;

void setup()
{
  Serial.begin(9600);
  while(!Serial){
    // busy wait
  }

  dmm.setPort(dmm_port, rx_pin);
  sample_pending = false;
}

void loop()
{
  if (Serial.available()){
    result_format = Serial.read();
    sample_pending = true;
  }

  if (dmm.poll() && sample_pending){
    sample_pending = false;
    switch(result_format){
    case 'n': // number only
    default:
      Serial.println(dmm.asciiValue());
      break;
    case 'u': // number + units
      Serial.print(dmm.asciiValue());
      Serial.print(" ");
      Serial.println(dmm.units());
      break;
    case 'b': // low battery status
      Serial.println(dmm.flags.low_batt);
      break;
    }
  }
}
