#!/usr/bin/env groovy

import groovy.xml.XmlSlurper;


public class Global { }

if (args.size() < 1) {
    println "";
    println "Usage ./${this.class.getSimpleName()} <pom.xml>";
    println "";
    System.exit(-1);
}

def fileName = args[0];

def file = new File(fileName);

def pom = new XmlSlurper().parseText(file.text);

println pom.properties.majorMinor
