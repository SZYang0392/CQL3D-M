! PGPLOT stub routines for CQL3D Windows builds
! Provides dummy implementations so cql3d compiles without the PGPLOT library.
! Plotting output is disabled; computation results are unaffected.
! Based on genray/pgplot_stubs.f90, extended with CQL3D-specific stubs.

integer function pgopen(device)
  character*(*) device
  pgopen = 1
  return
end function pgopen

subroutine pgclos
  return
end subroutine pgclos

subroutine pgpage
  return
end subroutine pgpage

subroutine pgend
  return
end subroutine pgend

subroutine pgsvp(xleft, xright, ybot, ytop)
  real xleft, xright, ybot, ytop
  return
end subroutine pgsvp

subroutine pgswin(x1, x2, y1, y2)
  real x1, x2, y1, y2
  return
end subroutine pgswin

subroutine pgbox(xopt, xtick, nxsub, yopt, ytick, nysub)
  character*(*) xopt, yopt
  real xtick, ytick
  integer nxsub, nysub
  return
end subroutine pgbox

subroutine pglab(xlab, ylab, toplab)
  character*(*) xlab, ylab, toplab
  return
end subroutine pglab

subroutine pgcont(a, idim, jdim, i1, i2, j1, j2, c, nc, tr)
  integer idim, jdim, i1, i2, j1, j2, nc
  real a(idim,jdim), c(*), tr(6)
  return
end subroutine pgcont

subroutine pgconl(a, idim, jdim, i1, i2, j1, j2, c, tr, label, intval, minint)
  integer idim, jdim, i1, i2, j1, j2, intval, minint
  real a(idim,jdim), c, tr(6)
  character*(*) label
  return
end subroutine pgconl

subroutine pgmtxt(side, disp, coord, fjust, text)
  character*(*) side, text
  real disp, coord, fjust
  return
end subroutine pgmtxt

subroutine pgsci(ci)
  integer ci
  return
end subroutine pgsci

subroutine pgsls(ls)
  integer ls
  return
end subroutine pgsls

subroutine pgline(n, xpts, ypts)
  integer n
  real xpts(n), ypts(n)
  return
end subroutine pgline

subroutine pgslw(lw)
  integer lw
  return
end subroutine pgslw

subroutine pgsch(sz)
  real sz
  return
end subroutine pgsch

subroutine pgenv(xmin, xmax, ymin, ymax, just, axis)
  real xmin, xmax, ymin, ymax
  integer just, axis
  return
end subroutine pgenv

subroutine pgpt(x, y, symbol)
  real x, y
  integer symbol
  return
end subroutine pgpt

subroutine pgtext(x, y, text)
  real x, y
  character*(*) text
  return
end subroutine pgtext

! Additional PGPLOT stubs needed by CQL3D

subroutine pgarro(x1, y1, x2, y2)
  real x1, y1, x2, y2
  return
end subroutine pgarro

subroutine pgconx(a, idim, jdim, i1, i2, j1, j2, c, nc, plot, tr)
  integer idim, jdim, i1, i2, j1, j2, nc
  real a(idim,jdim), c(*), tr(6)
  external plot
  return
end subroutine pgconx

subroutine pgctab(l, r, g, b, nc, contra, bright)
  integer nc
  real l(nc), r(nc), g(nc), b(nc), contra, bright
  return
end subroutine pgctab

subroutine pgdraw(x, y)
  real x, y
  return
end subroutine pgdraw

subroutine pgimag(a, idim, jdim, i1, i2, j1, j2, a1, a2, tr)
  integer idim, jdim, i1, i2, j1, j2
  real a(idim,jdim), a1, a2, tr(6)
  return
end subroutine pgimag

subroutine pgmove(x, y)
  real x, y
  return
end subroutine pgmove

subroutine pgpt1(x, y, symbol)
  real x, y
  integer symbol
  return
end subroutine pgpt1

subroutine pgptxt(x, y, angle, fjust, text)
  real x, y, angle, fjust
  character*(*) text
  return
end subroutine pgptxt

subroutine pgqcir(ci1, ci2)
  integer ci1, ci2
  ci1 = 0
  ci2 = 15
  return
end subroutine pgqcir

subroutine pgqinf(item, value, length)
  character*(*) item, value
  integer length
  value = ' '
  length = 0
  return
end subroutine pgqinf

subroutine pgsah(sa, angle, barb)
  integer sa
  real angle, barb
  return
end subroutine pgsah

subroutine pgsave
  return
end subroutine pgsave

subroutine pgunsa
  return
end subroutine pgunsa

subroutine pgwedg(side, disp, width, fg, bg, label)
  character*(*) side, label
  real disp, width, fg, bg
  return
end subroutine pgwedg

subroutine pgwnad(x1, x2, y1, y2)
  real x1, x2, y1, y2
  return
end subroutine pgwnad
