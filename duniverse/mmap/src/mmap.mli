(** Compat module for memory mapping files *)

module V1 : sig
  val map_file :
       Unix.file_descr
    -> ?pos:int64
    -> ('a, 'b) Bigarray_compat.kind
    -> 'c Bigarray_compat.layout
    -> bool
    -> int array
    -> ('a, 'b, 'c) Bigarray_compat.Genarray.t
  (** [map_file] is the same as {!Unix.map_file} in OCaml >= 4.06.0 *)
end
