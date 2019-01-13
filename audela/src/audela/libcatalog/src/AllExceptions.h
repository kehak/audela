/* AllExceptions.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Yassine Damerdji <yassine.damerdji@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#ifndef ALLEXCEPTIONS_H_
#define ALLEXCEPTIONS_H_

#include "string.h"       // pour strncpy
#include "libcatalog.h"  // pour IAllExceptions
using namespace libcatalog;

class AllExceptions : public IAllExceptions {

private:
	char theMessage[1024];
   unsigned long code;

public:
	AllExceptions(const char* inputMessage) {
		////sprintf(theMessage,"%s",inputMessage);
      // Pour eviter un debordement de memoire , il faut limiter 
      // la copie du message a la taille de la variable de destination
      strncpy(theMessage,inputMessage, 1023); 
      code =  GenericError;
	}

	AllExceptions(const AllExceptions &inputException) {
		//// sprintf(theMessage,"%s",inputException.theMessage);
      // Pour eviter un debordement de memoire , il faut limiter 
      // la copie du message a la taille de la variable de destination
      strncpy(theMessage,inputException.theMessage, 1023); 
      code =  GenericError;
	}

   AllExceptions(unsigned long code, const AllExceptions &inputException) {
      this->code = code;
		//// sprintf(theMessage,"%s",inputException.theMessage);
      // Pour eviter un debordement de memoire , il faut limiter 
      // la copie du message a la taille de la variable de destination
      strncpy(theMessage,inputException.theMessage, 1023); 
	}


	char* getTheMessage() {
		return theMessage;
	}
   unsigned long  getCode(void) { 
      return code; 
   };

	virtual ~AllExceptions() {}

};

/**
 * Exception when we can not create directory
 */
class CanNotCreateDirectoryException : public AllExceptions {
public:
	CanNotCreateDirectoryException(const char* inputMessage) : AllExceptions(inputMessage) {}
};

/**
 * Exception when we can not open a stream (for reading or writing)
 */
class FileNotFoundException : public AllExceptions {
public:
	FileNotFoundException(const char* inputMessage) : AllExceptions(inputMessage) {}
};

/**
 * Exception when we can not read a stream
 */
class CanNotReadInStreamException : public AllExceptions {
public:
	CanNotReadInStreamException(const char* inputMessage) : AllExceptions(inputMessage) {}
};

/**
 * Exception when we can not write in a stream
 */
class CanNotWriteInStreamException : public AllExceptions {
public:
	CanNotWriteInStreamException(const char* inputMessage) : AllExceptions(inputMessage) {}
};

/**
 * Exception when memory allocation fails
 */
class InsufficientMemoryException : public AllExceptions {
public:
	InsufficientMemoryException(const char* inputMessage) : AllExceptions(inputMessage) {}
};

/**
 * Exception when data are not valid
 */
class InvalidDataException : public AllExceptions {
public:
	InvalidDataException(const char* inputMessage) : AllExceptions(inputMessage) {}
};

#endif /* ALLEXCEPTIONS_H_ */
