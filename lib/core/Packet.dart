import 'dart:typed_data';

const dataLen = 30; // bytes

class Packet {
  final int screenNum;
  final int cmd;
  final Uint8List dataBuffer;
  final int crc;

  Packet([this.screenNum, this.cmd, this.dataBuffer])
      : crc = screenNum + cmd + dataBuffer.fold(0, (previousValue, element) => previousValue + element);

  Packet.fromBytes(Uint8List data)
      : screenNum = data[0],
        cmd = data[1],
        dataBuffer = data.sublist(2, 30/*dataLen - 2*/),
        crc = ByteData.view(data.buffer, 30, 2).getUint16(0, Endian.little);


  bool crcValid() {
      return (screenNum + cmd + dataBuffer.fold(0, (previousValue, element) => previousValue + element)) == crc; // max value = 0x1DE2, no uint16 overflow
  }

  Uint8List get toBytes => Uint8List.fromList(<int>[screenNum, cmd] + dataBuffer + [crc, crc >> 8]);
}
