(* Copyright (C) 2015  Petter A. Urkedal <paurkedal@gmail.com>
 *
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or (at your
 * option) any later version, with the LGPL-3.0 Linking Exception.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
 * License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * and the LGPL-3.0 Linking Exception along with this library.  If not, see
 * <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.
 *)

let bprint_sql_escaped buf s =
  for i = 0 to String.length s - 1 do
    match s.[i] with
    | '\'' -> Buffer.add_string buf "''"
    | c -> Buffer.add_char buf c
  done

let bprint_sql_quoted buf s =
  Buffer.add_char buf '\'';
  bprint_sql_escaped buf s;
  Buffer.add_char buf '\''

let sql_escaped s =
  let buf = Buffer.create (5 * String.length s / 4) in
  bprint_sql_escaped buf s;
  Buffer.contents buf

let sql_quoted s =
  let buf = Buffer.create (5 * String.length s / 4 + 2) in
  bprint_sql_quoted buf s;
  Buffer.contents buf
