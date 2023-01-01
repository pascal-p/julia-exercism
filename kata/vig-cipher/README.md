# Vigenere cipher

## Description

(For a full description, check the wikipedia article.)

In a Caesar cipher, each letter of the alphabet is shifted along some number of places. For example, with a shift of 3, A would become D, B would become E, Y would become B, and so on. The Vigenère cipher has several Caesar ciphers in sequence with different shift values.

The secret key is selected, and then repeated until it becomes as long as the text you want to encrypt/decrypt (if the key ends up being longer than the text, the superfluous key-characters can be removed):

```
text          =  "HELLOWORLD"
original key  =  "ABCXYZ"
repeated key  =  "ABCXYZABCX" (superfluous "YZ" at the end was removed)
```

Each character of the key tells how many times a character of the original text standing at the same position has to be shifted:

```
text:      H    E    L    L    O    W    O    R    L    D
          ------------------------------------------------
key:       A    B    C    X    Y    Z    A    B    C    X
          ------------------------------------------------
shift:     0    1    2   23   24   25    0    1    2   23
          ------------------------------------------------
result:    H    F    N    I    M    V    O    S    N    A
```

A ciphertext can then be decrypted by applying the same shifts but with a negative sign:
```
text:      H    F    N    I    M    V    O    S    N    A
          ------------------------------------------------
key:       A    B    C    X    Y    Z    A    B    C    X
          ------------------------------------------------
shift:     0   -1   -2  -23  -24  -25    0   -1   -2  -23
          ------------------------------------------------
result:    H    E    L    L    O    W    O    R    L    D
```

## Tasks

Write encode and decode function, given a key

Write a function that can deduce which key was used during a Vigenere cipher encryption, given the resulting ciphertext, and the length of that key. (cf. [wikipedia VIgenere code](https://en.wikipedia.org/wiki/Vigen%C3%A8re_cipher) in particular key elimination)

Notes:
  - The input string, as well as the encryption key, will consist of uppercase letters only
  - All texts will be in English

Examples:

Given ciphered sequence: `HFNIMVOSNA` and (original) length of the key used, here 6, deduce that the key used was "ABCXYZ" (...)


## Source

ref. https://www.codewars.com/kata/544e5d75908f2d5eb700052b
