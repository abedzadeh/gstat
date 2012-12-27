R		= RKG_CPPFLAGS='-Wall -std=gnu99' R

default:
	make build install

nv:
	make nvbuild install

install:
	$(R) CMD INSTALL gstat_*gz

check:
	rm -f gstat_*tar.gz
	make build
	$(R) CMD check --as-cran gstat_*tar.gz

build:
	# make cl
	_R_BUILD_RESAVE_DATA_=best _R_BUILD_COMPACT_VIGNETTES_=qpdf $(R) CMD build pkg --force --resave-data

nvbuild:
	$(R) CMD build --no-vignettes pkg --force

cl:
	svn2cl > ChangeLog
	cat ChangeLog pkg/inst/ChangeLog0 > pkg/inst/ChangeLog

valgrind:
	(cd gstat.Rcheck; R_LIBS=/home/edzer/S/library R -d "valgrind --tool=memcheck --leak-check=yes --show-reachable=yes" --vanilla < gstat-Ex.R > valgrind.out 2>&1)
