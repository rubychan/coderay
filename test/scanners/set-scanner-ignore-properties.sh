#!/usr/bin/env bash
echo -e "*.actual.*\n*.expected.html\n*.debug.diff*" > svn-ignore-value
find . -depth 1 -type d -not -name '.*' -exec svn ps svn:ignore -F svn-ignore-value {} \;
rm svn-ignore-value