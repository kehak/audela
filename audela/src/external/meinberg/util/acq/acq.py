#!/usr/bin/python

from Tkinter import *
import os
import time
import tkMessageBox
import subprocess as subp
import re

#import numpy
import matplotlib.pyplot as plt
from scipy.stats import norm
import matplotlib.mlab as mlab

import decimal

class Application(Frame):

	def gps_status(self):
		self.p = subp.Popen(["mbgstatus","-vvv"],stdout=subp.PIPE)
		#os.waitpid(self.p.pid,0)
		self.gps = self.inf.mbg.label["text"] = self.p.communicate()[0]
		if (re.search("Antenna is connected",self.gps) and re.search("Time is synchronized",self.gps)):
			self.inf.mbg.button["bg"] = "green"
		else:
			self.inf.mbg.button["bg"] = "red"

	def diff(self):
		os.system("testUTC 1000 /tmp/utc.dat >/dev/null")
		m,s = an_file("/tmp/utc.dat")
		#print type(m),type(s)
		self.inf.mbg.diff.label["text"] = "T_PC - T_GPS = "+format_error(str(m),str(s))+" s"
		

	def start(self):
		if self.filename.get() == "":
			tkMessageBox.showinfo("Error!","Empty filename")
			return
		if os.path.exists(self.filename.get()):
			if not tkMessageBox.askyesno("File existing","Overwrite file?"):
				return
		os_start(self.filename.get())
		
	def stop(self):
		os_stop()

	def del_handler(self):
		self.master.destroy()
		self.master.quit()

	def createWidgets(self):
		self.sup = Frame(self)

		#self.sup.QUIT = Button(self.sup)
		#self.sup.QUIT["text"] = "QUIT"
		#self.sup.QUIT["fg"] = "red"
		#self.sup.QUIT["command"] = self.quit

		#self.sup.QUIT.pack({"side":"left"})

		self.sup.start = Button(self.sup)
		self.sup.start["text"] = "Start"
		self.sup.start["command"] = self.start

		self.sup.start.pack({"side":"left"})

		self.sup.stop = Button(self.sup)
		self.sup.stop["text"] = "Stop"
		self.sup.stop["command"] = self.stop

		self.sup.stop.pack({"side":"left"})

		self.sup.pack({"side":"top"})

		self.inf = Frame(self)

		self.inf.file = Frame(self.inf)

		self.inf.file.label = Label(self.inf.file)
		self.inf.file.label["text"] = "Timestamp filename"
		self.inf.file.label.pack({"side":"left"})

		self.inf.file.entry = Entry(self.inf.file)
		self.inf.file.entry["textvariable"] = self.filename
		self.inf.file.entry.pack({"side":"right"})

		self.inf.file.pack({"side":"top"})

		self.inf.mbg = Frame(self.inf)

		self.inf.mbg.button = Button(self.inf.mbg)
		self.inf.mbg.button["text"] = "GPS"
		self.inf.mbg.button["bg"] = "red"
		self.inf.mbg.button["command"] = self.gps_status
		self.inf.mbg.button.pack({"side":"top"})

		self.inf.mbg.label = Label(self.inf.mbg)
		#self.inf.mbg.label["height"] = "100"
		#self.inf.mbg.label["width"] = "100"
		self.inf.mbg.label["text"] = self.gps
		self.inf.mbg.label.pack({"side":"top"})

		self.inf.mbg.diff = Frame(self.inf.mbg)

		self.inf.mbg.diff.button = Button(self.inf.mbg.diff)
		self.inf.mbg.diff.button["text"] = "Compute difference"
		self.inf.mbg.diff.button["command"] = self.diff
		self.inf.mbg.diff.button.pack({"side":"left"})

		self.inf.mbg.diff.label = Label(self.inf.mbg.diff)
		self.inf.mbg.diff.label.pack({"side":"top"})

		self.inf.mbg.diff.pack({"side":"bottom","pady":"10"})

		self.inf.mbg.pack({"side":"bottom"})

		self.inf.pack({"side":"top"})

	def __init__(self,master=None):
		Frame.__init__(self,master)
		self.master = master
		master.protocol("WM_DELETE_WINDOW",self.del_handler)
		self.filename=StringVar()
		self.gps=""
		self.pack()
		self.createWidgets()
		self.gps_status()
		self.diff()

def xcap_command(f):
	os.system("cp /usr/local/xcap/scripts/"+f+".scr /usr/local/xcap/scripts/command.scr")
	while 1:
		if not os.path.exists("/usr/local/xcap/scripts/command.scr"):
			break
		time.sleep(0.001)


def os_start(f):
	#xcap_command("prepare_start")
	print "start"
	os.system("gpscap -f "+f+" &")

def os_stop():
	#xcap_command("stop")
	print "stop"
	os.system("pkill -2 gpscap")

def an_file(name):
	diff=[]
	#t=0
	f=open(name)
	for line in f.readlines():
		if line[0]=='#':
			continue
		l=line.split()
		#if t==0:
		#	t=int(float(l[0]))
		diff.append(float(l[2])-float(l[0]))
	f.close()
	h,bins,patched = plt.hist(diff,60,normed=True)
	(mu,sigma) = norm.fit(diff)
	y = mlab.normpdf(bins,mu,sigma)
	plt.plot(bins,y,'r--')
	print
	print name
	print '  Fitted mean = ',mu
	print '  Fitted standard deviation = ', sigma
	#return t,(mu,sigma)
	return (mu,sigma)

def format_error_1(value,error):
	value = decimal.Decimal(value)
	error = decimal.Decimal(error)
	value_scale = value.log10().to_integral(decimal.ROUND_FLOOR)
	error_scale = value.log10().to_integral(decimal.ROUND_FLOOR)
	precision = value_scale - error_scale
	if error_scale > 0:
		format = "%%.%dE" % max(precision,0)
	else:
		format = "%%.%dG" % (max(precision,0)+1)
	value_str = format % value.quantize(decimal.Decimal("10")**error_scale)
	error_str = '(%d)' % error.scaleb(-error_scale).to_integral()
	if 'E' in value_str:
		index = value_str.index('E')
		return value_str[:index]+error_str+value_str[index:]
	else:
		return value_str+error_str

def format_error(value,error):
	value = decimal.Decimal(value)
	error = decimal.Decimal(error)
	error_scale = error.adjusted()
	error_scale += error.scaleb(-error_scale).to_integral().adjusted()
	value_str = str(value.quantize(decimal.Decimal("1E%d" %error_scale)))
	error_str = '(%d)' % error.scaleb(-error_scale).to_integral()
	if 'E' in value_str:
		index = value_str.index('E')
		return value_str[:index] + error_str + value_str[index:]
	else:
		return value_str+error_str


root = Tk()
root.wm_title("Meinberg GPS control")
app = Application(master=root)
app.mainloop()
