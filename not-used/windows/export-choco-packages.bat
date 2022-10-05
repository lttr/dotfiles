@echo off
choco list -lo | gawk 'BEGIN {OFS=""; print "<?xml version=\42 1.0\42 encoding=\42utf-8\42?>\n<packages>"} {print "  <package id=\42", $1, "\42>"} END {print "</packages>"}'
