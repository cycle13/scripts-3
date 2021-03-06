
; Description:
;
;      Author: OU Yuyuan <ouyuyuan@lasg.iap.ac.cn>
;     Created: 2014-10-28 09:18:37 BJT
; Last Change: 2014-11-12 20:59:20 BJT

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

procedure draw_sec(img, inres, arg)
local res, nc, wks
begin
  cmap = "NCL_default"
  nc = getenv("NCL_ARG_1")
  fontheight = 0.03

  f = addfile(nc, "r")
  cn_p = f->$arg@cnNames(0)$
  cn_a = f->$arg@cnNames(1)$
  cn_i = f->$arg@cnNames(2)$
  delete(f)
  cn_p = smth9( cn_p, 0.5, 0.25, False )
  cn_a = smth9( cn_a, 0.5, 0.25, False )
  cn_i = smth9( cn_i, 0.5, 0.25, False )

  wks = gsn_open_wks ("eps", img)
  gsn_define_colormap(wks, cmap)

  res = True

  res@tiYAxisString = "depth (m)"
  res@tiXAxisString = "latitude"
  res@tiYAxisFontHeightF = fontheight*1.3
  res@tiMainFontHeightF = fontheight * 1.5

;  res@vpWidthF = 0.9
;  res@vpHeightF = 0.5
;  res@vpXF = 0.1

  res@gsnDraw = False
  res@gsnFrame = False
;  res@gsnScale = True
;  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorEnd    = 250
  if (cmap.eq."BlGrYeOrReVi200") then
    res@gsnSpreadColorEnd    = 180
  end if
  res@gsnLeftString = ""
  res@gsnRightString = ""
  res@gsnYAxisIrregular2Linear = True   ; converts irreg depth to linear 
  res@gsnLeftStringOrthogonalPosF = 0.03
  res@gsnRightStringOrthogonalPosF = 0.03

  res@cnFillOn             = True               ; turn on color for contours
;  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineThicknessF = 0.5
  res@cnLineLabelsOn       = False; turn off contour line labels
  res@cnInfoLabelOn        = False      ; turns off contour info label
  res@cnMissingValFillColor = "gray60"
;  symMinMaxPlt(cn, 50, False, res)
  if ( isatt(arg, "autolevels") .and. (arg@autolevels .eq. True) ) then
  else
    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMaxLevelValF       = arg@cnlevels(0)
    res@cnMinLevelValF       = arg@cnlevels(1)
    res@cnLevelSpacingF      = arg@cnlevels(2)
  end if
;  res@cnFillMode = "RasterFill"

  res@lbLabelBarOn = False
;  res@lbOrientation            = "Vertical"     ; vertical label bar
  res@lbPerimOn                = False             ; no box around it
;  res@lbBoxLinesOn = False
  ;   res@lbBoxLinesOn = False
  ;    res@lbLabelStride            = 4
  res@lbLabelFontHeightF = fontheight
  res@lbTitleString = "(~S~o~N~C)"
  res@lbTitlePosition = "top"
  res@lbTitleFontHeightF = fontheight*1.3

  ;    res@pmLabelBarDisplayMode    = "Always"          ; Turn on a label bar.
;  res@pmLabelBarWidthF = 0.8
;  res@pmLabelBarHeightF = 0.15
;  res@pmLabelBarOrthogonalPosF = 0.1

  res@tmLabelAutoStride = True
;  res@tmYROn = False
;  res@tmXTOn = False
  ;   res@tmYLMode = "Manual"
  ;   res@tmYLTickStartF    = 100.
  ;   res@tmYLTickSpacingF  = 100.
;  res@tmXBMode = "Explicit"
;  res@tmXBValues = (/140, 180, 220, 260/)
;  res@tmXBMinorValues =  ispan(140,280,20)
;  res@tmXBLabels = (/"140~S~o~N~E", "180~S~o", "140~S~o~N~W", "100~S~o~N~W"/)
  res@tmXBLabelFontHeightF = fontheight

;  res@tmYLMode = "Explicit"
;  res@tmYLValues = (/0, 100, 200, 300/)
;  res@tmYLMinorValues =  ispan(0,350,50)
;  res@tmYLLabels = res@tmYLValues
  res@tmYLLabelFontHeightF = fontheight

  res@trYMaxF = 3000.
;  res@trYMinF = 0.
  res@trYReverse               = True   ; reverses y-axis

  copy_VarAtts(inres, res)

  plot = new(3, graphic)
  res@tiMainString = "Pacific"
  res@trXMinF = -60.
  res@trXMaxF = 60.
  plot(0) = gsn_csm_contour(wks, cn_p, res)

  res@tiMainString = "Atlantic"
;  res@tmXBTickSpacingF  = 10.
  plot(1) = gsn_csm_contour(wks, cn_a, res)

  res@tiMainString = "Indian"
;  res@trXMaxF = 25.5
;  res@tmXBTickSpacingF  = 10.
  plot(2) = gsn_csm_contour(wks, cn_i, res)

  if (isatt(arg, "add_20deg_line").and.(arg@add_20deg_line .eq. True)) then
     sres = True
     sres@tiMainString = ""
     sres@cnFillOn             = False
     sres@cnLinesOn            = True
     sres@cnLevelSelectionMode = "ExplicitLevels"
     sres@cnLevels = (/20/)
     sres@cnLineThicknessF = 2.0
;     sres@cnLineLabelsOn       = True
     sres@cnLineColor = "black"

     copy_VarAtts(sres, res)
     plot_ov = gsn_csm_contour(wks, cn_p, res)
     overlay(plot(0), plot_ov)
     plot_ov = gsn_csm_contour(wks, cn_a, res)
     overlay(plot(1), plot_ov)
     plot_ov = gsn_csm_contour(wks, cn_i, res)
     overlay(plot(2), plot_ov)
  end if

   resP = True
   resP@txString = arg@panel_title

   resP@gsnFrame = False
   resP@gsnPanelLabelBar = True
;      resP@gsnPanelBottom = 0.05
   resP@gsnPanelXWhiteSpacePercent = 5
   resP@gsnPanelYWhiteSpacePercent = 5
   resP@gsnPanelRowSpec = True

   resP@pmLabelBarWidthF = 0.8
   resP@pmLabelBarHeightF = 0.07
   resP@pmLabelBarOrthogonalPosF = -0.01

;   resP@lbAutoManage = False
   resP@lbLabelFontHeightF = 0.013
   resP@lbPerimOn                = False             ; no box around it
;   resP@lbLabelAutoStride = True
;   resP@lbLabelStride            = 5
;   resP@lbTitleString = "Verical mean sea salinity (psu)"
   resP@lbTitleFontHeightF = 0.013
;   resP@lbBoxLinesOn = False
  resP@lbTitleString = "(~S~o~N~C)"
  resP@lbTitlePosition = "bottom"

   gsn_panel(wks, plot, (/3/), resP)
;  draw(plot)
;  frame(wks)

  delete(wks)
  system("eps2png_trim " + img)
end

img = getenv("NCL_ARG_2")

arg = True
arg@add_20deg_line = True

res = True
res@trYMaxF = 600.

; control run
;======================================
arg@cnlevels = (/28.,2.,2./)
arg@cnNames = (/"control_p","control_a","control_i"/)
arg@panel_title = "Potential Temperature at meridional section, control run"
;draw_sec(img+"___ctr", res, arg)

; experiment run
;======================================
arg@cnNames = (/"ex_60S60N_p","ex_60S60N_a","ex_60S60N_i"/)
arg@panel_title = "Potential Temperature at meridional section, exp_60S-60N"
draw_sec(img+"___60S60N", res, arg)
