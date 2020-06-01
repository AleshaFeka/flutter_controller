// Import the test package and Counter class
import 'package:flutter_controller/core/LiveData.dart';
import 'package:test/test.dart';
import 'dart:typed_data';
import 'package:flutter_controller/core/Packet.dart';

void main() {
  test('CRC should match expected 1', () {
    final rawBytes = <int>[
      0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, // 0-16
      0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xE2, 0x1D, // 17-32
    ];
    final data = Uint8List.fromList(rawBytes);
    final packet = Packet.fromBytes(data);

    expect(packet.crc, 0x1DE2);
  });

  test('CRC should match expected 2', () {
    final rawBytes = <int>[
      0x00, 0x00, 0x75, 0x1b, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x00, 0xa7, 0x02, // 0-16
      0xe4, 0x0e, 0x00, 0x00, 0x1a, 0x00, 0x03, 0x00, 0x24, 0x03, 0x03, 0x08, 0x00, 0x00, 0x95, 0x02, // 17-32
    ];
    final data = Uint8List.fromList(rawBytes);
    final packet = Packet.fromBytes(data);

    expect(packet.crcValid, true);
  });

  test('Packet decoding', () {
    final rawBytes = <int>[
      0x01, 0x02, 0x75, 0x1b, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x00, 0xa7, 0x02, // 0-16
      0xe4, 0x0e, 0x00, 0x00, 0x1a, 0x00, 0x03, 0x00, 0x24, 0x03, 0x03, 0x08, 0x00, 0x00, 0x98, 0x02, // 17-32
    ];
    final data = Uint8List.fromList(rawBytes);
    final packet = Packet.fromBytes(data);

    expect(packet.crc, ByteData.view(data.buffer, 30, 2).getUint16(0, Endian.little));
    expect(packet.screenNum, 1);
    expect(packet.cmd, 2);
    final db = packet.dataBuffer;
    for (int i = 0; i < dataLen-2; i++) {
      expect(db[i], rawBytes[i+2]);
    }
  });

  test('Packet encoding', () {
    final dataBuffer = <int>[
      0x75, 0x1b, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x00, 0xa7, 0x02, // 0-14
      0xe4, 0x0e, 0x00, 0x00, 0x1a, 0x00, 0x03, 0x00, 0x24, 0x03, 0x03, 0x08, 0x00, 0x00, // 15-28
    ];
    final packet = Packet(1, 2, Uint8List.fromList(dataBuffer));

    final expected = <int>[
      0x01, 0x02, 0x75, 0x1b, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x00, 0xa7, 0x02, // 0-16
      0xe4, 0x0e, 0x00, 0x00, 0x1a, 0x00, 0x03, 0x00, 0x24, 0x03, 0x03, 0x08, 0x00, 0x00, 0x98, 0x02, // 17-32
    ];
    expect(packet.toBytes.toList(), expected);
  });

  test('LiveData decoding', () {
//    final rawBytes = <int>[
//      0, 0, //screenNum, cmd
//      113, 29, // [0] udc 0x1D71 Little-endian = 75,37
//      8, 0, // [1] Uz 0x0008 Little-endian = 8.00
//      0, 0, // [2] Iamp 0x0000 Little-endian = 0
//      0, 0, // [3] Speed 0x0000 Little-endian = 0
//      0, 0, // [4] Pel 0x0000 Little-endian = 0
//      7, 0, // [5] Tfet 0x0007 Little-endian = 7
//      167, 2, // [6] Active_Flux 0x02A7 Little-endian = 0,0679
//      143, 10, // [7] Brake 0x0A8F Little-endian = 2,703
//      0, 0, // [8] Teta_shift 0x0000 Little-endian = 0
//      0, 0, // [9] Tmot 0x0000 Little-endian = 0
//      7, 0, // [10] Hall_cnt 0x0007 Little-endian = 7
//      6, 3, // [11] Trottle_Act 0x0306 Little-endian = 0,774
//      3, 128, // [12] statuc_word 0x8003 Little-endian
//      0, 0, // [13] alg_mode 0x0000
//      114, 2 // crc
//    ];
    final rawBytes = <int>[
      0x00, 0x00, //screenNum, cmd
      0x75, 0x1b, // [0] udc 0x1B75 Little-endian = 70,29
      0x03, 0x00, // [1] Uz 0x0003 Little-endian = 0,03
      0x02, 0x00, // [2] Iamp 0x0002 Little-endian = 2
      0x04, 0x00, // [3] Speed 0x0003 Little-endian = 4
      0x08, 0x00, // [4] Pel 0x0008 Little-endian = 8
      0x18, 0x00, // [5] Tfet 0x0018 Little-endian = 24
      0xa7, 0x02, // [6] Active_Flux 0x02A7 Little-endian = 0,0679
      0xe4, 0x0e, // [7] Brake 0x0EE4 Little-endian = 3,812
      0x01, 0x00, // [8] Teta_shift 0x0001 Little-endian = 0.001
      0x1a, 0x00, // [9] Tmot 0x001A Little-endian = 26
      0x03, 0x00, // [10] Hall_cnt 0x0003 Little-endian = 3
      0x24, 0x03, // [11] Trottle_Act 0x0324 Little-endian = 0,804
      0x03, 0x08, // [12] statuc_word 0x0803 Little-endian
      0x00, 0x00, // [13] alg_mode 0x0000
      0xA4, 0x02, // crc
    ];
    final packet = Packet.fromBytes(Uint8List.fromList(rawBytes));

    expect(packet.crcValid, true);

    final liveData = LiveData.fromBytes(packet.dataBuffer);

    expect(liveData.udc, 70.29);
    expect(liveData.uz, 0.03);
    expect(liveData.iAmp, 2);
    expect(liveData.speed, 4);
    expect(liveData.pel, 8);
    expect(liveData.tFet, 24);
    expect(liveData.activeFlux, 0.0679);
    expect(liveData.brake, 3.812);
    expect(liveData.tetaShift, 0.001);
    expect(liveData.tMot, 26);
    expect(liveData.hallCnt, 3);
    expect(liveData.throttleAct, 0.804);
  });
}
