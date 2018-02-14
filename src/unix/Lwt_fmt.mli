(* OCaml promise library
 * http://www.ocsigen.org/lwt
 * Copyright (C) 2018 Gabriel Radanne
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, with linking exceptions;
 * either version 2.1 of the License, or (at your option) any later
 * version. See COPYING file for details.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
 * 02111-1307, USA.
 *)

(** Format API for Lwt-powered IOs *)

(** This module bridges the gap between [Format] and [Lwt].
    Although it is not required, it is recommended to use this module with the
    [Fmt] library.

    Compared to regular formatting function, the main difference is that
    printing statements will now return promises instead of blocking.
*)

val printf : ('a, Format.formatter, unit, unit Lwt.t) format4 -> 'a
(** Returns a promise that prints on the standard output. 
    Similar to [Format.printf]. *)

val eprintf : ('a, Format.formatter, unit, unit Lwt.t) format4 -> 'a
(** Returns a promise that prints on the standard error. 
    Similar to [Format.eprintf]. *)

(** {1 Formatters} *)

type formatter
(** Lwt enabled formatters *)

type order =
  | String of string * int * int (** [String (s, off, len)] indicate the output of [s] at offset [off] and length [len]. *)
  | Flush (** Flush operation *)

val make_stream : unit -> order Lwt_stream.t * formatter
(** [make_stream ()] returns a formatter and a stream of all the writing
    order given on that stream.
*)


val of_channel : Lwt_io.output_channel -> formatter
(** [of_channel oc] creates a formatter that writes to the channel [oc]. *)

val stdout : formatter (** Formatter printing on {!Lwt_io.stdout}. *)
val stderr : formatter (** Formatter printing on {!Lwt_io.stdout}. *)

val make_formatter :
  commit:(unit -> unit Lwt.t) -> fmt:Format.formatter -> unit -> formatter
(** [make_formatter ~commit ~fmt] creates a new lwt formatter based on the
    {!Format.formatter} [fmt]. The [commit] function will be called by the printing
    functions to update the underlying channel.
*)

(** {2 Printing} *)

val fprintf : formatter -> ('a, Format.formatter, unit, unit Lwt.t) format4 -> 'a

val kfprintf :
  (Format.formatter -> unit Lwt.t -> 'a) ->
  formatter -> ('b, Format.formatter, unit, 'a) format4 -> 'b

val ifprintf : formatter -> ('a, Format.formatter, unit, unit Lwt.t) format4 -> 'a

val ikfprintf :
  (Format.formatter -> unit Lwt.t -> 'a) ->
  formatter -> ('b, Format.formatter, unit, 'a) format4 -> 'b

val flush : formatter -> unit Lwt.t
(** [flush fmt] flushes the formatter (as with {!Format.pp_print_flush}) and
    executes all the printing action on the underlying channel.
*)


(** Low level functions *)

val write_order : Lwt_io.output_channel -> order -> unit Lwt.t
(** [write_order oc o] applies the order [o] on the channel [oc]. *)

val write_pending : formatter -> unit Lwt.t
(** Write all the pending orders of a formatter.
    Warning: This function flush neither the internal format queues
    nor the underlying channel and is intended for low level use only. 
    You should probably use {!flush} instead.
*)
