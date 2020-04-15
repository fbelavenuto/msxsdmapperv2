/*
Copyright (c) 2017 FBLabs

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "conio.h"
#include "strings.h"
#include "mem.h"
#include "bios.h"
#include "mapper.h"
#include "interface.h"

/* Constants */
//const unsigned char *CUR_BANK = (volatile unsigned char *)0x40FF;	// current bank

const char *title1 =			"FBLabs SDXC programmer utility\r\n";
const char *usage2 =			"     fbl-upd /opts <filename.ext>\r\n"
								"Example: fbl-upd DRIVER.ROM\r\n"
								"         fbl-upd /e\r\n";
static const char *found =		"Found SDXC interface";

/* Variables */
static int i;
static unsigned char c, t1, t2;
static unsigned char flashIdMan, flashIdProd, alg;
static unsigned char mySlot;
static unsigned char *source, *dest;

/* Private Functions */

/******************************************************************************/
static unsigned char flashIdent(unsigned char manId, unsigned char prodId)
{
	if (manId == 0x01) {				// AMD
		if (prodId == 0x20) {			// AM29F010
			alg = ALGBYTE;
			return 1;
		}
	} else if (manId == 0x1F) {			// Atmel
		if (prodId == 0x07) {			// AT49F002
			alg = ALGBYTE;
			return 1;
		} else if (prodId == 0x08) {	// AT49F002T
			alg = ALGBYTE;
			return 1;
		} else if (prodId == 0x17) {	// AT49F010
			alg = ALGBYTE;
			return 1;
		} else if (prodId == 0xD5) {	// AT29C010 (page)
			alg = ALGPAGE;
			return 1;
		}
	} else if (manId == 0xBF) {			// SST
		if (prodId == 0x07) {			// SST29EE010 (page)
			alg = ALGPAGE;
			return 1;
		} else if (prodId == 0xB5) {	// SST39SF010A
			alg = ALGBYTE;
			return 1;
		} else if (prodId == 0xB6) {	// SST39SF020
			alg = ALGBYTE;
			return 1;
		}
	} else if (manId == 0xDA) {			// Winbond
		if (prodId == 0x0B) {			// W49F002UN
			alg = ALGBYTE;
			return 1;
		} else if (prodId == 0x25) {	// W49F002B
			alg = ALGBYTE;
			return 1;
		} else if (prodId == 0xA1) {	// W39F010
			alg = ALGBYTE;
			return 1;
		}
	}
	return 0;
}

/******************************************************************************/
static void flashSendCmd(unsigned char cmd)
{
	poke(0x7000, 0x09);		// Bank 1 in the Frame-2 (4000-7FFF)
	poke(0x9555, 0xAA);		// Absolute address 0x05555
	poke(0x7000, 0x08);		// Bank 0 in the Frame-2 (0000-3FFF)
	poke(0xAAAA, 0x55);		// Absolute address 0x02AAA
	poke(0x7000, 0x09);		// Bank 1 in the Frame-2 (4000-7FFF)
	poke(0x9555, cmd);
}

/******************************************************************************/
static void flashEraseSectorSendCmd(unsigned char sector)
{
	poke(0x7000, 0x09);		// Bank 1 in the Frame-2 (4000-7FFF)
	poke(0x9555, 0xAA);		// Absolute address 0x05555
	poke(0x7000, 0x08);		// Bank 0 in the Frame-2 (0000-3FFF)
	poke(0xAAAA, 0x55);		// Absolute address 0x02AAA
	poke(0x7000, 0x08 | (sector >> 2));		// Bank x in the Frame-2
	poke(0x8000 | ((sector & 0x03) << 12), FLASHCMD_ERASESECTOR);
}


/******************************************************************************/
static unsigned char writeHalfBlock(unsigned char bank)
{
	putSlotFrame1(mySlot);
	putSlotFrame2(mySlot);
	t1 = 0;
	source = (unsigned char *)0x2000;
	while ((unsigned int)source < 0x4000) {
		flashSendCmd(FLASHCMD_WRITEBYTE);
		poke(0x7000, bank | 0x08);
		if (alg == ALGBYTE) {
			*dest = *source;			// write byte
		} else {
			for (i = 0; i < 127; i++) {	// write 128-byte
				*dest = *source;
				++dest;
				++source;
			}
			*dest = *source;
		}
		i = 3800;
		while (--i != 0) {
			if (*dest == *source) {		// toggle bit, if equal byte was written
				break;
			}
		}
		if (i == 0) {					// timeout
			t1 = 1;						// error
			goto exit;
		}
		++dest;
		++source;
	}
exit:
	putRamFrame1();
	putRamFrame2();
	return t1;
}


/* Public Functions */

/******************************************************************************/
unsigned char detectInterface(unsigned char slot)
{
	__asm__("di");
	putSlotFrame1(slot);
	putSlotFrame2(slot);
//	flashSendCmd(FLASHCMD_SOFTRESET);
	flashSendCmd(FLASHCMD_SOFTIDENTRY);
	flashIdMan = peek(0x8000);
	flashIdProd = peek(0x8001);
	flashSendCmd(FLASHCMD_SOFTRESET);
	putRamFrame1();
	putRamFrame2();
	__asm__("ei");
//	puthex8(flashIdMan); puts(" ");
//	puthex8(flashIdProd); puts("\r\n");
	if (flashIdent(flashIdMan, flashIdProd) == 1) {
/*		__asm__("halt");
		__asm__("di");
		putSlotFrame1(slot);
		poke(0x7FF1, 0xAA);				// Initialize timer
		c = peek(0x7FF1);				// Timer register
		putRamFrame1();
		__asm__("ei");
		__asm__("halt");
		__asm__("di");
		putSlotFrame1(slot);
		if (peek(0x7FF1) != c) {
			putRamFrame1();
			__asm__("ei");*/
			puts(found);
			return 1;
/*		}
		putRamFrame1();
		__asm__("ei");
		puts(found);
		return 1;*/
	}
	return 0;
}

/******************************************************************************/
unsigned char verifySwId(unsigned char *str)
{
	if (memcmp(str, "FBLabs SDXC", 11) == 0) {
		return 1;
	}
	return 0;
}

/******************************************************************************/
static void waitErase(void)
{
	c = 0;
	t2 = 10;
	while (--t2 != 0) {
		__asm__("ei");
		__asm__("halt");
		__asm__("di");
		t1 = peek(0x4000);
		t2 = peek(0x4000);
		if (t1 == t2) {
			break;
		}
		putchar(ce[c]);
		putchar(8);
		c = (c + 1) & 0x03;
	}
}

/******************************************************************************/
void eraseFlash(unsigned char slot)
{
	puts(erasingFlash);
	putSlotFrame1(slot);
	putSlotFrame2(slot);
	for (i = 0; i < 32; i++) {
		flashSendCmd(FLASHCMD_ERASE);
		flashEraseSectorSendCmd(i);
		waitErase();
	}
	flashSendCmd(FLASHCMD_SOFTRESET);
	putRamFrame1();
	putRamFrame2();
	puts(ok0);
}

/******************************************************************************/
unsigned char writeBlock(unsigned char slot, unsigned char segment,
						 unsigned char curSegm, unsigned char bank)
{
	mySlot = slot;
	dest = (unsigned char *)0x8000;
	putSegFrame1(segment);
	__asm__("push hl");
	__asm__("push de");
	__asm__("push bc");
	__asm__("ld hl, #0x4000");
	__asm__("ld de, #0x2000");
	__asm__("ld bc, #0x2000");
	__asm__("ldir");
	__asm__("pop bc");
	__asm__("pop de");
	__asm__("pop hl");
	putSegFrame1(curSegm);
	if (writeHalfBlock(bank) != 0) {
		return 0;
	}
	putchar('*');
	putSegFrame1(segment);
	__asm__("push hl");
	__asm__("push de");
	__asm__("push bc");
	__asm__("ld hl, #0x6000");
	__asm__("ld de, #0x2000");
	__asm__("ld bc, #0x2000");
	__asm__("ldir");
	__asm__("pop bc");
	__asm__("pop de");
	__asm__("pop hl");
	putSegFrame1(curSegm);
	if (writeHalfBlock(bank) != 0) {
		return 0;
	}
	putchar('*');
	return 1;
}
