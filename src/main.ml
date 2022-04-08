let () =
  Dream.run
  @@ Dream.router [
     Dream.get "/**" (fun _ -> Dream.respond Text.large_string)
  ]