/*
 * This file is part of the coreboot project.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */

#include <console/console.h>
#include <commonlib/helpers.h>
#include <spi_flash.h>
#include <spi-generic.h>
#include <string.h>

#include "spi_flash_internal.h"

/* M25Pxx-specific commands */
#define CMD_AT25_WREN		0x06	/* Write Enable */
#define CMD_AT25_WRDI		0x04	/* Write Disable */
#define CMD_AT25_RDSR		0x05	/* Read Status Register */
#define CMD_AT25_WRSR		0x01	/* Write Status Register */
#define CMD_AT25_READ		0x03	/* Read Data Bytes */
#define CMD_AT25_FAST_READ	0x0b	/* Read Data Bytes at Higher Speed */
#define CMD_AT25_PP			0x02	/* Page Program */
#define CMD_AT25_SE			0x20	/* Sector (4K) Erase */
#define CMD_AT25_BE			0xd8	/* Block (64K) Erase */
#define CMD_AT25_CE			0xc7	/* Chip Erase */
#define CMD_AT25_DP			0xb9	/* Deep Power-down */
#define CMD_AT25_RES		0xab	/* Release from DP, and Read Signature */

struct atmel_spi_flash_params {
	uint16_t	id;
	/* Log2 of page size in power-of-two mode */
	uint8_t		l2_page_size;
	uint16_t	pages_per_sector;
	uint16_t	sectors_per_block;
	uint16_t	nr_blocks;
	const char	*name;
};

static const struct atmel_spi_flash_params atmel_spi_flash_table[] = {
	{
		.id			= 0x3015,
		.l2_page_size		= 8,
		.pages_per_sector	= 16,
		.sectors_per_block	= 16,
		.nr_blocks		= 32,
		.name			= "AT25X16",
	},
	{
		.id			= 0x47,
		.l2_page_size		= 8,
		.pages_per_sector	= 16,
		.sectors_per_block	= 16,
		.nr_blocks		= 64,
		.name			= "AT25DF32",
	},
	{
		.id			= 0x3017,
		.l2_page_size		= 8,
		.pages_per_sector	= 16,
		.sectors_per_block	= 16,
		.nr_blocks		= 128,
		.name			= "AT25X64",
	},
	{
		.id			= 0x4015,
		.l2_page_size		= 8,
		.pages_per_sector	= 16,
		.sectors_per_block	= 16,
		.nr_blocks		= 32,
		.name			= "AT25Q16",
	},
	{
		.id			= 0x4016,
		.l2_page_size		= 8,
		.pages_per_sector	= 16,
		.sectors_per_block	= 16,
		.nr_blocks		= 64,
		.name			= "AT25Q32",
	},
	{
		.id			= 0x4017,
		.l2_page_size		= 8,
		.pages_per_sector	= 16,
		.sectors_per_block	= 16,
		.nr_blocks		= 128,
		.name			= "AT25Q64",
	},
	{
		.id			= 0x4018,
		.l2_page_size		= 8,
		.pages_per_sector	= 16,
		.sectors_per_block	= 16,
		.nr_blocks		= 256,
		.name			= "AT25Q128",
	},
};

static const struct spi_flash_ops spi_flash_ops = {
	.write = spi_flash_cmd_write_page_program,
	.erase = spi_flash_cmd_erase,
};

int spi_flash_probe_atmel(const struct spi_slave *spi, u8 *idcode,
			  struct spi_flash *flash)
{
	const struct atmel_spi_flash_params *params;
	unsigned int i;

	for (i = 0; i < ARRAY_SIZE(atmel_spi_flash_table); i++) {
		params = &atmel_spi_flash_table[i];
		if (params->id == ((idcode[1] << 8) | idcode[2]))
			break;
	}

	if (i == ARRAY_SIZE(atmel_spi_flash_table)) {
		printk(BIOS_WARNING, "SF: Unsupported Atmel ID %02x%02x\n",
				idcode[1], idcode[2]);
		return -1;
	}

	memcpy(&flash->spi, spi, sizeof(*spi));
	flash->name = params->name;

	/* Assuming power-of-two page size initially. */
	flash->page_size = 1 << params->l2_page_size;
	flash->sector_size = flash->page_size * params->pages_per_sector;
	flash->size = flash->sector_size * params->sectors_per_block *
			params->nr_blocks;
	flash->erase_cmd = CMD_AT25_SE;
	flash->pp_cmd = CMD_AT25_PP;
	flash->wren_cmd = CMD_AT25_WREN;

	flash->ops = &spi_flash_ops;

	return 0;
}
