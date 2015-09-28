
! Description: 
!
!      Author: OU Yuyuan <ouyuyuan@lasg.iap.ac.cn>
!     Created: 2013-04-20 19:56:27 CST
! Last Change: 2013-05-13 06:25:41 CST

module io_mod

    use basic_mod, only: lat_min, lon_min, dlat, dlon, pi, nx, ny, total, &
        z, u, v, ek, div, vor, ens, pvor, pens, mean, z_ncep
    use mod_type, only: dict, type_nc, type_var
    use mod_io, only: mod_io_create, mod_io_write, mod_io_read
    
    implicit none
    private
    
    public init_io, output_field, read_ncep

    character(len = *), parameter :: data_dir = "/snfs01/ou/models/gpem/data"
    character(len = *), parameter :: foutname = data_dir // "/gpem.nc"
    character(len = *), parameter :: finname  = data_dir // "/ncep_z.nc"
    integer, parameter :: nvar = 17
    real, dimension(nx, ny), target :: z_a, u_a, v_a

    type :: io_total_scalar
        real, dimension(1,1) :: mass, ek, ep, div, vor, ens, pvor, pens
    end type io_total_scalar
    type(io_total_scalar), target :: io_total

    type(type_nc) :: model
    type(type_var) :: netcdf_vars(nvar)

contains

    ! init. I/O <<<1

    subroutine init_io

        type(dict), dimension(2), target :: ncfile_attrs

        ncfile_attrs = (/ &
            dict("title", "zuv of gpem"), & 
            dict("souce", "output of gpem") &
        /)

        model%lat_min = lat_min * 180 / pi
        model%lon_min = lon_min * 180 / pi
        model%dlat    = dlat * 180 / pi
        model%dlon    = dlon * 180 / pi
        model%nlats   = ny
        model%nlons   = nx
        model%pattrs  => ncfile_attrs

        netcdf_vars = (/ &
            type_var("ph", "potential height", "m", z_a), &
            type_var("u", "zonal wind", "m/s", u_a), &
            type_var("v", "meridianal wind", "m/s", v_a), &
            type_var("ek", "kinectic energy", "J", ek), &
            type_var("div", "divergence", "", div), &
            type_var("vor", "vorticity", "", vor), &
            type_var("ens", "enstrophy", "", ens), &
            type_var("pvor", "potential vorticity", "", pvor), &
            type_var("pens", "potential enstrophy", "", pens), & 
            type_var("total_mass", "total mass", "", io_total%mass), & 
            type_var("total_ek", "total ek", "", io_total%ek), & 
            type_var("total_ep", "total ep", "", io_total%ep), & 
            type_var("total_div", "total div", "", io_total%div), & 
            type_var("total_vor", "total vor", "", io_total%vor), & 
            type_var("total_ens", "total ens", "", io_total%ens), & 
            type_var("total_pvor", "total pvor", "", io_total%pvor), & 
            type_var("total_pens", "total pens", "", io_total%pens) &
        /)

        call mod_io_create(foutname, model, netcdf_vars)

    end subroutine init_io

    ! output var. <<<1

    subroutine output_field

        io_total%mass = total%mass
        io_total%ek   = total%ek
        io_total%ep   = total%ep
        io_total%div  = total%div
        io_total%vor  = total%vor
        io_total%ens  = total%ens
        io_total%pvor = total%pvor
        io_total%pens = total%pens

        z_a = z
        u_a = mean(u, 'xh')
        v_a = mean(v, 'yh')

        call mod_io_write(foutname, netcdf_vars)

    end subroutine output_field

    ! input var. <<<1

    subroutine read_ncep

        call mod_io_read(finname, 'z', z_ncep)

    end subroutine read_ncep

end module io_mod
