# coding:utf-8
import codecs
import os
import re
from os.path import getsize, splitext
import json
import shutil
import plistlib
import sys
import time

rootSDKConfig = "sdkConfig"
rootAppResPath= "appRes"
plistTemplate = "template.plist"

def generateUpdatePlist(channel,scheme,version,infoPlistPath,downloadURL):
    targetName = "lieyanzhetian_"+channel+"_"+version
    plistName = targetName+".plist"
    ipaName = targetName+".ipa"
    targetPath = "publish/"+channel+"/"+scheme
    if not os.path.exists(targetPath):
        os.makedirs(targetPath)
    plistPath = targetPath+"/"+plistName
    print plistPath
    plist = plist = plistlib.readPlist(infoPlistPath)
    outURL = downloadURL+channel+"/"+ipaName
    bundleName = plist["CFBundleIdentifier"]
    template = plistlib.readPlist(plistTemplate)
    template["items"][0]["assets"][0]["url"] = outURL
    template["items"][0]["metadata"]["bundle-identifier"] = bundleName
    template["items"][0]["metadata"]["bundle-version"] = version
    plistlib.writePlist(template,plistPath)
    
def copyPlist(outFormat,channel):
    formatList = outFormat.split("-")
    targetPath = rootSDKConfig+"/"+channel+"/"+formatList[0]+"/"+formatList[1]+"/sdkConfig.plist"
    newPath = rootAppResPath+"/"+rootSDKConfig+"/"+channel
    if os.path.isfile(newPath):
        os.remove(newPath)
    if not os.path.exists(newPath):
        os.makedirs(newPath)
    shutil.copy(targetPath,newPath)
    
def saveArchiveRecord(targetPath,channel):
    newPath = "record/"+str(time.time())+"/"+channel+".xcarchive"
    if not os.path.exists(targetPath):
        os.makedirs(targetPath)
    shutil.copytree(targetPath,newPath)
    
def changePlistVersion(path,version):
    keys = [
        "CFBundleShortVersionString",
        "CFBundleVersion"
        ]
    plist = plistlib.readPlist(path)
    for key in keys:
        plist[key] = version
    plistlib.writePlist(plist,path)


def archive(name,scheme,channel):
    outName = scheme+"-"+channel+".xcarchive"
    command = "xcodebuild -workspace "+name+"/"+name+".xcodeproj/project.xcworkspace -scheme "+scheme+" archive -archivePath publish/"+outName
    os.system(command)

def exportIPA(name,scheme,channel,version,provision):
    archiveName = scheme+"-"+channel+".xcarchive"
    archivePath = "publish/"+archiveName
    exportName = "lieyanzhetian_"+channel+"_"+version
    exportPath = "publish/"+channel+"/"+scheme
    if not os.path.exists(exportPath):
        os.makedirs(exportPath)
    exportPath = exportPath +"/"+exportName
    if os.path.isfile(exportPath+".ipa"):
        os.remove(exportPath+".ipa")
    command = "xcodebuild -exportArchive -exportFormat IPA -archivePath "+archivePath+" -exportPath "+exportPath+" -exportProvisioningProfile "+provision
    os.system(command)
    saveArchiveRecord(archivePath,channel)

def archiveWithSetting(option,buildRule,settingPath):
    rule = plistlib.readPlist(buildRule)
    buildList = rule["build_list"]
    version = rule["version"]
    setting = plistlib.readPlist(settingPath)
    outFormat = rule["outputFormat"]
    downloadURL = rule["downloadURL"][outFormat.split("-")[0]]
    for key in buildList:
        infoDict = setting[key]
        name = infoDict["name"]
        scheme = infoDict["scheme"]
        channel = infoDict["channel"]
        copyPlist(outFormat,channel)
        provision = infoDict["provision"]
        plistPath = infoDict["plist"]
        generateUpdatePlist(channel,scheme,version,plistPath,downloadURL)
        if option != "plist":
            changePlistVersion(plistPath,version)
            archive(name,scheme,channel)
            exportIPA(name,scheme,channel,version,provision)
           

if __name__ == '__main__':
    option = None
    if len(sys.argv) > 1:
        option = sys.argv[1]
    start = time.time()
    archiveWithSetting(option,"build_rule.plist","setting.plist")
    print "cost time "+str(time.time() - start)
        

