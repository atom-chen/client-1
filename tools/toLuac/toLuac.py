# coding:utf-8
import codecs
import os
import re
from os.path import getsize, splitext
import json
import shutil
import glob
import sys

loginDir = "..\..\game\Resources\\base\\loginScript"
rootDir = "..\..\game\Resources\\base\\script"
resCount = "..\..\game\Resources/"
outDir = "outLuac"

def cleanDir( Dir ):
    print("cleanDir:", Dir)
    if os.path.isdir( Dir ):
        paths = os.listdir( Dir )
        for path in paths:
            filePath = os.path.join( Dir, path )
            if os.path.isfile( filePath ):
                try:
                    os.remove( filePath )
                except os.error:
                    autoRun.exception( "remove %s error." %filePath )#引入logging
            elif os.path.isdir( filePath ):
                print("clean", filePath)
                shutil.rmtree(filePath,True)
    return True


if not os.path.exists(outDir):
    os.makedirs(outDir)
cleanDir(outDir)

def outDict(out):
    contentStr = ""
    nameDir = ""
    for root, dirs, files in os.walk(out):
        print(root)
        if len(files)!=0:
            for file in files:
            	path = outDir+"\\"+root[len(resCount):]
            	print(path)
            	newPath = os.path.join( path, file )
            	oldPath = os.path.join( root, file )
            	if not os.path.exists(path):
                    os.makedirs(path)
            	command = "luajit -b "+oldPath+" "+newPath
            	os.system(command)
outDict(loginDir)
outDict(rootDir)
os.system("pause")
