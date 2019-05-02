#! /usr/bin/env bash

export PDFBOX_PATH="$(pwd)/lib/scripts/pdfbox/"

export CLASSPATH=$CLASSPATH:$PDFBOX_PATH/*

# To compile AddJavascript.java
# javac -cp .:lib/scripts/pdfbox/* lib/scripts/pdfbox/AddJavascript.java

cd lib/scripts

java pdfbox.AddJavascript $1 $2 $3
