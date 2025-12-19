#!/bin/bash
wm=$(xprop -root | grep "WM_NAME" | cut -d '"' -f 2)
echo "$wm"

