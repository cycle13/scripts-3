
; Description: top panel: time series of a line
;              bottom panel: the wavelet analysis of that time series
;
;      Author: OU Yuyuan <ouyuyuan@lasg.iap.ac.cn>
;     Created: 2014-12-29 20:33:15 BJT
; Last Change: 2015-01-12 19:15:53 BJT

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

datDir  = getenv("NCL_ARG_1")
img     = getenv("NCL_ARG_2")
autoTicks = True

;guess data
;{{{
isNino = False
if isStrSubset(img, "___nino") then
  isNino = True
end if

isIshii = False
if isStrSubset(datDir, "Ishii") then
  isIshii = True
;  autoTicks = False
end if

isSoda = False
if isStrSubset(datDir, "soda") then
  isSoda = True
end if

isPcom = False
if isStrSubset(datDir,"pcom") .and. .not.isStrSubset(datDir,"pcom_grid") then
  isPcom = True
end if

isSpinup = False
if isPcom .and. isStrSubset(datDir, "exp_spinup") then
  isSpinup = True
end if

is120yr = False
if isSpinup .and. isStrSubset(img, "___120yr") then
  is120yr = True
end if

isExp24 = False
if isPcom .and. isStrSubset(datDir, "exp24") then
  isExp24 = True
end if
;}}}

function get_sst(fname, varName, lat, lon)
;{{{
local sst, f
begin
  f = addfile(fname,"r")
  sst = f->$varName$(:,0,{lat},{lon})
  delete(f)
  sst@units = "~S~o~N~C"

  ; remove seasonal cycle
  do month = 1, 12
    i = month-1
    monAvg = dim_avg_n(sst(i::12), 0)
    sst(i::12) = sst(i::12) - monAvg
  end do

  yyyymm = cd_calendar(sst&time, -1)
  yrfrac = yyyymm_to_yyyyfrac(yyyymm, 0.0)
  
  time = yrfrac
  sst&time = time

  ; low pass filter
;  ihp = 0
;  sigma = 1.0
;  nWgt = 25
;  fca = 1./(2*12.)
;  wgt = filwgts_lanczos(nWgt, ihp, fca, -999., sigma)

;  sstBPF = wgt_runave_n_Wrap(sst, wgt, 0, 0)
;  return sstBPF
  return sst
end
;}}}

function get_sst_yearly(fname, varName)
;{{{
local sst, f
begin
  f = addfile(fname,"r")
  sst = f->$varName$(0:119)
  if is120yr
    delete(sst)
    sst = f->$varName$({501:620})
  end if
;  sst = dtrend_n(sst, False, 0)
  sst = dim_rmvmean_n(sst,0)
  delete(f)
  sst@units = "~S~o~N~C"

; if isNino
;    ihp = 1
;    sigma = 1.0
;    nWgt = 7
;    fca = 1./(7.)
;    fcb = 1./(3.)
;    wgt = filwgts_lanczos(nWgt, ihp, fca, fcb, sigma)
;    sst = wgt_runave_n_Wrap(sst, wgt, 0, 0)
;  end if

  return sst
end
;}}}

;  cmap = "NCL_default"
;  cmap = "GMT_jet"
cmap    = "WhiteBlueGreenYellowRed"

if isPcom
  sst = get_sst_yearly( datDir+"sst.nc", "nino34" )
end if
if isIshii ; 60S, 120W
  sst = get_sst( datDir+"sst_monthly.nc", "var80", -60, 360-120 )
end if
y = sst
y@long_name = "NINO34 SSTa"

;ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
; plot model
;ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

y_mean = dim_avg_n(y,0)
time = y&time
if isPcom
  time = time - 500
end if

yMinMaxInc = (/-6, 7, 3/)

fontSize = 0.03
yLabelSize = fontSize*0.8
xLabelSize = fontSize*0.8
plotWid = 0.9
plotHei = 0.2
yTitle = y@units
xTitle = "year"
if isPcom
  xTitle = "model year"
end if

;************************************
; compute wavelet
;************************************
N     = dimsizes(time)
;{{{
mother  = 0
param   = 6.0
dt      = 1./12.    ;timesteps in units of years
if isPcom
  dt      = 1.
end if
s0      = dt
dj      = 0.25
jtot    = 1+floattointeger(((log10(N*dt/s0))/dj)/log10(2.))
npad    = N
nadof   = 0
noise   = 1
siglvl  = .05
isigtest= 0

w = wavelet(y,mother,dt,param,s0,dj,jtot,npad,noise,isigtest,siglvl,nadof)
;************************************
; create coodinate arrays for plot
;************************************
power            = onedtond(w@power,(/jtot,N/))
power!0          = "period"                        ; Y axis
power&period     = w@period                      ; convert period to units of years

power!1          = "time"                          ; X axis
power&time       = time

power@long_name  = "Power Spectrum"
power@units      = "1/unit-freq"

; compute significance ( >= 1 is significant)
sig              = power                            ; transfer meta data
;sigc = conform(power, w@signif, 0)
sig              = power/conform (power,w@signif,0)
sig@long_name    = "Significance"
sig@units        = " "
;}}}

wks = gsn_open_wks ("eps", img)
gsn_define_colormap(wks,cmap)

res = True
;{{{
res@vpWidthF = plotWid
res@vpHeightF = plotHei
;  res@vpXF = 0.1
;  res@vpYF = 0.9
res@tiXAxisString = xTitle
res@tiXAxisFontHeightF = fontSize
res@gsnDraw = False
res@gsnFrame = False
res@gsnStringFontHeightF = fontSize
res@gsnLeftString = ""
res@gsnRightString = ""
res@gsnCenterString = ""
res@gsnCenterStringOrthogonalPosF = -0.2
res@tmXTOn = False
res@tmYROn = False
res@tmYLLabelFontHeightF = yLabelSize 
res@tmXBLabelFontHeightF = xLabelSize
res@tmLabelAutoStride = True
;}}}

res_line = res
;{{{
res_line@tiYAxisString = y@units
res_line@gsnYRefLine = 0.
res_line@gsnCenterStringOrthogonalPosF = -0.2
res_line@gsnCenterString = y@long_name
;res_line@gsnCenterStringParallelPosF = 0.17
res_line@gsnAboveYRefLineColor = "IndianRed2"
res_line@gsnBelowYRefLineColor = "SteelBlue2"
res_line@xyMonoLineColor = False
res_line@xyDashPattern = 0 ; solid
res_line@xyMarkLineMode = "Lines"
;  res_line@xyLineColors = (/"magenta1", "cyan", "red", "blue", "forestgreen"/)
;  res_line@xyLineColors = lineColors
;res_line@xyLineColor = "blue3"
res_line@xyLineColor = "transparent"
res_line@xyLineThicknessF = 0.5
res_line@xyDashPattern = 0
;  res_line@tmXBMode = "Explicit"
;  res_line@tmXBValues = xTicks
;  res_line@tmXBLabels = xTicks

;res_line@tmYLPrecision = 6
res_line@tmYLMinorOn = False
;res_line@tmXUseBottom = False
;res_line@tmXTLabelsOn = True
res_line@tmXTLabelFontHeightF = xLabelSize *0.9
res_line@tmXTOn = False
;res_line@tmXBOn = False

if .not.autoTicks then
  res_line@tmYLMode = "Manual"
  res_line@tmYLTickStartF   = yMinMaxInc(0)
  res_line@tmYLTickEndF     = yMinMaxInc(1)
  res_line@tmYLTickSpacingF = yMinMaxInc(2)
  res_line@trYMinF = yMinMaxInc(0)
  res_line@trYMaxF = yMinMaxInc(1)
end if
;}}}

res_cn = res
;{{{
res_cn@vpHeightF = plotHei*2
res_cn@tiYAxisString = "period (year)"
;   res_cn@gsnYAxisIrregular2Linear = True
 res_cn@cnLinesOn            = False              ; turn off contour lines
 res_cn@cnLineLabelsOn       = False              ; turn off contour line labels
 res_cn@cnInfoLabelOn        = False      ; turns off contour info label
;  res_cn@cnMissingValFillColor = "gray60"
;   res_cn@cnFillMode = "RasterFill"
;   res_cn@lbPerimOn                = False             ; no box around it
res_cn@lbLabelFontHeightF = fontSize*0.8
res_cn@tmYLMode = "Explicit"
res_cn@tmYLValues = (/1,2,4,8,16,32,64,128/)
res_cn@tmYLLabels = (/"1","2","4","8","16","32","64","128"/)
res_cn@trYMinF = 2
res_cn@trYMaxF = 100
if isSpinup
  res_cn@trYMaxF = 128
end if
if isIshii
  res_cn@trYMaxF = 64
end if
if autoTicks
  delete(res_cn@trYMinF)
  delete(res_cn@trYMaxF)
end if
res_cn@trYReverse          = True                  ; reverse y-axis
if (cmap.eq."WhiteBlueGreenYellowRed") then
  res_cn@gsnSpreadColorStart  = 20
end if
;}}}

plot = new(2, graphic)
plot(0) = gsn_csm_xy(wks, time, y, res_line)

res_wave = res_cn
;{{{
res_wave@gsnCenterString = "Wavelet power spectrum of "+y@long_name
res_wave@gsnCenterStringOrthogonalPosF = -0.125
 res_wave@cnFillOn             = True               ; turn on color for contours
;   res_wave@cnLineThicknessF = 0.5
; res_wave@cnLevelSelectionMode = "ExplicitLevels"
; res_wave@cnLevels = (/\
; {{{
;   2^-5,\
;   2^-4,\
;   2^-3,\
;   2^-2,\
;   2^-1,\
;   2^0,\
;   2^1,\
;   2^2,\
;   2^3/)
; }}}
if isSpinup
   ;{{{
   delete(res_wave@cnLevels)
   res_wave@cnLevels = (/\
     2^-8,\
     2^-7,\
     2^-6,\
     2^-5,\
     2^-4,\
     2^-3,\
     2^-2,\
     2^-1,\
     2^0,\
     2^1,\
     2^2,\
     2^3,\
     2^4,\
     2^5/)
   ;}}}
end if
 if isSoda
   ;{{{
   delete(res_wave@cnLevels)
   res_wave@cnLevels = (/\
     2^1,\
     2^2,\
     2^3,\
     2^4,\
     2^5,\
     2^6,\
     2^7,\
     2^8,\
     2^9,\
     2^10,\
     2^11/)
   ;}}}
 end if

;   res_wave@lbLabelBarOn = False
res_wave@lbOrientation = "vertical"
;   res_wave@lbLabelStride            = 5
;   res_wave@lbLabelPosition = "Top"
 res_wave@lbTitleString = "unit^2"
;   res_wave@lbTitlePosition = "Right"
 res_wave@lbTitleFontHeightF = fontSize*0.8
;   res_wave@lbTitleOffsetF = 0.1
 res_wave@lbBoxLinesOn = False

 res_wave@pmLabelBarHeightF = 0.5
 res_wave@pmLabelBarWidthF = 0.01
 res_wave@pmLabelBarOrthogonalPosF = 0.01
 res_wave@pmLabelBarParallelPosF = 0.6
;}}}
plot(1) = gsn_csm_contour(wks,power,res_wave)

res_sig = res_cn ; res_sig probability plots
;{{{
res_sig@cnLevelSelectionMode = "ManualLevels" ; set manual contour levels
res_sig@cnMinLevelValF      = 0.00        ; set min contour level
res_sig@cnMaxLevelValF      = 2.00        ; set max contour level
res_sig@cnLevelSpacingF     = 1.00        ; set contour spacing
res_sig@cnFillScaleF        = 0.8          ; add extra density
plot_sig = gsn_csm_contour(wks,sig,res_sig)
plot_sig = ShadeGtContour(plot_sig,1.,17)
;}}}
;  plot(1) = plot_sig
overlay(plot(1),plot_sig)				; overlay probability plot onto power plot

resAtt1 = True
resAtt1@gsnAttachPlotsXAxis = True
resAtt2 = True
attachid = gsn_attach_plots(plot(0), plot(1), resAtt1, resAtt2)

draw(plot(0))
frame(wks)

;resP = True
;resP@gsnFrame = False
;      resP@gsnPanelBottom = 0.05
;resP@gsnPanelXWhiteSpacePercent = 0
;resP@gsnPanelYWhiteSpacePercent = 5
;resP@gsnPanelRowSpec = True
;   resP@txString = "Sea surface salinity"
;gsn_panel(wks, plot, (/1,1/), resP)

delete(wks)
system("eps2png_trim "+img)
