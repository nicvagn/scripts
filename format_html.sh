#!/usr/bin/env bash

# Format all the html in current dir with tidey

html_files=`ls ./*.html`


for f in $(ls ./*.html)
do
  echo $f
  tidy -i -ashtml -utf8  -modify $f
done
