#!/usr/bin/env bash

# td is a CLI-based todolist manager
# Copyright (C) 2016  Thibaut Rousseau
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

readonly TODOLIST="$HOME/.todolist"
readonly TODO="☐ "
readonly DONE="☑ "
readonly USAGE="Usage: $0 COMMAND [arg...]

Commands:
  todo
    display the list of todo items
  todo DESCRIPTION
    create a todo item
  done
    display the list of done items
  done TASKNUMBER...
    mark a todo item as done
  help
    display this help message"

# Make sure the file exists before doing anything
touch "$TODOLIST"

die() {
	echo "$@" 1>&2
	exit 1
}

list_tasks() {
	grep -n "$1" "$TODOLIST"
}

list_todo() {
	list_tasks "^$TODO"
}

list_done() {
	list_tasks "^$DONE"
}

td_todo() {
	if [ -z "$*" ]
	then
		list_todo
	else
		echo "$TODO" "$*" >> "$TODOLIST"
	fi
}

td_done() {
	if [ -z "$*" ]
	then
		list_done
	else
		# Reverse sort the task numbers
		tasks=$(
			# Do this in a subshell to preserve IFS
			# This allows `sort` to split on spaces
			IFS=$'\n \t'
			echo "$*" | sort -nr
		)

		for task in $tasks
		do
			# If $task is numeric
			if [ "$task" -eq "$task" ] 2> /dev/null
			then
				sed -i "${task}s/$TODO/$DONE/" "$TODOLIST"
			fi
		done
	fi
}

td_help() {
	echo "$USAGE"
}

case "$1" in
	todo|done)
		td_"$1" "${@:2}"
		;;
	*)
		td_help
		;;
esac
