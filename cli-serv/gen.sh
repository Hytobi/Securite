#!/bin/bash

keytool -genkey -alias server -keyalg RSA -keystore server-keystore.jks -keysize 2048 -storepass password -dname "CN=server"
keytool -export -alias server -file server.cer -keystore server-keystore.jks -storepass password


keytool -import -trustcacerts -alias server -file server.cer -keystore client-truststore.jks -storepass password
