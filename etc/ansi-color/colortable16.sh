#!/bin/bash
#
# Description:
#
#    Prints a color table of 8bg * 8fg * 2 states (regular/bold)
#
# Copyright:
#
#    (C) 2009 Wolfgang Frisch <xororand@unfoog.de>
#
# License:
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

echo
echo Table for 16-color terminal escape sequences.
echo Replace ESC with \\033 in bash.
echo
echo "Background | Foreground colors"
echo "---------------------------------------------------------------------"
for((bg=40;bg<=47;bg++)); do
	for((bold=0;bold<=1;bold++)) do
		echo -en "\033[0m"" ESC[${bg}m   | "
		for((fg=30;fg<=37;fg++)); do
			if [ $bold == "0" ]; then
				echo -en "\033[${bg}m\033[${fg}m [${fg}m  "
			else
				echo -en "\033[${bg}m\033[1;${fg}m [1;${fg}m"
			fi
		done
		echo -e "\033[0m"
	done
	echo "--------------------------------------------------------------------- "
done

echo
echo
