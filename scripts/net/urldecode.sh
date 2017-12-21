#!/bin/bash
python -c "import sys, urllib as ul; print ul.unquote_plus(sys.stdin.read())"
