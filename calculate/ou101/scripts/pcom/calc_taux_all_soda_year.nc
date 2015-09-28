
; Description: create climatory monthly mean 
;
;      Author: OU Yuyuan <ouyuyuan@lasg.iap.ac.cn>
;     Created: 2014-11-06 20:37:58 BJT
; Last Change: 2014-11-15 09:15:17 BJT

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  yb = 1958
  ye = 2007

  orifile = "/snfs01/ou/data/yyq_soda/preprocess/taux_1871to2008_month.nc"
  outfile = "/snfs01/ou/data/pcom/pcom_bcu_mn_soda_1871-2008.nc"

;  tb = (yb - 1948) * 12
;  te = (ye - 1948 + 1) * 12 - 1
  f = addfile( orifile, "r" )
  bcu = f->taux
;  bcu = f->bcu(tb:te,:,:)
;  bcv = f->bcv(tb:te,:,:)
;  bct = f->bct(tb:te,:,:)
;  bcs = f->bcs(tb:te,:,:)
;  bcp = f->bcp(tb:te,:,:)
;  emp = f->emp(tb:te,:,:)
;  ddd = f->ddd(tb:te,:,:)
  delete(f)

  system("rm -f " + outfile)
  f = addfile( outfile, "c" )
  f->bcu = clmMonTLL(bcu)
;  f->bcv = clmMonTLL(bcv)
;  f->bct = clmMonTLL(bct)
;  f->bcs = clmMonTLL(bcs)
;  f->bcp = clmMonTLL(bcp)
;  f->emp = clmMonTLL(emp)
;  f->ddd = clmMonTLL(ddd)

  f@data = "monthly mean boundary conditon data"
;  f@source = "create by " + systemfunc("pwd") + "/" + getenv("NCL_ARG_0") + \
;  ", " + systemfunc("date")
  delete(f)
end
