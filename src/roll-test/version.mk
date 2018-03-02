NAME       = sdsc-qe-roll-test
VERSION    = 2
RELEASE    = 1
PKGROOT    = /root/rolltests

RPM.EXTRAS = AutoReq:No\nAutoProv:No\nObsoletes: qe-roll-test
RPM.FILES  = $(PKGROOT)/qe.t
