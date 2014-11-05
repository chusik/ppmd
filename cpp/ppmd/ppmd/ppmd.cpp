// ppmd.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <io.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "PPMdVariantI.h"


typedef struct 
{
	uint8_t (*nextByte)(InStream *self);
	int f;
} TInStream;

uint8_t nextByte(InStream *self)
{
	uint8_t value;

	_read(((TInStream *)self)->f, &value, sizeof(uint8_t));

	return value;
}

int _tmain(int argc, _TCHAR* argv[])
{
	uint8_t b;
	int nb;
	int ff;
	TInStream s;
	uint16_t params;
	PPMdModelVariantI *ppmd;

	ff = _open("output.c", _O_WRONLY | _O_CREAT, _S_IREAD | 
                            _S_IWRITE);

	s.f = _open("test.ppmd", O_RDWR);
	s.nextByte = nextByte;

	_read(s.f, &params, sizeof(params));

      ppmd = CreatePPMdModelVariantI((InStream *)&s,
        (((params >> 4) & 0xFF) + 1) << 20,// sub-allocator size
        (params & 0x0F) + 1,                 // model order
        params >> 12); 

          while (1) {
            nb = NextPPMdVariantIByte(ppmd);
            if (nb < 0) break;
			b = (uint8_t)nb;
			_write(ff, &b, 1);
		  };

FreePPMdModelVariantI(ppmd);

//_fsync(ff);
_close(ff);
_close(s.f);

	return 0;
}

