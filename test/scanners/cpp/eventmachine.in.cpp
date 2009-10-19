/*****************************************************************************

$Id$

File:     binder.cpp
Date:     07Apr06

Copyright (C) 2006-07 by Francis Cianfrocca. All Rights Reserved.
Gmail: blackhedd

This program is free software; you can redistribute it and/or modify
it under the terms of either: 1) the GNU General Public License
as published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version; or 2) Ruby's License.

See the file COPYING for complete licensing information.

*****************************************************************************/

#include "project.h"

#define DEV_URANDOM "/dev/urandom"


map<string, Bindable_t*> Bindable_t::BindingBag;


/********************************
STATIC Bindable_t::CreateBinding
********************************/

string Bindable_t::CreateBinding()
{
	static int index = 0;
	static string seed;

	if ((index >= 1000000) || (seed.length() == 0)) {
		#ifdef OS_UNIX
		int fd = open (DEV_URANDOM, O_RDONLY);
		if (fd < 0)
			throw std::runtime_error ("No entropy device");

		unsigned char u[16];
		size_t r = read (fd, u, sizeof(u));
		if (r < sizeof(u))
			throw std::runtime_error ("Unable to read entropy device");

		unsigned char *u1 = (unsigned char*)u;
		char u2 [sizeof(u) * 2 + 1];

		for (size_t i=0; i < sizeof(u); i++)
			sprintf (u2 + (i * 2), "%02x", u1[i]);

		seed = string (u2);
		#endif


		#ifdef OS_WIN32
		UUID uuid;
		UuidCreate (&uuid);
		unsigned char *uuidstring = NULL;
		UuidToString (&uuid, &uuidstring);
		if (!uuidstring)
			throw std::runtime_error ("Unable to read uuid");
		seed = string ((const char*)uuidstring);

		RpcStringFree (&uuidstring);
		#endif

		index = 0;


	}

	stringstream ss;
	ss << seed << (++index);
	return ss.str();
}


/*****************************
STATIC: Bindable_t::GetObject
*****************************/

Bindable_t *Bindable_t::GetObject (const char *binding)
{
  string s (binding ? binding : "");
  return GetObject (s);
}

/*****************************
STATIC: Bindable_t::GetObject
*****************************/

Bindable_t *Bindable_t::GetObject (const string &binding)
{
  map<string, Bindable_t*>::const_iterator i = BindingBag.find (binding);
  if (i != BindingBag.end())
    return i->second;
  else
    return NULL;
}


/**********************
Bindable_t::Bindable_t
**********************/

Bindable_t::Bindable_t()
{
	Binding = Bindable_t::CreateBinding();
	BindingBag [Binding] = this;
}



/***********************
Bindable_t::~Bindable_t
***********************/

Bindable_t::~Bindable_t()
{
	BindingBag.erase (Binding);
}


/*****************************************************************************

$Id$

File:			cmain.cpp
Date:			06Apr06

Copyright (C) 2006-07 by Francis Cianfrocca. All Rights Reserved.
Gmail: blackhedd

This program is free software; you can redistribute it and/or modify
it under the terms of either: 1) the GNU General Public License
as published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version; or 2) Ruby's License.

See the file COPYING for complete licensing information.

*****************************************************************************/

#include "project.h"


static EventMachine_t *EventMachine;
static int bUseEpoll = 0;
static int bUseKqueue = 0;

extern "C" void ensure_eventmachine (const char *caller = "unknown caller")
{
	if (!EventMachine) {
		const int err_size = 128;
		char err_string[err_size];
		snprintf (err_string, err_size, "eventmachine not initialized: %s", caller);
		#ifdef BUILD_FOR_RUBY
			rb_raise(rb_eRuntimeError, err_string);
		#else
			throw std::runtime_error (err_string);
		#endif
	}
}

/***********************
evma_initialize_library
***********************/

extern "C" void evma_initialize_library (void(*cb)(const char*, int, const char*, int))
{
	// Probably a bad idea to mess with the signal mask of a process
	// we're just being linked into.
	//InstallSignalHandlers();
	if (EventMachine)
		#ifdef BUILD_FOR_RUBY
			rb_raise(rb_eRuntimeError, "eventmachine already initialized: evma_initialize_library");
		#else
			throw std::runtime_error ("eventmachine already initialized: evma_initialize_library");
		#endif
	EventMachine = new EventMachine_t (cb);
	if (bUseEpoll)
		EventMachine->_UseEpoll();
	if (bUseKqueue)
		EventMachine->_UseKqueue();
}


/********************
evma_release_library
********************/

extern "C" void evma_release_library()
{
	ensure_eventmachine("evma_release_library");
	delete EventMachine;
	EventMachine = NULL;
}


/****************
evma_run_machine
****************/

extern "C" void evma_run_machine()
{
	ensure_eventmachine("evma_run_machine");
	EventMachine->Run();
}


/**************************
evma_install_oneshot_timer
**************************/

extern "C" const char *evma_install_oneshot_timer (int seconds)
{
	ensure_eventmachine("evma_install_oneshot_timer");
	return EventMachine->InstallOneshotTimer (seconds);
}


/**********************
evma_connect_to_server
**********************/

extern "C" const char *evma_connect_to_server (const char *server, int port)
{
	ensure_eventmachine("evma_connect_to_server");
	return EventMachine->ConnectToServer (server, port);
}

/***************************
evma_connect_to_unix_server
***************************/

extern "C" const char *evma_connect_to_unix_server (const char *server)
{
	ensure_eventmachine("evma_connect_to_unix_server");
	return EventMachine->ConnectToUnixServer (server);
}

/**************
evma_attach_fd
**************/

extern "C" const char *evma_attach_fd (int file_descriptor, int notify_readable, int notify_writable)
{
	ensure_eventmachine("evma_attach_fd");
	return EventMachine->AttachFD (file_descriptor, (notify_readable ? true : false), (notify_writable ? true : false));
}

/**************
evma_detach_fd
**************/

extern "C" int evma_detach_fd (const char *binding)
{
	ensure_eventmachine("evma_dettach_fd");
	EventableDescriptor *ed = dynamic_cast <EventableDescriptor*> (Bindable_t::GetObject (binding));
	if (ed)
		return EventMachine->DetachFD (ed);
	else
		#ifdef BUILD_FOR_RUBY
			rb_raise(rb_eRuntimeError, "invalid binding to detach");
		#else
			throw std::runtime_error ("invalid binding to detach");
		#endif
}

/**********************
evma_create_tcp_server
**********************/

extern "C" const char *evma_create_tcp_server (const char *address, int port)
{
	ensure_eventmachine("evma_create_tcp_server");
	return EventMachine->CreateTcpServer (address, port);
}

/******************************
evma_create_unix_domain_server
******************************/

extern "C" const char *evma_create_unix_domain_server (const char *filename)
{
	ensure_eventmachine("evma_create_unix_domain_server");
	return EventMachine->CreateUnixDomainServer (filename);
}

/*************************
evma_open_datagram_socket
*************************/

extern "C" const char *evma_open_datagram_socket (const char *address, int port)
{
	ensure_eventmachine("evma_open_datagram_socket");
	return EventMachine->OpenDatagramSocket (address, port);
}

/******************
evma_open_keyboard
******************/

extern "C" const char *evma_open_keyboard()
{
	ensure_eventmachine("evma_open_keyboard");
	return EventMachine->OpenKeyboard();
}



/****************************
evma_send_data_to_connection
****************************/

extern "C" int evma_send_data_to_connection (const char *binding, const char *data, int data_length)
{
	ensure_eventmachine("evma_send_data_to_connection");
	return ConnectionDescriptor::SendDataToConnection (binding, data, data_length);
}

/******************
evma_send_datagram
******************/

extern "C" int evma_send_datagram (const char *binding, const char *data, int data_length, const char *address, int port)
{
	ensure_eventmachine("evma_send_datagram");
	return DatagramDescriptor::SendDatagram (binding, data, data_length, address, port);
}


/*********************
evma_close_connection
*********************/

extern "C" void evma_close_connection (const char *binding, int after_writing)
{
	ensure_eventmachine("evma_close_connection");
	ConnectionDescriptor::CloseConnection (binding, (after_writing ? true : false));
}

/***********************************
evma_report_connection_error_status
***********************************/

extern "C" int evma_report_connection_error_status (const char *binding)
{
	ensure_eventmachine("evma_report_connection_error_status");
	return ConnectionDescriptor::ReportErrorStatus (binding);
}

/********************
evma_stop_tcp_server
********************/

extern "C" void evma_stop_tcp_server (const char *binding)
{
	ensure_eventmachine("evma_stop_tcp_server");
	AcceptorDescriptor::StopAcceptor (binding);
}


/*****************
evma_stop_machine
*****************/

extern "C" void evma_stop_machine()
{
	ensure_eventmachine("evma_stop_machine");
	EventMachine->ScheduleHalt();
}


/**************
evma_start_tls
**************/

extern "C" void evma_start_tls (const char *binding)
{
	ensure_eventmachine("evma_start_tls");
	EventableDescriptor *ed = dynamic_cast <EventableDescriptor*> (Bindable_t::GetObject (binding));
	if (ed)
		ed->StartTls();
}

/******************
evma_set_tls_parms
******************/

extern "C" void evma_set_tls_parms (const char *binding, const char *privatekey_filename, const char *certchain_filename)
{
	ensure_eventmachine("evma_set_tls_parms");
	EventableDescriptor *ed = dynamic_cast <EventableDescriptor*> (Bindable_t::GetObject (binding));
	if (ed)
		ed->SetTlsParms (privatekey_filename, certchain_filename);
}


/*****************
evma_get_peername
*****************/

extern "C" int evma_get_peername (const char *binding, struct sockaddr *sa)
{
	ensure_eventmachine("evma_get_peername");
	EventableDescriptor *ed = dynamic_cast <EventableDescriptor*> (Bindable_t::GetObject (binding));
	if (ed) {
		return ed->GetPeername (sa) ? 1 : 0;
	}
	else
		return 0;
}

/*****************
evma_get_sockname
*****************/

extern "C" int evma_get_sockname (const char *binding, struct sockaddr *sa)
{
	ensure_eventmachine("evma_get_sockname");
	EventableDescriptor *ed = dynamic_cast <EventableDescriptor*> (Bindable_t::GetObject (binding));
	if (ed) {
		return ed->GetSockname (sa) ? 1 : 0;
	}
	else
		return 0;
}

/***********************
evma_get_subprocess_pid
***********************/

extern "C" int evma_get_subprocess_pid (const char *binding, pid_t *pid)
{
	ensure_eventmachine("evma_get_subprocess_pid");
	EventableDescriptor *ed = dynamic_cast <EventableDescriptor*> (Bindable_t::GetObject (binding));
	if (ed) {
		return ed->GetSubprocessPid (pid) ? 1 : 0;
	}
	else
		return 0;
}

/**************************
evma_get_subprocess_status
**************************/

extern "C" int evma_get_subprocess_status (const char *binding, int *status)
{
	ensure_eventmachine("evma_get_subprocess_status");
	if (status) {
		*status = EventMachine->SubprocessExitStatus;
		return 1;
	}
	else
		return 0;
}


/*********************
evma_signal_loopbreak
*********************/

extern "C" void evma_signal_loopbreak()
{
	ensure_eventmachine("evma_signal_loopbreak");
	EventMachine->SignalLoopBreaker();
}



/****************
evma__write_file
****************/

extern "C" const char *evma__write_file (const char *filename)
{
	ensure_eventmachine("evma__write_file");
	return EventMachine->_OpenFileForWriting (filename);
}


/********************************
evma_get_comm_inactivity_timeout
********************************/

extern "C" int evma_get_comm_inactivity_timeout (const char *binding, int *value)
{
	ensure_eventmachine("evma_get_comm_inactivity_timeout");
	EventableDescriptor *ed = dynamic_cast <EventableDescriptor*> (Bindable_t::GetObject (binding));
	if (ed) {
		return ed->GetCommInactivityTimeout (value);
	}
	else
		return 0; //Perhaps this should be an exception. Access to an unknown binding.
}

/********************************
evma_set_comm_inactivity_timeout
********************************/

extern "C" int evma_set_comm_inactivity_timeout (const char *binding, int *value)
{
	ensure_eventmachine("evma_set_comm_inactivity_timeout");
	EventableDescriptor *ed = dynamic_cast <EventableDescriptor*> (Bindable_t::GetObject (binding));
	if (ed) {
		return ed->SetCommInactivityTimeout (value);
	}
	else
		return 0; //Perhaps this should be an exception. Access to an unknown binding.
}


/**********************
evma_set_timer_quantum
**********************/

extern "C" void evma_set_timer_quantum (int interval)
{
	ensure_eventmachine("evma_set_timer_quantum");
	EventMachine->SetTimerQuantum (interval);
}

/************************
evma_set_max_timer_count
************************/

extern "C" void evma_set_max_timer_count (int ct)
{
	// This may only be called if the reactor is not running.

	if (EventMachine)
		#ifdef BUILD_FOR_RUBY
			rb_raise(rb_eRuntimeError, "eventmachine already initialized: evma_set_max_timer_count");
		#else
			throw std::runtime_error ("eventmachine already initialized: evma_set_max_timer_count");
		#endif
	EventMachine_t::SetMaxTimerCount (ct);
}

/******************
evma_setuid_string
******************/

extern "C" void evma_setuid_string (const char *username)
{
	// We do NOT need to be running an EM instance because this method is static.
	EventMachine_t::SetuidString (username);
}


/**********
evma_popen
**********/

extern "C" const char *evma_popen (char * const*cmd_strings)
{
	ensure_eventmachine("evma_popen");
	return EventMachine->Socketpair (cmd_strings);
}


/***************************
evma_get_outbound_data_size
***************************/

extern "C" int evma_get_outbound_data_size (const char *binding)
{
	ensure_eventmachine("evma_get_outbound_data_size");
	EventableDescriptor *ed = dynamic_cast <EventableDescriptor*> (Bindable_t::GetObject (binding));
	return ed ? ed->GetOutboundDataSize() : 0;
}


/***********
evma__epoll
***********/

extern "C" void evma__epoll()
{
	bUseEpoll = 1;
}

/************
evma__kqueue
************/

extern "C" void evma__kqueue()
{
	bUseKqueue = 1;
}


/**********************
evma_set_rlimit_nofile
**********************/

extern "C" int evma_set_rlimit_nofile (int nofiles)
{
	return EventMachine_t::SetRlimitNofile (nofiles);
}


/*********************************
evma_send_file_data_to_connection
*********************************/

extern "C" int evma_send_file_data_to_connection (const char *binding, const char *filename)
{
	/* This is a sugaring over send_data_to_connection that reads a file into a
	 * locally-allocated buffer, and sends the file data to the remote peer.
	 * Return the number of bytes written to the caller.
	 * TODO, needs to impose a limit on the file size. This is intended only for
	 * small files. (I don't know, maybe 8K or less.) For larger files, use interleaved
	 * I/O to avoid slowing the rest of the system down.
	 * TODO: we should return a code rather than barf, in case of file-not-found.
	 * TODO, does this compile on Windows?
	 * TODO, given that we want this to work only with small files, how about allocating
	 * the buffer on the stack rather than the heap?
	 *
	 * Modified 25Jul07. This now returns -1 on file-too-large; 0 for success, and a positive
	 * errno in case of other errors.
	 *
	/* Contributed by Kirk Haines.
	 */

	char data[32*1024];
	int r;

	ensure_eventmachine("evma_send_file_data_to_connection");

	int Fd = open (filename, O_RDONLY);

	if (Fd < 0)
		return errno;
	// From here on, all early returns MUST close Fd.

	struct stat st;
	if (fstat (Fd, &st)) {
		int e = errno;
		close (Fd);
		return e;
	}

	int filesize = st.st_size;
	if (filesize <= 0) {
		close (Fd);
		return 0;
	}
	else if (filesize > sizeof(data)) {
		close (Fd);
		return -1;
	}


	r = read (Fd, data, filesize);
	if (r != filesize) {
		int e = errno;
		close (Fd);
		return e;
	}
	evma_send_data_to_connection (binding, data, r);
	close (Fd);

	return 0;
}

/*****************************************************************************

$Id$

File:     cplusplus.cpp
Date:     27Jul07

Copyright (C) 2006-07 by Francis Cianfrocca. All Rights Reserved.
Gmail: blackhedd

This program is free software; you can redistribute it and/or modify
it under the terms of either: 1) the GNU General Public License
as published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version; or 2) Ruby's License.

See the file COPYING for complete licensing information.

*****************************************************************************/


#include "project.h"


namespace EM {
	static map<string, Eventable*> Eventables;
	static map<string, void(*)()> Timers;
}


/*******
EM::Run
*******/

void EM::Run (void (*start_func)())
{
	evma__epoll();
	evma_initialize_library (EM::Callback);
	if (start_func)
		AddTimer (0, start_func);
	evma_run_machine();
	evma_release_library();
}

/************
EM::AddTimer
************/

void EM::AddTimer (int milliseconds, void (*func)())
{
	if (func) {
		const char *sig = evma_install_oneshot_timer (milliseconds);
		Timers.insert (make_pair (sig, func));
	}
}


/***************
EM::StopReactor
***************/

void EM::StopReactor()
{
	evma_stop_machine();
}


/********************
EM::Acceptor::Accept
********************/

void EM::Acceptor::Accept (const char *signature)
{
	Connection *c = MakeConnection();
	c->Signature = signature;
	Eventables.insert (make_pair (c->Signature, c));
	c->PostInit();
}

/************************
EM::Connection::SendData
************************/

void EM::Connection::SendData (const char *data)
{
	if (data)
		SendData (data, strlen (data));
}


/************************
EM::Connection::SendData
************************/

void EM::Connection::SendData (const char *data, int length)
{
	evma_send_data_to_connection (Signature.c_str(), data, length);
}


/*********************
EM::Connection::Close
*********************/

void EM::Connection::Close (bool afterWriting)
{
	evma_close_connection (Signature.c_str(), afterWriting);
}


/***********************
EM::Connection::Connect
***********************/

void EM::Connection::Connect (const char *host, int port)
{
	Signature = evma_connect_to_server (host, port);
	Eventables.insert( make_pair (Signature, this));
}

/*******************
EM::Acceptor::Start
*******************/

void EM::Acceptor::Start (const char *host, int port)
{
	Signature = evma_create_tcp_server (host, port);
	Eventables.insert( make_pair (Signature, this));
}



/************
EM::Callback
************/

void EM::Callback (const char *sig, int ev, const char *data, int length)
{
	EM::Eventable *e;
	void (*f)();

	switch (ev) {
		case EM_TIMER_FIRED:
			f = Timers [data];
			if (f)
				(*f)();
			Timers.erase (sig);
			break;

		case EM_CONNECTION_READ:
			e = EM::Eventables [sig];
			e->ReceiveData (data, length);
			break;

		case EM_CONNECTION_COMPLETED:
			e = EM::Eventables [sig];
			e->ConnectionCompleted();
			break;

		case EM_CONNECTION_ACCEPTED:
			e = EM::Eventables [sig];
			e->Accept (data);
			break;

		case EM_CONNECTION_UNBOUND:
			e = EM::Eventables [sig];
			e->Unbind();
			EM::Eventables.erase (sig);
			delete e;
			break;
	}
}

/*****************************************************************************

$Id$

File:     ed.cpp
Date:     06Apr06

Copyright (C) 2006-07 by Francis Cianfrocca. All Rights Reserved.
Gmail: blackhedd

This program is free software; you can redistribute it and/or modify
it under the terms of either: 1) the GNU General Public License
as published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version; or 2) Ruby's License.

See the file COPYING for complete licensing information.

*****************************************************************************/

#include "project.h"



/********************
SetSocketNonblocking
********************/

bool SetSocketNonblocking (SOCKET sd)
{
	#ifdef OS_UNIX
	int val = fcntl (sd, F_GETFL, 0);
	return (fcntl (sd, F_SETFL, val | O_NONBLOCK) != SOCKET_ERROR) ? true : false;
	#endif
	
	#ifdef OS_WIN32
	unsigned long one = 1;
	return (ioctlsocket (sd, FIONBIO, &one) == 0) ? true : false;
	#endif
}


/****************************************
EventableDescriptor::EventableDescriptor
****************************************/

EventableDescriptor::EventableDescriptor (int sd, EventMachine_t *em):
	bCloseNow (false),
	bCloseAfterWriting (false),
	MySocket (sd),
	EventCallback (NULL),
	LastRead (0),
	LastWritten (0),
	bCallbackUnbind (true),
	MyEventMachine (em)
{
	/* There are three ways to close a socket, all of which should
	 * automatically signal to the event machine that this object
	 * should be removed from the polling scheduler.
	 * First is a hard close, intended for bad errors or possible
	 * security violations. It immediately closes the connection
	 * and puts this object into an error state.
	 * Second is to set bCloseNow, which will cause the event machine
	 * to delete this object (and thus close the connection in our
	 * destructor) the next chance it gets. bCloseNow also inhibits
	 * the writing of new data on the socket (but not necessarily
	 * the reading of new data).
	 * The third way is to set bCloseAfterWriting, which inhibits
	 * the writing of new data and converts to bCloseNow as soon
	 * as everything in the outbound queue has been written.
	 * bCloseAfterWriting is really for use only by protocol handlers
	 * (for example, HTTP writes an HTML page and then closes the
	 * connection). All of the error states we generate internally
	 * cause an immediate close to be scheduled, which may have the
	 * effect of discarding outbound data.
	 */

	if (sd == INVALID_SOCKET)
		throw std::runtime_error ("bad eventable descriptor");
	if (MyEventMachine == NULL)
		throw std::runtime_error ("bad em in eventable descriptor");
	CreatedAt = gCurrentLoopTime;

	#ifdef HAVE_EPOLL
	EpollEvent.data.ptr = this;
	#endif
}


/*****************************************
EventableDescriptor::~EventableDescriptor
*****************************************/

EventableDescriptor::~EventableDescriptor()
{
	if (EventCallback && bCallbackUnbind)
		(*EventCallback)(GetBinding().c_str(), EM_CONNECTION_UNBOUND, NULL, 0);
	Close();
}


/*************************************
EventableDescriptor::SetEventCallback
*************************************/

void EventableDescriptor::SetEventCallback (void(*cb)(const char*, int, const char*, int))
{
	EventCallback = cb;
}


/**************************
EventableDescriptor::Close
**************************/

void EventableDescriptor::Close()
{
	// Close the socket right now. Intended for emergencies.
	if (MySocket != INVALID_SOCKET) {
		shutdown (MySocket, 1);
		closesocket (MySocket);
		MySocket = INVALID_SOCKET;
	}
}


/*********************************
EventableDescriptor::ShouldDelete
*********************************/

bool EventableDescriptor::ShouldDelete()
{
	/* For use by a socket manager, which needs to know if this object
	 * should be removed from scheduling events and deleted.
	 * Has an immediate close been scheduled, or are we already closed?
	 * If either of these are the case, return true. In theory, the manager will
	 * then delete us, which in turn will make sure the socket is closed.
	 * Note, if bCloseAfterWriting is true, we check a virtual method to see
	 * if there is outbound data to write, and only request a close if there is none.
	 */

	return ((MySocket == INVALID_SOCKET) || bCloseNow || (bCloseAfterWriting && (GetOutboundDataSize() <= 0)));
}


/**********************************
EventableDescriptor::ScheduleClose
**********************************/

void EventableDescriptor::ScheduleClose (bool after_writing)
{
	// KEEP THIS SYNCHRONIZED WITH ::IsCloseScheduled.
	if (after_writing)
		bCloseAfterWriting = true;
	else
		bCloseNow = true;
}


/*************************************
EventableDescriptor::IsCloseScheduled
*************************************/

bool EventableDescriptor::IsCloseScheduled()
{
	// KEEP THIS SYNCHRONIZED WITH ::ScheduleClose.
	return (bCloseNow || bCloseAfterWriting);
}


/******************************************
ConnectionDescriptor::ConnectionDescriptor
******************************************/

ConnectionDescriptor::ConnectionDescriptor (int sd, EventMachine_t *em):
	EventableDescriptor (sd, em),
	bConnectPending (false),
	bNotifyReadable (false),
	bNotifyWritable (false),
	bReadAttemptedAfterClose (false),
	bWriteAttemptedAfterClose (false),
	OutboundDataSize (0),
	#ifdef WITH_SSL
	SslBox (NULL),
	#endif
	bIsServer (false),
	LastIo (gCurrentLoopTime),
	InactivityTimeout (0)
{
	#ifdef HAVE_EPOLL
	EpollEvent.events = EPOLLOUT;
	#endif
	// 22Jan09: Moved ArmKqueueWriter into SetConnectPending() to fix assertion failure in _WriteOutboundData()
}


/*******************************************
ConnectionDescriptor::~ConnectionDescriptor
*******************************************/

ConnectionDescriptor::~ConnectionDescriptor()
{
	// Run down any stranded outbound data.
	for (size_t i=0; i < OutboundPages.size(); i++)
		OutboundPages[i].Free();

	#ifdef WITH_SSL
	if (SslBox)
		delete SslBox;
	#endif
}


/**************************************************
STATIC: ConnectionDescriptor::SendDataToConnection
**************************************************/

int ConnectionDescriptor::SendDataToConnection (const char *binding, const char *data, int data_length)
{
	// TODO: This is something of a hack, or at least it's a static method of the wrong class.
	// TODO: Poor polymorphism here. We should be calling one virtual method
	// instead of hacking out the runtime information of the target object.
	ConnectionDescriptor *cd = dynamic_cast <ConnectionDescriptor*> (Bindable_t::GetObject (binding));
	if (cd)
		return cd->SendOutboundData (data, data_length);
	DatagramDescriptor *ds = dynamic_cast <DatagramDescriptor*> (Bindable_t::GetObject (binding));
	if (ds)
		return ds->SendOutboundData (data, data_length);
	#ifdef OS_UNIX
	PipeDescriptor *ps = dynamic_cast <PipeDescriptor*> (Bindable_t::GetObject (binding));
	if (ps)
		return ps->SendOutboundData (data, data_length);
	#endif
	return -1;
}


/*********************************************
STATIC: ConnectionDescriptor::CloseConnection
*********************************************/

void ConnectionDescriptor::CloseConnection (const char *binding, bool after_writing)
{
	// TODO: This is something of a hack, or at least it's a static method of the wrong class.
	EventableDescriptor *ed = dynamic_cast <EventableDescriptor*> (Bindable_t::GetObject (binding));
	if (ed)
		ed->ScheduleClose (after_writing);
}

/***********************************************
STATIC: ConnectionDescriptor::ReportErrorStatus
***********************************************/

int ConnectionDescriptor::ReportErrorStatus (const char *binding)
{
	// TODO: This is something of a hack, or at least it's a static method of the wrong class.
	// TODO: Poor polymorphism here. We should be calling one virtual method
	// instead of hacking out the runtime information of the target object.
	ConnectionDescriptor *cd = dynamic_cast <ConnectionDescriptor*> (Bindable_t::GetObject (binding));
	if (cd)
		return cd->_ReportErrorStatus();
	return -1;
}

/***************************************
ConnectionDescriptor::SetConnectPending
****************************************/

void ConnectionDescriptor::SetConnectPending(bool f)
{
	bConnectPending = f;
	#ifdef HAVE_KQUEUE
	MyEventMachine->ArmKqueueWriter (this);
	#endif
}


/**************************************
ConnectionDescriptor::SendOutboundData
**************************************/

int ConnectionDescriptor::SendOutboundData (const char *data, int length)
{
	#ifdef WITH_SSL
	if (SslBox) {
		if (length > 0) {
			int w = SslBox->PutPlaintext (data, length);
			if (w < 0)
				ScheduleClose (false);
			else
				_DispatchCiphertext();
		}
		// TODO: What's the correct return value?
		return 1; // That's a wild guess, almost certainly wrong.
	}
	else
	#endif
		return _SendRawOutboundData (data, length);
}



/******************************************
ConnectionDescriptor::_SendRawOutboundData
******************************************/

int ConnectionDescriptor::_SendRawOutboundData (const char *data, int length)
{
	/* This internal method is called to schedule bytes that
	 * will be sent out to the remote peer.
	 * It's not directly accessed by the caller, who hits ::SendOutboundData,
	 * which may or may not filter or encrypt the caller's data before
	 * sending it here.
	 */

	// Highly naive and incomplete implementation.
	// There's no throttle for runaways (which should abort only this connection
	// and not the whole process), and no coalescing of small pages.
	// (Well, not so bad, small pages are coalesced in ::Write)

	if (IsCloseScheduled())
	//if (bCloseNow || bCloseAfterWriting)
		return 0;

	if (!data && (length > 0))
		throw std::runtime_error ("bad outbound data");
	char *buffer = (char *) malloc (length + 1);
	if (!buffer)
		throw std::runtime_error ("no allocation for outbound data");
	memcpy (buffer, data, length);
	buffer [length] = 0;
	OutboundPages.push_back (OutboundPage (buffer, length));
	OutboundDataSize += length;
	#ifdef HAVE_EPOLL
	EpollEvent.events = (EPOLLIN | EPOLLOUT);
	assert (MyEventMachine);
	MyEventMachine->Modify (this);
	#endif
	#ifdef HAVE_KQUEUE
	MyEventMachine->ArmKqueueWriter (this);
	#endif
	return length;
}



/***********************************
ConnectionDescriptor::SelectForRead
***********************************/

bool ConnectionDescriptor::SelectForRead()
{
  /* A connection descriptor is always scheduled for read,
   * UNLESS it's in a pending-connect state.
   * On Linux, unlike Unix, a nonblocking socket on which
   * connect has been called, does NOT necessarily select
   * both readable and writable in case of error.
   * The socket will select writable when the disposition
   * of the connect is known. On the other hand, a socket
   * which successfully connects and selects writable may
   * indeed have some data available on it, so it will
   * select readable in that case, violating expectations!
   * So we will not poll for readability until the socket
   * is known to be in a connected state.
   */

  return bConnectPending ? false : true;
}


/************************************
ConnectionDescriptor::SelectForWrite
************************************/

bool ConnectionDescriptor::SelectForWrite()
{
  /* Cf the notes under SelectForRead.
   * In a pending-connect state, we ALWAYS select for writable.
   * In a normal state, we only select for writable when we
   * have outgoing data to send.
   */

  if (bConnectPending || bNotifyWritable)
    return true;
  else {
    return (GetOutboundDataSize() > 0);
  }
}


/**************************
ConnectionDescriptor::Read
**************************/

void ConnectionDescriptor::Read()
{
	/* Read and dispatch data on a socket that has selected readable.
	 * It's theoretically possible to get and dispatch incoming data on
	 * a socket that has already been scheduled for closing or close-after-writing.
	 * In those cases, we'll leave it up the to protocol handler to "do the
	 * right thing" (which probably means to ignore the incoming data).
	 *
	 * 22Aug06: Chris Ochs reports that on FreeBSD, it's possible to come
	 * here with the socket already closed, after the process receives
	 * a ctrl-C signal (not sure if that's TERM or INT on BSD). The application
	 * was one in which network connections were doing a lot of interleaved reads
	 * and writes.
	 * Since we always write before reading (in order to keep the outbound queues
	 * as light as possible), I think what happened is that an interrupt caused
	 * the socket to be closed in ConnectionDescriptor::Write. We'll then
	 * come here in the same pass through the main event loop, and won't get
	 * cleaned up until immediately after.
	 * We originally asserted that the socket was valid when we got here.
	 * To deal properly with the possibility that we are closed when we get here,
	 * I removed the assert. HOWEVER, the potential for an infinite loop scares me,
	 * so even though this is really clunky, I added a flag to assert that we never
	 * come here more than once after being closed. (FCianfrocca)
	 */

	int sd = GetSocket();
	//assert (sd != INVALID_SOCKET); (original, removed 22Aug06)
	if (sd == INVALID_SOCKET) {
		assert (!bReadAttemptedAfterClose);
		bReadAttemptedAfterClose = true;
		return;
	}

	if (bNotifyReadable) {
		if (EventCallback)
			(*EventCallback)(GetBinding().c_str(), EM_CONNECTION_NOTIFY_READABLE, NULL, 0);
		return;
	}

	LastIo = gCurrentLoopTime;

	int total_bytes_read = 0;
	char readbuffer [16 * 1024 + 1];

	for (int i=0; i < 10; i++) {
		// Don't read just one buffer and then move on. This is faster
		// if there is a lot of incoming.
		// But don't read indefinitely. Give other sockets a chance to run.
		// NOTICE, we're reading one less than the buffer size.
		// That's so we can put a guard byte at the end of what we send
		// to user code.
		

		int r = recv (sd, readbuffer, sizeof(readbuffer) - 1, 0);
		//cerr << "<R:" << r << ">";

		if (r > 0) {
			total_bytes_read += r;
			LastRead = gCurrentLoopTime;

			// Add a null-terminator at the the end of the buffer
			// that we will send to the callback.
			// DO NOT EVER CHANGE THIS. We want to explicitly allow users
			// to be able to depend on this behavior, so they will have
			// the option to do some things faster. Additionally it's
			// a security guard against buffer overflows.
			readbuffer [r] = 0;
			_DispatchInboundData (readbuffer, r);
		}
		else if (r == 0) {
			break;
		}
		else {
			// Basically a would-block, meaning we've read everything there is to read.
			break;
		}

	}


	if (total_bytes_read == 0) {
		// If we read no data on a socket that selected readable,
		// it generally means the other end closed the connection gracefully.
		ScheduleClose (false);
		//bCloseNow = true;
	}

}



/******************************************
ConnectionDescriptor::_DispatchInboundData
******************************************/

void ConnectionDescriptor::_DispatchInboundData (const char *buffer, int size)
{
	#ifdef WITH_SSL
	if (SslBox) {
		SslBox->PutCiphertext (buffer, size);

		int s;
		char B [2048];
		while ((s = SslBox->GetPlaintext (B, sizeof(B) - 1)) > 0) {
			B [s] = 0;
			if (EventCallback)
				(*EventCallback)(GetBinding().c_str(), EM_CONNECTION_READ, B, s);
		}
		// INCOMPLETE, s may indicate an SSL error that would force the connection down.
		_DispatchCiphertext();
	}
	else {
			if (EventCallback)
				(*EventCallback)(GetBinding().c_str(), EM_CONNECTION_READ, buffer, size);
	}
	#endif

	#ifdef WITHOUT_SSL
	if (EventCallback)
		(*EventCallback)(GetBinding().c_str(), EM_CONNECTION_READ, buffer, size);
	#endif
}





/***************************
ConnectionDescriptor::Write
***************************/

void ConnectionDescriptor::Write()
{
	/* A socket which is in a pending-connect state will select
	 * writable when the disposition of the connect is known.
	 * At that point, check to be sure there are no errors,
	 * and if none, then promote the socket out of the pending
	 * state.
	 * TODO: I haven't figured out how Windows signals errors on
	 * unconnected sockets. Maybe it does the untraditional but
	 * logical thing and makes the socket selectable for error.
	 * If so, it's unsupported here for the time being, and connect
	 * errors will have to be caught by the timeout mechanism.
	 */

	if (bConnectPending) {
		int error;
		socklen_t len;
		len = sizeof(error);
		#ifdef OS_UNIX
		int o = getsockopt (GetSocket(), SOL_SOCKET, SO_ERROR, &error, &len);
		#endif
		#ifdef OS_WIN32
		int o = getsockopt (GetSocket(), SOL_SOCKET, SO_ERROR, (char*)&error, &len);
		#endif
		if ((o == 0) && (error == 0)) {
			if (EventCallback)
				(*EventCallback)(GetBinding().c_str(), EM_CONNECTION_COMPLETED, "", 0);
			bConnectPending = false;
			#ifdef HAVE_EPOLL
			// The callback may have scheduled outbound data.
			EpollEvent.events = EPOLLIN | (SelectForWrite() ? EPOLLOUT : 0);
			#endif
			#ifdef HAVE_KQUEUE
			MyEventMachine->ArmKqueueReader (this);
			// The callback may have scheduled outbound data.
			if (SelectForWrite())
				MyEventMachine->ArmKqueueWriter (this);
			#endif
		}
		else
			ScheduleClose (false);
			//bCloseNow = true;
	}
	else {

		if (bNotifyWritable) {
			if (EventCallback)
				(*EventCallback)(GetBinding().c_str(), EM_CONNECTION_NOTIFY_WRITABLE, NULL, 0);
			return;
		}

		_WriteOutboundData();
	}
}


/****************************************
ConnectionDescriptor::_WriteOutboundData
****************************************/

void ConnectionDescriptor::_WriteOutboundData()
{
	/* This is a helper function called by ::Write.
	 * It's possible for a socket to select writable and then no longer
	 * be writable by the time we get around to writing. The kernel might
	 * have used up its available output buffers between the select call
	 * and when we get here. So this condition is not an error.
	 *
	 * 20Jul07, added the same kind of protection against an invalid socket
	 * that is at the top of ::Read. Not entirely how this could happen in 
	 * real life (connection-reset from the remote peer, perhaps?), but I'm
	 * doing it to address some reports of crashing under heavy loads.
	 */

	int sd = GetSocket();
	//assert (sd != INVALID_SOCKET);
	if (sd == INVALID_SOCKET) {
		assert (!bWriteAttemptedAfterClose);
		bWriteAttemptedAfterClose = true;
		return;
	}

	LastIo = gCurrentLoopTime;
	char output_buffer [16 * 1024];
	size_t nbytes = 0;

	while ((OutboundPages.size() > 0) && (nbytes < sizeof(output_buffer))) {
		OutboundPage *op = &(OutboundPages[0]);
		if ((nbytes + op->Length - op->Offset) < sizeof (output_buffer)) {
			memcpy (output_buffer + nbytes, op->Buffer + op->Offset, op->Length - op->Offset);
			nbytes += (op->Length - op->Offset);
			op->Free();
			OutboundPages.pop_front();
		}
		else {
			int len = sizeof(output_buffer) - nbytes;
			memcpy (output_buffer + nbytes, op->Buffer + op->Offset, len);
			op->Offset += len;
			nbytes += len;
		}
	}

	// We should never have gotten here if there were no data to write,
	// so assert that as a sanity check.
	// Don't bother to make sure nbytes is less than output_buffer because
	// if it were we probably would have crashed already.
	assert (nbytes > 0);

	assert (GetSocket() != INVALID_SOCKET);
	int bytes_written = send (GetSocket(), output_buffer, nbytes, 0);

	bool err = false;
	if (bytes_written < 0) {
		err = true;
		bytes_written = 0;
	}

	assert (bytes_written >= 0);
	OutboundDataSize -= bytes_written;
	if ((size_t)bytes_written < nbytes) {
		int len = nbytes - bytes_written;
		char *buffer = (char*) malloc (len + 1);
		if (!buffer)
			throw std::runtime_error ("bad alloc throwing back data");
		memcpy (buffer, output_buffer + bytes_written, len);
		buffer [len] = 0;
		OutboundPages.push_front (OutboundPage (buffer, len));
	}

	#ifdef HAVE_EPOLL
	EpollEvent.events = (EPOLLIN | (SelectForWrite() ? EPOLLOUT : 0));
	assert (MyEventMachine);
	MyEventMachine->Modify (this);
	#endif
	#ifdef HAVE_KQUEUE
	if (SelectForWrite())
		MyEventMachine->ArmKqueueWriter (this);
	#endif


	if (err) {
		#ifdef OS_UNIX
		if ((errno != EINPROGRESS) && (errno != EWOULDBLOCK) && (errno != EINTR))
		#endif
		#ifdef OS_WIN32
		if ((errno != WSAEINPROGRESS) && (errno != WSAEWOULDBLOCK))
		#endif
			Close();
	}
}


/****************************************
ConnectionDescriptor::_ReportErrorStatus
****************************************/

int ConnectionDescriptor::_ReportErrorStatus()
{
	int error;
	socklen_t len;
	len = sizeof(error);
	#ifdef OS_UNIX
	int o = getsockopt (GetSocket(), SOL_SOCKET, SO_ERROR, &error, &len);
	#endif
	#ifdef OS_WIN32
	int o = getsockopt (GetSocket(), SOL_SOCKET, SO_ERROR, (char*)&error, &len);
	#endif
	if ((o == 0) && (error == 0))
		return 0;
	else
		return 1;
}


/******************************
ConnectionDescriptor::StartTls
******************************/

void ConnectionDescriptor::StartTls()
{
	#ifdef WITH_SSL
	if (SslBox)
		throw std::runtime_error ("SSL/TLS already running on connection");

	SslBox = new SslBox_t (bIsServer, PrivateKeyFilename, CertChainFilename);
	_DispatchCiphertext();
	#endif

	#ifdef WITHOUT_SSL
	throw std::runtime_error ("Encryption not available on this event-machine");
	#endif
}


/*********************************
ConnectionDescriptor::SetTlsParms
*********************************/

void ConnectionDescriptor::SetTlsParms (const char *privkey_filename, const char *certchain_filename)
{
	#ifdef WITH_SSL
	if (SslBox)
		throw std::runtime_error ("call SetTlsParms before calling StartTls");
	if (privkey_filename && *privkey_filename)
		PrivateKeyFilename = privkey_filename;
	if (certchain_filename && *certchain_filename)
		CertChainFilename = certchain_filename;
	#endif

	#ifdef WITHOUT_SSL
	throw std::runtime_error ("Encryption not available on this event-machine");
	#endif
}



/*****************************************
ConnectionDescriptor::_DispatchCiphertext
*****************************************/
#ifdef WITH_SSL
void ConnectionDescriptor::_DispatchCiphertext()
{
	assert (SslBox);


	char BigBuf [2048];
	bool did_work;

	do {
		did_work = false;

		// try to drain ciphertext
		while (SslBox->CanGetCiphertext()) {
			int r = SslBox->GetCiphertext (BigBuf, sizeof(BigBuf));
			assert (r > 0);
			_SendRawOutboundData (BigBuf, r);
			did_work = true;
		}

		// Pump the SslBox, in case it has queued outgoing plaintext
		// This will return >0 if data was written,
		// 0 if no data was written, and <0 if there was a fatal error.
		bool pump;
		do {
			pump = false;
			int w = SslBox->PutPlaintext (NULL, 0);
			if (w > 0) {
				did_work = true;
				pump = true;
			}
			else if (w < 0)
				ScheduleClose (false);
		} while (pump);

		// try to put plaintext. INCOMPLETE, doesn't belong here?
		// In SendOutboundData, we're spooling plaintext directly
		// into SslBox. That may be wrong, we may need to buffer it
		// up here! 
		/*
		const char *ptr;
		int ptr_length;
		while (OutboundPlaintext.GetPage (&ptr, &ptr_length)) {
			assert (ptr && (ptr_length > 0));
			int w = SslMachine.PutPlaintext (ptr, ptr_length);
			if (w > 0) {
				OutboundPlaintext.DiscardBytes (w);
				did_work = true;
			}
			else
				break;
		}
		*/

	} while (did_work);

}
#endif



/*******************************
ConnectionDescriptor::Heartbeat
*******************************/

void ConnectionDescriptor::Heartbeat()
{
	/* Only allow a certain amount of time to go by while waiting
	 * for a pending connect. If it expires, then kill the socket.
	 * For a connected socket, close it if its inactivity timer
	 * has expired.
	 */

	if (bConnectPending) {
		if ((gCurrentLoopTime - CreatedAt) >= PendingConnectTimeout)
			ScheduleClose (false);
			//bCloseNow = true;
	}
	else {
		if (InactivityTimeout && ((gCurrentLoopTime - LastIo) >= InactivityTimeout))
			ScheduleClose (false);
			//bCloseNow = true;
	}
}


/****************************************
LoopbreakDescriptor::LoopbreakDescriptor
****************************************/

LoopbreakDescriptor::LoopbreakDescriptor (int sd, EventMachine_t *parent_em):
	EventableDescriptor (sd, parent_em)
{
	/* This is really bad and ugly. Change someday if possible.
	 * We have to know about an event-machine (probably the one that owns us),
	 * so we can pass newly-created connections to it.
	 */

	bCallbackUnbind = false;

	#ifdef HAVE_EPOLL
	EpollEvent.events = EPOLLIN;
	#endif
	#ifdef HAVE_KQUEUE
	MyEventMachine->ArmKqueueReader (this);
	#endif
}




/*************************
LoopbreakDescriptor::Read
*************************/

void LoopbreakDescriptor::Read()
{
	// TODO, refactor, this code is probably in the wrong place.
	assert (MyEventMachine);
	MyEventMachine->_ReadLoopBreaker();
}


/**************************
LoopbreakDescriptor::Write
**************************/

void LoopbreakDescriptor::Write()
{
  // Why are we here?
  throw std::runtime_error ("bad code path in loopbreak");
}

/**************************************
AcceptorDescriptor::AcceptorDescriptor
**************************************/

AcceptorDescriptor::AcceptorDescriptor (int sd, EventMachine_t *parent_em):
	EventableDescriptor (sd, parent_em)
{
	#ifdef HAVE_EPOLL
	EpollEvent.events = EPOLLIN;
	#endif
	#ifdef HAVE_KQUEUE
	MyEventMachine->ArmKqueueReader (this);
	#endif
}


/***************************************
AcceptorDescriptor::~AcceptorDescriptor
***************************************/

AcceptorDescriptor::~AcceptorDescriptor()
{
}

/****************************************
STATIC: AcceptorDescriptor::StopAcceptor
****************************************/

void AcceptorDescriptor::StopAcceptor (const char *binding)
{
	// TODO: This is something of a hack, or at least it's a static method of the wrong class.
	AcceptorDescriptor *ad = dynamic_cast <AcceptorDescriptor*> (Bindable_t::GetObject (binding));
	if (ad)
		ad->ScheduleClose (false);
	else
		throw std::runtime_error ("failed to close nonexistent acceptor");
}


/************************
AcceptorDescriptor::Read
************************/

void AcceptorDescriptor::Read()
{
	/* Accept up to a certain number of sockets on the listening connection.
	 * Don't try to accept all that are present, because this would allow a DoS attack
	 * in which no data were ever read or written. We should accept more than one,
	 * if available, to keep the partially accepted sockets from backing up in the kernel.
	 */

	/* Make sure we use non-blocking i/o on the acceptor socket, since we're selecting it
	 * for readability. According to Stevens UNP, it's possible for an acceptor to select readable
	 * and then block when we call accept. For example, the other end resets the connection after
	 * the socket selects readable and before we call accept. The kernel will remove the dead
	 * socket from the accept queue. If the accept queue is now empty, accept will block.
	 */


	struct sockaddr_in pin;
	socklen_t addrlen = sizeof (pin);

	for (int i=0; i < 10; i++) {
		int sd = accept (GetSocket(), (struct sockaddr*)&pin, &addrlen);
		if (sd == INVALID_SOCKET) {
			// This breaks the loop when we've accepted everything on the kernel queue,
			// up to 10 new connections. But what if the *first* accept fails?
			// Does that mean anything serious is happening, beyond the situation
			// described in the note above?
			break;
		}

		// Set the newly-accepted socket non-blocking.
		// On Windows, this may fail because, weirdly, Windows inherits the non-blocking
		// attribute that we applied to the acceptor socket into the accepted one.
		if (!SetSocketNonblocking (sd)) {
		//int val = fcntl (sd, F_GETFL, 0);
		//if (fcntl (sd, F_SETFL, val | O_NONBLOCK) == -1) {
			shutdown (sd, 1);
			closesocket (sd);
			continue;
		}


		// Disable slow-start (Nagle algorithm). Eventually make this configurable.
		int one = 1;
		setsockopt (sd, IPPROTO_TCP, TCP_NODELAY, (char*) &one, sizeof(one));


		ConnectionDescriptor *cd = new ConnectionDescriptor (sd, MyEventMachine);
		if (!cd)
			throw std::runtime_error ("no newly accepted connection");
		cd->SetServerMode();
		if (EventCallback) {
			(*EventCallback) (GetBinding().c_str(), EM_CONNECTION_ACCEPTED, cd->GetBinding().c_str(), cd->GetBinding().size());
		}
		#ifdef HAVE_EPOLL
		cd->GetEpollEvent()->events = EPOLLIN | (cd->SelectForWrite() ? EPOLLOUT : 0);
		#endif
		assert (MyEventMachine);
		MyEventMachine->Add (cd);
		#ifdef HAVE_KQUEUE
		if (cd->SelectForWrite())
			MyEventMachine->ArmKqueueWriter (cd);
		MyEventMachine->ArmKqueueReader (cd);
		#endif
	}

}


/*************************
AcceptorDescriptor::Write
*************************/

void AcceptorDescriptor::Write()
{
  // Why are we here?
  throw std::runtime_error ("bad code path in acceptor");
}


/*****************************
AcceptorDescriptor::Heartbeat
*****************************/

void AcceptorDescriptor::Heartbeat()
{
  // No-op
}


/*******************************
AcceptorDescriptor::GetSockname
*******************************/

bool AcceptorDescriptor::GetSockname (struct sockaddr *s)
{
	bool ok = false;
	if (s) {
		socklen_t len = sizeof(*s);
		int gp = getsockname (GetSocket(), s, &len);
		if (gp == 0)
			ok = true;
	}
	return ok;
}



/**************************************
DatagramDescriptor::DatagramDescriptor
**************************************/

DatagramDescriptor::DatagramDescriptor (int sd, EventMachine_t *parent_em):
	EventableDescriptor (sd, parent_em),
	OutboundDataSize (0),
	LastIo (gCurrentLoopTime),
	InactivityTimeout (0)
{
	memset (&ReturnAddress, 0, sizeof(ReturnAddress));

	/* Provisionally added 19Oct07. All datagram sockets support broadcasting.
	 * Until now, sending to a broadcast address would give EACCES (permission denied)
	 * on systems like Linux and BSD that require the SO_BROADCAST socket-option in order
	 * to accept a packet to a broadcast address. Solaris doesn't require it. I think
	 * Windows DOES require it but I'm not sure.
	 *
	 * Ruby does NOT do what we're doing here. In Ruby, you have to explicitly set SO_BROADCAST
	 * on a UDP socket in order to enable broadcasting. The reason for requiring the option
	 * in the first place is so that applications don't send broadcast datagrams by mistake.
	 * I imagine that could happen if a user of an application typed in an address that happened
	 * to be a broadcast address on that particular subnet.
	 *
	 * This is provisional because someone may eventually come up with a good reason not to
	 * do it for all UDP sockets. If that happens, then we'll need to add a usercode-level API
	 * to set the socket option, just like Ruby does. AND WE'LL ALSO BREAK CODE THAT DOESN'T
	 * EXPLICITLY SET THE OPTION.
	 */

	int oval = 1;
	int sob = setsockopt (GetSocket(), SOL_SOCKET, SO_BROADCAST, (char*)&oval, sizeof(oval));

	#ifdef HAVE_EPOLL
	EpollEvent.events = EPOLLIN;
	#endif
	#ifdef HAVE_KQUEUE
	MyEventMachine->ArmKqueueReader (this);
	#endif
}


/***************************************
DatagramDescriptor::~DatagramDescriptor
***************************************/

DatagramDescriptor::~DatagramDescriptor()
{
	// Run down any stranded outbound data.
	for (size_t i=0; i < OutboundPages.size(); i++)
		OutboundPages[i].Free();
}


/*****************************
DatagramDescriptor::Heartbeat
*****************************/

void DatagramDescriptor::Heartbeat()
{
	// Close it if its inactivity timer has expired.

	if (InactivityTimeout && ((gCurrentLoopTime - LastIo) >= InactivityTimeout))
		ScheduleClose (false);
		//bCloseNow = true;
}


/************************
DatagramDescriptor::Read
************************/

void DatagramDescriptor::Read()
{
	int sd = GetSocket();
	assert (sd != INVALID_SOCKET);
	LastIo = gCurrentLoopTime;

	// This is an extremely large read buffer.
	// In many cases you wouldn't expect to get any more than 4K.
	char readbuffer [16 * 1024];

	for (int i=0; i < 10; i++) {
		// Don't read just one buffer and then move on. This is faster
		// if there is a lot of incoming.
		// But don't read indefinitely. Give other sockets a chance to run.
		// NOTICE, we're reading one less than the buffer size.
		// That's so we can put a guard byte at the end of what we send
		// to user code.

		struct sockaddr_in sin;
		socklen_t slen = sizeof (sin);
		memset (&sin, 0, slen);

		int r = recvfrom (sd, readbuffer, sizeof(readbuffer) - 1, 0, (struct sockaddr*)&sin, &slen);
		//cerr << "<R:" << r << ">";

		// In UDP, a zero-length packet is perfectly legal.
		if (r >= 0) {
			LastRead = gCurrentLoopTime;

			// Add a null-terminator at the the end of the buffer
			// that we will send to the callback.
			// DO NOT EVER CHANGE THIS. We want to explicitly allow users
			// to be able to depend on this behavior, so they will have
			// the option to do some things faster. Additionally it's
			// a security guard against buffer overflows.
			readbuffer [r] = 0;


			// Set up a "temporary" return address so that callers can "reply" to us
			// from within the callback we are about to invoke. That means that ordinary
			// calls to "send_data_to_connection" (which is of course misnamed in this
			// case) will result in packets being sent back to the same place that sent
			// us this one.
			// There is a different call (evma_send_datagram) for cases where the caller
			// actually wants to send a packet somewhere else.

			memset (&ReturnAddress, 0, sizeof(ReturnAddress));
			memcpy (&ReturnAddress, &sin, slen);

			if (EventCallback)
				(*EventCallback)(GetBinding().c_str(), EM_CONNECTION_READ, readbuffer, r);

		}
		else {
			// Basically a would-block, meaning we've read everything there is to read.
			break;
		}

	}


}


/*************************
DatagramDescriptor::Write
*************************/

void DatagramDescriptor::Write()
{
	/* It's possible for a socket to select writable and then no longer
	 * be writable by the time we get around to writing. The kernel might
	 * have used up its available output buffers between the select call
	 * and when we get here. So this condition is not an error.
	 * This code is very reminiscent of ConnectionDescriptor::_WriteOutboundData,
	 * but differs in the that the outbound data pages (received from the
	 * user) are _message-structured._ That is, we send each of them out
	 * one message at a time.
	 * TODO, we are currently suppressing the EMSGSIZE error!!!
	 */

	int sd = GetSocket();
	assert (sd != INVALID_SOCKET);
	LastIo = gCurrentLoopTime;

	assert (OutboundPages.size() > 0);

	// Send out up to 10 packets, then cycle the machine.
	for (int i = 0; i < 10; i++) {
		if (OutboundPages.size() <= 0)
			break;
		OutboundPage *op = &(OutboundPages[0]);

		// The nasty cast to (char*) is needed because Windows is brain-dead.
		int s = sendto (sd, (char*)op->Buffer, op->Length, 0, (struct sockaddr*)&(op->From), sizeof(op->From));
		int e = errno;

		OutboundDataSize -= op->Length;
		op->Free();
		OutboundPages.pop_front();

		if (s == SOCKET_ERROR) {
			#ifdef OS_UNIX
			if ((e != EINPROGRESS) && (e != EWOULDBLOCK) && (e != EINTR)) {
			#endif
			#ifdef OS_WIN32
			if ((e != WSAEINPROGRESS) && (e != WSAEWOULDBLOCK)) {
			#endif
				Close();
				break;
			}
		}
	}

	#ifdef HAVE_EPOLL
	EpollEvent.events = (EPOLLIN | (SelectForWrite() ? EPOLLOUT : 0));
	assert (MyEventMachine);
	MyEventMachine->Modify (this);
	#endif
}


/**********************************
DatagramDescriptor::SelectForWrite
**********************************/

bool DatagramDescriptor::SelectForWrite()
{
	/* Changed 15Nov07, per bug report by Mark Zvillius.
	 * The outbound data size will be zero if there are zero-length outbound packets,
	 * so we now select writable in case the outbound page buffer is not empty.
	 * Note that the superclass ShouldDelete method still checks for outbound data size,
	 * which may be wrong.
	 */
	//return (GetOutboundDataSize() > 0); (Original)
	return (OutboundPages.size() > 0);
}


/************************************
DatagramDescriptor::SendOutboundData
************************************/

int DatagramDescriptor::SendOutboundData (const char *data, int length)
{
	// This is an exact clone of ConnectionDescriptor::SendOutboundData.
	// That means it needs to move to a common ancestor.

	if (IsCloseScheduled())
	//if (bCloseNow || bCloseAfterWriting)
		return 0;

	if (!data && (length > 0))
		throw std::runtime_error ("bad outbound data");
	char *buffer = (char *) malloc (length + 1);
	if (!buffer)
		throw std::runtime_error ("no allocation for outbound data");
	memcpy (buffer, data, length);
	buffer [length] = 0;
	OutboundPages.push_back (OutboundPage (buffer, length, ReturnAddress));
	OutboundDataSize += length;
	#ifdef HAVE_EPOLL
	EpollEvent.events = (EPOLLIN | EPOLLOUT);
	assert (MyEventMachine);
	MyEventMachine->Modify (this);
	#endif
	return length;
}


/****************************************
DatagramDescriptor::SendOutboundDatagram
****************************************/

int DatagramDescriptor::SendOutboundDatagram (const char *data, int length, const char *address, int port)
{
	// This is an exact clone of ConnectionDescriptor::SendOutboundData.
	// That means it needs to move to a common ancestor.
	// TODO: Refactor this so there's no overlap with SendOutboundData.

	if (IsCloseScheduled())
	//if (bCloseNow || bCloseAfterWriting)
		return 0;

	if (!address || !*address || !port)
		return 0;

	sockaddr_in pin;
	unsigned long HostAddr;

	HostAddr = inet_addr (address);
	if (HostAddr == INADDR_NONE) {
		// The nasty cast to (char*) is because Windows is brain-dead.
		hostent *hp = gethostbyname ((char*)address);
		if (!hp)
			return 0;
		HostAddr = ((in_addr*)(hp->h_addr))->s_addr;
	}

	memset (&pin, 0, sizeof(pin));
	pin.sin_family = AF_INET;
	pin.sin_addr.s_addr = HostAddr;
	pin.sin_port = htons (port);



	if (!data && (length > 0))
		throw std::runtime_error ("bad outbound data");
	char *buffer = (char *) malloc (length + 1);
	if (!buffer)
		throw std::runtime_error ("no allocation for outbound data");
	memcpy (buffer, data, length);
	buffer [length] = 0;
	OutboundPages.push_back (OutboundPage (buffer, length, pin));
	OutboundDataSize += length;
	#ifdef HAVE_EPOLL
	EpollEvent.events = (EPOLLIN | EPOLLOUT);
	assert (MyEventMachine);
	MyEventMachine->Modify (this);
	#endif
	return length;
}


/****************************************
STATIC: DatagramDescriptor::SendDatagram
****************************************/

int DatagramDescriptor::SendDatagram (const char *binding, const char *data, int length, const char *address, int port)
{
	DatagramDescriptor *dd = dynamic_cast <DatagramDescriptor*> (Bindable_t::GetObject (binding));
	if (dd)
		return dd->SendOutboundDatagram (data, length, address, port);
	else
		return -1;
}


/*********************************
ConnectionDescriptor::GetPeername
*********************************/

bool ConnectionDescriptor::GetPeername (struct sockaddr *s)
{
	bool ok = false;
	if (s) {
		socklen_t len = sizeof(*s);
		int gp = getpeername (GetSocket(), s, &len);
		if (gp == 0)
			ok = true;
	}
	return ok;
}

/*********************************
ConnectionDescriptor::GetSockname
*********************************/

bool ConnectionDescriptor::GetSockname (struct sockaddr *s)
{
	bool ok = false;
	if (s) {
		socklen_t len = sizeof(*s);
		int gp = getsockname (GetSocket(), s, &len);
		if (gp == 0)
			ok = true;
	}
	return ok;
}


/**********************************************
ConnectionDescriptor::GetCommInactivityTimeout
**********************************************/

int ConnectionDescriptor::GetCommInactivityTimeout (int *value)
{
	if (value) {
		*value = InactivityTimeout;
		return 1;
	}
	else {
		// TODO, extended logging, got bad parameter.
		return 0;  
	}
}


/**********************************************
ConnectionDescriptor::SetCommInactivityTimeout
**********************************************/

int ConnectionDescriptor::SetCommInactivityTimeout (int *value)
{
	int out = 0;

	if (value) {
		if ((*value==0) || (*value >= 2)) {
			// Replace the value and send the old one back to the caller.
			int v = *value;
			*value = InactivityTimeout;
			InactivityTimeout = v;
			out = 1;
		}
		else {
			// TODO, extended logging, got bad value.
		}
	}
	else {
		// TODO, extended logging, got bad parameter.
	}

	return out;
}

/*******************************
DatagramDescriptor::GetPeername
*******************************/

bool DatagramDescriptor::GetPeername (struct sockaddr *s)
{
	bool ok = false;
	if (s) {
		memset (s, 0, sizeof(struct sockaddr));
		memcpy (s, &ReturnAddress, sizeof(ReturnAddress));
		ok = true;
	}
	return ok;
}

/*******************************
DatagramDescriptor::GetSockname
*******************************/

bool DatagramDescriptor::GetSockname (struct sockaddr *s)
{
	bool ok = false;
	if (s) {
		socklen_t len = sizeof(*s);
		int gp = getsockname (GetSocket(), s, &len);
		if (gp == 0)
			ok = true;
	}
	return ok;
}



/********************************************
DatagramDescriptor::GetCommInactivityTimeout
********************************************/

int DatagramDescriptor::GetCommInactivityTimeout (int *value)
{
  if (value) {
    *value = InactivityTimeout;
    return 1;
  }
  else {
    // TODO, extended logging, got bad parameter.
    return 0;  
  }
}

/********************************************
DatagramDescriptor::SetCommInactivityTimeout
********************************************/

int DatagramDescriptor::SetCommInactivityTimeout (int *value)
{
  int out = 0;

  if (value) {
    if ((*value==0) || (*value >= 2)) {
      // Replace the value and send the old one back to the caller.
      int v = *value;
      *value = InactivityTimeout;
      InactivityTimeout = v;
      out = 1;
    }
    else {
      // TODO, extended logging, got bad value.
    }
  }
  else {
    // TODO, extended logging, got bad parameter.
  }

  return out;
}

/*****************************************************************************

$Id$

File:     em.cpp
Date:     06Apr06

Copyright (C) 2006-07 by Francis Cianfrocca. All Rights Reserved.
Gmail: blackhedd

This program is free software; you can redistribute it and/or modify
it under the terms of either: 1) the GNU General Public License
as published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version; or 2) Ruby's License.

See the file COPYING for complete licensing information.

*****************************************************************************/

// THIS ENTIRE FILE WILL EVENTUALLY BE FOR UNIX BUILDS ONLY.
//#ifdef OS_UNIX


#include "project.h"

// Keep a global variable floating around
// with the current loop time as set by the Event Machine.
// This avoids the need for frequent expensive calls to time(NULL);
time_t gCurrentLoopTime;

#ifdef OS_WIN32
unsigned gTickCountTickover;
unsigned gLastTickCount;
#endif


/* The numer of max outstanding timers was once a const enum defined in em.h.
 * Now we define it here so that users can change its value if necessary.
 */
static int MaxOutstandingTimers = 1000;


/* Internal helper to convert strings to internet addresses. IPv6-aware.
 * Not reentrant or threadsafe, optimized for speed.
 */
static struct sockaddr *name2address (const char *server, int port, int *family, int *bind_size);


/***************************************
STATIC EventMachine_t::SetMaxTimerCount
***************************************/

void EventMachine_t::SetMaxTimerCount (int count)
{
	/* Allow a user to increase the maximum number of outstanding timers.
	 * If this gets "too high" (a metric that is of course platform dependent),
	 * bad things will happen like performance problems and possible overuse
	 * of memory.
	 * The actual timer mechanism is very efficient so it's hard to know what
	 * the practical max, but 100,000 shouldn't be too problematical.
	 */
	if (count < 100)
		count = 100;
	MaxOutstandingTimers = count;
}



/******************************
EventMachine_t::EventMachine_t
******************************/

EventMachine_t::EventMachine_t (void (*event_callback)(const char*, int, const char*, int)):
	EventCallback (event_callback),
	NextHeartbeatTime (0),
	LoopBreakerReader (-1),
	LoopBreakerWriter (-1),
	bEpoll (false),
	bKqueue (false),
	epfd (-1)
{
	// Default time-slice is just smaller than one hundred mills.
	Quantum.tv_sec = 0;
	Quantum.tv_usec = 90000;

	gTerminateSignalReceived = false;
	// Make sure the current loop time is sane, in case we do any initializations of
	// objects before we start running.
	gCurrentLoopTime = time(NULL);

	/* We initialize the network library here (only on Windows of course)
	 * and initialize "loop breakers." Our destructor also does some network-level
	 * cleanup. There's thus an implicit assumption that any given instance of EventMachine_t
	 * will only call ::Run once. Is that a good assumption? Should we move some of these
	 * inits and de-inits into ::Run?
	 */
	#ifdef OS_WIN32
	WSADATA w;
	WSAStartup (MAKEWORD (1, 1), &w);
	#endif

	_InitializeLoopBreaker();
}


/*******************************
EventMachine_t::~EventMachine_t
*******************************/

EventMachine_t::~EventMachine_t()
{
	// Run down descriptors
	size_t i;
	for (i = 0; i < NewDescriptors.size(); i++)
		delete NewDescriptors[i];
	for (i = 0; i < Descriptors.size(); i++)
		delete Descriptors[i];

	close (LoopBreakerReader);
	close (LoopBreakerWriter);

	if (epfd != -1)
		close (epfd);
	if (kqfd != -1)
		close (kqfd);
}


/*************************
EventMachine_t::_UseEpoll
*************************/

void EventMachine_t::_UseEpoll()
{
	/* Temporary.
	 * Use an internal flag to switch in epoll-based functionality until we determine
	 * how it should be integrated properly and the extent of the required changes.
	 * A permanent solution needs to allow the integration of additional technologies,
	 * like kqueue and Solaris's events.
	 */

	#ifdef HAVE_EPOLL
	bEpoll = true;
	#endif
}

/**************************
EventMachine_t::_UseKqueue
**************************/

void EventMachine_t::_UseKqueue()
{
	/* Temporary.
	 * See comments under _UseEpoll.
	 */

	#ifdef HAVE_KQUEUE
	bKqueue = true;
	#endif
}


/****************************
EventMachine_t::ScheduleHalt
****************************/

void EventMachine_t::ScheduleHalt()
{
  /* This is how we stop the machine.
   * This can be called by clients. Signal handlers will probably
   * set the global flag.
   * For now this means there can only be one EventMachine ever running at a time.
   *
   * IMPORTANT: keep this light, fast, and async-safe. Don't do anything frisky in here,
   * because it may be called from signal handlers invoked from code that we don't
   * control. At this writing (20Sep06), EM does NOT install any signal handlers of
   * its own.
   *
   * We need a FAQ. And one of the questions is: how do I stop EM when Ctrl-C happens?
   * The answer is to call evma_stop_machine, which calls here, from a SIGINT handler.
   */
	gTerminateSignalReceived = true;
}



/*******************************
EventMachine_t::SetTimerQuantum
*******************************/

void EventMachine_t::SetTimerQuantum (int interval)
{
	/* We get a timer-quantum expressed in milliseconds.
	 * Don't set a quantum smaller than 5 or larger than 2500.
	 */

	if ((interval < 5) || (interval > 2500))
		throw std::runtime_error ("invalid timer-quantum");

	Quantum.tv_sec = interval / 1000;
	Quantum.tv_usec = (interval % 1000) * 1000;
}


/*************************************
(STATIC) EventMachine_t::SetuidString
*************************************/

void EventMachine_t::SetuidString (const char *username)
{
    /* This method takes a caller-supplied username and tries to setuid
     * to that user. There is no meaningful implementation (and no error)
     * on Windows. On Unix, a failure to setuid the caller-supplied string
     * causes a fatal abort, because presumably the program is calling here
     * in order to fulfill a security requirement. If we fail silently,
     * the user may continue to run with too much privilege.
     *
     * TODO, we need to decide on and document a way of generating C++ level errors
     * that can be wrapped in documented Ruby exceptions, so users can catch
     * and handle them. And distinguish it from errors that we WON'T let the Ruby
     * user catch (like security-violations and resource-overallocation).
     * A setuid failure here would be in the latter category.
     */

    #ifdef OS_UNIX
    if (!username || !*username)
	throw std::runtime_error ("setuid_string failed: no username specified");

    struct passwd *p = getpwnam (username);
    if (!p)
	throw std::runtime_error ("setuid_string failed: unknown username");

    if (setuid (p->pw_uid) != 0)
	throw std::runtime_error ("setuid_string failed: no setuid");

    // Success.
    #endif
}


/****************************************
(STATIC) EventMachine_t::SetRlimitNofile
****************************************/

int EventMachine_t::SetRlimitNofile (int nofiles)
{
	#ifdef OS_UNIX
	struct rlimit rlim;
	getrlimit (RLIMIT_NOFILE, &rlim);
	if (nofiles >= 0) {
		rlim.rlim_cur = nofiles;
		if (nofiles > rlim.rlim_max)
			rlim.rlim_max = nofiles;
		setrlimit (RLIMIT_NOFILE, &rlim);
		// ignore the error return, for now at least.
		// TODO, emit an error message someday when we have proper debug levels.
	}
	getrlimit (RLIMIT_NOFILE, &rlim);
	return rlim.rlim_cur;
	#endif

	#ifdef OS_WIN32
	// No meaningful implementation on Windows.
	return 0;
	#endif
}


/*********************************
EventMachine_t::SignalLoopBreaker
*********************************/

void EventMachine_t::SignalLoopBreaker()
{
	#ifdef OS_UNIX
	write (LoopBreakerWriter, "", 1);
	#endif
	#ifdef OS_WIN32
	sendto (LoopBreakerReader, "", 0, 0, (struct sockaddr*)&(LoopBreakerTarget), sizeof(LoopBreakerTarget));
	#endif
}


/**************************************
EventMachine_t::_InitializeLoopBreaker
**************************************/

void EventMachine_t::_InitializeLoopBreaker()
{
	/* A "loop-breaker" is a socket-descriptor that we can write to in order
	 * to break the main select loop. Primarily useful for things running on
	 * threads other than the main EM thread, so they can trigger processing
	 * of events that arise exogenously to the EM.
	 * Keep the loop-breaker pipe out of the main descriptor set, otherwise
	 * its events will get passed on to user code.
	 */

	#ifdef OS_UNIX
	int fd[2];
	if (pipe (fd))
		throw std::runtime_error ("no loop breaker");

	LoopBreakerWriter = fd[1];
	LoopBreakerReader = fd[0];
	#endif

	#ifdef OS_WIN32
	int sd = socket (AF_INET, SOCK_DGRAM, 0);
	if (sd == INVALID_SOCKET)
		throw std::runtime_error ("no loop breaker socket");
	SetSocketNonblocking (sd);

	memset (&LoopBreakerTarget, 0, sizeof(LoopBreakerTarget));
	LoopBreakerTarget.sin_family = AF_INET;
	LoopBreakerTarget.sin_addr.s_addr = inet_addr ("127.0.0.1");

	srand ((int)time(NULL));
	int i;
	for (i=0; i < 100; i++) {
		int r = (rand() % 10000) + 20000;
		LoopBreakerTarget.sin_port = htons (r);
		if (bind (sd, (struct sockaddr*)&LoopBreakerTarget, sizeof(LoopBreakerTarget)) == 0)
			break;
	}

	if (i == 100)
		throw std::runtime_error ("no loop breaker");
	LoopBreakerReader = sd;
	#endif
}


/*******************
EventMachine_t::Run
*******************/

void EventMachine_t::Run()
{
	#ifdef OS_WIN32
	HookControlC (true);
	#endif

	#ifdef HAVE_EPOLL
	if (bEpoll) {
		epfd = epoll_create (MaxEpollDescriptors);
		if (epfd == -1) {
			char buf[200];
			snprintf (buf, sizeof(buf)-1, "unable to create epoll descriptor: %s", strerror(errno));
			throw std::runtime_error (buf);
		}
		int cloexec = fcntl (epfd, F_GETFD, 0);
		assert (cloexec >= 0);
		cloexec |= FD_CLOEXEC;
		fcntl (epfd, F_SETFD, cloexec);

		assert (LoopBreakerReader >= 0);
		LoopbreakDescriptor *ld = new LoopbreakDescriptor (LoopBreakerReader, this);
		assert (ld);
		Add (ld);
	}
	#endif

	#ifdef HAVE_KQUEUE
	if (bKqueue) {
		kqfd = kqueue();
		if (kqfd == -1) {
			char buf[200];
			snprintf (buf, sizeof(buf)-1, "unable to create kqueue descriptor: %s", strerror(errno));
			throw std::runtime_error (buf);
		}
		// cloexec not needed. By definition, kqueues are not carried across forks.

		assert (LoopBreakerReader >= 0);
		LoopbreakDescriptor *ld = new LoopbreakDescriptor (LoopBreakerReader, this);
		assert (ld);
		Add (ld);
	}
	#endif

	while (true) {
		gCurrentLoopTime = time(NULL);
		if (!_RunTimers())
			break;

		/* _Add must precede _Modify because the same descriptor might
		 * be on both lists during the same pass through the machine,
		 * and to modify a descriptor before adding it would fail.
		 */
		_AddNewDescriptors();
		_ModifyDescriptors();

		if (!_RunOnce())
			break;
		if (gTerminateSignalReceived)
			break;
	}

	#ifdef OS_WIN32
	HookControlC (false);
	#endif
}


/************************
EventMachine_t::_RunOnce
************************/

bool EventMachine_t::_RunOnce()
{
	if (bEpoll)
		return _RunEpollOnce();
	else if (bKqueue)
		return _RunKqueueOnce();
	else
		return _RunSelectOnce();
}



/*****************************
EventMachine_t::_RunEpollOnce
*****************************/

bool EventMachine_t::_RunEpollOnce()
{
	#ifdef HAVE_EPOLL
	assert (epfd != -1);
	struct epoll_event ev [MaxEpollDescriptors];
	int s;

	#ifdef BUILD_FOR_RUBY
	TRAP_BEG;
	#endif
	s = epoll_wait (epfd, ev, MaxEpollDescriptors, 50);
	#ifdef BUILD_FOR_RUBY
	TRAP_END;
	#endif

	if (s > 0) {
		for (int i=0; i < s; i++) {
			EventableDescriptor *ed = (EventableDescriptor*) ev[i].data.ptr;

			if (ev[i].events & (EPOLLERR | EPOLLHUP))
				ed->ScheduleClose (false);
			if (ev[i].events & EPOLLIN)
				ed->Read();
			if (ev[i].events & EPOLLOUT) {
				ed->Write();
				epoll_ctl (epfd, EPOLL_CTL_MOD, ed->GetSocket(), ed->GetEpollEvent());
				// Ignoring return value
			}
		}
	}
	else if (s < 0) {
		// epoll_wait can fail on error in a handful of ways.
		// If this happens, then wait for a little while to avoid busy-looping.
		// If the error was EINTR, we probably caught SIGCHLD or something,
		// so keep the wait short.
		timeval tv = {0, ((errno == EINTR) ? 5 : 50) * 1000};
		EmSelect (0, NULL, NULL, NULL, &tv);
	}

	{ // cleanup dying sockets
		// vector::pop_back works in constant time.
		// TODO, rip this out and only delete the descriptors we know have died,
		// rather than traversing the whole list.
		//  Modified 05Jan08 per suggestions by Chris Heath. It's possible that
		//  an EventableDescriptor will have a descriptor value of -1. That will
		//  happen if EventableDescriptor::Close was called on it. In that case,
		//  don't call epoll_ctl to remove the socket's filters from the epoll set.
		//  According to the epoll docs, this happens automatically when the
		//  descriptor is closed anyway. This is different from the case where
		//  the socket has already been closed but the descriptor in the ED object
		//  hasn't yet been set to INVALID_SOCKET.
		int i, j;
		int nSockets = Descriptors.size();
		for (i=0, j=0; i < nSockets; i++) {
			EventableDescriptor *ed = Descriptors[i];
			assert (ed);
			if (ed->ShouldDelete()) {
				if (ed->GetSocket() != INVALID_SOCKET) {
					assert (bEpoll); // wouldn't be in this method otherwise.
					assert (epfd != -1);
					int e = epoll_ctl (epfd, EPOLL_CTL_DEL, ed->GetSocket(), ed->GetEpollEvent());
					// ENOENT or EBADF are not errors because the socket may be already closed when we get here.
					if (e && (errno != ENOENT) && (errno != EBADF)) {
						char buf [200];
						snprintf (buf, sizeof(buf)-1, "unable to delete epoll event: %s", strerror(errno));
						throw std::runtime_error (buf);
					}
				}

				ModifiedDescriptors.erase (ed);
				delete ed;
			}
			else
				Descriptors [j++] = ed;
		}
		while ((size_t)j < Descriptors.size())
			Descriptors.pop_back();

	}

	// TODO, heartbeats.
	// Added 14Sep07, its absence was noted by Brian Candler. But the comment was here, indicated
	// that this got thought about and not done when EPOLL was originally written. Was there a reason
	// not to do it, or was it an oversight? Certainly, running a heartbeat on 50,000 connections every
	// two seconds can get to be a real bear, especially if all we're doing is timing out dead ones.
	// Maybe there's a better way to do this. (Or maybe it's not that expensive after all.)
	//
	{ // dispatch heartbeats
		if (gCurrentLoopTime >= NextHeartbeatTime) {
			NextHeartbeatTime = gCurrentLoopTime + HeartbeatInterval;

			for (int i=0; i < Descriptors.size(); i++) {
				EventableDescriptor *ed = Descriptors[i];
				assert (ed);
				ed->Heartbeat();
			}
		}
	}

	#ifdef BUILD_FOR_RUBY
	if (!rb_thread_alone()) {
		rb_thread_schedule();
	}
	#endif

	return true;
	#else
	throw std::runtime_error ("epoll is not implemented on this platform");
	#endif
}


/******************************
EventMachine_t::_RunKqueueOnce
******************************/

bool EventMachine_t::_RunKqueueOnce()
{
	#ifdef HAVE_KQUEUE
	assert (kqfd != -1);
	const int maxKevents = 2000;
	struct kevent Karray [maxKevents];
	struct timespec ts = {0, 10000000}; // Too frequent. Use blocking_region

	int k;
	#ifdef BUILD_FOR_RUBY
	TRAP_BEG;
	#endif
	k = kevent (kqfd, NULL, 0, Karray, maxKevents, &ts);
	#ifdef BUILD_FOR_RUBY
	TRAP_END;
	#endif
	struct kevent *ke = Karray;
	while (k > 0) {
		EventableDescriptor *ed = (EventableDescriptor*) (ke->udata);
		assert (ed);

		if (ke->filter == EVFILT_READ)
			ed->Read();
		else if (ke->filter == EVFILT_WRITE)
			ed->Write();
		else
			cerr << "Discarding unknown kqueue event " << ke->filter << endl;

		--k;
		++ke;
	}

	{ // cleanup dying sockets
		// vector::pop_back works in constant time.
		// TODO, rip this out and only delete the descriptors we know have died,
		// rather than traversing the whole list.
		// In kqueue, closing a descriptor automatically removes its event filters.

		int i, j;
		int nSockets = Descriptors.size();
		for (i=0, j=0; i < nSockets; i++) {
			EventableDescriptor *ed = Descriptors[i];
			assert (ed);
			if (ed->ShouldDelete()) {
				ModifiedDescriptors.erase (ed);
				delete ed;
			}
			else
				Descriptors [j++] = ed;
		}
		while ((size_t)j < Descriptors.size())
			Descriptors.pop_back();

	}

	{ // dispatch heartbeats
		if (gCurrentLoopTime >= NextHeartbeatTime) {
			NextHeartbeatTime = gCurrentLoopTime + HeartbeatInterval;

			for (int i=0; i < Descriptors.size(); i++) {
				EventableDescriptor *ed = Descriptors[i];
				assert (ed);
				ed->Heartbeat();
			}
		}
	}


	// TODO, replace this with rb_thread_blocking_region for 1.9 builds.
	#ifdef BUILD_FOR_RUBY
	if (!rb_thread_alone()) {
		rb_thread_schedule();
	}
	#endif

	return true;
	#else
	throw std::runtime_error ("kqueue is not implemented on this platform");
	#endif
}


/*********************************
EventMachine_t::_ModifyEpollEvent
*********************************/

void EventMachine_t::_ModifyEpollEvent (EventableDescriptor *ed)
{
	#ifdef HAVE_EPOLL
	if (bEpoll) {
		assert (epfd != -1);
		assert (ed);
		int e = epoll_ctl (epfd, EPOLL_CTL_MOD, ed->GetSocket(), ed->GetEpollEvent());
		if (e) {
			char buf [200];
			snprintf (buf, sizeof(buf)-1, "unable to modify epoll event: %s", strerror(errno));
			throw std::runtime_error (buf);
		}
	}
	#endif
}



/**************************
SelectData_t::SelectData_t
**************************/

SelectData_t::SelectData_t()
{
	maxsocket = 0;
	FD_ZERO (&fdreads);
	FD_ZERO (&fdwrites);
}


#ifdef BUILD_FOR_RUBY
/*****************
_SelectDataSelect
*****************/

#ifdef HAVE_TBR
static VALUE _SelectDataSelect (void *v)
{
	SelectData_t *sd = (SelectData_t*)v;
	sd->nSockets = select (sd->maxsocket+1, &(sd->fdreads), &(sd->fdwrites), NULL, &(sd->tv));
	return Qnil;
}
#endif

/*********************
SelectData_t::_Select
*********************/

int SelectData_t::_Select()
{
	#ifdef HAVE_TBR
	rb_thread_blocking_region (_SelectDataSelect, (void*)this, RUBY_UBF_IO, 0);
	return nSockets;
	#endif

	#ifndef HAVE_TBR
	return EmSelect (maxsocket+1, &fdreads, &fdwrites, NULL, &tv);
	#endif
}
#endif



/******************************
EventMachine_t::_RunSelectOnce
******************************/

bool EventMachine_t::_RunSelectOnce()
{
	// Crank the event machine once.
	// If there are no descriptors to process, then sleep
	// for a few hundred mills to avoid busy-looping.
	// Return T/F to indicate whether we should continue.
	// This is based on a select loop. Alternately provide epoll
	// if we know we're running on a 2.6 kernel.
	// epoll will be effective if we provide it as an alternative,
	// however it has the same problem interoperating with Ruby
	// threads that select does.

	//cerr << "X";

	/* This protection is now obsolete, because we will ALWAYS
	 * have at least one descriptor (the loop-breaker) to read.
	 */
	/*
	if (Descriptors.size() == 0) {
		#ifdef OS_UNIX
		timeval tv = {0, 200 * 1000};
		EmSelect (0, NULL, NULL, NULL, &tv);
		return true;
		#endif
		#ifdef OS_WIN32
		Sleep (200);
		return true;
		#endif
	}
	*/

	SelectData_t SelectData;
	/*
	fd_set fdreads, fdwrites;
	FD_ZERO (&fdreads);
	FD_ZERO (&fdwrites);

	int maxsocket = 0;
	*/

	// Always read the loop-breaker reader.
	// Changed 23Aug06, provisionally implemented for Windows with a UDP socket
	// running on localhost with a randomly-chosen port. (*Puke*)
	// Windows has a version of the Unix pipe() library function, but it doesn't
	// give you back descriptors that are selectable.
	FD_SET (LoopBreakerReader, &(SelectData.fdreads));
	if (SelectData.maxsocket < LoopBreakerReader)
		SelectData.maxsocket = LoopBreakerReader;

	// prepare the sockets for reading and writing
	size_t i;
	for (i = 0; i < Descriptors.size(); i++) {
		EventableDescriptor *ed = Descriptors[i];
		assert (ed);
		int sd = ed->GetSocket();
		assert (sd != INVALID_SOCKET);

		if (ed->SelectForRead())
			FD_SET (sd, &(SelectData.fdreads));
		if (ed->SelectForWrite())
			FD_SET (sd, &(SelectData.fdwrites));

		if (SelectData.maxsocket < sd)
			SelectData.maxsocket = sd;
	}


	{ // read and write the sockets
		//timeval tv = {1, 0}; // Solaris fails if the microseconds member is >= 1000000.
		//timeval tv = Quantum;
		SelectData.tv = Quantum;
		int s = SelectData._Select();
		//rb_thread_blocking_region(xxx,(void*)&SelectData,RUBY_UBF_IO,0);
		//int s = EmSelect (SelectData.maxsocket+1, &(SelectData.fdreads), &(SelectData.fdwrites), NULL, &(SelectData.tv));
		//int s = SelectData.nSockets;
		if (s > 0) {
			/* Changed 01Jun07. We used to handle the Loop-breaker right here.
			 * Now we do it AFTER all the regular descriptors. There's an
			 * incredibly important and subtle reason for this. Code on
			 * loop breakers is sometimes used to cause the reactor core to
			 * cycle (for example, to allow outbound network buffers to drain).
			 * If a loop-breaker handler reschedules itself (say, after determining
			 * that the write buffers are still too full), then it will execute
			 * IMMEDIATELY if _ReadLoopBreaker is done here instead of after
			 * the other descriptors are processed. That defeats the whole purpose.
			 */
			for (i=0; i < Descriptors.size(); i++) {
				EventableDescriptor *ed = Descriptors[i];
				assert (ed);
				int sd = ed->GetSocket();
				assert (sd != INVALID_SOCKET);

				if (FD_ISSET (sd, &(SelectData.fdwrites)))
					ed->Write();
				if (FD_ISSET (sd, &(SelectData.fdreads)))
					ed->Read();
			}

			if (FD_ISSET (LoopBreakerReader, &(SelectData.fdreads)))
				_ReadLoopBreaker();
		}
		else if (s < 0) {
			// select can fail on error in a handful of ways.
			// If this happens, then wait for a little while to avoid busy-looping.
			// If the error was EINTR, we probably caught SIGCHLD or something,
			// so keep the wait short.
			timeval tv = {0, ((errno == EINTR) ? 5 : 50) * 1000};
			EmSelect (0, NULL, NULL, NULL, &tv);
		}
	}


	{ // dispatch heartbeats
		if (gCurrentLoopTime >= NextHeartbeatTime) {
			NextHeartbeatTime = gCurrentLoopTime + HeartbeatInterval;

			for (i=0; i < Descriptors.size(); i++) {
				EventableDescriptor *ed = Descriptors[i];
				assert (ed);
				ed->Heartbeat();
			}
		}
	}

	{ // cleanup dying sockets
		// vector::pop_back works in constant time.
		int i, j;
		int nSockets = Descriptors.size();
		for (i=0, j=0; i < nSockets; i++) {
			EventableDescriptor *ed = Descriptors[i];
			assert (ed);
			if (ed->ShouldDelete())
				delete ed;
			else
				Descriptors [j++] = ed;
		}
		while ((size_t)j < Descriptors.size())
			Descriptors.pop_back();

	}

	return true;
}


/********************************
EventMachine_t::_ReadLoopBreaker
********************************/

void EventMachine_t::_ReadLoopBreaker()
{
	/* The loop breaker has selected readable.
	 * Read it ONCE (it may block if we try to read it twice)
	 * and send a loop-break event back to user code.
	 */
	char buffer [1024];
	read (LoopBreakerReader, buffer, sizeof(buffer));
	if (EventCallback)
		(*EventCallback)("", EM_LOOPBREAK_SIGNAL, "", 0);
}


/**************************
EventMachine_t::_RunTimers
**************************/

bool EventMachine_t::_RunTimers()
{
	// These are caller-defined timer handlers.
	// Return T/F to indicate whether we should continue the main loop.
	// We rely on the fact that multimaps sort by their keys to avoid
	// inspecting the whole list every time we come here.
	// Just keep inspecting and processing the list head until we hit
	// one that hasn't expired yet.

	#ifdef OS_UNIX
	struct timeval tv;
	gettimeofday (&tv, NULL);
	Int64 now = (((Int64)(tv.tv_sec)) * 1000000LL) + ((Int64)(tv.tv_usec));
	#endif

	#ifdef OS_WIN32
	unsigned tick = GetTickCount();
	if (tick < gLastTickCount)
		gTickCountTickover += 1;
	gLastTickCount = tick;
	Int64 now = ((Int64)gTickCountTickover << 32) + (Int64)tick;
	#endif

	while (true) {
		multimap<Int64,Timer_t>::iterator i = Timers.begin();
		if (i == Timers.end())
			break;
		if (i->first > now)
			break;
		if (EventCallback)
			(*EventCallback) ("", EM_TIMER_FIRED, i->second.GetBinding().c_str(), i->second.GetBinding().length());
		Timers.erase (i);
	}
	return true;
}



/***********************************
EventMachine_t::InstallOneshotTimer
***********************************/

const char *EventMachine_t::InstallOneshotTimer (int milliseconds)
{
	if (Timers.size() > MaxOutstandingTimers)
		return false;
	// Don't use the global loop-time variable here, because we might
	// get called before the main event machine is running.

	#ifdef OS_UNIX
	struct timeval tv;
	gettimeofday (&tv, NULL);
	Int64 fire_at = (((Int64)(tv.tv_sec)) * 1000000LL) + ((Int64)(tv.tv_usec));
	fire_at += ((Int64)milliseconds) * 1000LL;
	#endif

	#ifdef OS_WIN32
	unsigned tick = GetTickCount();
	if (tick < gLastTickCount)
		gTickCountTickover += 1;
	gLastTickCount = tick;

	Int64 fire_at = ((Int64)gTickCountTickover << 32) + (Int64)tick;
	fire_at += (Int64)milliseconds;
	#endif

	Timer_t t;
	multimap<Int64,Timer_t>::iterator i =
		Timers.insert (make_pair (fire_at, t));
	return i->second.GetBindingChars();
}


/*******************************
EventMachine_t::ConnectToServer
*******************************/

const char *EventMachine_t::ConnectToServer (const char *server, int port)
{
	/* We want to spend no more than a few seconds waiting for a connection
	 * to a remote host. So we use a nonblocking connect.
	 * Linux disobeys the usual rules for nonblocking connects.
	 * Per Stevens (UNP p.410), you expect a nonblocking connect to select
	 * both readable and writable on error, and not to return EINPROGRESS
	 * if the connect can be fulfilled immediately. Linux violates both
	 * of these expectations.
	 * Any kind of nonblocking connect on Linux returns EINPROGRESS.
	 * The socket will then return writable when the disposition of the
	 * connect is known, but it will not also be readable in case of
	 * error! Weirdly, it will be readable in case there is data to read!!!
	 * (Which can happen with protocols like SSH and SMTP.)
	 * I suppose if you were so inclined you could consider this logical,
	 * but it's not the way Unix has historically done it.
	 * So we ignore the readable flag and read getsockopt to see if there
	 * was an error connecting. A select timeout works as expected.
	 * In regard to getsockopt: Linux does the Berkeley-style thing,
	 * not the Solaris-style, and returns zero with the error code in
	 * the error parameter.
	 * Return the binding-text of the newly-created pending connection,
	 * or NULL if there was a problem.
	 */

	if (!server || !*server || !port)
		return NULL;

	int family, bind_size;
	struct sockaddr *bind_as = name2address (server, port, &family, &bind_size);
	if (!bind_as)
		return NULL;

	int sd = socket (family, SOCK_STREAM, 0);
	if (sd == INVALID_SOCKET)
		return NULL;

	/*
	sockaddr_in pin;
	unsigned long HostAddr;

	HostAddr = inet_addr (server);
	if (HostAddr == INADDR_NONE) {
		hostent *hp = gethostbyname ((char*)server); // Windows requires (char*)
		if (!hp) {
			// TODO: This gives the caller a fatal error. Not good.
			// They can respond by catching RuntimeError (blecch).
			// Possibly we need to fire an unbind event and provide
			// a status code so user code can detect the cause of the
			// failure.
			return NULL;
		}
		HostAddr = ((in_addr*)(hp->h_addr))->s_addr;
	}

	memset (&pin, 0, sizeof(pin));
	pin.sin_family = AF_INET;
	pin.sin_addr.s_addr = HostAddr;
	pin.sin_port = htons (port);

	int sd = socket (AF_INET, SOCK_STREAM, 0);
	if (sd == INVALID_SOCKET)
		return NULL;
	*/

	// From here on, ALL error returns must close the socket.
	// Set the new socket nonblocking.
	if (!SetSocketNonblocking (sd)) {
		closesocket (sd);
		return NULL;
	}
	// Disable slow-start (Nagle algorithm).
	int one = 1;
	setsockopt (sd, IPPROTO_TCP, TCP_NODELAY, (char*) &one, sizeof(one));

	const char *out = NULL;

	#ifdef OS_UNIX
	//if (connect (sd, (sockaddr*)&pin, sizeof pin) == 0) {
	if (connect (sd, bind_as, bind_size) == 0) {
		// This is a connect success, which Linux appears
		// never to give when the socket is nonblocking,
		// even if the connection is intramachine or to
		// localhost.

		/* Changed this branch 08Aug06. Evidently some kernels
		 * (FreeBSD for example) will actually return success from
		 * a nonblocking connect. This is a pretty simple case,
		 * just set up the new connection and clear the pending flag.
		 * Thanks to Chris Ochs for helping track this down.
		 * This branch never gets taken on Linux or (oddly) OSX.
		 * The original behavior was to throw an unimplemented,
		 * which the user saw as a fatal exception. Very unfriendly.
		 *
		 * Tweaked 10Aug06. Even though the connect disposition is
		 * known, we still set the connect-pending flag. That way
		 * some needed initialization will happen in the ConnectionDescriptor.
		 * (To wit, the ConnectionCompleted event gets sent to the client.)
		 */
		ConnectionDescriptor *cd = new ConnectionDescriptor (sd, this);
		if (!cd)
			throw std::runtime_error ("no connection allocated");
		cd->SetConnectPending (true);
		Add (cd);
		out = cd->GetBinding().c_str();
	}
	else if (errno == EINPROGRESS) {
		// Errno will generally always be EINPROGRESS, but on Linux
		// we have to look at getsockopt to be sure what really happened.
		int error;
		socklen_t len;
		len = sizeof(error);
		int o = getsockopt (sd, SOL_SOCKET, SO_ERROR, &error, &len);
		if ((o == 0) && (error == 0)) {
			// Here, there's no disposition.
			// Put the connection on the stack and wait for it to complete
			// or time out.
			ConnectionDescriptor *cd = new ConnectionDescriptor (sd, this);
			if (!cd)
				throw std::runtime_error ("no connection allocated");
			cd->SetConnectPending (true);
			Add (cd);
			out = cd->GetBinding().c_str();
		}
		else {
			/* This could be connection refused or some such thing.
			 * We will come here on Linux if a localhost connection fails.
			 * Changed 16Jul06: Originally this branch was a no-op, and
			 * we'd drop down to the end of the method, close the socket,
			 * and return NULL, which would cause the caller to GET A
			 * FATAL EXCEPTION. Now we keep the socket around but schedule an
			 * immediate close on it, so the caller will get a close-event
			 * scheduled on it. This was only an issue for localhost connections
			 * to non-listening ports. We may eventually need to revise this
			 * revised behavior, in case it causes problems like making it hard
			 * for people to know that a failure occurred.
			 */
			ConnectionDescriptor *cd = new ConnectionDescriptor (sd, this);
			if (!cd)
				throw std::runtime_error ("no connection allocated");
			cd->ScheduleClose (false);
			Add (cd);
			out = cd->GetBinding().c_str();
		}
	}
	else {
		// The error from connect was something other then EINPROGRESS.
	}
	#endif

	#ifdef OS_WIN32
	//if (connect (sd, (sockaddr*)&pin, sizeof pin) == 0) {
	if (connect (sd, bind_as, bind_size) == 0) {
		// This is a connect success, which Windows appears
		// never to give when the socket is nonblocking,
		// even if the connection is intramachine or to
		// localhost.
		throw std::runtime_error ("unimplemented");
	}
	else if (WSAGetLastError() == WSAEWOULDBLOCK) {
		// Here, there's no disposition.
		// Windows appears not to surface refused connections or
		// such stuff at this point.
		// Put the connection on the stack and wait for it to complete
		// or time out.
		ConnectionDescriptor *cd = new ConnectionDescriptor (sd, this);
		if (!cd)
			throw std::runtime_error ("no connection allocated");
		cd->SetConnectPending (true);
		Add (cd);
		out = cd->GetBinding().c_str();
	}
	else {
		// The error from connect was something other then WSAEWOULDBLOCK.
	}

	#endif

	if (out == NULL)
		closesocket (sd);
	return out;
}

/***********************************
EventMachine_t::ConnectToUnixServer
***********************************/

const char *EventMachine_t::ConnectToUnixServer (const char *server)
{
	/* Connect to a Unix-domain server, which by definition is running
	 * on the same host.
	 * There is no meaningful implementation on Windows.
	 * There's no need to do a nonblocking connect, since the connection
	 * is always local and can always be fulfilled immediately.
	 */

	#ifdef OS_WIN32
	throw std::runtime_error ("unix-domain connection unavailable on this platform");
	return NULL;
	#endif

	// The whole rest of this function is only compiled on Unix systems.
	#ifdef OS_UNIX

	const char *out = NULL;

	if (!server || !*server)
		return NULL;

	sockaddr_un pun;
	memset (&pun, 0, sizeof(pun));
	pun.sun_family = AF_LOCAL;

	// You ordinarily expect the server name field to be at least 1024 bytes long,
	// but on Linux it can be MUCH shorter.
	if (strlen(server) >= sizeof(pun.sun_path))
		throw std::runtime_error ("unix-domain server name is too long");


	strcpy (pun.sun_path, server);

	int fd = socket (AF_LOCAL, SOCK_STREAM, 0);
	if (fd == INVALID_SOCKET)
		return NULL;

	// From here on, ALL error returns must close the socket.
	// NOTE: At this point, the socket is still a blocking socket.
	if (connect (fd, (struct sockaddr*)&pun, sizeof(pun)) != 0) {
		closesocket (fd);
		return NULL;
	}

	// Set the newly-connected socket nonblocking.
	if (!SetSocketNonblocking (fd)) {
		closesocket (fd);
		return NULL;
	}

	// Set up a connection descriptor and add it to the event-machine.
	// Observe, even though we know the connection status is connect-success,
	// we still set the "pending" flag, so some needed initializations take
	// place.
	ConnectionDescriptor *cd = new ConnectionDescriptor (fd, this);
	if (!cd)
		throw std::runtime_error ("no connection allocated");
	cd->SetConnectPending (true);
	Add (cd);
	out = cd->GetBinding().c_str();

	if (out == NULL)
		closesocket (fd);

	return out;
	#endif
}

/************************
EventMachine_t::AttachFD
************************/

const char *EventMachine_t::AttachFD (int fd, bool notify_readable, bool notify_writable)
{
	#ifdef OS_UNIX
	if (fcntl(fd, F_GETFL, 0) < 0)
		throw std::runtime_error ("invalid file descriptor");
	#endif

	#ifdef OS_WIN32
	// TODO: add better check for invalid file descriptors (see ioctlsocket or getsockopt)
	if (fd == INVALID_SOCKET)
		throw std::runtime_error ("invalid file descriptor");
	#endif

	{// Check for duplicate descriptors
		size_t i;
		for (i = 0; i < Descriptors.size(); i++) {
			EventableDescriptor *ed = Descriptors[i];
			assert (ed);
			if (ed->GetSocket() == fd)
				throw std::runtime_error ("adding existing descriptor");
		}

		for (i = 0; i < NewDescriptors.size(); i++) {
			EventableDescriptor *ed = NewDescriptors[i];
			assert (ed);
			if (ed->GetSocket() == fd)
				throw std::runtime_error ("adding existing new descriptor");
		}
	}

	ConnectionDescriptor *cd = new ConnectionDescriptor (fd, this);
	if (!cd)
		throw std::runtime_error ("no connection allocated");

	cd->SetConnectPending (true);
	cd->SetNotifyReadable (notify_readable);
	cd->SetNotifyWritable (notify_writable);

	Add (cd);

	const char *out = NULL;
	out = cd->GetBinding().c_str();
	if (out == NULL)
		closesocket (fd);
	return out;
}

/************************
EventMachine_t::DetachFD
************************/

int EventMachine_t::DetachFD (EventableDescriptor *ed)
{
	if (!ed)
		throw std::runtime_error ("detaching bad descriptor");

	#ifdef HAVE_EPOLL
	if (bEpoll) {
		if (ed->GetSocket() != INVALID_SOCKET) {
			assert (bEpoll); // wouldn't be in this method otherwise.
			assert (epfd != -1);
			int e = epoll_ctl (epfd, EPOLL_CTL_DEL, ed->GetSocket(), ed->GetEpollEvent());
			// ENOENT or EBADF are not errors because the socket may be already closed when we get here.
			if (e && (errno != ENOENT) && (errno != EBADF)) {
				char buf [200];
				snprintf (buf, sizeof(buf)-1, "unable to delete epoll event: %s", strerror(errno));
				throw std::runtime_error (buf);
			}
		}
	}
	#endif

	#ifdef HAVE_KQUEUE
	if (bKqueue) {
		struct kevent k;
		EV_SET (&k, ed->GetSocket(), EVFILT_READ, EV_DELETE, 0, 0, ed);
		int t = kevent (kqfd, &k, 1, NULL, 0, NULL);
		assert (t == 0);
	}
	#endif

	{ // remove descriptor from lists
		int i, j;
		int nSockets = Descriptors.size();
		for (i=0, j=0; i < nSockets; i++) {
			EventableDescriptor *ted = Descriptors[i];
			assert (ted);
			if (ted != ed)
				Descriptors [j++] = ted;
		}
		while ((size_t)j < Descriptors.size())
			Descriptors.pop_back();

		ModifiedDescriptors.erase (ed);
	}

	int fd = ed->GetSocket();

	// We depend on ~EventableDescriptor not calling close() if the socket is invalid
	ed->SetSocketInvalid();
	delete ed;

	return fd;
}

/************
name2address
************/

struct sockaddr *name2address (const char *server, int port, int *family, int *bind_size)
{
	// THIS IS NOT RE-ENTRANT OR THREADSAFE. Optimize for speed.
	// Check the more-common cases first.
	// Return NULL if no resolution.

	static struct sockaddr_in in4;
	#ifndef __CYGWIN__
	static struct sockaddr_in6 in6;
	#endif
	struct hostent *hp;

	if (!server || !*server)
		server = "0.0.0.0";

	memset (&in4, 0, sizeof(in4));
	if ( (in4.sin_addr.s_addr = inet_addr (server)) != INADDR_NONE) {
		if (family)
			*family = AF_INET;
		if (bind_size)
			*bind_size = sizeof(in4);
		in4.sin_family = AF_INET;
		in4.sin_port = htons (port);
		return (struct sockaddr*)&in4;
	}

	#if defined(OS_UNIX) && !defined(__CYGWIN__)
	memset (&in6, 0, sizeof(in6));
	if (inet_pton (AF_INET6, server, in6.sin6_addr.s6_addr) > 0) {
		if (family)
			*family = AF_INET6;
		if (bind_size)
			*bind_size = sizeof(in6);
		in6.sin6_family = AF_INET6;
		in6.sin6_port = htons (port);
		return (struct sockaddr*)&in6;
	}
	#endif

	#ifdef OS_WIN32
	// TODO, must complete this branch. Windows doesn't have inet_pton.
	// A possible approach is to make a getaddrinfo call with the supplied
	// server address, constraining the hints to ipv6 and seeing if we
	// get any addresses.
	// For the time being, Ipv6 addresses aren't supported on Windows.
	#endif

	hp = gethostbyname ((char*)server); // Windows requires the cast.
	if (hp) {
		in4.sin_addr.s_addr = ((in_addr*)(hp->h_addr))->s_addr;
		if (family)
			*family = AF_INET;
		if (bind_size)
			*bind_size = sizeof(in4);
		in4.sin_family = AF_INET;
		in4.sin_port = htons (port);
		return (struct sockaddr*)&in4;
	}

	return NULL;
}


/*******************************
EventMachine_t::CreateTcpServer
*******************************/

const char *EventMachine_t::CreateTcpServer (const char *server, int port)
{
	/* Create a TCP-acceptor (server) socket and add it to the event machine.
	 * Return the binding of the new acceptor to the caller.
	 * This binding will be referenced when the new acceptor sends events
	 * to indicate accepted connections.
	 */


	int family, bind_size;
	struct sockaddr *bind_here = name2address (server, port, &family, &bind_size);
	if (!bind_here)
		return NULL;

	const char *output_binding = NULL;

	//struct sockaddr_in sin;

	int sd_accept = socket (family, SOCK_STREAM, 0);
	if (sd_accept == INVALID_SOCKET) {
		goto fail;
	}

	/*
	memset (&sin, 0, sizeof(sin));
	sin.sin_family = AF_INET;
	sin.sin_addr.s_addr = INADDR_ANY;
	sin.sin_port = htons (port);

	if (server && *server) {
		sin.sin_addr.s_addr = inet_addr (server);
		if (sin.sin_addr.s_addr == INADDR_NONE) {
			hostent *hp = gethostbyname ((char*)server); // Windows requires the cast.
			if (hp == NULL) {
				//__warning ("hostname not resolved: ", server);
				goto fail;
			}
			sin.sin_addr.s_addr = ((in_addr*)(hp->h_addr))->s_addr;
		}
	}
	*/

	{ // set reuseaddr to improve performance on restarts.
		int oval = 1;
		if (setsockopt (sd_accept, SOL_SOCKET, SO_REUSEADDR, (char*)&oval, sizeof(oval)) < 0) {
			//__warning ("setsockopt failed while creating listener","");
			goto fail;
		}
	}

	{ // set CLOEXEC. Only makes sense on Unix
		#ifdef OS_UNIX
		int cloexec = fcntl (sd_accept, F_GETFD, 0);
		assert (cloexec >= 0);
		cloexec |= FD_CLOEXEC;
		fcntl (sd_accept, F_SETFD, cloexec);
		#endif
	}


	//if (bind (sd_accept, (struct sockaddr*)&sin, sizeof(sin))) {
	if (bind (sd_accept, bind_here, bind_size)) {
		//__warning ("binding failed");
		goto fail;
	}

	if (listen (sd_accept, 100)) {
		//__warning ("listen failed");
		goto fail;
	}

	{
		// Set the acceptor non-blocking.
		// THIS IS CRUCIALLY IMPORTANT because we read it in a select loop.
		if (!SetSocketNonblocking (sd_accept)) {
		//int val = fcntl (sd_accept, F_GETFL, 0);
		//if (fcntl (sd_accept, F_SETFL, val | O_NONBLOCK) == -1) {
			goto fail;
		}
	}

	{ // Looking good.
		AcceptorDescriptor *ad = new AcceptorDescriptor (sd_accept, this);
		if (!ad)
			throw std::runtime_error ("unable to allocate acceptor");
		Add (ad);
		output_binding = ad->GetBinding().c_str();
	}

	return output_binding;

	fail:
	if (sd_accept != INVALID_SOCKET)
		closesocket (sd_accept);
	return NULL;
}


/**********************************
EventMachine_t::OpenDatagramSocket
**********************************/

const char *EventMachine_t::OpenDatagramSocket (const char *address, int port)
{
	const char *output_binding = NULL;

	int sd = socket (AF_INET, SOCK_DGRAM, 0);
	if (sd == INVALID_SOCKET)
		goto fail;
	// from here on, early returns must close the socket!


	struct sockaddr_in sin;
	memset (&sin, 0, sizeof(sin));
	sin.sin_family = AF_INET;
	sin.sin_port = htons (port);


	if (address && *address) {
		sin.sin_addr.s_addr = inet_addr (address);
		if (sin.sin_addr.s_addr == INADDR_NONE) {
			hostent *hp = gethostbyname ((char*)address); // Windows requires the cast.
			if (hp == NULL)
				goto fail;
			sin.sin_addr.s_addr = ((in_addr*)(hp->h_addr))->s_addr;
		}
	}
	else
		sin.sin_addr.s_addr = htonl (INADDR_ANY);


	// Set the new socket nonblocking.
	{
		if (!SetSocketNonblocking (sd))
		//int val = fcntl (sd, F_GETFL, 0);
		//if (fcntl (sd, F_SETFL, val | O_NONBLOCK) == -1)
			goto fail;
	}

	if (bind (sd, (struct sockaddr*)&sin, sizeof(sin)) != 0)
		goto fail;

	{ // Looking good.
		DatagramDescriptor *ds = new DatagramDescriptor (sd, this);
		if (!ds)
			throw std::runtime_error ("unable to allocate datagram-socket");
		Add (ds);
		output_binding = ds->GetBinding().c_str();
	}

	return output_binding;

	fail:
	if (sd != INVALID_SOCKET)
		closesocket (sd);
	return NULL;
}



/*******************
EventMachine_t::Add
*******************/

void EventMachine_t::Add (EventableDescriptor *ed)
{
	if (!ed)
		throw std::runtime_error ("added bad descriptor");
	ed->SetEventCallback (EventCallback);
	NewDescriptors.push_back (ed);
}


/*******************************
EventMachine_t::ArmKqueueWriter
*******************************/

void EventMachine_t::ArmKqueueWriter (EventableDescriptor *ed)
{
	#ifdef HAVE_KQUEUE
	if (bKqueue) {
		if (!ed)
			throw std::runtime_error ("added bad descriptor");
		struct kevent k;
		EV_SET (&k, ed->GetSocket(), EVFILT_WRITE, EV_ADD | EV_ONESHOT, 0, 0, ed);
		int t = kevent (kqfd, &k, 1, NULL, 0, NULL);
		assert (t == 0);
	}
	#endif
}

/*******************************
EventMachine_t::ArmKqueueReader
*******************************/

void EventMachine_t::ArmKqueueReader (EventableDescriptor *ed)
{
	#ifdef HAVE_KQUEUE
	if (bKqueue) {
		if (!ed)
			throw std::runtime_error ("added bad descriptor");
		struct kevent k;
		EV_SET (&k, ed->GetSocket(), EVFILT_READ, EV_ADD, 0, 0, ed);
		int t = kevent (kqfd, &k, 1, NULL, 0, NULL);
		assert (t == 0);
	}
	#endif
}

/**********************************
EventMachine_t::_AddNewDescriptors
**********************************/

void EventMachine_t::_AddNewDescriptors()
{
	/* Avoid adding descriptors to the main descriptor list
	 * while we're actually traversing the list.
	 * Any descriptors that are added as a result of processing timers
	 * or acceptors should go on a temporary queue and then added
	 * while we're not traversing the main list.
	 * Also, it (rarely) happens that a newly-created descriptor
	 * is immediately scheduled to close. It might be a good
	 * idea not to bother scheduling these for I/O but if
	 * we do that, we might bypass some important processing.
	 */

	for (size_t i = 0; i < NewDescriptors.size(); i++) {
		EventableDescriptor *ed = NewDescriptors[i];
		if (ed == NULL)
			throw std::runtime_error ("adding bad descriptor");

		#if HAVE_EPOLL
		if (bEpoll) {
			assert (epfd != -1);
			int e = epoll_ctl (epfd, EPOLL_CTL_ADD, ed->GetSocket(), ed->GetEpollEvent());
			if (e) {
				char buf [200];
				snprintf (buf, sizeof(buf)-1, "unable to add new descriptor: %s", strerror(errno));
				throw std::runtime_error (buf);
			}
		}
		#endif

		#if HAVE_KQUEUE
		/*
		if (bKqueue) {
			// INCOMPLETE. Some descriptors don't want to be readable.
			assert (kqfd != -1);
			struct kevent k;
			EV_SET (&k, ed->GetSocket(), EVFILT_READ, EV_ADD, 0, 0, ed);
			int t = kevent (kqfd, &k, 1, NULL, 0, NULL);
			assert (t == 0);
		}
		*/
		#endif

		Descriptors.push_back (ed);
	}
	NewDescriptors.clear();
}


/**********************************
EventMachine_t::_ModifyDescriptors
**********************************/

void EventMachine_t::_ModifyDescriptors()
{
	/* For implementations which don't level check every descriptor on
	 * every pass through the machine, as select does.
	 * If we're not selecting, then descriptors need a way to signal to the
	 * machine that their readable or writable status has changed.
	 * That's what the ::Modify call is for. We do it this way to avoid
	 * modifying descriptors during the loop traversal, where it can easily
	 * happen that an object (like a UDP socket) gets data written on it by
	 * the application during #post_init. That would take place BEFORE the
	 * descriptor even gets added to the epoll descriptor, so the modify
	 * operation will crash messily.
	 * Another really messy possibility is for a descriptor to put itself
	 * on the Modified list, and then get deleted before we get here.
	 * Remember, deletes happen after the I/O traversal and before the
	 * next pass through here. So we have to make sure when we delete a
	 * descriptor to remove it from the Modified list.
	 */

	#ifdef HAVE_EPOLL
	if (bEpoll) {
		set<EventableDescriptor*>::iterator i = ModifiedDescriptors.begin();
		while (i != ModifiedDescriptors.end()) {
			assert (*i);
			_ModifyEpollEvent (*i);
			++i;
		}
	}
	#endif

	ModifiedDescriptors.clear();
}


/**********************
EventMachine_t::Modify
**********************/

void EventMachine_t::Modify (EventableDescriptor *ed)
{
	if (!ed)
		throw std::runtime_error ("modified bad descriptor");
	ModifiedDescriptors.insert (ed);
}


/***********************************
EventMachine_t::_OpenFileForWriting
***********************************/

const char *EventMachine_t::_OpenFileForWriting (const char *filename)
{
  /*
	 * Return the binding-text of the newly-opened file,
	 * or NULL if there was a problem.
	 */

	if (!filename || !*filename)
		return NULL;

  int fd = open (filename, O_CREAT|O_TRUNC|O_WRONLY|O_NONBLOCK, 0644);
  
	FileStreamDescriptor *fsd = new FileStreamDescriptor (fd, this);
  if (!fsd)
  	throw std::runtime_error ("no file-stream allocated");
  Add (fsd);
  return fsd->GetBinding().c_str();

}


/**************************************
EventMachine_t::CreateUnixDomainServer
**************************************/

const char *EventMachine_t::CreateUnixDomainServer (const char *filename)
{
	/* Create a UNIX-domain acceptor (server) socket and add it to the event machine.
	 * Return the binding of the new acceptor to the caller.
	 * This binding will be referenced when the new acceptor sends events
	 * to indicate accepted connections.
	 * THERE IS NO MEANINGFUL IMPLEMENTATION ON WINDOWS.
	 */

	#ifdef OS_WIN32
	throw std::runtime_error ("unix-domain server unavailable on this platform");
	#endif

	// The whole rest of this function is only compiled on Unix systems.
	#ifdef OS_UNIX
	const char *output_binding = NULL;

	struct sockaddr_un s_sun;

	int sd_accept = socket (AF_LOCAL, SOCK_STREAM, 0);
	if (sd_accept == INVALID_SOCKET) {
		goto fail;
	}

	if (!filename || !*filename)
		goto fail;
	unlink (filename);

	bzero (&s_sun, sizeof(s_sun));
	s_sun.sun_family = AF_LOCAL;
	strncpy (s_sun.sun_path, filename, sizeof(s_sun.sun_path)-1);

	// don't bother with reuseaddr for a local socket.

	{ // set CLOEXEC. Only makes sense on Unix
		#ifdef OS_UNIX
		int cloexec = fcntl (sd_accept, F_GETFD, 0);
		assert (cloexec >= 0);
		cloexec |= FD_CLOEXEC;
		fcntl (sd_accept, F_SETFD, cloexec);
		#endif
	}

	if (bind (sd_accept, (struct sockaddr*)&s_sun, sizeof(s_sun))) {
		//__warning ("binding failed");
		goto fail;
	}

	if (listen (sd_accept, 100)) {
		//__warning ("listen failed");
		goto fail;
	}

	{
		// Set the acceptor non-blocking.
		// THIS IS CRUCIALLY IMPORTANT because we read it in a select loop.
		if (!SetSocketNonblocking (sd_accept)) {
		//int val = fcntl (sd_accept, F_GETFL, 0);
		//if (fcntl (sd_accept, F_SETFL, val | O_NONBLOCK) == -1) {
			goto fail;
		}
	}

	{ // Looking good.
		AcceptorDescriptor *ad = new AcceptorDescriptor (sd_accept, this);
		if (!ad)
			throw std::runtime_error ("unable to allocate acceptor");
		Add (ad);
		output_binding = ad->GetBinding().c_str();
	}

	return output_binding;

	fail:
	if (sd_accept != INVALID_SOCKET)
		closesocket (sd_accept);
	return NULL;
	#endif // OS_UNIX
}


/*********************
EventMachine_t::Popen
*********************/
#if OBSOLETE
const char *EventMachine_t::Popen (const char *cmd, const char *mode)
{
	#ifdef OS_WIN32
	throw std::runtime_error ("popen is currently unavailable on this platform");
	#endif

	// The whole rest of this function is only compiled on Unix systems.
	// Eventually we need this functionality (or a full-duplex equivalent) on Windows.
	#ifdef OS_UNIX
	const char *output_binding = NULL;

	FILE *fp = popen (cmd, mode);
	if (!fp)
		return NULL;

	// From here, all early returns must pclose the stream.

	// According to the pipe(2) manpage, descriptors returned from pipe have both
	// CLOEXEC and NONBLOCK clear. Do NOT set CLOEXEC. DO set nonblocking.
	if (!SetSocketNonblocking (fileno (fp))) {
		pclose (fp);
		return NULL;
	}

	{ // Looking good.
		PipeDescriptor *pd = new PipeDescriptor (fp, this);
		if (!pd)
			throw std::runtime_error ("unable to allocate pipe");
		Add (pd);
		output_binding = pd->GetBinding().c_str();
	}

	return output_binding;
	#endif
}
#endif // OBSOLETE

/**************************
EventMachine_t::Socketpair
**************************/

const char *EventMachine_t::Socketpair (char * const*cmd_strings)
{
	#ifdef OS_WIN32
	throw std::runtime_error ("socketpair is currently unavailable on this platform");
	#endif

	// The whole rest of this function is only compiled on Unix systems.
	// Eventually we need this functionality (or a full-duplex equivalent) on Windows.
	#ifdef OS_UNIX
	// Make sure the incoming array of command strings is sane.
	if (!cmd_strings)
		return NULL;
	int j;
	for (j=0; j < 100 && cmd_strings[j]; j++)
		;
	if ((j==0) || (j==100))
		return NULL;

	const char *output_binding = NULL;

	int sv[2];
	if (socketpair (AF_LOCAL, SOCK_STREAM, 0, sv) < 0)
		return NULL;
	// from here, all early returns must close the pair of sockets.

	// Set the parent side of the socketpair nonblocking.
	// We don't care about the child side, and most child processes will expect their
	// stdout to be blocking. Thanks to Duane Johnson and Bill Kelly for pointing this out.
	// Obviously DON'T set CLOEXEC.
	if (!SetSocketNonblocking (sv[0])) {
		close (sv[0]);
		close (sv[1]);
		return NULL;
	}

	pid_t f = fork();
	if (f > 0) {
		close (sv[1]);
		PipeDescriptor *pd = new PipeDescriptor (sv[0], f, this);
		if (!pd)
			throw std::runtime_error ("unable to allocate pipe");
		Add (pd);
		output_binding = pd->GetBinding().c_str();
	}
	else if (f == 0) {
		close (sv[0]);
		dup2 (sv[1], STDIN_FILENO);
		close (sv[1]);
		dup2 (STDIN_FILENO, STDOUT_FILENO);
		execvp (cmd_strings[0], cmd_strings+1);
		exit (-1); // end the child process if the exec doesn't work.
	}
	else
		throw std::runtime_error ("no fork");

	return output_binding;
	#endif
}


/****************************
EventMachine_t::OpenKeyboard
****************************/

const char *EventMachine_t::OpenKeyboard()
{
	KeyboardDescriptor *kd = new KeyboardDescriptor (this);
	if (!kd)
		throw std::runtime_error ("no keyboard-object allocated");
	Add (kd);
	return kd->GetBinding().c_str();
}





//#endif // OS_UNIX

/*****************************************************************************

$Id$

File:     emwin.cpp
Date:     05May06

Copyright (C) 2006-07 by Francis Cianfrocca. All Rights Reserved.
Gmail: blackhedd

This program is free software; you can redistribute it and/or modify
it under the terms of either: 1) the GNU General Public License
as published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version; or 2) Ruby's License.

See the file COPYING for complete licensing information.

*****************************************************************************/


// THIS ENTIRE FILE IS FOR WINDOWS BUILDS ONLY
// INCOMPLETE AND DISABLED FOR NOW.
#ifdef xOS_WIN32

#include "project.h"


// Keep a global variable floating around
// with the current loop time as set by the Event Machine.
// This avoids the need for frequent expensive calls to time(NULL);
time_t gCurrentLoopTime;


/******************************
EventMachine_t::EventMachine_t
******************************/

EventMachine_t::EventMachine_t (void (*event_callback)(const char*, int, const char*, int)):
	EventCallback (event_callback),
	NextHeartbeatTime (0)
{
	gTerminateSignalReceived = false;
	Iocp = NULL;
}


/*******************************
EventMachine_t::~EventMachine_t
*******************************/

EventMachine_t::~EventMachine_t()
{
	cerr << "EM __dt\n";
	if (Iocp)
		CloseHandle (Iocp);
}


/****************************
EventMachine_t::ScheduleHalt
****************************/

void EventMachine_t::ScheduleHalt()
{
  /* This is how we stop the machine.
   * This can be called by clients. Signal handlers will probably
   * set the global flag.
   * For now this means there can only be one EventMachine ever running at a time.
   */
	gTerminateSignalReceived = true;
}



/*******************
EventMachine_t::Run
*******************/

void EventMachine_t::Run()
{
	HookControlC (true);

	Iocp = CreateIoCompletionPort (INVALID_HANDLE_VALUE, NULL, 0, 0);
	if (Iocp == NULL)
		throw std::runtime_error ("no completion port");


	DWORD nBytes, nCompletionKey;
	LPOVERLAPPED Overlapped;

	do {
		gCurrentLoopTime = time(NULL);
		// Have some kind of strategy that will dequeue maybe up to 10 completions 
		// without running the timers as long as they are available immediately.
		// Otherwise in a busy server we're calling them every time through the loop.
		if (!_RunTimers())
			break;
		if (GetQueuedCompletionStatus (Iocp, &nBytes, &nCompletionKey, &Overlapped, 1000)) {
		}
		cerr << "+";
	} while (!gTerminateSignalReceived);


	/*
	while (true) {
		gCurrentLoopTime = time(NULL);
		if (!_RunTimers())
			break;
		_AddNewDescriptors();
		if (!_RunOnce())
			break;
		if (gTerminateSignalReceived)
			break;
	}
	*/

	HookControlC (false);
}


/**************************
EventMachine_t::_RunTimers
**************************/

bool EventMachine_t::_RunTimers()
{
	// These are caller-defined timer handlers.
	// Return T/F to indicate whether we should continue the main loop.
	// We rely on the fact that multimaps sort by their keys to avoid
	// inspecting the whole list every time we come here.
	// Just keep inspecting and processing the list head until we hit
	// one that hasn't expired yet.

	while (true) {
		multimap<time_t,Timer_t>::iterator i = Timers.begin();
		if (i == Timers.end())
			break;
		if (i->first > gCurrentLoopTime)
			break;
		if (EventCallback)
			(*EventCallback) ("", EM_TIMER_FIRED, i->second.GetBinding().c_str(), i->second.GetBinding().length());
		Timers.erase (i);
	}
	return true;
}


/***********************************
EventMachine_t::InstallOneshotTimer
***********************************/

const char *EventMachine_t::InstallOneshotTimer (int seconds)
{
	if (Timers.size() > MaxOutstandingTimers)
		return false;
	// Don't use the global loop-time variable here, because we might
	// get called before the main event machine is running.

	Timer_t t;
	Timers.insert (make_pair (time(NULL) + seconds, t));
	return t.GetBinding().c_str();
}


/**********************************
EventMachine_t::OpenDatagramSocket
**********************************/

const char *EventMachine_t::OpenDatagramSocket (const char *address, int port)
{
	cerr << "OPEN DATAGRAM SOCKET\n";
	return "Unimplemented";
}


/*******************************
EventMachine_t::CreateTcpServer
*******************************/

const char *EventMachine_t::CreateTcpServer (const char *server, int port)
{
	/* Create a TCP-acceptor (server) socket and add it to the event machine.
	 * Return the binding of the new acceptor to the caller.
	 * This binding will be referenced when the new acceptor sends events
	 * to indicate accepted connections.
	 */

	const char *output_binding = NULL;

	struct sockaddr_in sin;

	SOCKET sd_accept = socket (AF_INET, SOCK_STREAM, 0);
	if (sd_accept == INVALID_SOCKET) {
		goto fail;
	}

	memset (&sin, 0, sizeof(sin));
	sin.sin_family = AF_INET;
	sin.sin_addr.s_addr = INADDR_ANY;
	sin.sin_port = htons (port);

	if (server && *server) {
		sin.sin_addr.s_addr = inet_addr (server);
		if (sin.sin_addr.s_addr == INADDR_NONE) {
			hostent *hp = gethostbyname (server);
			if (hp == NULL) {
				//__warning ("hostname not resolved: ", server);
				goto fail;
			}
			sin.sin_addr.s_addr = ((in_addr*)(hp->h_addr))->s_addr;
		}
	}


	// No need to set reuseaddr on Windows.


	if (bind (sd_accept, (struct sockaddr*)&sin, sizeof(sin))) {
		//__warning ("binding failed");
		goto fail;
	}

	if (listen (sd_accept, 100)) {
		//__warning ("listen failed");
		goto fail;
	}

	{ // Looking good.
		AcceptorDescriptor *ad = new AcceptorDescriptor (this, sd_accept);
		if (!ad)
			throw std::runtime_error ("unable to allocate acceptor");
		Add (ad);
		output_binding = ad->GetBinding().c_str();

		CreateIoCompletionPort ((HANDLE)sd_accept, Iocp, NULL, 0);
		SOCKET sd = socket (AF_INET, SOCK_STREAM, 0);
		CreateIoCompletionPort ((HANDLE)sd, Iocp, NULL, 0);
		AcceptEx (sd_accept, sd, 
	}

	return output_binding;

	fail:
	if (sd_accept != INVALID_SOCKET)
		closesocket (sd_accept);
	return NULL;
}


/*******************************
EventMachine_t::ConnectToServer
*******************************/

const char *EventMachine_t::ConnectToServer (const char *server, int port)
{
	if (!server || !*server || !port)
		return NULL;

	sockaddr_in pin;
	unsigned long HostAddr;

	HostAddr = inet_addr (server);
	if (HostAddr == INADDR_NONE) {
		hostent *hp = gethostbyname (server);
		if (!hp)
			return NULL;
		HostAddr = ((in_addr*)(hp->h_addr))->s_addr;
	}

	memset (&pin, 0, sizeof(pin));
	pin.sin_family = AF_INET;
	pin.sin_addr.s_addr = HostAddr;
	pin.sin_port = htons (port);

	int sd = socket (AF_INET, SOCK_STREAM, 0);
	if (sd == INVALID_SOCKET)
		return NULL;


	LPOVERLAPPED olap = (LPOVERLAPPED) calloc (1, sizeof (OVERLAPPED));
	cerr << "I'm dying now\n";
	throw runtime_error ("UNIMPLEMENTED!!!\n");

}



/*******************
EventMachine_t::Add
*******************/

void EventMachine_t::Add (EventableDescriptor *ed)
{
	cerr << "ADD\n";
}



#endif // OS_WIN32

/*****************************************************************************

$Id$

File:     epoll.cpp
Date:     06Jun07

Copyright (C) 2006-07 by Francis Cianfrocca. All Rights Reserved.
Gmail: blackhedd

This program is free software; you can redistribute it and/or modify
it under the terms of either: 1) the GNU General Public License
as published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version; or 2) Ruby's License.

See the file COPYING for complete licensing information.

*****************************************************************************/


#ifdef HAVE_EPOLL

#include "project.h"

#endif // HAVE_EPOLL

/*****************************************************************************

$Id: mapper.cpp 4527 2007-07-04 10:21:34Z francis $

File:     mapper.cpp
Date:     02Jul07

Copyright (C) 2007 by Francis Cianfrocca. All Rights Reserved.
Gmail: garbagecat10

This program is free software; you can redistribute it and/or modify
it under the terms of either: 1) the GNU General Public License
as published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version; or 2) Ruby's License.

See the file COPYING for complete licensing information.

*****************************************************************************/


//////////////////////////////////////////////////////////////////////
// UNIX implementation
//////////////////////////////////////////////////////////////////////


#ifdef OS_UNIX

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <errno.h>

#include <iostream>
#include "unistd.h"
#include <string>
#include <cstring>
#include <stdexcept>
using namespace std;

#include "mapper.h"

/******************
Mapper_t::Mapper_t
******************/

Mapper_t::Mapper_t (const string &filename)
{
	/* We ASSUME we can open the file.
	 * (More precisely, we assume someone else checked before we got here.)
	 */

	Fd = open (filename.c_str(), O_RDONLY);
	if (Fd < 0)
		throw runtime_error (strerror (errno));

	struct stat st;
	if (fstat (Fd, &st))
		throw runtime_error (strerror (errno));
	FileSize = st.st_size;

	MapPoint = (const char*) mmap (0, FileSize, PROT_READ, MAP_SHARED, Fd, 0);
	if (MapPoint == MAP_FAILED)
		throw runtime_error (strerror (errno));
}


/*******************
Mapper_t::~Mapper_t
*******************/

Mapper_t::~Mapper_t()
{
	Close();
}


/***************
Mapper_t::Close
***************/

void Mapper_t::Close()
{
	// Can be called multiple times.
	// Calls to GetChunk are invalid after a call to Close.
	if (MapPoint) {
		munmap ((void*)MapPoint, FileSize);
		MapPoint = NULL;
	}
	if (Fd >= 0) {
		close (Fd);
		Fd = -1;
	}
}

/******************
Mapper_t::GetChunk
******************/

const char *Mapper_t::GetChunk (unsigned start)
{
	return MapPoint + start;
}



#endif // OS_UNIX


//////////////////////////////////////////////////////////////////////
// WINDOWS implementation
//////////////////////////////////////////////////////////////////////

#ifdef OS_WIN32

#include <windows.h>

#include <iostream>
#include <string>
#include <stdexcept>
using namespace std;

#include "mapper.h"

/******************
Mapper_t::Mapper_t
******************/

Mapper_t::Mapper_t (const string &filename)
{
	/* We ASSUME we can open the file.
	 * (More precisely, we assume someone else checked before we got here.)
	 */

	hFile = INVALID_HANDLE_VALUE;
	hMapping = NULL;
	MapPoint = NULL;
	FileSize = 0;

	hFile = CreateFile (filename.c_str(), GENERIC_READ|GENERIC_WRITE, FILE_SHARE_DELETE|FILE_SHARE_READ|FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);

	if (hFile == INVALID_HANDLE_VALUE)
		throw runtime_error ("File not found");

	BY_HANDLE_FILE_INFORMATION i;
	if (GetFileInformationByHandle (hFile, &i))
		FileSize = i.nFileSizeLow;

	hMapping = CreateFileMapping (hFile, NULL, PAGE_READWRITE, 0, 0, NULL);
	if (!hMapping)
		throw runtime_error ("File not mapped");

	MapPoint = (const char*) MapViewOfFile (hMapping, FILE_MAP_WRITE, 0, 0, 0);
	if (!MapPoint)
		throw runtime_error ("Mappoint not read");
}


/*******************
Mapper_t::~Mapper_t
*******************/

Mapper_t::~Mapper_t()
{
	Close();
}

/***************
Mapper_t::Close
***************/

void Mapper_t::Close()
{
	// Can be called multiple times.
	// Calls to GetChunk are invalid after a call to Close.
	if (MapPoint) {
		UnmapViewOfFile (MapPoint);
		MapPoint = NULL;
	}
	if (hMapping != NULL) {
		CloseHandle (hMapping);
		hMapping = NULL;
	}
	if (hFile != INVALID_HANDLE_VALUE) {
		CloseHandle (hFile);
		hMapping = INVALID_HANDLE_VALUE;
	}
}


/******************
Mapper_t::GetChunk
******************/

const char *Mapper_t::GetChunk (unsigned start)
{
	return MapPoint + start;
}



#endif // OS_WINDOWS
/*****************************************************************************

$Id: rubymain.cpp 4529 2007-07-04 11:32:22Z francis $

File:     rubymain.cpp
Date:     02Jul07

Copyright (C) 2007 by Francis Cianfrocca. All Rights Reserved.
Gmail: garbagecat10

This program is free software; you can redistribute it and/or modify
it under the terms of either: 1) the GNU General Public License
as published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version; or 2) Ruby's License.

See the file COPYING for complete licensing information.

*****************************************************************************/



#include <iostream>
#include <stdexcept>
using namespace std;

#include <ruby.h>
#include "mapper.h"

static VALUE EmModule;
static VALUE FastFileReader;
static VALUE Mapper;



/*********
mapper_dt
*********/

static void mapper_dt (void *ptr)
{
	if (ptr)
		delete (Mapper_t*) ptr;
}

/**********
mapper_new
**********/

static VALUE mapper_new (VALUE self, VALUE filename)
{
	Mapper_t *m = new Mapper_t (StringValuePtr (filename));
	if (!m)
		rb_raise (rb_eException, "No Mapper Object");
	VALUE v = Data_Wrap_Struct (Mapper, 0, mapper_dt, (void*)m);
	return v;
}


/****************
mapper_get_chunk
****************/

static VALUE mapper_get_chunk (VALUE self, VALUE start, VALUE length)
{
	Mapper_t *m = NULL;
	Data_Get_Struct (self, Mapper_t, m);
	if (!m)
		rb_raise (rb_eException, "No Mapper Object");

	// TODO, what if some moron sends us a negative start value?
	unsigned _start = NUM2INT (start);
	unsigned _length = NUM2INT (length);
	if ((_start + _length) > m->GetFileSize())
		rb_raise (rb_eException, "Mapper Range Error");

	const char *chunk = m->GetChunk (_start);
	if (!chunk)
		rb_raise (rb_eException, "No Mapper Chunk");
	return rb_str_new (chunk, _length);
}

/************
mapper_close
************/

static VALUE mapper_close (VALUE self)
{
	Mapper_t *m = NULL;
	Data_Get_Struct (self, Mapper_t, m);
	if (!m)
		rb_raise (rb_eException, "No Mapper Object");
	m->Close();
	return Qnil;
}

/***********
mapper_size
***********/

static VALUE mapper_size (VALUE self)
{
	Mapper_t *m = NULL;
	Data_Get_Struct (self, Mapper_t, m);
	if (!m)
		rb_raise (rb_eException, "No Mapper Object");
	return INT2NUM (m->GetFileSize());
}


/**********************
Init_fastfilereaderext
**********************/

extern "C" void Init_fastfilereaderext()
{
	EmModule = rb_define_module ("EventMachine");
	FastFileReader = rb_define_class_under (EmModule, "FastFileReader", rb_cObject);
	Mapper = rb_define_class_under (FastFileReader, "Mapper", rb_cObject);

	rb_define_module_function (Mapper, "new", (VALUE(*)(...))mapper_new, 1);
	rb_define_method (Mapper, "size", (VALUE(*)(...))mapper_size, 0);
	rb_define_method (Mapper, "close", (VALUE(*)(...))mapper_close, 0);
	rb_define_method (Mapper, "get_chunk", (VALUE(*)(...))mapper_get_chunk, 2);
}



/*****************************************************************************

$Id$

File:     files.cpp
Date:     26Aug06

Copyright (C) 2006-07 by Francis Cianfrocca. All Rights Reserved.
Gmail: blackhedd

This program is free software; you can redistribute it and/or modify
it under the terms of either: 1) the GNU General Public License
as published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version; or 2) Ruby's License.

See the file COPYING for complete licensing information.

*****************************************************************************/

#include "project.h"


/******************************************
FileStreamDescriptor::FileStreamDescriptor
******************************************/

FileStreamDescriptor::FileStreamDescriptor (int fd, EventMachine_t *em):
	EventableDescriptor (fd, em),
	OutboundDataSize (0)
{
cerr << "#####";
}


/*******************************************
FileStreamDescriptor::~FileStreamDescriptor
*******************************************/

FileStreamDescriptor::~FileStreamDescriptor()
{
	// Run down any stranded outbound data.
	for (size_t i=0; i < OutboundPages.size(); i++)
		OutboundPages[i].Free();
}


/**************************
FileStreamDescriptor::Read
**************************/

void FileStreamDescriptor::Read()
{
}

/***************************
FileStreamDescriptor::Write
***************************/

void FileStreamDescriptor::Write()
{
}


/*******************************
FileStreamDescriptor::Heartbeat
*******************************/

void FileStreamDescriptor::Heartbeat()
{
}


/***********************************
FileStreamDescriptor::SelectForRead
***********************************/

bool FileStreamDescriptor::SelectForRead()
{
  cerr << "R?";
  return false;
}


/************************************
FileStreamDescriptor::SelectForWrite
************************************/

bool FileStreamDescriptor::SelectForWrite()
{
  cerr << "W?";
  return false;
}


/*****************************************************************************

$Id$

File:     kb.cpp
Date:     24Aug07

Copyright (C) 2006-07 by Francis Cianfrocca. All Rights Reserved.
Gmail: blackhedd

This program is free software; you can redistribute it and/or modify
it under the terms of either: 1) the GNU General Public License
as published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version; or 2) Ruby's License.

See the file COPYING for complete licensing information.

*****************************************************************************/

#include "project.h"


/**************************************
KeyboardDescriptor::KeyboardDescriptor
**************************************/

KeyboardDescriptor::KeyboardDescriptor (EventMachine_t *parent_em):
	EventableDescriptor (0, parent_em),
	bReadAttemptedAfterClose (false),
	LastIo (gCurrentLoopTime),
	InactivityTimeout (0)
{
	#ifdef HAVE_EPOLL
	EpollEvent.events = EPOLLIN;
	#endif
	#ifdef HAVE_KQUEUE
	MyEventMachine->ArmKqueueReader (this);
	#endif
}


/***************************************
KeyboardDescriptor::~KeyboardDescriptor
***************************************/

KeyboardDescriptor::~KeyboardDescriptor()
{
}


/*************************
KeyboardDescriptor::Write
*************************/

void KeyboardDescriptor::Write()
{
	// Why are we here?
	throw std::runtime_error ("bad code path in keyboard handler");
}


/*****************************
KeyboardDescriptor::Heartbeat
*****************************/

void KeyboardDescriptor::Heartbeat()
{
	// no-op
}


/************************
KeyboardDescriptor::Read
************************/

void KeyboardDescriptor::Read()
{
	char c;
	read (GetSocket(), &c, 1);
	if (EventCallback)
		(*EventCallback)(GetBinding().c_str(), EM_CONNECTION_READ, &c, 1);
}




#if 0
/******************************
PipeDescriptor::PipeDescriptor
******************************/

PipeDescriptor::PipeDescriptor (int fd, pid_t subpid, EventMachine_t *parent_em):
	EventableDescriptor (fd, parent_em),
	bReadAttemptedAfterClose (false),
	LastIo (gCurrentLoopTime),
	InactivityTimeout (0),
	OutboundDataSize (0),
	SubprocessPid (subpid)
{
	#ifdef HAVE_EPOLL
	EpollEvent.events = EPOLLIN;
	#endif
}


/*******************************
PipeDescriptor::~PipeDescriptor
*******************************/

PipeDescriptor::~PipeDescriptor()
{
	// Run down any stranded outbound data.
	for (size_t i=0; i < OutboundPages.size(); i++)
		OutboundPages[i].Free();

	/* As a virtual destructor, we come here before the base-class
	 * destructor that closes our file-descriptor.
	 * We have to make sure the subprocess goes down (if it's not
	 * already down) and we have to reap the zombie.
	 *
	 * This implementation is PROVISIONAL and will surely be improved.
	 * The intention here is that we never block, hence the highly
	 * undesirable sleeps. But if we can't reap the subprocess even
	 * after sending it SIGKILL, then something is wrong and we
	 * throw a fatal exception, which is also not something we should
	 * be doing.
	 *
	 * Eventually the right thing to do will be to have the reactor
	 * core respond to SIGCHLD by chaining a handler on top of the
	 * one Ruby may have installed, and dealing with a list of dead
	 * children that are pending cleanup.
	 *
	 * Since we want to have a signal processor integrated into the
	 * client-visible API, let's wait until that is done before cleaning
	 * this up.
	 */

	struct timespec req = {0, 10000000};
	kill (SubprocessPid, SIGTERM);
	nanosleep (&req, NULL);
	if (waitpid (SubprocessPid, NULL, WNOHANG) == 0) {
		kill (SubprocessPid, SIGKILL);
		nanosleep (&req, NULL);
		if (waitpid (SubprocessPid, NULL, WNOHANG) == 0)
			throw std::runtime_error ("unable to reap subprocess");
	}
}



/********************
PipeDescriptor::Read
********************/

void PipeDescriptor::Read()
{
	int sd = GetSocket();
	if (sd == INVALID_SOCKET) {
		assert (!bReadAttemptedAfterClose);
		bReadAttemptedAfterClose = true;
		return;
	}

	LastIo = gCurrentLoopTime;

	int total_bytes_read = 0;
	char readbuffer [16 * 1024];

	for (int i=0; i < 10; i++) {
		// Don't read just one buffer and then move on. This is faster
		// if there is a lot of incoming.
		// But don't read indefinitely. Give other sockets a chance to run.
		// NOTICE, we're reading one less than the buffer size.
		// That's so we can put a guard byte at the end of what we send
		// to user code.
		// Use read instead of recv, which on Linux gives a "socket operation
		// on nonsocket" error.
		

		int r = read (sd, readbuffer, sizeof(readbuffer) - 1);
		//cerr << "<R:" << r << ">";

		if (r > 0) {
			total_bytes_read += r;
			LastRead = gCurrentLoopTime;

			// Add a null-terminator at the the end of the buffer
			// that we will send to the callback.
			// DO NOT EVER CHANGE THIS. We want to explicitly allow users
			// to be able to depend on this behavior, so they will have
			// the option to do some things faster. Additionally it's
			// a security guard against buffer overflows.
			readbuffer [r] = 0;
			if (EventCallback)
				(*EventCallback)(GetBinding().c_str(), EM_CONNECTION_READ, readbuffer, r);
			}
		else if (r == 0) {
			break;
		}
		else {
			// Basically a would-block, meaning we've read everything there is to read.
			break;
		}

	}


	if (total_bytes_read == 0) {
		// If we read no data on a socket that selected readable,
		// it generally means the other end closed the connection gracefully.
		ScheduleClose (false);
		//bCloseNow = true;
	}

}

/*********************
PipeDescriptor::Write
*********************/

void PipeDescriptor::Write()
{
	int sd = GetSocket();
	assert (sd != INVALID_SOCKET);

	LastIo = gCurrentLoopTime;
	char output_buffer [16 * 1024];
	size_t nbytes = 0;

	while ((OutboundPages.size() > 0) && (nbytes < sizeof(output_buffer))) {
		OutboundPage *op = &(OutboundPages[0]);
		if ((nbytes + op->Length - op->Offset) < sizeof (output_buffer)) {
			memcpy (output_buffer + nbytes, op->Buffer + op->Offset, op->Length - op->Offset);
			nbytes += (op->Length - op->Offset);
			op->Free();
			OutboundPages.pop_front();
		}
		else {
			int len = sizeof(output_buffer) - nbytes;
			memcpy (output_buffer + nbytes, op->Buffer + op->Offset, len);
			op->Offset += len;
			nbytes += len;
		}
	}

	// We should never have gotten here if there were no data to write,
	// so assert that as a sanity check.
	// Don't bother to make sure nbytes is less than output_buffer because
	// if it were we probably would have crashed already.
	assert (nbytes > 0);

	assert (GetSocket() != INVALID_SOCKET);
	int bytes_written = write (GetSocket(), output_buffer, nbytes);

	if (bytes_written > 0) {
		OutboundDataSize -= bytes_written;
		if ((size_t)bytes_written < nbytes) {
			int len = nbytes - bytes_written;
			char *buffer = (char*) malloc (len + 1);
			if (!buffer)
				throw std::runtime_error ("bad alloc throwing back data");
			memcpy (buffer, output_buffer + bytes_written, len);
			buffer [len] = 0;
			OutboundPages.push_front (OutboundPage (buffer, len));
		}
		#ifdef HAVE_EPOLL
		EpollEvent.events = (EPOLLIN | (SelectForWrite() ? EPOLLOUT : 0));
		assert (MyEventMachine);
		MyEventMachine->Modify (this);
		#endif
	}
	else {
		#ifdef OS_UNIX
		if ((errno != EINPROGRESS) && (errno != EWOULDBLOCK) && (errno != EINTR))
		#endif
		#ifdef OS_WIN32
		if ((errno != WSAEINPROGRESS) && (errno != WSAEWOULDBLOCK))
		#endif
			Close();
	}
}


/*************************
PipeDescriptor::Heartbeat
*************************/

void PipeDescriptor::Heartbeat()
{
	// If an inactivity timeout is defined, then check for it.
	if (InactivityTimeout && ((gCurrentLoopTime - LastIo) >= InactivityTimeout))
		ScheduleClose (false);
		//bCloseNow = true;
}


/*****************************
PipeDescriptor::SelectForRead
*****************************/

bool PipeDescriptor::SelectForRead()
{
	/* Pipe descriptors, being local by definition, don't have
	 * a pending state, so this is simpler than for the
	 * ConnectionDescriptor object.
	 */
	return true;
}

/******************************
PipeDescriptor::SelectForWrite
******************************/

bool PipeDescriptor::SelectForWrite()
{
	/* Pipe descriptors, being local by definition, don't have
	 * a pending state, so this is simpler than for the
	 * ConnectionDescriptor object.
	 */
	return (GetOutboundDataSize() > 0);
}




/********************************
PipeDescriptor::SendOutboundData
********************************/

int PipeDescriptor::SendOutboundData (const char *data, int length)
{
	//if (bCloseNow || bCloseAfterWriting)
	if (IsCloseScheduled())
		return 0;

	if (!data && (length > 0))
		throw std::runtime_error ("bad outbound data");
	char *buffer = (char *) malloc (length + 1);
	if (!buffer)
		throw std::runtime_error ("no allocation for outbound data");
	memcpy (buffer, data, length);
	buffer [length] = 0;
	OutboundPages.push_back (OutboundPage (buffer, length));
	OutboundDataSize += length;
	#ifdef HAVE_EPOLL
	EpollEvent.events = (EPOLLIN | EPOLLOUT);
	assert (MyEventMachine);
	MyEventMachine->Modify (this);
	#endif
	return length;
}

/********************************
PipeDescriptor::GetSubprocessPid
********************************/

bool PipeDescriptor::GetSubprocessPid (pid_t *pid)
{
	bool ok = false;
	if (pid && (SubprocessPid > 0)) {
		*pid = SubprocessPid;
		ok = true;
	}
	return ok;
}

#endif 

/*****************************************************************************

$Id$

File:     page.cpp
Date:     30Apr06

Copyright (C) 2006-07 by Francis Cianfrocca. All Rights Reserved.
Gmail: blackhedd

This program is free software; you can redistribute it and/or modify
it under the terms of either: 1) the GNU General Public License
as published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version; or 2) Ruby's License.

See the file COPYING for complete licensing information.

*****************************************************************************/


#include "project.h"


/******************
PageList::PageList
******************/

PageList::PageList()
{
}


/*******************
PageList::~PageList
*******************/

PageList::~PageList()
{
	while (HasPages())
		PopFront();
}


/***************
PageList::Front
***************/

void PageList::Front (const char **page, int *length)
{
	assert (page && length);

	if (HasPages()) {
		Page p = Pages.front();
		*page = p.Buffer;
		*length = p.Size;
	}
	else {
		*page = NULL;
		*length = 0;
	}
}


/******************
PageList::PopFront
******************/

void PageList::PopFront()
{
	if (HasPages()) {
		Page p = Pages.front();
		Pages.pop_front();
		if (p.Buffer)
			free ((void*)p.Buffer);
	}
}


/******************
PageList::HasPages
******************/

bool PageList::HasPages()
{
	return (Pages.size() > 0) ? true : false;
}


/**************
PageList::Push
**************/

void PageList::Push (const char *buf, int size)
{
	if (buf && (size > 0)) {
		char *copy = (char*) malloc (size);
		if (!copy)
			throw runtime_error ("no memory in pagelist");
		memcpy (copy, buf, size);
		Pages.push_back (Page (copy, size));
	}
}





/*****************************************************************************

$Id$

File:     pipe.cpp
Date:     30May07

Copyright (C) 2006-07 by Francis Cianfrocca. All Rights Reserved.
Gmail: blackhedd

This program is free software; you can redistribute it and/or modify
it under the terms of either: 1) the GNU General Public License
as published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version; or 2) Ruby's License.

See the file COPYING for complete licensing information.

*****************************************************************************/

#include "project.h"


#ifdef OS_UNIX
// THIS ENTIRE FILE IS ONLY COMPILED ON UNIX-LIKE SYSTEMS.

/******************************
PipeDescriptor::PipeDescriptor
******************************/

PipeDescriptor::PipeDescriptor (int fd, pid_t subpid, EventMachine_t *parent_em):
	EventableDescriptor (fd, parent_em),
	bReadAttemptedAfterClose (false),
	LastIo (gCurrentLoopTime),
	InactivityTimeout (0),
	OutboundDataSize (0),
	SubprocessPid (subpid)
{
	#ifdef HAVE_EPOLL
	EpollEvent.events = EPOLLIN;
	#endif
	#ifdef HAVE_KQUEUE
	MyEventMachine->ArmKqueueReader (this);
	#endif
}


/*******************************
PipeDescriptor::~PipeDescriptor
*******************************/

PipeDescriptor::~PipeDescriptor()
{
	// Run down any stranded outbound data.
	for (size_t i=0; i < OutboundPages.size(); i++)
		OutboundPages[i].Free();

	/* As a virtual destructor, we come here before the base-class
	 * destructor that closes our file-descriptor.
	 * We have to make sure the subprocess goes down (if it's not
	 * already down) and we have to reap the zombie.
	 *
	 * This implementation is PROVISIONAL and will surely be improved.
	 * The intention here is that we never block, hence the highly
	 * undesirable sleeps. But if we can't reap the subprocess even
	 * after sending it SIGKILL, then something is wrong and we
	 * throw a fatal exception, which is also not something we should
	 * be doing.
	 *
	 * Eventually the right thing to do will be to have the reactor
	 * core respond to SIGCHLD by chaining a handler on top of the
	 * one Ruby may have installed, and dealing with a list of dead
	 * children that are pending cleanup.
	 *
	 * Since we want to have a signal processor integrated into the
	 * client-visible API, let's wait until that is done before cleaning
	 * this up.
	 *
	 * Added a very ugly hack to support passing the subprocess's exit
	 * status to the user. It only makes logical sense for user code to access
	 * the subprocess exit status in the unbind callback. But unbind is called
	 * back during the EventableDescriptor destructor. So by that time there's
	 * no way to call back this object through an object binding, because it's
	 * already been cleaned up. We might have added a parameter to the unbind
	 * callback, but that would probably break a huge amount of existing code.
	 * So the hack-solution is to define an instance variable in the EventMachine
	 * object and stick the exit status in there, where it can easily be accessed
	 * with an accessor visible to user code.
	 * User code should ONLY access the exit status from within the unbind callback.
	 * Otherwise there's no guarantee it'll be valid.
	 * This hack won't make it impossible to run multiple EventMachines in a single
	 * process, but it will make it impossible to reliably nest unbind calls
	 * within other unbind calls. (Not sure if that's even possible.)
	 */

	assert (MyEventMachine);

	// check if the process is already dead
	if (waitpid (SubprocessPid, &(MyEventMachine->SubprocessExitStatus), WNOHANG) == 0) {
		kill (SubprocessPid, SIGTERM);
		// wait 0.25s for process to die
		struct timespec req = {0, 250000000};
		nanosleep (&req, NULL);
		if (waitpid (SubprocessPid, &(MyEventMachine->SubprocessExitStatus), WNOHANG) == 0) {
			kill (SubprocessPid, SIGKILL);
			// wait 0.5s for process to die
			struct timespec req = {0, 500000000};
			nanosleep (&req, NULL);
			if (waitpid (SubprocessPid, &(MyEventMachine->SubprocessExitStatus), WNOHANG) == 0)
				throw std::runtime_error ("unable to reap subprocess");
		}
	}
}



/********************
PipeDescriptor::Read
********************/

void PipeDescriptor::Read()
{
	int sd = GetSocket();
	if (sd == INVALID_SOCKET) {
		assert (!bReadAttemptedAfterClose);
		bReadAttemptedAfterClose = true;
		return;
	}

	LastIo = gCurrentLoopTime;

	int total_bytes_read = 0;
	char readbuffer [16 * 1024];

	for (int i=0; i < 10; i++) {
		// Don't read just one buffer and then move on. This is faster
		// if there is a lot of incoming.
		// But don't read indefinitely. Give other sockets a chance to run.
		// NOTICE, we're reading one less than the buffer size.
		// That's so we can put a guard byte at the end of what we send
		// to user code.
		// Use read instead of recv, which on Linux gives a "socket operation
		// on nonsocket" error.
		

		int r = read (sd, readbuffer, sizeof(readbuffer) - 1);
		//cerr << "<R:" << r << ">";

		if (r > 0) {
			total_bytes_read += r;
			LastRead = gCurrentLoopTime;

			// Add a null-terminator at the the end of the buffer
			// that we will send to the callback.
			// DO NOT EVER CHANGE THIS. We want to explicitly allow users
			// to be able to depend on this behavior, so they will have
			// the option to do some things faster. Additionally it's
			// a security guard against buffer overflows.
			readbuffer [r] = 0;
			if (EventCallback)
				(*EventCallback)(GetBinding().c_str(), EM_CONNECTION_READ, readbuffer, r);
			}
		else if (r == 0) {
			break;
		}
		else {
			// Basically a would-block, meaning we've read everything there is to read.
			break;
		}

	}


	if (total_bytes_read == 0) {
		// If we read no data on a socket that selected readable,
		// it generally means the other end closed the connection gracefully.
		ScheduleClose (false);
		//bCloseNow = true;
	}

}

/*********************
PipeDescriptor::Write
*********************/

void PipeDescriptor::Write()
{
	int sd = GetSocket();
	assert (sd != INVALID_SOCKET);

	LastIo = gCurrentLoopTime;
	char output_buffer [16 * 1024];
	size_t nbytes = 0;

	while ((OutboundPages.size() > 0) && (nbytes < sizeof(output_buffer))) {
		OutboundPage *op = &(OutboundPages[0]);
		if ((nbytes + op->Length - op->Offset) < sizeof (output_buffer)) {
			memcpy (output_buffer + nbytes, op->Buffer + op->Offset, op->Length - op->Offset);
			nbytes += (op->Length - op->Offset);
			op->Free();
			OutboundPages.pop_front();
		}
		else {
			int len = sizeof(output_buffer) - nbytes;
			memcpy (output_buffer + nbytes, op->Buffer + op->Offset, len);
			op->Offset += len;
			nbytes += len;
		}
	}

	// We should never have gotten here if there were no data to write,
	// so assert that as a sanity check.
	// Don't bother to make sure nbytes is less than output_buffer because
	// if it were we probably would have crashed already.
	assert (nbytes > 0);

	assert (GetSocket() != INVALID_SOCKET);
	int bytes_written = write (GetSocket(), output_buffer, nbytes);

	if (bytes_written > 0) {
		OutboundDataSize -= bytes_written;
		if ((size_t)bytes_written < nbytes) {
			int len = nbytes - bytes_written;
			char *buffer = (char*) malloc (len + 1);
			if (!buffer)
				throw std::runtime_error ("bad alloc throwing back data");
			memcpy (buffer, output_buffer + bytes_written, len);
			buffer [len] = 0;
			OutboundPages.push_front (OutboundPage (buffer, len));
		}
		#ifdef HAVE_EPOLL
		EpollEvent.events = (EPOLLIN | (SelectForWrite() ? EPOLLOUT : 0));
		assert (MyEventMachine);
		MyEventMachine->Modify (this);
		#endif
	}
	else {
		#ifdef OS_UNIX
		if ((errno != EINPROGRESS) && (errno != EWOULDBLOCK) && (errno != EINTR))
		#endif
		#ifdef OS_WIN32
		if ((errno != WSAEINPROGRESS) && (errno != WSAEWOULDBLOCK))
		#endif
			Close();
	}
}


/*************************
PipeDescriptor::Heartbeat
*************************/

void PipeDescriptor::Heartbeat()
{
	// If an inactivity timeout is defined, then check for it.
	if (InactivityTimeout && ((gCurrentLoopTime - LastIo) >= InactivityTimeout))
		ScheduleClose (false);
		//bCloseNow = true;
}


/*****************************
PipeDescriptor::SelectForRead
*****************************/

bool PipeDescriptor::SelectForRead()
{
	/* Pipe descriptors, being local by definition, don't have
	 * a pending state, so this is simpler than for the
	 * ConnectionDescriptor object.
	 */
	return true;
}

/******************************
PipeDescriptor::SelectForWrite
******************************/

bool PipeDescriptor::SelectForWrite()
{
	/* Pipe descriptors, being local by definition, don't have
	 * a pending state, so this is simpler than for the
	 * ConnectionDescriptor object.
	 */
	return (GetOutboundDataSize() > 0);
}




/********************************
PipeDescriptor::SendOutboundData
********************************/

int PipeDescriptor::SendOutboundData (const char *data, int length)
{
	//if (bCloseNow || bCloseAfterWriting)
	if (IsCloseScheduled())
		return 0;

	if (!data && (length > 0))
		throw std::runtime_error ("bad outbound data");
	char *buffer = (char *) malloc (length + 1);
	if (!buffer)
		throw std::runtime_error ("no allocation for outbound data");
	memcpy (buffer, data, length);
	buffer [length] = 0;
	OutboundPages.push_back (OutboundPage (buffer, length));
	OutboundDataSize += length;
	#ifdef HAVE_EPOLL
	EpollEvent.events = (EPOLLIN | EPOLLOUT);
	assert (MyEventMachine);
	MyEventMachine->Modify (this);
	#endif
	return length;
}

/********************************
PipeDescriptor::GetSubprocessPid
********************************/

bool PipeDescriptor::GetSubprocessPid (pid_t *pid)
{
	bool ok = false;
	if (pid && (SubprocessPid > 0)) {
		*pid = SubprocessPid;
		ok = true;
	}
	return ok;
}


#endif // OS_UNIX

/*****************************************************************************

$Id$

File:     rubymain.cpp
Date:     06Apr06

Copyright (C) 2006-07 by Francis Cianfrocca. All Rights Reserved.
Gmail: blackhedd

This program is free software; you can redistribute it and/or modify
it under the terms of either: 1) the GNU General Public License
as published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version; or 2) Ruby's License.

See the file COPYING for complete licensing information.

*****************************************************************************/

#include "project.h"
#include "eventmachine.h"
#include <ruby.h>



/*******
Statics
*******/

static VALUE EmModule;
static VALUE EmConnection;

static VALUE Intern_at_signature;
static VALUE Intern_at_timers;
static VALUE Intern_at_conns;
static VALUE Intern_event_callback;
static VALUE Intern_run_deferred_callbacks;
static VALUE Intern_delete;
static VALUE Intern_call;
static VALUE Intern_receive_data;

static VALUE Intern_notify_readable;
static VALUE Intern_notify_writable;

/****************
t_event_callback
****************/

static void event_callback (const char *a1, int a2, const char *a3, int a4)
{
	if (a2 == EM_CONNECTION_READ) {
		VALUE t = rb_ivar_get (EmModule, Intern_at_conns);
		VALUE q = rb_hash_aref (t, rb_str_new2(a1));
		if (q == Qnil)
			rb_raise (rb_eRuntimeError, "no connection");
		rb_funcall (q, Intern_receive_data, 1, rb_str_new (a3, a4));
	}
	else if (a2 == EM_CONNECTION_NOTIFY_READABLE) {
		VALUE t = rb_ivar_get (EmModule, Intern_at_conns);
		VALUE q = rb_hash_aref (t, rb_str_new2(a1));
		if (q == Qnil)
			rb_raise (rb_eRuntimeError, "no connection");
		rb_funcall (q, Intern_notify_readable, 0);
	}
	else if (a2 == EM_CONNECTION_NOTIFY_WRITABLE) {
		VALUE t = rb_ivar_get (EmModule, Intern_at_conns);
		VALUE q = rb_hash_aref (t, rb_str_new2(a1));
		if (q == Qnil)
			rb_raise (rb_eRuntimeError, "no connection");
		rb_funcall (q, Intern_notify_writable, 0);
	}
	else if (a2 == EM_LOOPBREAK_SIGNAL) {
		rb_funcall (EmModule, Intern_run_deferred_callbacks, 0);
	}
	else if (a2 == EM_TIMER_FIRED) {
		VALUE t = rb_ivar_get (EmModule, Intern_at_timers);
		VALUE q = rb_funcall (t, Intern_delete, 1, rb_str_new(a3, a4));
		if (q == Qnil)
			rb_raise (rb_eRuntimeError, "no timer");
		rb_funcall (q, Intern_call, 0);
	}
	else
		rb_funcall (EmModule, Intern_event_callback, 3, rb_str_new2(a1), (a2 << 1) | 1, rb_str_new(a3,a4));
}



/**************************
t_initialize_event_machine
**************************/

static VALUE t_initialize_event_machine (VALUE self)
{
	evma_initialize_library (event_callback);
	return Qnil;
}



/*****************************
t_run_machine_without_threads
*****************************/

static VALUE t_run_machine_without_threads (VALUE self)
{
	evma_run_machine();
	return Qnil;
}


/*******************
t_add_oneshot_timer
*******************/

static VALUE t_add_oneshot_timer (VALUE self, VALUE interval)
{
	const char *f = evma_install_oneshot_timer (FIX2INT (interval));
	if (!f || !*f)
		rb_raise (rb_eRuntimeError, "no timer");
	return rb_str_new2 (f);
}


/**************
t_start_server
**************/

static VALUE t_start_server (VALUE self, VALUE server, VALUE port)
{
	const char *f = evma_create_tcp_server (StringValuePtr(server), FIX2INT(port));
	if (!f || !*f)
		rb_raise (rb_eRuntimeError, "no acceptor");
	return rb_str_new2 (f);
}

/*************
t_stop_server
*************/

static VALUE t_stop_server (VALUE self, VALUE signature)
{
	evma_stop_tcp_server (StringValuePtr (signature));
	return Qnil;
}


/*******************
t_start_unix_server
*******************/

static VALUE t_start_unix_server (VALUE self, VALUE filename)
{
	const char *f = evma_create_unix_domain_server (StringValuePtr(filename));
	if (!f || !*f)
		rb_raise (rb_eRuntimeError, "no unix-domain acceptor");
	return rb_str_new2 (f);
}



/***********
t_send_data
***********/

static VALUE t_send_data (VALUE self, VALUE signature, VALUE data, VALUE data_length)
{
	int b = evma_send_data_to_connection (StringValuePtr (signature), StringValuePtr (data), FIX2INT (data_length));
	return INT2NUM (b);
}


/***********
t_start_tls
***********/

static VALUE t_start_tls (VALUE self, VALUE signature)
{
	evma_start_tls (StringValuePtr (signature));
	return Qnil;
}

/***************
t_set_tls_parms
***************/

static VALUE t_set_tls_parms (VALUE self, VALUE signature, VALUE privkeyfile, VALUE certchainfile)
{
	/* set_tls_parms takes a series of positional arguments for specifying such things
	 * as private keys and certificate chains.
	 * It's expected that the parameter list will grow as we add more supported features.
	 * ALL of these parameters are optional, and can be specified as empty or NULL strings.
	 */
	evma_set_tls_parms (StringValuePtr (signature), StringValuePtr (privkeyfile), StringValuePtr (certchainfile) );
	return Qnil;
}

/**************
t_get_peername
**************/

static VALUE t_get_peername (VALUE self, VALUE signature)
{
	struct sockaddr s;
	if (evma_get_peername (StringValuePtr (signature), &s)) {
		return rb_str_new ((const char*)&s, sizeof(s));
	}

	return Qnil;
}

/**************
t_get_sockname
**************/

static VALUE t_get_sockname (VALUE self, VALUE signature)
{
	struct sockaddr s;
	if (evma_get_sockname (StringValuePtr (signature), &s)) {
		return rb_str_new ((const char*)&s, sizeof(s));
	}

	return Qnil;
}

/********************
t_get_subprocess_pid
********************/

static VALUE t_get_subprocess_pid (VALUE self, VALUE signature)
{
	pid_t pid;
	if (evma_get_subprocess_pid (StringValuePtr (signature), &pid)) {
		return INT2NUM (pid);
	}

	return Qnil;
}

/***********************
t_get_subprocess_status
***********************/

static VALUE t_get_subprocess_status (VALUE self, VALUE signature)
{
	int status;
	if (evma_get_subprocess_status (StringValuePtr (signature), &status)) {
		return INT2NUM (status);
	}

	return Qnil;
}

/*****************************
t_get_comm_inactivity_timeout
*****************************/

static VALUE t_get_comm_inactivity_timeout (VALUE self, VALUE signature)
{
	int timeout;
	if (evma_get_comm_inactivity_timeout (StringValuePtr (signature), &timeout))
		return INT2FIX (timeout);
	return Qnil;
}

/*****************************
t_set_comm_inactivity_timeout
*****************************/

static VALUE t_set_comm_inactivity_timeout (VALUE self, VALUE signature, VALUE timeout)
{
	int ti = FIX2INT (timeout);
	if (evma_set_comm_inactivity_timeout (StringValuePtr (signature), &ti));
		return Qtrue;
	return Qnil;
}


/***************
t_send_datagram
***************/

static VALUE t_send_datagram (VALUE self, VALUE signature, VALUE data, VALUE data_length, VALUE address, VALUE port)
{
	int b = evma_send_datagram (StringValuePtr (signature), StringValuePtr (data), FIX2INT (data_length), StringValuePtr(address), FIX2INT(port));
	return INT2NUM (b);
}


/******************
t_close_connection
******************/

static VALUE t_close_connection (VALUE self, VALUE signature, VALUE after_writing)
{
	evma_close_connection (StringValuePtr (signature), ((after_writing == Qtrue) ? 1 : 0));
	return Qnil;
}

/********************************
t_report_connection_error_status
********************************/

static VALUE t_report_connection_error_status (VALUE self, VALUE signature)
{
	int b = evma_report_connection_error_status (StringValuePtr (signature));
	return INT2NUM (b);
}



/****************
t_connect_server
****************/

static VALUE t_connect_server (VALUE self, VALUE server, VALUE port)
{
	// Avoid FIX2INT in this case, because it doesn't deal with type errors properly.
	// Specifically, if the value of port comes in as a string rather than an integer,
	// NUM2INT will throw a type error, but FIX2INT will generate garbage.

	const char *f = evma_connect_to_server (StringValuePtr(server), NUM2INT(port));
	if (!f || !*f)
		rb_raise (rb_eRuntimeError, "no connection");
	return rb_str_new2 (f);
}

/*********************
t_connect_unix_server
*********************/

static VALUE t_connect_unix_server (VALUE self, VALUE serversocket)
{
	const char *f = evma_connect_to_unix_server (StringValuePtr(serversocket));
	if (!f || !*f)
		rb_raise (rb_eRuntimeError, "no connection");
	return rb_str_new2 (f);
}

/***********
t_attach_fd
***********/

static VALUE t_attach_fd (VALUE self, VALUE file_descriptor, VALUE read_mode, VALUE write_mode)
{
	const char *f = evma_attach_fd (NUM2INT(file_descriptor), (read_mode == Qtrue) ? 1 : 0, (write_mode == Qtrue) ? 1 : 0);
	if (!f || !*f)
		rb_raise (rb_eRuntimeError, "no connection");
	return rb_str_new2 (f);
}

/***********
t_detach_fd
***********/

static VALUE t_detach_fd (VALUE self,  VALUE signature)
{
	return INT2NUM(evma_detach_fd (StringValuePtr(signature)));
}

/*****************
t_open_udp_socket
*****************/

static VALUE t_open_udp_socket (VALUE self, VALUE server, VALUE port)
{
	const char *f = evma_open_datagram_socket (StringValuePtr(server), FIX2INT(port));
	if (!f || !*f)
		rb_raise (rb_eRuntimeError, "no datagram socket");
	return rb_str_new2 (f);
}



/*****************
t_release_machine
*****************/

static VALUE t_release_machine (VALUE self)
{
	evma_release_library();
	return Qnil;
}


/******
t_stop
******/

static VALUE t_stop (VALUE self)
{
	evma_stop_machine();
	return Qnil;
}

/******************
t_signal_loopbreak
******************/

static VALUE t_signal_loopbreak (VALUE self)
{
	evma_signal_loopbreak();
	return Qnil;
}

/**************
t_library_type
**************/

static VALUE t_library_type (VALUE self)
{
	return rb_eval_string (":extension");
}



/*******************
t_set_timer_quantum
*******************/

static VALUE t_set_timer_quantum (VALUE self, VALUE interval)
{
  evma_set_timer_quantum (FIX2INT (interval));
  return Qnil;
}

/********************
t_set_max_timer_count
********************/

static VALUE t_set_max_timer_count (VALUE self, VALUE ct)
{
  evma_set_max_timer_count (FIX2INT (ct));
  return Qnil;
}

/***************
t_setuid_string
***************/

static VALUE t_setuid_string (VALUE self, VALUE username)
{
  evma_setuid_string (StringValuePtr (username));
  return Qnil;
}



/*************
t__write_file
*************/

static VALUE t__write_file (VALUE self, VALUE filename)
{
	const char *f = evma__write_file (StringValuePtr (filename));
	if (!f || !*f)
		rb_raise (rb_eRuntimeError, "file not opened");
	return rb_str_new2 (f);
}

/**************
t_invoke_popen
**************/

static VALUE t_invoke_popen (VALUE self, VALUE cmd)
{
	// 1.8.7+
	#ifdef RARRAY_LEN
		int len = RARRAY_LEN(cmd);
	#else
		int len = RARRAY (cmd)->len;
	#endif
	if (len > 98)
		rb_raise (rb_eRuntimeError, "too many arguments to popen");
	char *strings [100];
	for (int i=0; i < len; i++) {
		VALUE ix = INT2FIX (i);
		VALUE s = rb_ary_aref (1, &ix, cmd);
		strings[i] = StringValuePtr (s);
	}
	strings[len] = NULL;

	const char *f = evma_popen (strings);
	if (!f || !*f) {
		char *err = strerror (errno);
		char buf[100];
		memset (buf, 0, sizeof(buf));
		snprintf (buf, sizeof(buf)-1, "no popen: %s", (err?err:"???"));
		rb_raise (rb_eRuntimeError, buf);
	}
	return rb_str_new2 (f);
}


/***************
t_read_keyboard
***************/

static VALUE t_read_keyboard (VALUE self)
{
	const char *f = evma_open_keyboard();
	if (!f || !*f)
		rb_raise (rb_eRuntimeError, "no keyboard reader");
	return rb_str_new2 (f);
}


/********
t__epoll
********/

static VALUE t__epoll (VALUE self)
{
	// Temporary.
	evma__epoll();
	return Qnil;
}

/**********
t__epoll_p
**********/

static VALUE t__epoll_p (VALUE self)
{
  #ifdef HAVE_EPOLL
  return Qtrue;
  #else
  return Qfalse;
  #endif
}


/*********
t__kqueue
*********/

static VALUE t__kqueue (VALUE self)
{
	// Temporary.
	evma__kqueue();
	return Qnil;
}

/***********
t__kqueue_p
***********/

static VALUE t__kqueue_p (VALUE self)
{
  #ifdef HAVE_KQUEUE
  return Qtrue;
  #else
  return Qfalse;
  #endif
}


/****************
t_send_file_data
****************/

static VALUE t_send_file_data (VALUE self, VALUE signature, VALUE filename)
{

	/* The current implementation of evma_send_file_data_to_connection enforces a strict
	 * upper limit on the file size it will transmit (currently 32K). The function returns
	 * zero on success, -1 if the requested file exceeds its size limit, and a positive
	 * number for other errors.
	 * TODO: Positive return values are actually errno's, which is probably the wrong way to
	 * do this. For one thing it's ugly. For another, we can't be sure zero is never a real errno.
	 */

	int b = evma_send_file_data_to_connection (StringValuePtr(signature), StringValuePtr(filename));
	if (b == -1)
		rb_raise(rb_eRuntimeError, "File too large.  send_file_data() supports files under 32k.");
	if (b > 0) {
		char *err = strerror (b);
		char buf[1024];
		memset (buf, 0, sizeof(buf));
		snprintf (buf, sizeof(buf)-1, ": %s %s", StringValuePtr(filename),(err?err:"???"));

		rb_raise (rb_eIOError, buf);
	}

	return INT2NUM (0);
}


/*******************
t_set_rlimit_nofile
*******************/

static VALUE t_set_rlimit_nofile (VALUE self, VALUE arg)
{
	arg = (NIL_P(arg)) ? -1 : NUM2INT (arg);
	return INT2NUM (evma_set_rlimit_nofile (arg));
}

/***************************
conn_get_outbound_data_size
***************************/

static VALUE conn_get_outbound_data_size (VALUE self)
{
	VALUE sig = rb_ivar_get (self, Intern_at_signature);
	return INT2NUM (evma_get_outbound_data_size (StringValuePtr(sig)));
}


/******************************
conn_associate_callback_target
******************************/

static VALUE conn_associate_callback_target (VALUE self, VALUE sig)
{
	// No-op for the time being.
	return Qnil;
}


/***************
t_get_loop_time
****************/

static VALUE t_get_loop_time (VALUE self)
{
  VALUE cTime = rb_path2class("Time");
  if (gCurrentLoopTime != 0) {
    return rb_funcall(cTime,
                      rb_intern("at"),
                      1,
                      INT2NUM(gCurrentLoopTime));
  }
  return Qnil;
}


/*********************
Init_rubyeventmachine
*********************/

extern "C" void Init_rubyeventmachine()
{
	// Tuck away some symbol values so we don't have to look 'em up every time we need 'em.
	Intern_at_signature = rb_intern ("@signature");
	Intern_at_timers = rb_intern ("@timers");
	Intern_at_conns = rb_intern ("@conns");

	Intern_event_callback = rb_intern ("event_callback");
	Intern_run_deferred_callbacks = rb_intern ("run_deferred_callbacks");
	Intern_delete = rb_intern ("delete");
	Intern_call = rb_intern ("call");
	Intern_receive_data = rb_intern ("receive_data");

	Intern_notify_readable = rb_intern ("notify_readable");
	Intern_notify_writable = rb_intern ("notify_writable");

	// INCOMPLETE, we need to define class Connections inside module EventMachine
	// run_machine and run_machine_without_threads are now identical.
	// Must deprecate the without_threads variant.
	EmModule = rb_define_module ("EventMachine");
	EmConnection = rb_define_class_under (EmModule, "Connection", rb_cObject);

	rb_define_class_under (EmModule, "ConnectionNotBound", rb_eException);
	rb_define_class_under (EmModule, "NoHandlerForAcceptedConnection", rb_eException);
	rb_define_class_under (EmModule, "UnknownTimerFired", rb_eException);

	rb_define_module_function (EmModule, "initialize_event_machine", (VALUE(*)(...))t_initialize_event_machine, 0);
	rb_define_module_function (EmModule, "run_machine", (VALUE(*)(...))t_run_machine_without_threads, 0);
	rb_define_module_function (EmModule, "run_machine_without_threads", (VALUE(*)(...))t_run_machine_without_threads, 0);
	rb_define_module_function (EmModule, "add_oneshot_timer", (VALUE(*)(...))t_add_oneshot_timer, 1);
	rb_define_module_function (EmModule, "start_tcp_server", (VALUE(*)(...))t_start_server, 2);
	rb_define_module_function (EmModule, "stop_tcp_server", (VALUE(*)(...))t_stop_server, 1);
	rb_define_module_function (EmModule, "start_unix_server", (VALUE(*)(...))t_start_unix_server, 1);
	rb_define_module_function (EmModule, "set_tls_parms", (VALUE(*)(...))t_set_tls_parms, 3);
	rb_define_module_function (EmModule, "start_tls", (VALUE(*)(...))t_start_tls, 1);
	rb_define_module_function (EmModule, "send_data", (VALUE(*)(...))t_send_data, 3);
	rb_define_module_function (EmModule, "send_datagram", (VALUE(*)(...))t_send_datagram, 5);
	rb_define_module_function (EmModule, "close_connection", (VALUE(*)(...))t_close_connection, 2);
	rb_define_module_function (EmModule, "report_connection_error_status", (VALUE(*)(...))t_report_connection_error_status, 1);
	rb_define_module_function (EmModule, "connect_server", (VALUE(*)(...))t_connect_server, 2);
	rb_define_module_function (EmModule, "connect_unix_server", (VALUE(*)(...))t_connect_unix_server, 1);

	rb_define_module_function (EmModule, "attach_fd", (VALUE (*)(...))t_attach_fd, 3);
	rb_define_module_function (EmModule, "detach_fd", (VALUE (*)(...))t_detach_fd, 1);

	rb_define_module_function (EmModule, "current_time", (VALUE(*)(...))t_get_loop_time, 0);

	rb_define_module_function (EmModule, "open_udp_socket", (VALUE(*)(...))t_open_udp_socket, 2);
	rb_define_module_function (EmModule, "read_keyboard", (VALUE(*)(...))t_read_keyboard, 0);
	rb_define_module_function (EmModule, "release_machine", (VALUE(*)(...))t_release_machine, 0);
	rb_define_module_function (EmModule, "stop", (VALUE(*)(...))t_stop, 0);
	rb_define_module_function (EmModule, "signal_loopbreak", (VALUE(*)(...))t_signal_loopbreak, 0);
	rb_define_module_function (EmModule, "library_type", (VALUE(*)(...))t_library_type, 0);
	rb_define_module_function (EmModule, "set_timer_quantum", (VALUE(*)(...))t_set_timer_quantum, 1);
	rb_define_module_function (EmModule, "set_max_timer_count", (VALUE(*)(...))t_set_max_timer_count, 1);
	rb_define_module_function (EmModule, "setuid_string", (VALUE(*)(...))t_setuid_string, 1);
	rb_define_module_function (EmModule, "invoke_popen", (VALUE(*)(...))t_invoke_popen, 1);
	rb_define_module_function (EmModule, "send_file_data", (VALUE(*)(...))t_send_file_data, 2);

	// Provisional:
	rb_define_module_function (EmModule, "_write_file", (VALUE(*)(...))t__write_file, 1);

	rb_define_module_function (EmModule, "get_peername", (VALUE(*)(...))t_get_peername, 1);
	rb_define_module_function (EmModule, "get_sockname", (VALUE(*)(...))t_get_sockname, 1);
	rb_define_module_function (EmModule, "get_subprocess_pid", (VALUE(*)(...))t_get_subprocess_pid, 1);
	rb_define_module_function (EmModule, "get_subprocess_status", (VALUE(*)(...))t_get_subprocess_status, 1);
	rb_define_module_function (EmModule, "get_comm_inactivity_timeout", (VALUE(*)(...))t_get_comm_inactivity_timeout, 1);
	rb_define_module_function (EmModule, "set_comm_inactivity_timeout", (VALUE(*)(...))t_set_comm_inactivity_timeout, 2);
	rb_define_module_function (EmModule, "set_rlimit_nofile", (VALUE(*)(...))t_set_rlimit_nofile, 1);

	// Temporary:
	rb_define_module_function (EmModule, "epoll", (VALUE(*)(...))t__epoll, 0);
	rb_define_module_function (EmModule, "kqueue", (VALUE(*)(...))t__kqueue, 0);

	rb_define_module_function (EmModule, "epoll?", (VALUE(*)(...))t__epoll_p, 0);
	rb_define_module_function (EmModule, "kqueue?", (VALUE(*)(...))t__kqueue_p, 0);

	rb_define_method (EmConnection, "get_outbound_data_size", (VALUE(*)(...))conn_get_outbound_data_size, 0);
	rb_define_method (EmConnection, "associate_callback_target", (VALUE(*)(...))conn_associate_callback_target, 1);

	rb_define_const (EmModule, "TimerFired", INT2NUM(100));
	rb_define_const (EmModule, "ConnectionData", INT2NUM(101));
	rb_define_const (EmModule, "ConnectionUnbound", INT2NUM(102));
	rb_define_const (EmModule, "ConnectionAccepted", INT2NUM(103));
	rb_define_const (EmModule, "ConnectionCompleted", INT2NUM(104));
	rb_define_const (EmModule, "LoopbreakSignalled", INT2NUM(105));

	rb_define_const (EmModule, "ConnectionNotifyReadable", INT2NUM(106));
	rb_define_const (EmModule, "ConnectionNotifyWritable", INT2NUM(107));

}

/*****************************************************************************

$Id$

File:     sigs.cpp
Date:     06Apr06

Copyright (C) 2006-07 by Francis Cianfrocca. All Rights Reserved.
Gmail: blackhedd

This program is free software; you can redistribute it and/or modify
it under the terms of either: 1) the GNU General Public License
as published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version; or 2) Ruby's License.

See the file COPYING for complete licensing information.

*****************************************************************************/

#include "project.h"


bool gTerminateSignalReceived;


/**************
SigtermHandler
**************/

void SigtermHandler (int sig)
{
	// This is a signal-handler, don't do anything frisky. Interrupts are disabled.
	// Set the terminate flag WITHOUT trying to lock a mutex- otherwise we can easily
	// self-deadlock, especially if the event machine is looping quickly.
	gTerminateSignalReceived = true;
}


/*********************
InstallSignalHandlers
*********************/

void InstallSignalHandlers()
{
	#ifdef OS_UNIX
	static bool bInstalled = false;
	if (!bInstalled) {
		bInstalled = true;
		signal (SIGINT, SigtermHandler);
		signal (SIGTERM, SigtermHandler);
		signal (SIGPIPE, SIG_IGN);
	}
	#endif
}



/*******************
WintelSignalHandler
*******************/

#ifdef OS_WIN32
BOOL WINAPI WintelSignalHandler (DWORD control)
{
	if (control == CTRL_C_EVENT)
		gTerminateSignalReceived = true;
	return TRUE;
}
#endif

/************
HookControlC
************/

#ifdef OS_WIN32
void HookControlC (bool hook)
{
	if (hook) {
		// INSTALL hook
		SetConsoleCtrlHandler (WintelSignalHandler, TRUE);
	}
	else {
		// UNINSTALL hook
		SetConsoleCtrlHandler (WintelSignalHandler, FALSE);
	}
}
#endif


/*****************************************************************************

$Id$

File:     ssl.cpp
Date:     30Apr06

Copyright (C) 2006-07 by Francis Cianfrocca. All Rights Reserved.
Gmail: blackhedd

This program is free software; you can redistribute it and/or modify
it under the terms of either: 1) the GNU General Public License
as published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version; or 2) Ruby's License.

See the file COPYING for complete licensing information.

*****************************************************************************/


#ifdef WITH_SSL

#include "project.h"


bool SslContext_t::bLibraryInitialized = false;



static void InitializeDefaultCredentials();
static EVP_PKEY *DefaultPrivateKey = NULL;
static X509 *DefaultCertificate = NULL;

static char PrivateMaterials[] = {
"-----BEGIN RSA PRIVATE KEY-----\n"
"MIICXAIBAAKBgQDCYYhcw6cGRbhBVShKmbWm7UVsEoBnUf0cCh8AX+MKhMxwVDWV\n"
"Igdskntn3cSJjRtmgVJHIK0lpb/FYHQB93Ohpd9/Z18pDmovfFF9nDbFF0t39hJ/\n"
"AqSzFB3GiVPoFFZJEE1vJqh+3jzsSF5K56bZ6azz38VlZgXeSozNW5bXkQIDAQAB\n"
"AoGALA89gIFcr6BIBo8N5fL3aNHpZXjAICtGav+kTUpuxSiaym9cAeTHuAVv8Xgk\n"
"H2Wbq11uz+6JMLpkQJH/WZ7EV59DPOicXrp0Imr73F3EXBfR7t2EQDYHPMthOA1D\n"
"I9EtCzvV608Ze90hiJ7E3guGrGppZfJ+eUWCPgy8CZH1vRECQQDv67rwV/oU1aDo\n"
"6/+d5nqjeW6mWkGqTnUU96jXap8EIw6B+0cUKskwx6mHJv+tEMM2748ZY7b0yBlg\n"
"w4KDghbFAkEAz2h8PjSJG55LwqmXih1RONSgdN9hjB12LwXL1CaDh7/lkEhq0PlK\n"
"PCAUwQSdM17Sl0Xxm2CZiekTSlwmHrtqXQJAF3+8QJwtV2sRJp8u2zVe37IeH1cJ\n"
"xXeHyjTzqZ2803fnjN2iuZvzNr7noOA1/Kp+pFvUZUU5/0G2Ep8zolPUjQJAFA7k\n"
"xRdLkzIx3XeNQjwnmLlncyYPRv+qaE3FMpUu7zftuZBnVCJnvXzUxP3vPgKTlzGa\n"
"dg5XivDRfsV+okY5uQJBAMV4FesUuLQVEKb6lMs7rzZwpeGQhFDRfywJzfom2TLn\n"
"2RdJQQ3dcgnhdVDgt5o1qkmsqQh8uJrJ9SdyLIaZQIc=\n"
"-----END RSA PRIVATE KEY-----\n"
"-----BEGIN CERTIFICATE-----\n"
"MIID6TCCA1KgAwIBAgIJANm4W/Tzs+s+MA0GCSqGSIb3DQEBBQUAMIGqMQswCQYD\n"
"VQQGEwJVUzERMA8GA1UECBMITmV3IFlvcmsxETAPBgNVBAcTCE5ldyBZb3JrMRYw\n"
"FAYDVQQKEw1TdGVhbWhlYXQubmV0MRQwEgYDVQQLEwtFbmdpbmVlcmluZzEdMBsG\n"
"A1UEAxMUb3BlbmNhLnN0ZWFtaGVhdC5uZXQxKDAmBgkqhkiG9w0BCQEWGWVuZ2lu\n"
"ZWVyaW5nQHN0ZWFtaGVhdC5uZXQwHhcNMDYwNTA1MTcwNjAzWhcNMjQwMjIwMTcw\n"
"NjAzWjCBqjELMAkGA1UEBhMCVVMxETAPBgNVBAgTCE5ldyBZb3JrMREwDwYDVQQH\n"
"EwhOZXcgWW9yazEWMBQGA1UEChMNU3RlYW1oZWF0Lm5ldDEUMBIGA1UECxMLRW5n\n"
"aW5lZXJpbmcxHTAbBgNVBAMTFG9wZW5jYS5zdGVhbWhlYXQubmV0MSgwJgYJKoZI\n"
"hvcNAQkBFhllbmdpbmVlcmluZ0BzdGVhbWhlYXQubmV0MIGfMA0GCSqGSIb3DQEB\n"
"AQUAA4GNADCBiQKBgQDCYYhcw6cGRbhBVShKmbWm7UVsEoBnUf0cCh8AX+MKhMxw\n"
"VDWVIgdskntn3cSJjRtmgVJHIK0lpb/FYHQB93Ohpd9/Z18pDmovfFF9nDbFF0t3\n"
"9hJ/AqSzFB3GiVPoFFZJEE1vJqh+3jzsSF5K56bZ6azz38VlZgXeSozNW5bXkQID\n"
"AQABo4IBEzCCAQ8wHQYDVR0OBBYEFPJvPd1Fcmd8o/Tm88r+NjYPICCkMIHfBgNV\n"
"HSMEgdcwgdSAFPJvPd1Fcmd8o/Tm88r+NjYPICCkoYGwpIGtMIGqMQswCQYDVQQG\n"
"EwJVUzERMA8GA1UECBMITmV3IFlvcmsxETAPBgNVBAcTCE5ldyBZb3JrMRYwFAYD\n"
"VQQKEw1TdGVhbWhlYXQubmV0MRQwEgYDVQQLEwtFbmdpbmVlcmluZzEdMBsGA1UE\n"
"AxMUb3BlbmNhLnN0ZWFtaGVhdC5uZXQxKDAmBgkqhkiG9w0BCQEWGWVuZ2luZWVy\n"
"aW5nQHN0ZWFtaGVhdC5uZXSCCQDZuFv087PrPjAMBgNVHRMEBTADAQH/MA0GCSqG\n"
"SIb3DQEBBQUAA4GBAC1CXey/4UoLgJiwcEMDxOvW74plks23090iziFIlGgcIhk0\n"
"Df6hTAs7H3MWww62ddvR8l07AWfSzSP5L6mDsbvq7EmQsmPODwb6C+i2aF3EDL8j\n"
"uw73m4YIGI0Zw2XdBpiOGkx2H56Kya6mJJe/5XORZedh1wpI7zki01tHYbcy\n"
"-----END CERTIFICATE-----\n"};

/* These private materials were made with:
 * openssl req -new -x509 -keyout cakey.pem -out cacert.pem -nodes -days 6500
 * TODO: We need a full-blown capability to work with user-supplied
 * keypairs and properly-signed certificates.
 */


/*****************
builtin_passwd_cb
*****************/

extern "C" int builtin_passwd_cb (char *buf, int bufsize, int rwflag, void *userdata)
{
	strcpy (buf, "kittycat");
	return 8;
}

/****************************
InitializeDefaultCredentials
****************************/

static void InitializeDefaultCredentials()
{
	BIO *bio = BIO_new_mem_buf (PrivateMaterials, -1);
	assert (bio);

	if (DefaultPrivateKey) {
		// we may come here in a restart.
		EVP_PKEY_free (DefaultPrivateKey);
		DefaultPrivateKey = NULL;
	}
	PEM_read_bio_PrivateKey (bio, &DefaultPrivateKey, builtin_passwd_cb, 0);

	if (DefaultCertificate) {
		// we may come here in a restart.
		X509_free (DefaultCertificate);
		DefaultCertificate = NULL;
	}
	PEM_read_bio_X509 (bio, &DefaultCertificate, NULL, 0);

	BIO_free (bio);
}



/**************************
SslContext_t::SslContext_t
**************************/

SslContext_t::SslContext_t (bool is_server, const string &privkeyfile, const string &certchainfile):
	pCtx (NULL),
	PrivateKey (NULL),
	Certificate (NULL)
{
	/* TODO: the usage of the specified private-key and cert-chain filenames only applies to
	 * client-side connections at this point. Server connections currently use the default materials.
	 * That needs to be fixed asap.
	 * Also, in this implementation, server-side connections use statically defined X-509 defaults.
	 * One thing I'm really not clear on is whether or not you have to explicitly free X509 and EVP_PKEY
	 * objects when we call our destructor, or whether just calling SSL_CTX_free is enough.
	 */

	if (!bLibraryInitialized) {
		bLibraryInitialized = true;
		SSL_library_init();
		OpenSSL_add_ssl_algorithms();
	        OpenSSL_add_all_algorithms();
		SSL_load_error_strings();
		ERR_load_crypto_strings();

		InitializeDefaultCredentials();
	}

	bIsServer = is_server;
	pCtx = SSL_CTX_new (is_server ? SSLv23_server_method() : SSLv23_client_method());
	if (!pCtx)
		throw std::runtime_error ("no SSL context");

	SSL_CTX_set_options (pCtx, SSL_OP_ALL);
	//SSL_CTX_set_options (pCtx, (SSL_OP_NO_SSLv2 | SSL_OP_NO_SSLv3));

	if (is_server) {
		// The SSL_CTX calls here do NOT allocate memory.
		int e;
		if (privkeyfile.length() > 0)
			e = SSL_CTX_use_PrivateKey_file (pCtx, privkeyfile.c_str(), SSL_FILETYPE_PEM);
		else
			e = SSL_CTX_use_PrivateKey (pCtx, DefaultPrivateKey);
		assert (e > 0);
		if (certchainfile.length() > 0)
			e = SSL_CTX_use_certificate_chain_file (pCtx, certchainfile.c_str());
		else
			e = SSL_CTX_use_certificate (pCtx, DefaultCertificate);
		assert (e > 0);
	}

	SSL_CTX_set_cipher_list (pCtx, "ALL:!ADH:!LOW:!EXP:!DES-CBC3-SHA:@STRENGTH");

	if (is_server) {
		SSL_CTX_sess_set_cache_size (pCtx, 128);
		SSL_CTX_set_session_id_context (pCtx, (unsigned char*)"eventmachine", 12);
	}
	else {
		int e;
		if (privkeyfile.length() > 0) {
			e = SSL_CTX_use_PrivateKey_file (pCtx, privkeyfile.c_str(), SSL_FILETYPE_PEM);
			assert (e > 0);
		}
		if (certchainfile.length() > 0) {
			e = SSL_CTX_use_certificate_chain_file (pCtx, certchainfile.c_str());
			assert (e > 0);
		}
	}
}



/***************************
SslContext_t::~SslContext_t
***************************/

SslContext_t::~SslContext_t()
{
	if (pCtx)
		SSL_CTX_free (pCtx);
	if (PrivateKey)
		EVP_PKEY_free (PrivateKey);
	if (Certificate)
		X509_free (Certificate);
}



/******************
SslBox_t::SslBox_t
******************/

SslBox_t::SslBox_t (bool is_server, const string &privkeyfile, const string &certchainfile):
	bIsServer (is_server),
	pSSL (NULL),
	pbioRead (NULL),
	pbioWrite (NULL)
{
	/* TODO someday: make it possible to re-use SSL contexts so we don't have to create
	 * a new one every time we come here.
	 */

	Context = new SslContext_t (bIsServer, privkeyfile, certchainfile);
	assert (Context);

	pbioRead = BIO_new (BIO_s_mem());
	assert (pbioRead);

	pbioWrite = BIO_new (BIO_s_mem());
	assert (pbioWrite);

	pSSL = SSL_new (Context->pCtx);
	assert (pSSL);
	SSL_set_bio (pSSL, pbioRead, pbioWrite);

	if (!bIsServer)
		SSL_connect (pSSL);
}



/*******************
SslBox_t::~SslBox_t
*******************/

SslBox_t::~SslBox_t()
{
	// Freeing pSSL will also free the associated BIOs, so DON'T free them separately.
	if (pSSL) {
		if (SSL_get_shutdown (pSSL) & SSL_RECEIVED_SHUTDOWN)
			SSL_shutdown (pSSL);
		else
			SSL_clear (pSSL);
		SSL_free (pSSL);
	}

	delete Context;
}



/***********************
SslBox_t::PutCiphertext
***********************/

bool SslBox_t::PutCiphertext (const char *buf, int bufsize)
{
	assert (buf && (bufsize > 0));

	assert (pbioRead);
	int n = BIO_write (pbioRead, buf, bufsize);

	return (n == bufsize) ? true : false;
}


/**********************
SslBox_t::GetPlaintext
**********************/

int SslBox_t::GetPlaintext (char *buf, int bufsize)
{
	if (!SSL_is_init_finished (pSSL)) {
		int e = bIsServer ? SSL_accept (pSSL) : SSL_connect (pSSL);
		if (e < 0) {
			int er = SSL_get_error (pSSL, e);
			if (er != SSL_ERROR_WANT_READ) {
				// Return -1 for a nonfatal error, -2 for an error that should force the connection down.
				return (er == SSL_ERROR_SSL) ? (-2) : (-1);
			}
			else
				return 0;
		}
		// If handshake finished, FALL THROUGH and return the available plaintext.
	}

	if (!SSL_is_init_finished (pSSL)) {
		// We can get here if a browser abandons a handshake.
		// The user can see a warning dialog and abort the connection.
		cerr << "<SSL_incomp>";
		return 0;
	}

	//cerr << "CIPH: " << SSL_get_cipher (pSSL) << endl;

	int n = SSL_read (pSSL, buf, bufsize);
	if (n >= 0) {
		return n;
	}
	else {
		if (SSL_get_error (pSSL, n) == SSL_ERROR_WANT_READ) {
			return 0;
		}
		else {
			return -1;
		}
	}

	return 0;
}



/**************************
SslBox_t::CanGetCiphertext
**************************/

bool SslBox_t::CanGetCiphertext()
{
	assert (pbioWrite);
	return BIO_pending (pbioWrite) ? true : false;
}



/***********************
SslBox_t::GetCiphertext
***********************/

int SslBox_t::GetCiphertext (char *buf, int bufsize)
{
	assert (pbioWrite);
	assert (buf && (bufsize > 0));

	return BIO_read (pbioWrite, buf, bufsize);
}



/**********************
SslBox_t::PutPlaintext
**********************/

int SslBox_t::PutPlaintext (const char *buf, int bufsize)
{
	// The caller will interpret the return value as the number of bytes written.
	// WARNING WARNING WARNING, are there any situations in which a 0 or -1 return
	// from SSL_write means we should immediately retry? The socket-machine loop
	// will probably wait for a time-out cycle (perhaps a second) before re-trying.
	// THIS WOULD CAUSE A PERCEPTIBLE DELAY!

	/* We internally queue any outbound plaintext that can't be dispatched
	 * because we're in the middle of a handshake or something.
	 * When we get called, try to send any queued data first, and then
	 * send the caller's data (or queue it). We may get called with no outbound
	 * data, which means we try to send the outbound queue and that's all.
	 *
	 * Return >0 if we wrote any data, 0 if we didn't, and <0 for a fatal error.
	 * Note that if we return 0, the connection is still considered live
	 * and we are signalling that we have accepted the outbound data (if any).
	 */

	OutboundQ.Push (buf, bufsize);

	if (!SSL_is_init_finished (pSSL))
		return 0;

	bool fatal = false;
	bool did_work = false;

	while (OutboundQ.HasPages()) {
		const char *page;
		int length;
		OutboundQ.Front (&page, &length);
		assert (page && (length > 0));
		int n = SSL_write (pSSL, page, length);
		if (n > 0) {
			did_work = true;
			OutboundQ.PopFront();
		}
		else {
			int er = SSL_get_error (pSSL, n);
			if ((er != SSL_ERROR_WANT_READ) && (er != SSL_ERROR_WANT_WRITE))
				fatal = true;
			break;
		}
	}


	if (did_work)
		return 1;
	else if (fatal)
		return -1;
	else
		return 0;
}


#endif // WITH_SSL

