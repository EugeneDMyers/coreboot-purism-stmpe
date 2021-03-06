##
## This file is part of the coreboot project.
##
## Copyright 2018 Google LLC
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; version 2 of the License.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##

## GPP_F12-F16 indicates mem_id to match specific spd file
SPD_SOURCES = empty_ddr4			# 0b00000

bootblock-y += gpio.c
ramstage-y += gpio.c
romstage-y += gpio.c
verstage-y += gpio.c

ramstage-y += sku.c
