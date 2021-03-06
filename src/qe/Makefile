# $Id$
#
# @Copyright@
#
# 				Rocks(r)
# 		         www.rocksclusters.org
# 		         version 7.0 (Manzanita)
#
# Copyright (c) 2000 - 2017 The Regents of the University of California.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
# notice unmodified and in its entirety, this list of conditions and the
# following disclaimer in the documentation and/or other materials provided
# with the distribution.
#
# 3. All advertising and press materials, printed or electronic, mentioning
# features or use of this software must display the following acknowledgement:
#
# 	"This product includes software developed by the Rocks(r)
# 	Cluster Group at the San Diego Supercomputer Center at the
# 	University of California, San Diego and its contributors."
#
# 4. Except as permitted for the purposes of acknowledgment in paragraph 3,
# neither the name or logo of this software nor the names of its
# authors may be used to endorse or promote products derived from this
# software without specific prior written permission.  The name of the
# software includes the following terms, and any derivatives thereof:
# "Rocks", "Rocks Clusters", and "Avalanche Installer".  For licensing of
# the associated name, interested parties should contact Technology
# Transfer & Intellectual Property Services, University of California,
# San Diego, 9500 Gilman Drive, Mail Code 0910, La Jolla, CA 92093-0910,
# Ph: (858) 534-5815, FAX: (858) 534-7345, E-MAIL:invent@ucsd.edu
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS''
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# @Copyright@

REDHAT.ROOT = $(CURDIR)/../../

-include $(ROCKSROOT)/etc/Rules.mk
include Rules.mk
include $(SDSCDEVEL)/Pull.mk
include $(SDSCDEVEL)/Rules.mk

$(NAME).spec: DESCRIPTION LICENSE

DESCRIPTION:
	$(MODULE_LOAD_CC); \
	( \
	  $(DESCRIBE_PKG); \
	  $(DESCRIBE_CC); \
	  $(DESCRIBE_MKL); \
	  $(DESCRIBE_MPI) \
	) > $@

LICENSE: $(SRC_DIRS)
	$(CHECK_LICENSE_FILES)
	echo GPLv2 > $@

SCALAPACK = yes
ifeq ("$(MPINAME)", "$(filter mvapich% intelmpi,$(MPINAME))")
SCALAPACK = intel
endif

COMPILE_FLAGS = -O2 -fopenmp
ifeq ("$(COMPILERNAME)","gnu")
  LDFLAGS = -lgomp
else ifeq ("$(COMPILERNAME)","intel")
  COMPILE_FLAGS = -O2 -xHOST -qopenmp
  LDFLAGS=-qopenmp
else ifeq ("$(COMPILERNAME)","pgi")
  COMPILE_FLAGS = -fast -mp
endif


build: $(SRC_DIRS)
	patch $(SOURCE_DIR)/environment_variables patch-files/environment_variables.patch
	perl -pi -e "s!ROLLPREFIX!$(PKGROOT)!" $(SOURCE_DIR)/environment_variables
	-cp $(ATOMIC_PKG) $(NEB_PKG) $(PHONON_PKG) $(PWCOND_PKG) \
	    $(TDDFPT_PKG) $(XSPECTRA_PKG) $(SOURCE_DIR)/archive/
	if test "$(MPINAME)" = "rocks-openmpi"; then \
          perl -pi -e "s!RUNASROOT!!" $(SOURCE_DIR)/environment_variables; \
	elif [[ "$(MPINAME)" =~ "openmpi" ]]; then \
          perl -pi -e "s!RUNASROOT!--allow-run-as-root!" $(SOURCE_DIR)/environment_variables; \
        else \
          perl -pi -e "s!RUNASROOT!!" $(SOURCE_DIR)/environment_variables; \
        fi

	( \
          $(MODULE_LOAD_CC); \
          $(MODULE_LOAD_MKL); \
          $(MODULE_LOAD_MPI); \
          export MKLLIB=$${MKLHOME}/lib/intel64; \
          export CC=mpicc; \
          export FC=mpif90; \
          export DFLAGS="-D__OPENMP -D__MPI -D__DFTI -D__PARA -D__SCALAPACK "; \
          export CFLAGS="$(COMPILE_FLAGS)"; \
          export FFLAGS="$(COMPILE_FLAGS)"; \
          export LDFLAGS="$(LDFLAGS) -L$${MKLLIB} -lmkl_rt -lpthread -lm"; \
          cd $(SOURCE_DIR); \
          ./configure --prefix=$(ROOT)/$(PKGROOT) \
              --with-scalapack=$(SCALAPACK) --enable-parallel; \
          $(MAKE) -j `/bin/nproc --ignore=2` all; \
          $(MAKE) -j `/bin/nproc --ignore=2` epw; \
          $(MAKE) gwl \
	)
	@echo "::: Package $(NAME) build complete :::"

install::
	mkdir -p -m 755 $(ROOT)/$(PKGROOT)
	mkdir -p -m 755 $(ROOT)/$(PKGROOT)/bin
	mkdir -p -m 755 $(ROOT)/$(PKGROOT)/tests
	mkdir -p -m 755 $(ROOT)/$(PKGROOT)/pseudo
	( \
          cp -r $(EXAMPLE_SOURCE_DIR)/NEB/* $(ROOT)/$(PKGROOT)/tests; \
          patch $(ROOT)/$(PKGROOT)/tests/check-neb.x.j patch-files/check-neb.x.j.patch; \
	  perl -pi -e "s!ROLLPREFIX!$(PKGROOT)!" $(ROOT)/$(PKGROOT)/tests/check-neb.x.j; \
	  cd $(SOURCE_DIR); \
	  cp bin/* $(ROOT)/$(PKGROOT)/bin; \
	  cp environment_variables $(ROOT)/$(PKGROOT)/tests; \
	  cp pseudo/* $(ROOT)/$(PKGROOT)/pseudo \
	)
	$(INSTALL_LICENSE_FILES)
	@echo "::: Package $(NAME) install complete :::"

clean::
	rm -rf $(SOURCE_DIR) $(EXAMPLE_SOURCE_DIR) DESCRIPTION LICENSE
