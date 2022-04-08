(* Copyright (C) 2021  Petter A. Urkedal <paurkedal@gmail.com>
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

open Caqti_common_priv

let (-->) tA tR f =
  Caqti_request.create_p tA tR Caqti_mult.one
    (f % Caqti_driver_info.dialect_tag)

let select_two_q =
  Caqti_request.find Caqti_type.unit Caqti_type.int "SELECT 2"
let select_twice_q =
  Caqti_request.find Caqti_type.int Caqti_type.int "SELECT 2 * ?"

let sleep_q =
  Caqti_type.(unit --> option int) @@ function
   | `Pgsql -> "SELECT pg_sleep(2)"
   | _ -> "SELECT sleep(2)"

module Make (Ground : Testlib.Sig.Ground) = struct
  open Ground

  let test_raise_in_call fail' (module Db : Caqti_sys.CONNECTION) =
    let test i =
      catch
        (fun () ->
          Db.call ~f:(fun _ -> fail' Not_found) select_two_q ()
            >|= fun _ -> assert false)
        (function
         | Not_found -> return ()
         | exn -> failwith ("unexpected exception: " ^ Printexc.to_string exn))
        >>= fun () ->
      Db.find select_twice_q i
        >|= (function Ok j -> assert (j = 2 * i) | _ -> assert false)
    in
    test 3 >>= fun () ->
    test 5 >>= fun () ->
    test 15

  let test_statement_timeout (module Db : Caqti_sys.CONNECTION) =
    if Caqti_driver_info.dialect_tag Db.driver_info = `Sqlite then
      return () (* Does not support statement timeout. *)
    else
    let check_timed_out = function
      | Error (`Request_failed _) -> ()
      | Error err -> failwith ("unexpected error: " ^ Caqti_error.show err)
      | Ok _ -> assert false
    in
    let test i =
      Db.find sleep_q () >|= check_timed_out >>= fun () ->
      Db.find select_twice_q i
        >|= (function Ok j -> assert (j = 2 * i) | _ -> assert false)
    in
    Db.set_statement_timeout (Some 0.1) >>= or_fail >>= fun () ->
    test 3 >>= fun () ->
    test 5 >>= fun () ->
    Db.set_statement_timeout None >>= or_fail

  let test_cases = [
    "raise in call", `Quick, test_raise_in_call raise;
    "fail in call", `Quick, test_raise_in_call fail;
    "statement timeout", `Quick, test_statement_timeout;
  ]
end
