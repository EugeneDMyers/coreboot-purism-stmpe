/*
 * This file is part of the coreboot project.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * Originally imported from linux/include/asm-arm/io.h. This file has changed
 * substantially since then.
 */

#ifndef __ARCH_MMIO_H__
#define __ARCH_MMIO_H__

#include <endian.h>
#include <stdint.h>

static inline uint8_t read8(const void *addr)
{
	return *(volatile uint8_t *)addr;
}

static inline uint16_t read16(const void *addr)
{
	return *(volatile uint16_t *)addr;
}

static inline uint32_t read32(const void *addr)
{
	return *(volatile uint32_t *)addr;
}

static inline void write8(void *addr, uint8_t val)
{
	*(volatile uint8_t *)addr = val;
}

static inline void write16(void *addr, uint16_t val)
{
	*(volatile uint16_t *)addr = val;
}

static inline void write32(void *addr, uint32_t val)
{
	*(volatile uint32_t *)addr = val;
}

#endif /* __ARCH_MMIO_H__ */
