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
#include "msxdos.h"
#include "mapper.h"
#include "interface.h"


/* Structs */

/* Constants */
const unsigned char *EXPTBL = (volatile unsigned char *)0xFCC1;	// slots expanded or not
const unsigned char *DSKSLT = (volatile unsigned char *)0xF348;	// slotid diskrom


/* Global vars */
//unsigned char *HKEYI = (volatile unsigned char *)0xFD9A;
unsigned char *HTIMI = (volatile unsigned char *)0xFD9F;
//unsigned char *HCHPU = (volatile unsigned char *)0xFDA4;

static TDevInfo devInfo;
static unsigned char numMprPages, mprSegments[8], curSegm;
static unsigned char hooks[1], pfi, askslot, onlyErase, resetAtEnd;
static unsigned char buffer[64], pause;
static unsigned char c, t1, t2, slot, swId, isMain, isSlave;
static int fhandle, i, r;
static unsigned long fileSize, seekpos;


/******************************************************************************/
static void restoreHooks()
{
	// Restore hooks
	*HTIMI = hooks[0];
	//*HCHPU = hooks[1];
}

/******************************************************************************/
int main(char** argv, int argc)
{
	puts(title1);
	puts(title2);

	if (argc < 1) {
showUsage:
		puts(usage1);
		puts(usage2);
		puts(usage3);
		return 1;
	}
	pfi = 0;
	onlyErase = 0;
	askslot = 0;
	pause = 0;
	for (i = 0; i < argc; i++) {
		if (argv[i][0] == '/') {
			if (argv[i][1] == 'h' || argv[i][1] == 'H') {
				puts(usage1);
				puts(usage2);
				puts(usage3);
				return 0;
			} else if (argv[i][1] == 'e' || argv[i][1] == 'E') {
				onlyErase = 1;
				++pfi;
			} else if (argv[i][1] == 's' || argv[i][1] == 'S') {
				askslot = 1;
				++pfi;
			} else if (argv[i][1] == 'p' || argv[i][1] == 'P') {
				pause = 1;
				++pfi;
			} else {
				goto showUsage;
			}
		}
	}
	if (pfi == argc && onlyErase == 0) {
		goto showUsage;
	}

	// Save hooks
	hooks[0] = *HTIMI;
	//hooks[1] = *HCHPU;
	// Temporary disable hooks
	*HTIMI = 0xC9;
	//*HCHPU = 0xC9;

	if (askslot == 1) {
		puts(whatslot);
		while(1) {
			c = getchar();
			if (c >= '0' && c <= '3') {
				break;
			}
		}
		putchar(c);
		puts(crlf);
		slot = c - '0';
		if ((*(EXPTBL+slot) & 0x80) == 0x80) {
			puts(whatsubslot);
			while(1) {
				c = getchar();
				if (c >= '0' && c <= '3') {
					break;
				}
			}
			putchar(c);
			puts(crlf);
			c -= '0';
			slot |= 0x80 | (c << 2);
		}
		if (detectInterface(slot) == 0) {
			slot = 0xFF;
		}
		puts(crlf);
	} else {
		// Find interface
		puts(searching);
		slot = (*EXPTBL) & 0x80;
		while (1) {
			if (slot == 0x8F || slot == 0x03) {
				slot = 0xFF;
				break;
			}
			if (detectInterface(slot) == 1) {
				puts(found3);
				putdec8(slot & 0x03);
				if ((slot & 0x80) == 0x80) {
					putchar('.');
					putdec8((slot & 0x0C) >> 2);
				}
				puts(crlf);
				break;
			}
			// Next slot
			if (slot & 0x80) {
				if ((slot & 0x0C) != 0x0C) {
					slot += 0x04;
					continue;
				}
			}
			slot = (slot & 0x03) + 1;
			slot |= (*(EXPTBL+slot)) & 0x80;
		}
	}

	if (slot == 0xFF) {
		restoreHooks();
		puts(notfound);
		return 4;
	}

	// Detects MSXDOS version
	msxdos_init();

	/* If is MSXDOS1, we can not verify which is the main DOS, we assume it is. */
	if (dosversion < 2 || *DSKSLT == slot) {
		isMain = 1;
	} else {
		isMain = 0;
	}

	isSlave = 0;
	if (dosversion == 0x82) {			// Is Nextor, check devices
		for (c = 0; c < 16; c++) {
			if (0 == getDeviceInfo(c, &devInfo)) {
				if (devInfo.slotNum == slot) {
					isSlave = 1;
				}
			}
		}
	} else {
		isSlave = 1;					// Forces a reset
	}

	if (onlyErase == 1) {
		if (isMain == 1 || isSlave == 1) {
			puts(confirmReset0);
			puts(confirmReset1);
			puts(confirmReset3);
			clearKeyBuf();
			c = getchar();
			putchar(c);
			puts(crlf);
			if (c == 'y' || c == 'Y') {
				__asm__("di");
				eraseFlash(slot);
				resetSystem();
			}
			restoreHooks();
			return 0;
		} else {
			eraseFlash(slot);
			restoreHooks();
			return 0;
		}
	}

	c = mpInit();
	if (c != 0) {
		puts(errorNoExtBios);
		numMprPages = numMapperPages();
	} else {
		numMprPages = mpVars->numFree;
	}
	if (numMprPages < 8) {
		puts(noMemAvailable);
		restoreHooks();
		return 3;
	}
	// Saves the current segment;
	curSegm = getCurSegFrame1();

	// Try open file
	fhandle = open(argv[pfi], O_RDONLY);
	if (fhandle == -1) {
		puts(openingError);
		restoreHooks();
		return 4;
	}

	if (dosversion < 2) {
		fileSize = dos1GetFilesize();
	} else {
		fileSize = lseek(fhandle, 0, SEEK_END);
	}
	if (fileSize != 131072) {
		puts(filesizeError);
		restoreHooks();
		return 5;
	}
	/* Only for MSXDOS2 */
	if (dosversion > 1) {
		lseek(fhandle, 0x1C100, SEEK_SET);
		r = read(fhandle, buffer, 32);
		if (r == -1) {
			goto readErr;
		}
		if (memcmp(buffer, "NEXTOR_DRIVER", 13) == 1) {
			puts(errorNotNxtDrv);
			restoreHooks();
			return 6;		
		}
		if (verifySwId(buffer+16) == 0) {
			puts(errorWrongDrv);
			restoreHooks();
			return 7;
		}
		seekpos = lseek(fhandle, 0, SEEK_SET);
		if (seekpos != 0) {
			puts(errorSeek);
			restoreHooks();
			return 7;
		}
	} else {
		//
	}

	resetAtEnd = 0;
	if (isMain == 1 || isSlave == 1) {
		puts(confirmReset0);
		puts(confirmReset2);
		puts(confirmReset3);
		clearKeyBuf();
		c = getchar();
		putchar(c);
		puts(crlf);
		if (c == 'y' || c == 'Y') {
			resetAtEnd = 1;
		} else {
			close(fhandle);
			restoreHooks();
			return 0;
		}
	}

	for (i = 0; i < 8; i++) {
		mprSegments[i] = allocUserSegment();
		if (mprSegments[i] == 0) {
			puts(errorAllocMapper);
			close(fhandle);
			restoreHooks();
			return 10;
		}
	}
	puts(readingFile);
	c = 0;
	for (i = 0; i < 8; i++) {
		putchar(ce[c]);
		putchar(8);
		c = (c + 1) & 0x03;
		t1 = mprSegments[i];
		putSegFrame1(t1);
		r = read(fhandle, (void *)0x4000, 16384);
		putSegFrame1(curSegm);
		if (r != 16384) {
readErr:
			puts(readingError0);
			puthex8(last_error);
			puts(readingError1);
			close(fhandle);
			restoreHooks();
			return 11;
		}
	}
	puts(ok0);
	close(fhandle);

	if (pause == 1) {
		puts(pauseMsg);
		getchar();
		puts(crlf);
	}

	__asm__("di");
	eraseFlash(slot);

	puts(writingFlash);
	for (i = 0; i < 8; i++) {
		if (writeBlock(slot, mprSegments[i], curSegm, i) == 0) {
			break;
		}
	}
	__asm__("ei");
	if (i != 8) {
		puts(errorWriting);
		eraseFlash(slot);
		puts(systemHalted);
		__asm__("di");
		__asm__("halt");
	} else {
		putchar(' ');
		puts(ok0);
	}
	if (resetAtEnd == 1) {
		puts(anyKeyToReset);
		clearKeyBuf();
		getchar();
		resetSystem();
	}
	restoreHooks();
	return 0;
}
