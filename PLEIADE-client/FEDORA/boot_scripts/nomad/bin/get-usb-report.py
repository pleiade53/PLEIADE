#!/bin/python

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey

import sys

def summary(log):
	i=0
	header = ""
	lines = log.split("\n")
	while i < 5:
		line=lines[i]
		if "Analyse du" in line:
			header=line
		i+=1
	return header + "\n" + log.split("----------- SCAN SUMMARY -----------")[1]

def detail(log):
	return log.split("----------- SCAN SUMMARY -----------")[0]


def main():
	with open("/var/log/usb_log.txt") as logfile:
		content=logfile.read()
		analysis_array=content.split("++++++++++NEW++++++++++")
		matching = []
		if len(sys.argv) < 2:
			matching = analysis_array
		elif sys.argv[1] == "all":
			for analysis in analysis_array:
				if ": Analyse du" in analysis:
					matching.append(analysis)
		else:
			for analysis in analysis_array:
				if "%s : Analyse du"%sys.argv[1] in analysis:
					matching.append(analysis)	
		# -s print only summary, -d print only details, empty print summary then details
		match=len(matching)
		if not match:
			print("no match")
			return
		if len(sys.argv) < 3:
			print("%s" %summary(matching[match-1]))
			print("%s" %detail(matching[match-1]))
		elif "-s" in sys.argv[2]:
			if len(sys.argv) < 4:
				print("%s" %summary(matching[match-1]))
			elif "-a" in sys.argv[3]:
				for analysis in matching:
					print("%s" %summary(analysis))
		elif "-d" in sys.argv[2]:
			if len(sys.argv) < 4:
				print("%s" %detail(matching[match-1]))
			elif "-a" in sys.argv[3]:
				for analysis in matching:
					print("%s" %detail(analysis))
		
main()				
			
	
