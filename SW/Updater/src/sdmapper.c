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
const char *title1 =			"FBLabs SDMapper programmer utility\r\n";
const char *usage2 =			"     sdm-upd /opts <filename.ext>\r\n"
								"Example: sdm-upd DRIVER.ROM\r\n"
								"         sdm-upd /e\r\n";
static const char *found =		"Found SDMapper interface";
__sfr __at 0x5F IOFW;


/* Variables */
static int i;
static unsigned char c, t1, t2;
static unsigned char flashIdMan, flashIdProd, alg;
static unsigned char hwId, swId, mySlot;
static unsigned char *source, *dest;

/* Private Functions */

/******************************************************************************/
static unsigned char flashIdent(unsigned char manId, unsigned char prodId)
{
	alg = ALGBYTE;
	if (manId == 0x01) {				// AMD
		if (prodId == 0x20) {			// AM29F010
			return 1;
		}
	} else if (manId == 0x1F) {			// Atmel
		if (prodId == 0x07) {			// AT49F002
			return 1;
		} else if (prodId == 0x08) {	// AT49F002T
			return 1;
		} else if (prodId == 0x17) {	// AT49F010
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
			return 1;
		} else if (prodId == 0xB6) {	// SST39SF020
			return 1;
		}
	} else if (manId == 0xDA) {			// Winbond
		if (prodId == 0x0B) {			// W49F002UN
			return 1;
		} else if (prodId == 0x25) {	// W49F002B
			return 1;
		} else if (prodId == 0xA1) {	// W39F010
			return 1;
		}
	}
	return 0;
}

/******************************************************************************/
static void flashSendCmd(unsigned char cmd)
{
	IOFW = 0x81;
	poke(0x9555, 0xAA);
	IOFW = 0x80;
	poke(0xAAAA, 0x55);
	IOFW = 0x81;
	poke(0x9555, cmd);
}


/* Public Functions */

/******************************************************************************/
unsigned char detectInterface(unsigned char slot)
{
	putSlotFrame2(slot);
	flashSendCmd(FLASHCMD_SOFTRESET);
	flashSendCmd(FLASHCMD_SOFTIDENTRY);
	flashIdMan = peek(0x8000);
	flashIdProd = peek(0x8001);
	flashSendCmd(FLASHCMD_SOFTRESET);
	IOFW = 0;
	putRamFrame2();
	if (flashIdent(flashIdMan, flashIdProd) == 1) {
		puts(found);
		return 1;
	}
	return 0;
}

/******************************************************************************/
unsigned char verifySwId(unsigned char *str)
{
	return !memcmp(str, "SDMapper", 8);
}

/******************************************************************************/
static void waitErase(void)
{
	c = 0;
	t2 = 50;
	while (--t2 != 0) {
		__asm__("ei");
		__asm__("halt");
		__asm__("di");
		t1 = peek(0x8000);
		t2 = peek(0x8000);
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
	putSlotFrame2(slot);
	flashSendCmd(FLASHCMD_ERASE);
	flashSendCmd(FLASHCMD_ERASEALL);
	waitErase();
	flashSendCmd(FLASHCMD_SOFTRESET);
	putRamFrame1();
	IOFW = 0x00;
	puts(ok0);
}

/******************************************************************************/
unsigned char writeBlock(unsigned char slot, unsigned char segment,
						 unsigned char curSegm, unsigned char bank)
{
	putSegFrame1(segment);		// Data to be write
	putSlotFrame2(slot);		// Flash
	t1 = 1;
	source = (unsigned char *)0x4000;
	dest   = (unsigned char *)0x8000;
	while ((unsigned int)source < 0x8000) {
		flashSendCmd(FLASHCMD_WRITEBYTE);
		IOFW = 0x80 | bank;
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
			if (*dest == *source) {		// /DATAPOLLING, if equal byte was written
				break;
			}
		}
		if (i == 0) {					// timeout
			t1 = 0;						// error
			break;
		}
		++dest;
		++source;
	}
	IOFW = 0;
	putRamFrame2();
	putSegFrame1(curSegm);
	putchar('*');
	return t1;
}
