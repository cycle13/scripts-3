
; Description: depth of thermocline
;
;      Author: OU Yuyuan <ouyuyuan@lasg.iap.ac.cn>
;     Created: 2014-10-10 10:19:03 BJT
; Last Change: 2014-11-30 07:38:30 BJT

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

  nc = getenv("NCL_ARG_1")+"isothermal_line_depth.nc"
  img = getenv("NCL_ARG_2")+getenv("NCL_ARG_0_base")

  fontheight = 0.03
  cmap = "GMT_jet"
  wks = gsn_open_wks("eps", img)
  gsn_define_colormap(wks,cmap)

  f = addfile(nc, "r")
  isot = f->isot(60:119,{20},:,:)
  delete(f)
  cn = dim_avg_n_Wrap(isot, 0)
  cn = smth9(cn, 0.5, 0.25, False)

  plotWid = 0.9
  plotHei = 0.2
  colorbarWid = 0.6
  colorbarHei = 0.05
  texta = ""
  lbPosUp = 0.09
  lbPosRight = 0.2
  lbUnitPosX = 0.9
  lbUnitPosY = 0.4
  lbMinMaxInc = (/0,350,5/)

   res = True

  res@vpHeightF = plotHei
  res@vpWidthF = plotWid

   res@gsnDraw = False
   res@gsnFrame = False
   res@gsnSpreadColors      = True               ; use full color map
;   res@gsnSpreadColorStart  = 30                 ; start at color 17
;   res@gsnSpreadColorEnd    = 180
   res@gsnLeftString = ""
   res@gsnRightString = ""

   res@cnFillOn             = True               ; turn on color for contours
   res@cnLinesOn            = False              ; turn off contour lines
;   res@cnLineThicknessF = 0.5
   res@cnLineLabelsOn       = False              ; turn off contour line labels
   res@cnInfoLabelOn        = False      ; turns off contour info label
   res@cnLevelSelectionMode = "ManualLevels"
   res@cnMinLevelValF       = lbMinMaxInc(0)
   res@cnMaxLevelValF       = lbMinMaxInc(1)
   res@cnLevelSpacingF      = lbMinMaxInc(2)
;  res@cnMissingValFillColor = "gray60"
;   res@cnFillMode = "RasterFill"

   res@lbLabelBarOn = False

   res@tmLabelAutoStride = False
   res@tmYROn = False
   res@tmXTOn = False
   res@tmXBOn = False
   res@tmYLLabelFontHeightF = fontheight
   res@tmXBLabelFontHeightF = fontheight
  res@tmYLMode = "Explicit"
  res@tmYLValues = (/-20, 0, 20/)
  res@tmYLLabels = (/"20~S~o~N~S","EQ","20~S~o~N~N"/)

   res@mpShapeMode = "FreeAspect"
   res@mpMinLatF = -20
   res@mpMaxLatF = 20
   res@mpCenterLonF = 200

   res1 = res
   res2 = res

   plot = gsn_csm_contour_map(wks, cn, res1)

   resP = True
   resP@gsnFrame = False
;   resP@gsnPanelLabelBar = True
;      resP@gsnPanelBottom = 0.05
   resP@gsnPanelXWhiteSpacePercent = 5
   resP@gsnPanelYWhiteSpacePercent = 10
   resP@gsnPanelRowSpec = True

   resP@pmLabelBarWidthF = colorbarWid
   resP@pmLabelBarHeightF = colorbarHei
;   resP@pmLabelBarOrthogonalPosF = lbPosUp
;   resP@pmLabelBarParallelPosF = lbPosRight

;   resP@lbAutoManage = False
   resP@lbLabelFontHeightF = fontheight*0.8
;   resP@lbPerimOn   = True
;   resP@lbLabelAutoStride = True
   resP@lbLabelStride            = 5
;   resP@lbTitleString = "Verical mean sea salinity (psu)"
   resP@lbTitleFontHeightF = 0.013
   resP@lbBoxLinesOn = False
;   resP@lbLabelFontHeightF = 0.007
  resP@lbLabelPosition = "Top"

;   resP@txString = "Sea surface salinity"

   gsn_panel(wks, plot, (/1/), resP)

  txres               = True
  txres@txFontHeightF = fontheight
  text = texta
  gsn_text_ndc(wks, text, 0.3, 0.68, txres)
;  text = textb
;  gsn_text_ndc(wks, text, 0.3, 0.51, txres)
  text = "m"
;  gsn_text_ndc(wks, text, lbUnitPosX, lbUnitPosY, txres)

  delete(wks)
  system("eps2png_trim "+img)

end
