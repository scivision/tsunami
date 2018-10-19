module mod_field

  ! Provides the Field class and its methods.

  use mod_kinds, only: ik, rk
  use mod_parallel, only: tile_indices, tile_neighbors_2d
  implicit none

  private
  public :: Field

  type :: Field
    character(:), allocatable :: name
    integer(ik) :: lb(2), ub(2)
    integer(ik) :: neighbors(4)
    integer(ik) :: edge_size
    real(rk), allocatable :: data(:,:)
  contains
    procedure, private, pass(self) :: assign_array, assign_const_int, assign_const_real
    procedure, public, pass(self) :: init_gaussian
    procedure, public, pass(self) :: sync_edges
    generic :: assignment(=) => assign_array, assign_const_int, assign_const_real
  end type Field

  interface Field
    module procedure :: field_constructor
  end interface Field

contains

  type(Field) function field_constructor(name, dims) result(self)
    character(*), intent(in) :: name ! field name
    integer(ik), intent(in) :: dims(2) ! domain size in x and y
    integer(ik) :: edge_size, indices(4)
    self % name = name
    indices = tile_indices(dims)
    self % lb = indices([1, 3])
    self % ub = indices([2, 4])
    allocate(self % data(self % lb(1)-1:self % ub(1)+1,&
                         self % lb(2)-1:self % ub(2)+1))
    self % data = 0
    self % neighbors = tile_neighbors_2d(periodic=.true.)
    self % edge_size = max(self % ub(1)-self % lb(1)+1,&
                           self % ub(2)-self % lb(2)+1)
    call co_max(self % edge_size)
  end function field_constructor

  pure subroutine assign_array(self, a)
    class(Field), intent(in out) :: self
    real(rk), intent(in) :: a(:,:)
    self % data = a
  end subroutine assign_array

  !TODO this doesn't seem to overload assignment on gfortran-8.2.0
  !TODO check with other compilers
  pure subroutine assign_const_int(self, a)
    class(Field), intent(in out) :: self
    integer(rk), intent(in) :: a
    self % data = a
  end subroutine assign_const_int

  pure subroutine assign_const_real(self, a)
    class(Field), intent(in out) :: self
    real(rk), intent(in) :: a
    self % data = a
  end subroutine assign_const_real

  pure subroutine init_gaussian(self, decay, ic, jc)
    class(Field), intent(in out) :: self
    real(rk), intent(in) :: decay ! the rate of decay of gaussian
    integer(ik), intent(in) :: ic, jc ! center indices of the gaussian blob
    integer(ik) :: i, j
    do concurrent(i = self % lb(1)-1:self % ub(1)+1,&
                  j = self % lb(2)-1:self % ub(2)+1)
      self % data(i, j) = exp(-decay * ((i - ic)**2 + (j - jc)**2))
    end do
  end subroutine init_gaussian

  subroutine sync_edges(self)
    class(Field), intent(in out) :: self
    real(rk), allocatable :: edge(:,:)[:]
    integer(ik) :: is, ie, js, je

    is = self % lb(1)
    ie = self % ub(1)
    js = self % lb(2)
    je = self % ub(2)

    if (.not. allocated(edge)) allocate(edge(self % edge_size, 4)[*])
    edge = 0

    !sync images(neighbors) !TODO currently fails with OpenCoarrays-2.2.0
    sync all

    ! copy data into coarray buffer
    edge(1:je-js+1,1)[self % neighbors(1)] = self % data(is,js:je) ! send left
    edge(1:je-js+1,2)[self % neighbors(2)] = self % data(ie,js:je) ! send right
    edge(1:ie-is+1,3)[self % neighbors(3)] = self % data(is:ie,js) ! send down
    edge(1:ie-is+1,4)[self % neighbors(4)] = self % data(is:ie,je) ! send up

    !sync images(neighbors) !TODO currently fails with OpenCoarrays-2.2.0
    sync all

    ! copy from halo buffer into array
    self % data(is-1,js:je) = edge(1:je-js+1,2) ! from left
    self % data(ie+1,js:je) = edge(1:je-js+1,1) ! from right
    self % data(is:ie,js-1) = edge(1:ie-is+1,4) ! from down
    self % data(is:ie,je+1) = edge(1:ie-is+1,3) ! from up

    deallocate(edge)

  end subroutine sync_edges

end module mod_field
