#!/usr/bin/env python

# svg2font
# (c) 2009 Jakub Steiner
# (c) 2009 Novell, Inc.

ICONS_DIR = 'moblin'
BLANK_FONT = 'template.sfd'
OUTPUT_FONT = 'moblin-icons.ttf'
letters = 'abcdefghijklmnopqsrtuvwxyzABCDEFGHIJKLMOPQRSTUVWXYZ1234567890!@#$%^&*()[]\\;\',./{}|:"<>?'
glyphs = {}

# right-o, here we go
import fontforge
import os
import re

# open a blank font template
# TODO: dynamically generate the space character
font = fontforge.open(BLANK_FONT)
folder = os.listdir(ICONS_DIR+"/scalable/devices/")


def doInDir(arg, path, files):
    global i,letters,glyphs
    
    for f in files:
        if (re.search("svg$",f)):
            icon = os.path.join(path,f)
            glyphs[letters[i]] = icon
            i += 1

i = 0            
os.path.walk(ICONS_DIR, doInDir, "*.svg")

for glyph,icon in glyphs.iteritems():
    font.createMappedChar(glyph)
    font[glyph].importOutlines(icon)
    #hacky spacing
    font[glyph].left_side_bearing = 15
    font[glyph].right_side_bearing = 15
    font[glyph].autoInstr() #autohint


# create TTF
font.generate(OUTPUT_FONT)
