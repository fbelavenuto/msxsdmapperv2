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

#ifndef  __INTERFACE_H__
#define  __INTERFACE_H__

// Flash
#define ALGBYTE 0
#define ALGPAGE 1
#define FLASHCMD_SOFTRESET		0xF0
#define FLASHCMD_ERASE			0x80
#define FLASHCMD_ERASEALL		0x10
#define FLASHCMD_ERASESECTOR	0x30
#define FLASHCMD_WRITEBYTE		0xA0
#define FLASHCMD_SOFTIDENTRY	0x90

unsigned char detectInterface(unsigned char slot);

void eraseFlash(unsigned char slot);
unsigned char verifySwId(unsigned char *str);
unsigned char writeBlock(unsigned char slot, unsigned char segment,
						 unsigned char curSegm, unsigned char bank);



#endif /* __INTERFACE_H__ */
