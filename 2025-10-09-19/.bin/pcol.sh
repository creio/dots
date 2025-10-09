#!/bin/bash

colorpicker --short --one-shot --preview | head -c -1 | xsel -b -i
