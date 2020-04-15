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


#include "strings.h"

const char *title2 =			"(c) 2014-2017 FBLabs\r\n";
const char *usage1 =			"\r\n"
								"Usage:\r\n";
const char *usage3 =			"\r\n"
								"Options:\r\n"
								"     /h : Show this help.\r\n"
								"     /s : Ask the interface slot.\r\n"
								"     /e : Only erase flash and exit.\r\n"
								"     /p : Pause before flashing.\r\n";
const char *crlf =				"\r\n";
const char *whatslot =			"What is the interface slot? (0-3)";
const char *whatsubslot =		"What is the subslot? (0-3)";
const char *searching =			"Searching interface ...\r\n";
const char *found3 =			" in slot ";
const char *notfound =			"Oops! Interface not found!!\r\n";
const char *confirmReset0 =		"The system will have to be reset at the end of the ";
const char *confirmReset1 =		"erase";
const char *confirmReset2 =		"update";
const char *confirmReset3 =		" process. Do you want to proceed? (y/n)";
const char *errorNoExtBios =	"Memory Mapper management EXTBIOS not found. Falling back to direct I/O.\r\n";
const char *noMemAvailable =	"No memory available.\r\n";
const char *errorAllocMapper =	"\r\nError allocating mapper segment.\r\n";
const char *openingError =		"Error opening file!\r\n";
const char *readingFile =		"Reading file: ";
const char *readingError0 =		"\r\nReading error: ";
const char *readingError1 =		"!\r\n";
const char *filesizeError =		"ERROR: File size must be 128KB\r\n";
const char *errorNotNxtDrv =	"This file is not a Nextor driver!\r\n";
const char *errorWrongDrv =		"Wrong driver!\r\n";
const char *errorSeek =			"Error seeking!\r\n";
const char *pauseMsg =			"Press any key to continue.";
const char *erasingFlash =		"Erasing flash: ";
const char *writingFlash =		"Writing flash: ";
const char *errorWriting =		"\r\nError!\r\n";
const char *ok0 =				"OK\r\n";
const char *systemHalted =		"System halted.";
const char *anyKeyToReset =		"The BIOS was successfully updated. Press any key to reboot.";
const char ce[5] = "\\|/-";

