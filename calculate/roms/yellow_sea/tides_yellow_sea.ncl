
; Description: create tides forcing field 
;
;      Author: OU Yuyuan <ouyuyuan@lasg.iap.ac.cn>
;     Created: 2014-07-23 08:28:47 BJT
; Last Change: 2014-08-18 21:31:00 BJT

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/ou/archive/scripts/utils/ncl.ncl"

begin

  ncgen = True

;  cfsr_dir = "/media/DAT_OCN/HYCOM/force/ncep_cfsr/netcdf/"
  cfsr_dir = "/home/ou/archive/data/roms/latte/cfsr/"
  out_dir = "/home/ou/archive/models/roms/roms_734/Apps/yellow_sea/in/"
  nc_grid = out_dir + "yellow_sea_grid.nc"

  f = addfile(nc_grid, "r")
  lat2d = f->lat_rho
  lon2d = f->lon_rho
  delete(f)

  vname_roms = "Tair"
  vname_cfsr = "airtmp"
  nc_cfsr = cfsr_dir + "sea_2006_01hr_TaqaQrQp_box.nc"
;  vname_cfsr = "surtmp"
;  nc_cfsr = cfsr_dir + "sea_2006_01hr_surtmp_box.nc"

  date_b = "2006-04-05 00:00:00"
  date_e = "2006-04-30 23:00:00"

  print( "Extract " + vname_cfsr + " from CFSR dataset ...")
  f = addfile( nc_cfsr, "r")
  lat = f->Latitude(:)
  lon = f->Longitude(:)
  t_cfsr = f->time(:)

  tsta = ou_timestring2i(date_b, t_cfsr)
  tend = ou_timestring2i(date_e, t_cfsr)
  tmp = f->$vname_cfsr$(tsta:tend,:,:)
  delete(f)

  var_cfsr = new(dimsizes(tmp), double)
  var_cfsr = tmp*tmp@scale_factor + tmp@add_offset
  delete(tmp)

  cdl = "frc_cfsr_" + vname_roms + ".cdl"
  nc_out = out_dir + "frc_cfsr_" + vname_roms + ".nc"

  if (ncgen) then
    cmd = "ncgen -o " + nc_out + " " + cdl
    print(cmd+"")
    system(cmd)
  end if

  f = addfile( nc_out, "r")
  tunits = f->time@units
  delete(f)
  t_roms = cd_convert( t_cfsr, tunits )

  f = addfile( nc_out, "w")
  f->time@begin_date = date_b
  f->time@end_date = date_e
  f@source = "create by frc_cfsr.ncl from NCEP_CFSR dataset, " + \
  systemfunc("date")

  print( "Interpolate " + vname_cfsr + " from CFSR to roms " + \
  vname_roms + " ..." )
  lon = where( lon.gt.180.0, lon-360.0, lon )
  v_roms = rgrid2rcm( lat, lon, var_cfsr, lat2d, lon2d, 0)
  f->$vname_roms$ = (/v_roms/)
  f->time = (/t_roms(tsta:tend)/)
end
