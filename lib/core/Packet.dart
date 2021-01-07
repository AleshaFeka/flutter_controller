import 'dart:typed_data';

/* message struct definition */
//typedef struct {
//  uint8_t byte1 : 8;
//  uint8_t byte2 : 8;
//  uint8_t byte3 : 8;
//  uint8_t byte4 : 8;
//  uint8_t byte5 : 8;
//  uint8_t byte6 : 8;
//  uint8_t byte7 : 8;
//  uint8_t byte8 : 8;
//  uint8_t byte9 : 8;
//  uint8_t byte10 : 8;
//  uint8_t byte11 : 8;
//  uint8_t byte12 : 8;
//  uint8_t byte13 : 8;
//  uint8_t byte14 : 8;
//  uint8_t byte15 : 8;
//  uint8_t byte16 : 8;
//  uint8_t byte17 : 8;
//  uint8_t byte18 : 8;
//  uint8_t byte19 : 8;
//  uint8_t byte20 : 8;
//  uint8_t byte21 : 8;
//  uint8_t byte22 : 8;
//  uint8_t byte23 : 8;
//  uint8_t byte24 : 8;
//  uint8_t byte25 : 8;
//  uint8_t byte26 : 8;
//  uint8_t byte27 : 8;
//  uint8_t byte28 : 8;
//  uint8_t byte29 : 8;
//  uint8_t byte30 : 8;
//  uint8_t byte31 : 8;
//  uint8_t byte32 : 8;
//} message_bytes_st;

/*структура сообщения*/
//typedef struct
//{
//  uint8_t screen_num : 8;	/*Номер набора данных*/
//  uint8_t cmd : 8;		/*Команда обработки данных*/
//  uint16_t data_buffer[14];	/*Буфер с данными в INT16*/
//  uint16_t crc;			/*контрольная сумма*/
//} Message_st;

/*обьединение */
//union message_un {
//  message_bytes_st message_bytes;
//  Message_st message_layer;
//  uint16_t int_array[16];
//  uint32_t long_array[8];
//};

const dataLen = 30; // bytes

/* Packet is a Dart version of C struct
typedef struct
{
  uint8_t screen_num : 8; // Номер набора данных
  uint8_t cmd : 8;  // Команда обработки данных
  uint16_t data_buffer[14]; // Буфер с данными в INT16
  uint16_t crc;   // контрольная сумма
} Message_st;
 */
class Packet {
//  final Uint8List rawData; // ~ message_bytes_st
//  Uint8 screenNum; 	// Номер набора данных
//  Uint8 cmd; // Команда обработки данных
//  Uint16List dataBuffer; // Буфер с данными в INT16, размера 14 слов
//  Uint16 crc; // контрольная сумма

//  Packet.fromUint8List(Uint8List data) {
//    if (data.length != 32) {
//      throw new Exception('Data length must be 32 bytes');
//    }
//
//    this.rawData = data;
//  }

//  bool get crcOk => calcCRC() == crc();
//  ByteData get message => ByteData.view(rawData.buffer, 0, 30);
//  int get screenNum => this.rawData[0];
//  int get cmd => this.rawData[1];
//  ByteData get dataBuffer => ByteData.view(rawData.buffer, 2, 28);
  final int screenNum;
  final int cmd;
  final Uint8List dataBuffer;
  final int crc;

  Packet([this.screenNum, this.cmd, this.dataBuffer])
      : crc = screenNum + cmd + dataBuffer.fold(0, (previousValue, element) => previousValue + element);

  Packet.fromBytes(Uint8List data)
      : screenNum = data[0],
        cmd = data[1],
        dataBuffer = data.sublist(2, dataLen - 2),
        crc = ByteData.view(data.buffer, 30, 2).getUint16(0, Endian.little);

//  Packet.fromMessage(Uint8List data) :
//        rawData = data;

  bool crcValid() {
//    print ("data raw - " + (screenNum + cmd + dataBuffer.fold(0, (previousValue, element) => previousValue + element)).toString());
//    print("data crc - " + crc.toString());
      return (screenNum + cmd + dataBuffer.fold(0, (previousValue, element) => previousValue + element)) == crc; // max value = 0x1DE2, no uint16 overflow
  }

  Uint8List get toBytes => Uint8List.fromList(<int>[screenNum, cmd] + dataBuffer + [crc, crc >> 8]);
//  int calcCRC()
//  {
//
//    final data = ByteData.view(rawData.buffer, 0, dataLen);
//
//    int crc = 0;
//    for (int i = 0; i < data.lengthInBytes; i++)
//    {
//      crc += data.getUint8(i);
//    }
//
//    return crc; // max value = 0x1DE2, no uint16 overflow
//  }

//  int screenNum() {
//    return this.rawData[0];
//  }
//
//  int cmd() {
//    return this.rawData[1];
//  }

//  ByteData dataBuffer() {
//    return ByteData.view(rawData.buffer, 2, 28);
//  }

//  int crc() {
//    return ByteData.view(rawData.buffer, 30, 2).getUint16(0, Endian.little);
//  }
}

//class Message {
