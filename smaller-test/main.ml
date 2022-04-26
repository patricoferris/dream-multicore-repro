open Httpaf_lwt_unix

let forever, _ = Lwt.wait ()

let error_handler _ ?request:_ _error _ = failwith "ERROR!"

let request_handler _ r =
  let reqd : Httpaf.Reqd.t = r.Gluten.reqd in
  let headers = Httpaf.Headers.of_list ["content-length", Int.to_string (String.length Text.large_string)] in
  let response = Httpaf.Response.create ~headers `OK in
  Httpaf.Reqd.respond_with_string reqd response (Text.large_string)

let main port =
  let open Lwt.Infix in
  let listen_address = Unix.(ADDR_INET (inet_addr_loopback, port)) in
  Lwt.async begin fun () ->
    Lwt_io.establish_server_with_client_socket
      listen_address
      (Server.create_connection_handler ~request_handler ~error_handler)
    >>= fun _server -> Lwt.return_unit
  end;
  Lwt_main.run forever

let () =
  main 8080