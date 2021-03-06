#
# This file is part of the coreboot project.
#
# Copyright (C) 2012 secunet Security Networks AG
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#

ifeq ($(CONFIG_NORTHBRIDGE_INTEL_GM45),y)

bootblock-y += bootblock.c

romstage-y += early_init.c
romstage-y += early_reset.c
romstage-y += raminit.c
romstage-y += raminit_rcomp_calibration.c
romstage-y += raminit_receive_enable_calibration.c
romstage-y += raminit_read_write_training.c
romstage-y += pcie.c
romstage-y += thermal.c
romstage-y += igd.c
romstage-y += pm.c
romstage-y += memmap.c
romstage-y += iommu.c
romstage-y += romstage.c

ramstage-y += acpi.c

ramstage-y += memmap.c
ramstage-y += northbridge.c
ramstage-y += gma.c

postcar-y += memmap.c

endif
