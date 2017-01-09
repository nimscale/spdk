 {.deadCodeElim: on.}
when defined(windows):
  const
    libspdk* = "libspdk.dll"
elif defined(macosx):
  const
    libspdk* = "libspdk.dylib"
else:
  const
    libspdk* = "libspdk.so"
## -
##    BSD LICENSE
## 
##    Copyright (c) Intel Corporation.
##    All rights reserved.
## 
##    Redistribution and use in source and binary forms, with or without
##    modification, are permitted provided that the following conditions
##    are met:
## 
##      * Redistributions of source code must retain the above copyright
##        notice, this list of conditions and the following disclaimer.
##      * Redistributions in binary form must reproduce the above copyright
##        notice, this list of conditions and the following disclaimer in
##        the documentation and/or other materials provided with the
##        distribution.
##      * Neither the name of Intel Corporation nor the names of its
##        contributors may be used to endorse or promote products derived
##        from this software without specific prior written permission.
## 
##    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
##    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
##    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
##    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
##    OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
##    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
##    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
##    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
##    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
##    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
##    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
## 
## * \file
##  String utility functions
## 

## *
##  sprintf with automatic buffer allocation.
## 
##  The return value is the formatted string,
##  which should be passed to free() when no longer needed,
##  or NULL on failure.
## 

proc spdk_sprintf_alloc*(format: cstring): cstring {.varargs, cdecl,
    importc: "spdk_sprintf_alloc", dynlib: libspdk.}
  ## __attribute__((format(printf, 1, 2)))
## *
##  Convert string to lowercase in place.
## 
##  \param s String to convert to lowercase.
## 

proc spdk_strlwr*(s: cstring): cstring {.cdecl, importc: "spdk_strlwr", dynlib: libspdk.}
## *
##  Parse a delimited string with quote handling.
## 
##  \param stringp Pointer to starting location in string. *stringp will be updated to point to the
##  start of the next field, or NULL if the end of the string has been reached.
##  \param delim Null-terminated string containing the list of accepted delimiters.
## 
##  \return Pointer to beginning of the current field.
## 
##  Note that the string will be modified in place to add the string terminator to each field.
## 

proc spdk_strsepq*(stringp: cstringArray; delim: cstring): cstring {.cdecl,
    importc: "spdk_strsepq", dynlib: libspdk.}
## *
##  Trim whitespace from a string in place.
## 
##  \param s String to trim.
## 

proc spdk_str_trim*(s: cstring): cstring {.cdecl, importc: "spdk_str_trim",
                                       dynlib: libspdk.}