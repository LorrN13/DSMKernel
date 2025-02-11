

subroutine dcsymbdl(a,m,n,nn,eps,z,w,l,li,lj,ier)
  !**********************************************************************
  !  gauss method for a symmetric band matrix with a short width.       *
  !  this routine is for a vector computer.                             *
  !                                                                     *
  !  parameters:                                                        *
  !   on entry:                                                         *
  !     a      the array with dimension (m+1)*n which contains          *
  !            the lower band matrix in row-wise.                       *
  !     m      the half band width of the matrix a, excluding diadonals.*
  !     n      the order of the matrix a.                               *
  !     nn     the order of working arrays l, li, and lj.               *
  !     eps    the tolerance for pivotal elements.                      *
  !   on return:                                                        *
  !     a      the lower triangular matrix l after decomposition.       *
  !     ier    error code. if ier=0, normal return.                     *
  !   others: working parameters.                                       *
  !                                                                     *
  !  copyright:       fumiko nagahori    1 sep. 1991      ver. 1        *
  !**********************************************************************
  implicit none
  integer:: n,m,mm,nn
  integer:: l(nn),li(nn),lj(nn),ier
  real(kind(0d0)):: eps
  complex(kind(0d0)):: a((m+1)*n),z(m+1),w(m+1)
  integer:: i,j,k,ij,kk,nk,nkk,nki
  complex(kind(0d0)):: piv
  ! NF ignores if clauses
  ier = 0
  ij = 0
  do i=1,m
     ij = ij + 1
     li(ij) = i + 1
     lj(ij) = 2
     l(ij) = m * (i-1) + 1
     do j=i+1,m
	ij = ij + 1
	l(ij) = l(ij-1) + m + 1
	li(ij) = li(ij-1) + 1
	lj(ij) = lj(ij-1) + 1
     enddo
  enddo
  mm = (m+1) * m / 2
  do k=1,n-m
     nk = (m+1) * (k-1) + 1
     !if (zabs(a(nk+m)) .lt. eps) then
     !   print *, '(subr. symbdl) singular at step = ', k
     !   ier = 1
     !   return
     !endif
     piv = dcmplx(1.0d0) / a(nk+m)
     do j=2,m+1
	z(j) = - a(nk+m*j)
	w(j) =	 a(nk+m*j) * piv
   	a(nk+m*j) = w(j)
     enddo
     kk = nk + m + m
     !vortion vec
     do i=1,mm
   	a(kk+l(i)) = a(kk+l(i)) + w(lj(i)) * z(li(i))
     enddo
  enddo
  
  do k=n-m+1,n-1
     nk = (m+1) * (k-1) + 1
     nkk = (m+1) * k - 1
     !if (zabs(a(nk+m)) .lt. eps) then
     !   print *, '(subr. symbdl) singular at step = ', k
     !   ier = 1
     !   return
     !endif
     piv = dcmplx(1.0d0) / a(nk+m)
     do j=2,n-k+1
	z(j) = - a(nk+m*j)
	w(j) =	 a(nk+m*j) * piv
	a(nk+m*j) = w(j)
        
	nki = nkk + m * (j-1)
	do i=2,j
           a(nki+i) = a(nki+i) + w(j) * z(i)
        enddo
     enddo
  enddo
  return

end subroutine dcsymbdl


!

subroutine dcsbdlv(a,b,m,n,np,eps,z,ier)
  !**********************************************************************
  !  gauss method for a symmetric band matrix with a short width.       *
  !  this routine is for a vector computer.                             *
  !                                                                     *
  !  parameters:                                                        *
  !   on entry:                                                         *
  !     a      the array with dimension (m+1),n which contains          *
  !            the left hand side lower band matrix.                    *
  !     m      the half band width of the matrix a, excluding diadonals.*
  !     n      the order of the matrix a.                               *
  !     eps    the tolerance for pivotal elements.                      *
  !     b      right hand side vector                                   *
  !   on return:                                                        *
  !     b      solution.                                                *
  !     ier    error code. if ier=0, normal return.                     *
  !   others: working parameters.                                       *
  !                                                                     *
  !  copyright:       fumiko nagahori    1 sep. 1991      ver. 1        *
  !**********************************************************************
  implicit none
  integer:: m,n,np,ier
  real(kind(0d0)):: eps
  complex(kind(0d0)):: a(m+1,n),b(n),z(n)
  integer:: mm,j,k,i1
  complex(kind(0d0)):: sum

  !  forward substitution
  mm = m + 1
  if (mm .lt. 3) then
     z(np) = b(np)
     do j=np+1,n
        z(j) = b(j) - a(1,j) * z(j-1)
     enddo
     b(n) = z(n) / a(m+1,n)
  else
     z(np) = b(np)
     z(np+1) = b(np+1) - a(mm-1,np+1) * z(np)
     do j=np+2,n
        if (j .gt. np-1+mm) then
           i1 = 1
        else
           i1 = np-1+mm - j + 1
        endif
        sum = dcmplx(0.0d0)
        do k=i1,mm-1
           sum = sum + a(k,j) * z(j-mm+k)
        enddo
        z(j) = b(j) - sum
     enddo
    do j=n-1,n
       z(j) = z(j) / a(m+1,j)
    enddo
    b(n) = z(n)
    b(n-1) = z(n-1) - a(mm-1,n) * z(n)
 endif
 return
end subroutine dcsbdlv


subroutine mydcsbdlv3(a,b,n,z)
  implicit none
  integer, intent(in) :: n
  complex(kind(0d0)), dimension(4,n), intent(in) :: a
  complex(kind(0d0)), dimension(n), intent(inout) :: b
  complex(kind(0d0)), dimension(n), intent(out) :: z
  integer :: j,k,i1,j1
  complex(kind(0d0)):: sum

  z(1) = b(1)
  z(2) = b(2)-a(2,2)*z(1)
  do j = 3,n
    if (j>4) then
      i1 = 1
    else
      i1 = 4-j+1
    endif
    sum = dcmplx(0.0d0)
    do k = i1,3
      sum = sum+a(k,j)*z(j-4+k)
    enddo
    z(j) = b(j)-sum
  enddo
  do j = 1,n
    z(j) = z(j)/a(4,j)
  enddo
  b(n) = z(n)
  b(n-1) = z(n-1)-a(3,n)*z(n)
  do j = 3,n
    j1 = n-j+1
    i1 = 1
    if (j<4) i1 = 4-j+1
    sum = dcmplx(0.0d0)
    do k = i1,3
      sum = sum+a(k,4-k+j1)*b(4-k+j1)
    enddo
    b(j1) = z(j1)-sum
  enddo

  return
end subroutine mydcsbdlv3

subroutine mydcsbdlv1(a,b,n,z)
  implicit none
  integer, intent(in) :: n
  complex(kind(0d0)), dimension(2,n), intent(in) :: a
  complex(kind(0d0)), dimension(n), intent(inout) :: b
  complex(kind(0d0)), dimension(n), intent(out) :: z
  integer :: j

  z(1) = b(1)
  do j = 2,n
    z(j) = b(j)-a(1,j)*z(j-1)
  enddo
  do j = 1,n
    z(j) = z(j)/a(2,j)
  enddo
  b(n) = z(n)
  do j = 1,n-1
    b(n-j) = z(n-j)-a(1,n-j+1)*b(n-j+1)
  enddo

  return
end subroutine mydcsbdlv1


