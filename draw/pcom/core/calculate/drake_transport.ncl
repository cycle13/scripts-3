
; Description: Drake passage transport trend
;
;      Author: OU Yuyuan <ouyuyuan@lasg.iap.ac.cn>
;     Created: 2014-10-09 08:13:34 BJT
; Last Change: 2014-11-02 21:13:38 BJT

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; assume value is on the center of each layer, 
;  and the dimensions are {depth, lat}
undef("cal_sec_tran")
function cal_sec_tran(var:numeric)
;{{{
local nlev, dlev, tran, lat, nlat, torad, lev
begin

  r = 6371220.0 ; meters
  torad = 3.14159265 / 180

  lev = var&$var!0$
  lat = var&$var!1$ * torad

  nlev = dimsizes(lev)

  if (lev(0)-0 .lt. 1e-6) then
     print("the first layer is zero, stop.")
     return
  end if

  dlev = lev*0
  dlev(0) = lev(0) * 2
  do i = 1, nlev - 1
    dlev(i) = (lev(i) - sum(dlev)) * 2
    if (dlev(i) .lt. 0) then
      print("thickness of layer is not positive! stop.")
      return
    end if
  end do
;   print(dlev+0)

  nlat = dimsizes(lat)
  dy = lat * 0
  dy(1:nlat-2)  = abs(lat(2:nlat-1)-lat(0:nlat-3))*0.5 * r   
  dy(0) = dy(1)
  dy(nlat-1) = dy(nlat-2)

  area = conform(var, dlev, 0) * conform(var, dy, 1)
  area = where( ismissing(var), 0, area)

  tran = sum(area * var * 1e-6)

 return tran
;}}}
end

begin

  data_dir = "/home/ou/archive/data/pcom/moc_re_s/"
  outfile = getenv("NCL_ARG_1")

  nyear  = 500
;  nyear  = 5
  lat1 = -68.5
  lat2 = -54.5
  lon = 292.5

  do yr = 1, nyear
    fname = sprinti( "year_%0.4i.nc", yr )
    f = addfile( data_dir + fname, "r")
    u = f->u(0,:,{lat1:lat2},{lon})
    delete(f)
    if (yr .eq. 1) then
      tran = new( nyear+1, typeof(u) )
    end if
    print("Calculate " + fname)
    tran(yr) = cal_sec_tran( u )
  end do

  time = ispan(0, nyear, 1)
  time@units = "years since PCOM initial run"
  tran!0 = "x"
  tran&x = time
  tran@long_name = "Drake passage transport"
  tran@units = "Sv"

  system("rm -f " + outfile)
  f = addfile(outfile, "c")
  f->y = tran
  f@data = "Drake passage transport of PCOM"
  f@source = "create by " + systemfunc("pwd") + "/" + getenv("NCL_ARG_0") + \
  ", " + systemfunc("date")

end
