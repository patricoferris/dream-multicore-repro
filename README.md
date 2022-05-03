dream-multicore-repro
---------------------

**Turns out it was https://github.com/savonet/ocaml-ssl/issues/76**

Some GC issue when responding with a large string in Dream with Multicore OCaml (on macOS/x86). To run locally:

```
opam update
opam switch create 5.0.0+trunk
opam install dune
dune exec -- src/main.exe
```

Once the server is running, go to `localhost:8080` and keep refreshing the page quickly.

<details>
  <summary>lldb backtrace</summary>
  <pre>
    <code>
    Process 19588 stopped
    * thread #1, name = 'Domain0', queue = 'com.apple.main-thread', stop reason = EXC_BAD_ACCESS (code=2, address=0x10026d868)
        frame #0: 0x00000001002b9d29 main.exe`caml_darken(state=<unavailable>, v=4297513072, ignored=<unavailable>) at major_gc.c:789:7 [opt]
    Target 0: (main.exe) stopped.
    (lldb) bt
    * thread #1, name = 'Domain0', queue = 'com.apple.main-thread', stop reason = EXC_BAD_ACCESS (code=2, address=0x10026d868)
    * frame #0: 0x00000001002b9d29 main.exe`caml_darken(state=<unavailable>, v=4297513072, ignored=<unavailable>) at major_gc.c:789:7 [opt]
        frame #1: 0x00000001002b165e main.exe`caml_scan_global_roots [inlined] scan_native_globals(f=(main.exe`caml_darken at major_gc.c:772), fdata=0]
        frame #2: 0x00000001002b1599 main.exe`caml_scan_global_roots(f=(main.exe`caml_darken at major_gc.c:772), fdata=0x0000000000000000) at globroot]
        frame #3: 0x00000001002bb71f main.exe`cycle_all_domains_callback(domain=0x0000000100f05870, unused=0x0000000000000000, participating_count=<un]
        frame #4: 0x00000001002a8674 main.exe`caml_try_run_on_all_domains_with_spin_work(handler=(main.exe`cycle_all_domains_callback at major_gc.c:91]
        frame #5: 0x00000001002a86fa main.exe`caml_try_run_on_all_domains(handler=<unavailable>, data=<unavailable>, leader_setup=<unavailable>) at do]
        frame #6: 0x00000001002baa8c main.exe`major_collection_slice(howmuch=<unavailable>, participant_count=0, barrier_participants=0x00000000000000]
        frame #7: 0x00000001002baafb main.exe`caml_major_collection_slice(howmuch=-1) at major_gc.c:1360:31 [opt]
        frame #8: 0x00000001002a8847 main.exe`caml_poll_gc_work at domain.c:1251:5 [opt]
        frame #9: 0x00000001002a8790 main.exe`caml_handle_gc_interrupt at domain.c:1281:3 [opt] [artificial]
        frame #10: 0x00000001002c2149 main.exe`caml_process_pending_actions at signals.c:243:3 [opt]
        frame #11: 0x00000001002c924f main.exe`caml_call_gc + 231
        frame #12: 0x0000000100006486 main.exe`caml_curry2_1 + 38
        frame #13: 0x000000010001506f main.exe`camlDream__http__Http__forward_response_1501 + 255
        frame #14: 0x00000001001ac22b main.exe`camlLwt__catch_1477 + 59
        frame #15: 0x00000001001aeb4d main.exe`camlLwt__async_1855 + 61
        frame #16: 0x0000000100065712 main.exe`camlHttpaf__Server_connection__read_with_more_1340 + 146
        frame #17: 0x000000010004c499 main.exe`camlGluten_lwt__get_568 + 41
        frame #18: 0x000000010004cb4d main.exe`camlGluten_lwt__fun_1015 + 221
        frame #19: 0x00000001001ab7ab main.exe`camlLwt__callback_1364 + 155
        frame #20: 0x00000001001aa1dc main.exe`camlLwt__iter_callback_list_933 + 140
        frame #21: 0x00000001001aa383 main.exe`camlLwt__run_in_resolution_loop_1003 + 51
        frame #22: 0x00000001001aa551 main.exe`camlLwt__resolve_1023 + 113
        frame #23: 0x00000001001ac097 main.exe`camlLwt__callback_1449 + 263
        frame #24: 0x00000001001aa1dc main.exe`camlLwt__iter_callback_list_933 + 140
        frame #25: 0x00000001001aa383 main.exe`camlLwt__run_in_resolution_loop_1003 + 51
        frame #26: 0x00000001001aa551 main.exe`camlLwt__resolve_1023 + 113
        frame #27: 0x00000001001ac539 main.exe`camlLwt__callback_1491 + 201
        frame #28: 0x00000001001aa1dc main.exe`camlLwt__iter_callback_list_933 + 140
        frame #29: 0x00000001001aa383 main.exe`camlLwt__run_in_resolution_loop_1003 + 51
        frame #30: 0x00000001001aa551 main.exe`camlLwt__resolve_1023 + 113
        frame #31: 0x00000001001ac097 main.exe`camlLwt__callback_1449 + 263
        frame #32: 0x00000001001aa1dc main.exe`camlLwt__iter_callback_list_933 + 140
        frame #33: 0x00000001001aa383 main.exe`camlLwt__run_in_resolution_loop_1003 + 51
        frame #34: 0x00000001001aa551 main.exe`camlLwt__resolve_1023 + 113
        frame #35: 0x00000001001aa7e6 main.exe`camlLwt__wakeup_general_1060 + 198
        frame #36: 0x00000001001a8740 main.exe`camlLwt_sequence__loop_344 + 64
        frame #37: 0x00000001002c9434 main.exe`caml_start_program + 112
        frame #38: 0x00000001002a58bc main.exe`caml_callback_exn(closure=<unavailable>, arg=1) at callback.c:169:1 [opt]
        frame #39: 0x00000001002a5d59 main.exe`caml_callback(closure=<unavailable>, arg=<unavailable>) at callback.c:253:34 [opt]
        frame #40: 0x0000000100cbc473 libev.4.dylib`ev_invoke_pending + 90
        frame #41: 0x000000010028a74e main.exe`lwt_libev_loop(val_loop=<unavailable>, val_block=3) at lwt_libev_stubs.c:106:3 [opt]
        frame #42: 0x00000001002c937b main.exe`caml_c_call + 27
        frame #43: 0x0000000100172eb6 main.exe`camlLwt_engine__fun_2447 + 54
        frame #44: 0x00000001003b95c8 main.exe`camlDream__http__Http__149 + 24
        frame #45: 0x0000000100176e15 main.exe`camlLwt_main__run_loop_436 + 213
        frame #46: 0x0000000100177110 main.exe`camlLwt_main__run_499 + 288
        frame #47: 0x0000000100017759 main.exe`camlDream__http__Http__run_inner_3291 + 761
        frame #48: 0x00000001000076e7 main.exe`camlDune__exe__Main__entry + 199
        frame #49: 0x000000010000216b main.exe`caml_program + 4907
        frame #50: 0x00000001002c9434 main.exe`caml_start_program + 112
        frame #51: 0x00000001002c8c7b main.exe`caml_main [inlined] caml_startup(argv=<unavailable>) at startup_nat.c:136:7 [opt]
        frame #52: 0x00000001002c8c74 main.exe`caml_main(argv=<unavailable>) at startup_nat.c:142 [opt]
        frame #53: 0x00000001002b92dc main.exe`main(argc=<unavailable>, argv=<unavailable>) at main.c:37:3 [opt]
        frame #54: 0x00007fff6f886cc9 libdyld.dylib`start + 1
    </code>
  </pre>
</details>
