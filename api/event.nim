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
##  Event framework public API.
##
##  This is a framework for writing asynchronous, polled-mode, shared-nothing
##  server applications. The framework relies on DPDK for much of its underlying
##  architecture. The framework defines several concepts - reactors, events, pollers,
##  and subsystems - that are described in the following sections.
##
##  The framework runs one thread per core (the user provides a core mask), where
##  each thread is a tight loop. The threads never block for any reason. These threads
##  are called reactors and their main responsibility is to process incoming events
##  from a queue.
##
##  An event, defined by \ref spdk_event is a bundled function pointer and arguments that
##  can be sent to a different core and executed. The function pointer is executed only once,
##  and then the entire event is freed. These functions should never block and preferably
##  should execute very quickly. Events also have a pointer to a 'next' event that will be
##  executed upon completion of the given event, which allows chaining. This is
##  very much a simplified version of futures, promises, and continuations designed within
##  the constraints of the C programming language.
##
##  The framework also defines another type of function called a poller. Pollers are also
##  functions with arguments that can be bundled and sent to a different core to be executed,
##  but they are instead executed repeatedly on that core until unregistered. The reactor
##  will handle interspersing calls to the pollers with other event processing automatically.
##  Pollers are intended to poll hardware as a replacement for interrupts and they should not
##  generally be used for any other purpose.
##
##  The framework also defines an interface for subsystems, which are libraries of code that
##  depend on this framework. A library can register itself as a subsystem and provide
##  pointers to initialize and destroy itself which will be called at the appropriate time.
##  This is purely for sequencing initialization code in a convenient manner within the
##  framework.
##
##  The framework itself is bundled into a higher level abstraction called an "app". Once
##  \ref spdk_app_start is called it will block the current thread until the application
##  terminates (by calling \ref spdk_app_stop).
##

const
  SPDK_APP_DEFAULT_LOG_FACILITY* = "local7"
  SPDK_APP_DEFAULT_LOG_PRIORITY* = "info"

type
  spdk_event_t* = ptr spdk_event
    ## *
    ##  \brief An event is a function that is passed to and called on an lcore.
    ##
  spdk_event_fn* = proc (a2: spdk_event_t) {.cdecl.}
  spdk_event* = object
    lcore*: uint32
    fn*: spdk_event_fn
    arg1*: pointer
    arg2*: pointer
    next*: ptr spdk_event


  spdk_poller_fn* = proc (arg: pointer) {.cdecl.}

type
  INNER_C_STRUCT_923598915* = object
    tqe_next*: ptr spdk_poller  ##  next element
    tqe_prev*: ptr ptr spdk_poller ##  address of previous next element

  spdk_poller* = object
    ## *
    ##  \brief A poller is a function that is repeatedly called on an lcore.
    ##
    tailq*: INNER_C_STRUCT_923598915 ## 	TAILQ_ENTRY(spdk_poller)	tailq;
    lcore*: uint32
    period_ticks*: uint64
    next_run_tick*: uint64
    fn*: spdk_poller_fn
    arg*: pointer

  spdk_app_shutdown_cb* = proc () {.cdecl.}
  spdk_sighandler_t* = proc (a2: cint) {.cdecl.}

const
  SPDK_APP_DPDK_DEFAULT_MEM_SIZE* = 2048
  SPDK_APP_DPDK_DEFAULT_MASTER_CORE* = 0
  SPDK_APP_DPDK_DEFAULT_MEM_CHANNEL* = 4
  SPDK_APP_DPDK_DEFAULT_CORE_MASK* = "0x1"

type
  spdk_app_opts* = object
    ## *
    ##  \brief Event framework initialization options
    ##
    name*: cstring
    config_file*: cstring
    reactor_mask*: cstring
    log_facility*: cstring
    tpoint_group_mask*: cstring
    instance_id*: cint
    shutdown_cb*: spdk_app_shutdown_cb
    usr1_handler*: spdk_sighandler_t
    enable_coredump*: bool
    dpdk_mem_channel*: uint32
    dpdk_master_core*: uint32
    dpdk_mem_size*: cint


proc spdk_app_opts_init*(opts: ptr spdk_app_opts) {.cdecl,
    importc: "spdk_app_opts_init", dynlib: libspdk.}
    ## *
    ##  \brief Initialize the default value of opts
    ##

proc spdk_dpdk_framework_init*(opts: ptr spdk_app_opts) {.cdecl,
    importc: "spdk_dpdk_framework_init", dynlib: libspdk.}
    ## *
    ##  \brief Initialize DPDK via opts.
    ##

proc spdk_app_init*(opts: ptr spdk_app_opts) {.cdecl, importc: "spdk_app_init",
    dynlib: libspdk.}
    ## *
    ##  \brief Initialize an application to use the event framework. This must be called prior to using
    ##  any other functions in this library.
    ##

proc spdk_app_fini*() {.cdecl, importc: "spdk_app_fini", dynlib: libspdk.}
    ## *
    ##  \brief Perform final shutdown operations on an application using the event framework.
    ##

proc spdk_app_start*(start_fn: spdk_event_fn; arg1: pointer; arg2: pointer): cint {.
    cdecl, importc: "spdk_app_start", dynlib: libspdk.}
    ## *
    ##  \brief Start the framework. Once started, the framework will call start_fn on the master
    ##  core with the arguments provided. This call will block until \ref spdk_app_stop is called.
    ##

proc spdk_app_stop*(rc: cint) {.cdecl, importc: "spdk_app_stop", dynlib: libspdk.}
    ## *
    ##  \brief Stop the framework. This does not wait for all threads to exit. Instead, it kicks off
    ##  the shutdown process and returns. Once the shutdown process is complete, \ref spdk_app_start will return.
    ##

proc spdk_app_get_running_config*(config_str: cstringArray; name: cstring): cint {.
    cdecl, importc: "spdk_app_get_running_config", dynlib: libspdk.}
    ## *
    ##  \brief Generate a configuration file that corresponds to the current running state.
    ##

proc spdk_app_get_instance_id*(): cint {.cdecl, importc: "spdk_app_get_instance_id",
                                      dynlib: libspdk.}
    ## *
    ##  \brief Return the instance id for this application.
    ##

proc spdk_app_parse_core_mask*(mask: cstring; cpumask: ptr uint64): cint {.cdecl,
    importc: "spdk_app_parse_core_mask", dynlib: libspdk.}
    ## *
    ##  \brief Convert a string containing a CPU core mask into a bitmask
    ##

proc spdk_app_get_core_mask*(): uint64 {.cdecl, importc: "spdk_app_get_core_mask",
                                      dynlib: libspdk.}
    ## *
    ##  \brief Return a mask of the CPU cores active for this application
    ##

proc spdk_app_get_core_count*(): cint {.cdecl, importc: "spdk_app_get_core_count",
                                     dynlib: libspdk.}
    ## *
    ##  \brief Return the number of CPU cores utilized by this application
    ##

proc spdk_app_get_current_core*(): uint32 {.cdecl,
    importc: "spdk_app_get_current_core", dynlib: libspdk.}
    ## *
    ##  \brief Return the lcore of the current thread.
    ##

proc spdk_event_allocate*(lcore: uint32; fn: spdk_event_fn; arg1: pointer;
                         arg2: pointer; next: spdk_event_t): spdk_event_t {.cdecl,
    importc: "spdk_event_allocate", dynlib: libspdk.}
    ## *
    ##  \brief Allocate an event to be passed to \ref spdk_event_call
    ##

proc spdk_event_call*(event: spdk_event_t) {.cdecl, importc: "spdk_event_call",
    dynlib: libspdk.}
    ## *
    ##  \brief Pass the given event to the associated lcore and call the function.
    ##

template spdk_event_get_next*(event: untyped): untyped =
  (event).next

template spdk_event_get_arg1*(event: untyped): untyped =
  (event).arg1

template spdk_event_get_arg2*(event: untyped): untyped =
  (event).arg2

##  TODO: This is only used by tests and should be made private

proc spdk_event_queue_run_all*(lcore: uint32) {.cdecl,
    importc: "spdk_event_queue_run_all", dynlib: libspdk.}

proc spdk_poller_register*(poller: ptr spdk_poller; lcore: uint32;
                          complete: ptr spdk_event; period_microseconds: uint64) {.
    cdecl, importc: "spdk_poller_register", dynlib: libspdk.}
    ## *
    ##  \brief Register a poller on the given lcore.
    ##

proc spdk_poller_unregister*(poller: ptr spdk_poller; complete: ptr spdk_event) {.
    cdecl, importc: "spdk_poller_unregister", dynlib: libspdk.}
    ## *
    ##  \brief Unregister a poller on the given lcore.
    ##

proc spdk_poller_migrate*(poller: ptr spdk_poller; new_lcore: cint;
                         complete: ptr spdk_event) {.cdecl,
    importc: "spdk_poller_migrate", dynlib: libspdk.}
    ## *
    ##  \brief Move a poller from its current lcore to a new lcore.
    ##


type
  INNER_C_STRUCT_1654608893* = object
    tqe_next*: ptr spdk_subsystem ##  next element
    tqe_prev*: ptr ptr spdk_subsystem ##  address of previous next element

  spdk_subsystem* = object
    name*: cstring
    init*: proc (): cint {.cdecl.}
    fini*: proc (): cint {.cdecl.}
    config*: proc (fp: ptr FILE) {.cdecl.} ## 	TAILQ_ENTRY(spdk_subsystem) tailq;
    tailq*: INNER_C_STRUCT_1654608893

  INNER_C_STRUCT_2443457597* = object
    tqe_next*: ptr spdk_subsystem_depend ##  next element
    tqe_prev*: ptr ptr spdk_subsystem_depend ##  address of previous next element

  spdk_subsystem_depend* = object
    name*: cstring
    depends_on*: cstring
    depends_on_subsystem*: ptr spdk_subsystem ## 	TAILQ_ENTRY(spdk_subsystem_depend) tailq;
    tailq*: INNER_C_STRUCT_2443457597


proc spdk_add_subsystem*(subsystem: ptr spdk_subsystem) {.cdecl,
    importc: "spdk_add_subsystem", dynlib: libspdk.}
proc spdk_add_subsystem_depend*(depend: ptr spdk_subsystem_depend) {.cdecl,
    importc: "spdk_add_subsystem_depend", dynlib: libspdk.}
## *
##  \brief Register a new subsystem
##
##  TBD : needed to be corrected manually:
## #define SPDK_SUBSYSTEM_REGISTER(_name, _init, _fini, _config)			\
## 	struct spdk_subsystem __spdk_subsystem_ ## _name = {			\
## 	.name = #_name,								\
## 	.init = _init,								\
## 	.fini = _fini,								\
## 	.config = _config,							\
## 	};									\
## 	__attribute__((constructor)) static void _name ## _register(void)	\
## 	{									\
## 		spdk_add_subsystem(&__spdk_subsystem_ ## _name);		\
## 	}
##
## *
##  \brief Declare that a subsystem depends on another subsystem.
##
##  TBD : needed to be corrected manually:
## #define SPDK_SUBSYSTEM_DEPEND(_name, _depends_on)						\
## 	extern struct spdk_subsystem __spdk_subsystem_ ## _depends_on;				\
## 	static struct spdk_subsystem_depend __subsystem_ ## _name ## _depend_on ## _depends_on = { \
## 	.name = #_name,										\
## 	.depends_on = #_depends_on,								\
## 	.depends_on_subsystem = &__spdk_subsystem_ ## _depends_on,				\
## 	};											\
## 	__attribute__((constructor)) static void _name ## _depend_on ## _depends_on(void)	\
## 	{											\
## 		spdk_add_subsystem_depend(&__subsystem_ ## _name ## _depend_on ## _depends_on); \
## 	}
##
