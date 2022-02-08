#!/bin/bash

cat test 
echo -e '\n'
sed 's/\(ExecStart.*\)/\1 --noplugin=avrcp/' test
echo -e '\n'
