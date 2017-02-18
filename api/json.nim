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
## *
##  \file
##  JSON parsing and encoding
##

type
  spdk_json_val_type* {.size: sizeof(cint).} = enum
    SPDK_JSON_VAL_INVALID, SPDK_JSON_VAL_NULL, SPDK_JSON_VAL_TRUE,
    SPDK_JSON_VAL_FALSE, SPDK_JSON_VAL_NUMBER, SPDK_JSON_VAL_STRING,
    SPDK_JSON_VAL_ARRAY_BEGIN, SPDK_JSON_VAL_ARRAY_END,
    SPDK_JSON_VAL_OBJECT_BEGIN, SPDK_JSON_VAL_OBJECT_END, SPDK_JSON_VAL_NAME


type
  spdk_json_val* = object
    start*: pointer ## *
                  ##  Pointer to the location of the value within the parsed JSON input.
                  ##
                  ##  For SPDK_JSON_VAL_STRING and SPDK_JSON_VAL_NAME,
                  ##   this points to the beginning of the decoded UTF-8 string without quotes.
                  ##
                  ##  For SPDK_JSON_VAL_NUMBER, this points to the beginning of the number as represented in
                  ##   the original JSON (text representation, not converted to a numeric value).
                  ##
    ## *
    ##  Length of value.
    ##
    ##  For SPDK_JSON_VAL_STRING, SPDK_JSON_VAL_NUMBER, and SPDK_JSON_VAL_NAME,
    ##   this is the length in bytes of the value starting at \ref start.
    ##
    ##  For SPDK_JSON_VAL_ARRAY_BEGIN and SPDK_JSON_VAL_OBJECT_BEGIN,
    ##   this is the number of values contained within the array or object (including
    ##   nested objects and arrays, but not including the _END value).  The array or object _END
    ##   value can be found by advancing len values from the _BEGIN value.
    ##
    len*: uint32               ## *
               ##  Type of value.
               ##
    `type`*: spdk_json_val_type


const
  SPDK_JSON_PARSE_INVALID* = - 1
    ## *
    ##  Invalid JSON syntax.
    ##

const
  SPDK_JSON_PARSE_INCOMPLETE* = - 2
  SPDK_JSON_PARSE_MAX_DEPTH_EXCEEDED* = - 3
    ## *
    ##  JSON was valid up to the end of the current buffer, but did not represent a complete JSON value.
    ##

const
  SPDK_JSON_PARSE_FLAG_DECODE_IN_PLACE* = 0x0000000000000001'i64
    ## *
    ##  Decode JSON strings and names in place (modify the input buffer).
    ##

proc spdk_json_parse*(json: pointer; size: csize; values: ptr spdk_json_val;
                     num_values: csize; `end`: ptr pointer; flags: uint32): cint {.
    cdecl, importc: "spdk_json_parse", dynlib: libspdk.}  # returns ssize_t : it's different on 32-bit/64-bit machines
    ##
    ##  Parse JSON data.
    ##
    ##  \param data Raw JSON data; must be encoded in UTF-8.
    ##  Note that the data may be modified to perform in-place string decoding.
    ##
    ##  \param size Size of data in bytes.
    ##
    ##  \param end If non-NULL, this will be filled a pointer to the byte just beyond the end
    ##  of the valid JSON.
    ##
    ##  \return Number of values parsed, or negative on failure:
    ##  SPDK_JSON_PARSE_INVALID if the provided data was not valid JSON, or
    ##  SPDK_JSON_PARSE_INCOMPLETE if the provided data was not a complete JSON value.
    ##

type
  spdk_json_decode_fn* = proc (val: ptr spdk_json_val; `out`: pointer): cint {.cdecl.}
  spdk_json_object_decoder* = object
    name*: cstring
    offset*: csize
    decode_func*: spdk_json_decode_fn
    optional*: bool


proc spdk_json_decode_object*(values: ptr spdk_json_val;
                             decoders: ptr spdk_json_object_decoder;
                             num_decoders: csize; `out`: pointer): cint {.cdecl,
    importc: "spdk_json_decode_object", dynlib: libspdk.}
proc spdk_json_decode_array*(values: ptr spdk_json_val;
                            decode_func: spdk_json_decode_fn; `out`: pointer;
                            max_size: csize; out_size: ptr csize; stride: csize): cint {.
    cdecl, importc: "spdk_json_decode_array", dynlib: libspdk.}
proc spdk_json_decode_int32*(val: ptr spdk_json_val; `out`: pointer): cint {.cdecl,
    importc: "spdk_json_decode_int32", dynlib: libspdk.}
proc spdk_json_decode_uint32*(val: ptr spdk_json_val; `out`: pointer): cint {.cdecl,
    importc: "spdk_json_decode_uint32", dynlib: libspdk.}
proc spdk_json_decode_string*(val: ptr spdk_json_val; `out`: pointer): cint {.cdecl,
    importc: "spdk_json_decode_string", dynlib: libspdk.}

proc spdk_json_val_len*(val: ptr spdk_json_val): csize {.cdecl,
    importc: "spdk_json_val_len", dynlib: libspdk.}
    ## *
    ##  Get length of a value in number of values.
    ##
    ##  This can be used to skip over a value while interpreting parse results.
    ##
    ##  For SPDK_JSON_VAL_ARRAY_BEGIN and SPDK_JSON_VAL_OBJECT_BEGIN,
    ##   this returns the number of values contained within this value, plus the _BEGIN and _END values.
    ##
    ##  For all other values, this returns 1.
    ##

proc spdk_json_strequal*(val: ptr spdk_json_val; str: cstring): bool {.cdecl,
    importc: "spdk_json_strequal", dynlib: libspdk.}
    ## *
    ##  Compare JSON string with null terminated C string.
    ##
    ##  \return true if strings are equal or false if not
    ##
proc spdk_json_strdup*(val: ptr spdk_json_val): cstring {.cdecl,
    importc: "spdk_json_strdup", dynlib: libspdk.}
    ## *
    ##  Equivalent of strdup() for JSON string values.
    ##
    ##  If val is not representable as a C string (contains embedded '\0' characters),
    ##  returns NULL.
    ##
    ##  Caller is responsible for passing the result to free() when it is no longer needed.
    ##

proc spdk_json_number_to_double*(val: ptr spdk_json_val; num: ptr cdouble): cint {.
    cdecl, importc: "spdk_json_number_to_double", dynlib: libspdk.}
proc spdk_json_number_to_int32*(val: ptr spdk_json_val; num: ptr int32): cint {.cdecl,
    importc: "spdk_json_number_to_int32", dynlib: libspdk.}
proc spdk_json_number_to_uint32*(val: ptr spdk_json_val; num: ptr uint32): cint {.cdecl,
    importc: "spdk_json_number_to_uint32", dynlib: libspdk.}
type
  spdk_json_write_ctx* = object

  spdk_json_write_cb* = proc (cb_ctx: pointer; data: pointer; size: csize): cint {.cdecl.}

proc spdk_json_write_begin*(write_cb: spdk_json_write_cb; cb_ctx: pointer;
                           flags: uint32): ptr spdk_json_write_ctx {.cdecl,
    importc: "spdk_json_write_begin", dynlib: libspdk.}
proc spdk_json_write_end*(w: ptr spdk_json_write_ctx): cint {.cdecl,
    importc: "spdk_json_write_end", dynlib: libspdk.}
proc spdk_json_write_null*(w: ptr spdk_json_write_ctx): cint {.cdecl,
    importc: "spdk_json_write_null", dynlib: libspdk.}
proc spdk_json_write_bool*(w: ptr spdk_json_write_ctx; val: bool): cint {.cdecl,
    importc: "spdk_json_write_bool", dynlib: libspdk.}
proc spdk_json_write_int32*(w: ptr spdk_json_write_ctx; val: int32): cint {.cdecl,
    importc: "spdk_json_write_int32", dynlib: libspdk.}
proc spdk_json_write_uint32*(w: ptr spdk_json_write_ctx; val: uint32): cint {.cdecl,
    importc: "spdk_json_write_uint32", dynlib: libspdk.}
proc spdk_json_write_string*(w: ptr spdk_json_write_ctx; val: cstring): cint {.cdecl,
    importc: "spdk_json_write_string", dynlib: libspdk.}
proc spdk_json_write_string_raw*(w: ptr spdk_json_write_ctx; val: cstring; len: csize): cint {.
    cdecl, importc: "spdk_json_write_string_raw", dynlib: libspdk.}
proc spdk_json_write_array_begin*(w: ptr spdk_json_write_ctx): cint {.cdecl,
    importc: "spdk_json_write_array_begin", dynlib: libspdk.}
proc spdk_json_write_array_end*(w: ptr spdk_json_write_ctx): cint {.cdecl,
    importc: "spdk_json_write_array_end", dynlib: libspdk.}
proc spdk_json_write_object_begin*(w: ptr spdk_json_write_ctx): cint {.cdecl,
    importc: "spdk_json_write_object_begin", dynlib: libspdk.}
proc spdk_json_write_object_end*(w: ptr spdk_json_write_ctx): cint {.cdecl,
    importc: "spdk_json_write_object_end", dynlib: libspdk.}
proc spdk_json_write_name*(w: ptr spdk_json_write_ctx; name: cstring): cint {.cdecl,
    importc: "spdk_json_write_name", dynlib: libspdk.}
proc spdk_json_write_name_raw*(w: ptr spdk_json_write_ctx; name: cstring; len: csize): cint {.
    cdecl, importc: "spdk_json_write_name_raw", dynlib: libspdk.}
proc spdk_json_write_val*(w: ptr spdk_json_write_ctx; val: ptr spdk_json_val): cint {.
    cdecl, importc: "spdk_json_write_val", dynlib: libspdk.}

proc spdk_json_write_val_raw*(w: ptr spdk_json_write_ctx; data: pointer; len: csize): cint {.
    cdecl, importc: "spdk_json_write_val_raw", dynlib: libspdk.}
    ##
    ##  Append bytes directly to the output stream without validation.
    ##
    ##  Can be used to write values with specific encodings that differ from the JSON writer output.
    ##
