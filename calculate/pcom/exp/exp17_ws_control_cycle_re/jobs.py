#!/usr/bin/env python

# Description: 
#
#      Author: OU Yuyuan <ouyuyuan@lasg.iap.ac.cn>
#     Created: 2014-11-16 06:59:29 BJT
# Last Change: 2014-12-01 10:44:08 BJT

import os
import sys

jobnames = [
#'modify_filename',
#'isothermal_line_depth',
#'isot_eof_eq_Pac',
#'dtc_eof',
#'ssh',
#'ssh_eof',
'v_transport',
]

def runCmd(cmd):
  print(cmd)
  stat = os.system(cmd)
  if stat != 0:
    print("Error happen when run: "+cmd)
    sys.exit()

class Job:
  def __init__(self,name):
    self.name = name
    self.datDir = '/home/ou/archive/data/pcom/exp17_ws_control_cycle_re/post/'
    self.calcscript = ''

  def calc(self):
    cmd = "mkdir -p " + self.datDir
    print(cmd); os.system(cmd)
    scriptname = self.calcscript
    ext = scriptname.split('.')[-1]
    if ext == 'ncl':
      calculator = 'nclrun '
    elif ext == 'jnl':
      calculator = 'pyferret -nojnl -script '
    elif ext == 'py':
      calculator = 'python '
    else:
      print('Unknown script extension: ' + ext)
      sys.exit()
    runCmd(calculator + scriptname + ' ' + self.datDir)

# automatically execute jobs
#============================
for jobname in jobnames:
  job = Job(jobname)
  nclscript = jobname+'.ncl'
  pyscript  = jobname+'.py'
  if os.path.isfile(nclscript):
    job.calcscript = nclscript
    job.calc()
  elif os.path.isfile(pyscript):
    job.calcscript = pyscript
    job.calc()
  else:
    pass
