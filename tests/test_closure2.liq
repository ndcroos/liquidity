let version = 1.0

let%entry main
      (parameter : int)
      (storage : int)
      [%return : unit] =
  let x = parameter + 10 in
  let f ( arg : int * int ) (y : int) =
    arg.(0) + x + y
  in
  let storage = f (parameter, storage) 199 in
  ( (), storage )
