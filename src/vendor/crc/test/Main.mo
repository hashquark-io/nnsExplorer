/**
 * Module      : Main.mo
 * Description : Unit tests.
 * Copyright   : 2020 Enzo Haussecker
 * License     : Apache 2.0 with LLVM Exception
 * Maintainer  : Enzo Haussecker <enzo@dfinity.org>
 * Stability   : Stable
 */

import CRC8 "../src/CRC8";

actor {

  private let tests = [
    {
      data = [
      ] : [Word8];
      expect = 000 : Word8;
    },
    {
      data = [
        072, 101, 108, 108, 111, 032, 087, 111,
        114, 108, 100,
      ] : [Word8];
      expect = 037 : Word8;
    },
  ];

  public func run() {
    for (test in tests.vals()) {
      let expect = test.expect;
      let actual = CRC8.crc8(test.data);
      assert(expect == actual);
    };
  };
};
