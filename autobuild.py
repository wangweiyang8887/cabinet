#!/usr/bin/env python
# -*- coding:utf-8 -*-

from optparse import OptionParser
import subprocess
import requests

#configuration for iOS build setting
SCHEME = "cabinet"
CODE_SIGN_IDENTITY = "Apple Distribution: Weiyang Wang (EVG8QY6QFT)"
ADHOC_PROVISIONING_PROFILE = "cabinetadhocdis"
APPSTORE_PROVISIONING_PROFILE = "cabinetdis"
CODE_SIGNING_ALLOWED = "NO"
CONFIGURATION = "Release"
SDK = "iphoneos"
ADHOC_EXPORT_OPTIONS = "./ExportOptions.plist"
APPSTORE_EXPORT_OPTIONS = "./Dis-ExportOptions.plist"
# configuration for pgyer
PGYER_UPLOAD_URL = "http://www.pgyer.com/apiv1/app/upload"
DOWNLOAD_BASE_URL = "http://www.pgyer.com"
USER_KEY = "8d2ad219591cec2d03de8f755681424c"
API_KEY = "def5d066593ea17015ea4fec1ee4ef66"
# configuration for appstore
ALTOOL_PATH = "/Applications/Xcode.app/Contents/Applications/Application\ Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"
APPSTORE_USER_KEY = "app@xxxxxxxx.cn"
APPSTORE_USER_PASSWORD = "8XXXXXXXXXXXM"
def cleanXCArchive(xcArchive):
	cleanCmd = "rm -r %s" %(xcArchive)
	process = subprocess.Popen(cleanCmd, shell=True)
	process.wait()
	print ("cleaned xcArchive:%s" %(xcArchive))
	print ("** CLEANED SUCCEEDED **")
	pass

def uploadIpaToAppStore(ipaPath):
	print ("ipaPath:"+ipaPath)
	buildCmd = '%s --validate-app -f %s -u APPSTORE_USER_KEY -p APPSTORE_USER_PASSWORD --output-format xml' %(ALTOOL_PATH, ipaPath)
	process = subprocess.Popen(buildCmd, shell=True)
	process.wait()

	signCmd = '%s --upload-app -f %s -u APPSTORE_USER_KEY -p APPSTORE_USER_PASSWORD --output-format xml' %(ALTOOL_PATH, ipaPath)
	process = subprocess.Popen(signCmd, shell=True)
	(stdoutdata, stderrdata) = process.communicate()
	pass

def parserUploadResult(jsonResult):
	resultCode = jsonResult['code']
	if resultCode == 0:
		downUrl = DOWNLOAD_BASE_URL +"/"+jsonResult['data']['appShortcutUrl']
		print ("Upload Success")
		print ("DownUrl is:%s" %(downUrl))
	else:
		print ("Upload Fail!")
		print ("Reason:"+jsonResult['message'])

def uploadIpaToPgyer(ipaPath, description):
    print ("ipaPath:"+ipaPath)
    files = {'file': open(ipaPath, 'rb')}
    headers = {'enctype':'multipart/form-data'}
    if description is None:
    	payload = {'uKey':USER_KEY,'_api_key':API_KEY,'publishRange':'2','isPublishToPublic':'2', 'password':''}
    else:
    	payload = {'uKey':USER_KEY,'_api_key':API_KEY,'publishRange':'2','isPublishToPublic':'2', 'password':'',"updateDescription":description}
    print ("uploading....")
    r = requests.post(PGYER_UPLOAD_URL, data = payload ,files=files,headers=headers)
    if r.status_code == requests.codes.ok:
         result = r.json()
         parserUploadResult(result)
    else:
        print ('HTTPError,Code:'+r.status_code)

def buildProject(project, adhoc, appstore, output, ipa, provisionprofile, exportoptions, description):
	if adhoc is not None:
		ipaoutput = output + "/adhoc"
	elif appstore is not None:
		ipaoutput = output + "/appstore"

	archive = ipaoutput + "/" + SCHEME + ".xcarchive"
	buildCmd = 'xcodebuild archive -project %s -scheme %s -configuration %s -archivePath %s CODE_SIGN_IDENTITY="%s" PROVISIONING_PROFILE="%s" CODE_SIGNING_ALLOWED="%s"' %(project, SCHEME, CONFIGURATION, archive, CODE_SIGN_IDENTITY, provisionprofile, CODE_SIGNING_ALLOWED)
	process = subprocess.Popen(buildCmd, shell=True)
	process.wait()

	signCmd = "xcodebuild -exportArchive -archivePath %s -exportOptionsPlist %s -exportPath %s" %(archive, exportoptions, ipaoutput)
	process = subprocess.Popen(signCmd, shell=True)
	(stdoutdata, stderrdata) = process.communicate()
	
	if ipa is None and adhoc is not None:
		ipaPath = ipaoutput + "/" + SCHEME + ".ipa"
		uploadIpaToPgyer(ipaPath, description)
	elif ipa is None and appstore is not None:
		ipaPath = ipaoutput + "/" + SCHEME + ".ipa"
		uploadIpaToAppStore(ipaPath)
	#cleanXCArchive(archive)		
	
def buildWorkspace(workspace, adhoc, appstore, output, ipa, provisionprofile, exportoptions, description):
	if adhoc is not None:
		ipaoutput = output + "/adhoc"
	elif appstore is not None:
		ipaoutput = output + "/appstore"

	archive = ipaoutput + "/" + SCHEME + ".xcarchive"
	buildCmd = 'xcodebuild archive -workspace %s -scheme %s -configuration %s -archivePath %s CODE_SIGN_IDENTITY="%s" PROVISIONING_PROFILE="%s"' %(workspace, SCHEME, CONFIGURATION, archive, CODE_SIGN_IDENTITY, provisionprofile)
	process = subprocess.Popen(buildCmd, shell=True)
	process.wait()

	signCmd = "xcodebuild -exportArchive -archivePath %s -exportOptionsPlist %s -exportPath %s" %(archive, exportoptions, ipaoutput)
	process = subprocess.Popen(signCmd, shell=True)
	(stdoutdata, stderrdata) = process.communicate()

	if ipa is None and adhoc is not None:
		ipaPath = ipaoutput + "/" + SCHEME + ".ipa"
		uploadIpaToPgyer(ipaPath, description)
	elif ipa is None and appstore is not None:
		ipaPath = ipaoutput + "/" + SCHEME + ".ipa"
		uploadIpaToAppStore(ipaPath)
	# cleanXCArchive(archive)


def xcbuild(options):
	project = options.project
	workspace = options.workspace
	output = options.output
	altool = options.altool
	ipa = options.ipa
	adhoc = options.adhoc
	appstore = options.appstore
	upload = options.upload
	description = options.description

	if output is not None and upload is not None and project is None and workspace is None:
		uploadIpaToPgyer(output, description)
		pass

	if output is not None and altool is not None and project is None and workspace is None:
		uploadIpaToAppStore(output)
		pass

	if project is None and workspace is None and output is None:
		pass

	if project is not None:
		if adhoc is not None:
			buildProject(project, adhoc, appstore, output, ipa, ADHOC_PROVISIONING_PROFILE, ADHOC_EXPORT_OPTIONS, description)
		elif appstore is not None:
			buildProject(project, adhoc, appstore, output, ipa, APPSTORE_PROVISIONING_PROFILE, APPSTORE_EXPORT_OPTIONS, description)
	elif workspace is not None:
		if adhoc is not None:
			ipaoutput = output + "/adhoc"
			buildWorkspace(workspace, adhoc, appstore, output, ipa, ADHOC_PROVISIONING_PROFILE, ADHOC_EXPORT_OPTIONS, description)
		elif appstore is not None:
			ipaoutput = output + "/appstore"
			buildWorkspace(workspace, adhoc, appstore, output, ipa, APPSTORE_PROVISIONING_PROFILE, APPSTORE_EXPORT_OPTIONS, description)
	
def main():
	
	parser = OptionParser()
	parser.add_option("-w", "--workspace", help="Build the workspace name.xcworkspace.", metavar="name.xcworkspace")
	parser.add_option("-p", "--project", help="Build the project name.xcodeproj.", metavar="name.xcodeproj")
	parser.add_option("-o", "--output", help="specify output path /filename")
	parser.add_option("-i", "--ipa", help="archive and export ipa only,if None also upload to pgyer", metavar="ipa")
	parser.add_option("-c", "--adhoc", help="specify archive for adhoc", metavar="adhoc")
	parser.add_option("-e", "--appstore", help="specify archive for appstore", metavar="appstore")
	parser.add_option("-u", "--upload", help="upload exist ipa to pgyer", metavar="upload")
	parser.add_option("-a", "--altool", help="upload exist ipa to appstore", metavar="altool")
	parser.add_option("-d", "--description", help="pgyer update description about this api version", metavar="description")

	(options, args) = parser.parse_args()

	print ("options: %s, args: %s" % (options, args))

	xcbuild(options)

if __name__ == '__main__':
	main()
