# liberty2xml (not working...)

A simple lex&yacc program that translates Synopsys's .lib format into an XML-like format.

## Compilation
```
qmake -project
qmake
make
```

## Demo
```
./lib2xml < power_sample.lib > test.xml
```