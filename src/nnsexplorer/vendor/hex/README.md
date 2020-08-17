## The Hex Package

[![Build Status](https://travis-ci.org/enzoh/motoko-hex.svg?branch=master)](https://travis-ci.org/enzoh/motoko-hex?branch=master)

### Overview

This package implements hexadecimal encoding and decoding routines for the
Motoko programming language.

### Usage

Encode an array of unsigned 8-bit integers in hexadecimal format.
```motoko
public func encode(array : [Word8]) : Text
```

Decode an array of unsigned 8-bit integers in hexadecimal format.
```motoko
public func decode(text : Text) : Result<[Word8], DecodeError> 
```
