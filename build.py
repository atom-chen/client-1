# coding:utf-8
import codecs
import os
import re
from os.path import getsize, splitext
import json
import shutil

win32 = "Debug.win32"
out = "pcPack"
resources = "game/Resources"
dllDir = ""

def filter(file):
	ext = file[-4:]
	if ext is ".pdb":
		print "false"
		return False
	else:
		return True

def copyFiles(sourceDir, targetDir):
    print sourceDir
    for f in os.listdir(sourceDir):   
        sourceF = os.path.join(sourceDir, f)
        targetF = os.path.join(targetDir, f)

        if os.path.isfile(sourceF) and filter(f):   
            #创建目录   
            if not os.path.exists(targetDir):
                os.makedirs(targetDir)
            open(targetF, "wb").write(open(sourceF, "rb").read())
        else:
        	copyFiles(sourceF, targetF)			

copyFiles(win32,out)
copyFiles(resources,out)
#cmd_path='HaoZipC a -tzip pcPack.zip pcPack\*'
#os.system(cmd_path)
