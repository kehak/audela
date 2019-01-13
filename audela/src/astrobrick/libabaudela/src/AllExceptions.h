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

class AllExceptions {

private:
	char theMessage[1024];

public:
	AllExceptions(const char* inputMessage) {
		sprintf(theMessage,"%s",inputMessage);
	}
	AllExceptions(const AllExceptions &inputException) {
		sprintf(theMessage,"%s",inputException.theMessage);
	}
	const char* getTheMessage() {
		return theMessage;
	}
	virtual ~AllExceptions(){}
};

/**
 * Exception which stops the code
 */
class FatalException : public AllExceptions {
public:
	FatalException(const char* inputMessage) : AllExceptions(inputMessage) {}
};

/**
 * Exception which does not stop the code
 */
class ErrorException : public AllExceptions {
public:
	ErrorException(const char* inputMessage) : AllExceptions(inputMessage) {}
};

/**
 * Exception when we can not create directory
 */
class CanNotCreateDirectoryException : public FatalException {
public:
	CanNotCreateDirectoryException(const char* inputMessage) : FatalException(inputMessage) {}
};

/**
 * Exception when we can not open a stream (for reading or writing)
 */
class FileNotFoundException : public FatalException {
public:
	FileNotFoundException(const char* inputMessage) : FatalException(inputMessage) {}
};

/**
 * Exception when we can not read a stream
 */
class CanNotReadInStream : public FatalException {
public:
	CanNotReadInStream(const char* inputMessage) : FatalException(inputMessage) {}
};

/**
 * Exception when we can not write in a stream
 */
class CanNotWriteInStream : public FatalException {
public:
	CanNotWriteInStream(const char* inputMessage) : FatalException(inputMessage) {}
};

/**
 * Exception when memory allocation fails
 */
class InsufficientMemoryException : public FatalException {
public:
	InsufficientMemoryException(const char* inputMessage) : FatalException(inputMessage) {}
};

/**
 * Exception when data are not valid
 */
class InvalidDataException : public ErrorException {
public:
	InvalidDataException(const char* inputMessage) : ErrorException(inputMessage) {}
};

class BadlyConditionnedMatrixException : public ErrorException {
public:
	BadlyConditionnedMatrixException(const char* inputMessage) : ErrorException(inputMessage) {}
};

class NonDefinitePositiveMatrixException : public ErrorException {
public:
	NonDefinitePositiveMatrixException(const char* inputMessage) : ErrorException(inputMessage) {}
};

#endif /* ALLEXCEPTIONS_H_ */
