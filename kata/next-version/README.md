# Next Version

## Description
You're fed up about changing the version of your software manually. Instead, you will create a little script that will make it for you.

**Exercice**

Create a function nextVersion, that will take a string in parameter, and will return a string containing the next version number.

For example:

```Julia
Current           ->  Next version
"1.2.3"           ->  "1.2.4"
"0.9.9"           ->  "1.0.0"
"1"               ->  "2"
"1.2.3.4.5.6.7.8" ->  "1.2.3.4.5.6.7.9"
"9.9"             ->  "10.0"
```

Rules

All numbers, except the first one, must be lower than 10: if there are, you have to set them to 0 and increment the next number in sequence.

You can assume all tests inputs to be valid.

## Source

ref. https://www.codewars.com/kata/56c0ca8c6d88fdb61b000f06
