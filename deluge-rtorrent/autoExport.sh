#!/bin/bash

export PYTHONPATH=$HOME/.local/lib/python2.7/site-packages:/usr/lib/python3/dist-packages:$PYTHONPATH
export PERL5LIB=$HOME/perl5/lib/perl5:$PERL5LIB

/opt/deluge-1.3.15/bin/python2.7 $HOME/scripts/autoExport.py

exit
