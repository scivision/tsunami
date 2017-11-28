program tsunami
use iso_fortran_env, only: int32, real32

implicit none

integer(kind=int32) :: i, n

integer(kind=int32), parameter :: im = 100
integer(kind=int32), parameter :: nm = 100

real(kind=real32), parameter :: dt = 1
real(kind=real32), parameter :: dx = 1
real(kind=real32), parameter :: c = 1

real(kind=real32), dimension(im) :: du, u

end program tsunami
