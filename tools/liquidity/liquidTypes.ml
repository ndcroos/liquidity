(**************************************************************************)
(*                                                                        *)
(*    Copyright (c) 2017       .                                          *)
(*    Fabrice Le Fessant, OCamlPro SAS <fabrice@lefessant.net>            *)
(*                                                                        *)
(*    All rights reserved. No warranty, explicit or implicit, provided.   *)
(*                                                                        *)
(**************************************************************************)

module StringMap = Map.Make(String)
module StringSet = Set.Make(String)

exception InvalidFormat of string * string

type tez = { tezzies : string; centiles : string option }
type integer = { integer : string }

                 (*
module Tez : sig

  type t

  val of_ocaml : string -> t
  val to_ocaml : t -> string

  val of_tezos : string -> t
  val to_tezos : t -> string

end = struct

  (* Internally: tezzies * centiles *)
  type t = string * string option

  (* from an OCaml float *)
  let of_ocaml s =
    let b = Buffer.create 10 in
    let tezzies = ref None in
    for i = 0 to String.length s - 1 do
      match s.[i] with
      | '_' -> ()
      | '.' -> begin
          match !tezzies with
          end
      | c -> Buffer.add_char b c
    done;
    Buffer.contents b

  let to_ocaml s =
    let b = Buffer.create 10 in
    for i = 0 to String.length s - 1 do
      match s.[i] with
      | ',' ->  Buffer.add_char b '_'
      | c -> Buffer.add_char b c
    done;
    let before, after = String.cut_at '.' (Buffer.contents b)

  let to_tezos s = s
  let of_tezos s =s

end

module Integer : sig

  type t

  val of_ocaml : string -> t
  val to_ocaml : t -> string
  val of_tezos : string -> t
  val to_tezos : t -> string
  val to_int : t -> int
  val of_int : int -> t

end = struct

  type t = string

  let of_ocaml s = s
  let to_ocaml s = s

  let to_tezos s = s
  let of_tezos s = s

  let to_int s = int_of_string s
  let of_int s = string_of_int s
end
                  *)

type const =
  | CUnit
  | CBool of bool
  | CInt of integer
  | CNat of integer
  | CTez of tez
  | CTimestamp of string
  | CString of string
  | CKey of string
  | CSignature of string
  | CTuple of const list
  | CNone
  | CSome of const

  (* Map [ key_x_value_list ] or (Map [] : ('key,'value) map) *)
  | CMap of (const * const) list
  | CList of const list
  | CSet of const list

  | CLeft of const
  | CRight of const

and datatype =
  | Tunit
  | Tbool
  | Tint
  | Tnat
  | Ttez
  | Tstring
  | Ttimestamp
  | Tkey
  | Tsignature

  | Ttuple of datatype list

  | Toption of datatype
  | Tlist of datatype
  | Tset of datatype

  | Tmap of datatype * datatype
  | Tcontract of datatype * datatype
  | Tor of datatype * datatype
  | Tlambda of datatype * datatype
  | Tclosure of (datatype * datatype) * datatype

  | Tfail
  | Ttype of string * datatype


type 'exp contract = {
    parameter : datatype;
    storage : datatype;
    return : datatype;
    code : 'exp;
  }

type location = {
    loc_file : string;
    loc_pos : ( (int * int) * (int*int) ) option;
  }

exception Error of location * string



type primitive =
   (* resolved in LiquidCheck *)
  | Prim_unknown
  | Prim_coll_find
  | Prim_coll_update
  | Prim_coll_mem
  | Prim_coll_reduce
  | Prim_coll_map
  | Prim_coll_size

  (* generated in LiquidCheck *)
  | Prim_unused

  (* primitives *)
  | Prim_tuple_get_last
  | Prim_tuple_get
  | Prim_tuple_set_last
  | Prim_tuple_set
  | Prim_tuple

  | Prim_fail
  | Prim_self
  | Prim_balance
  | Prim_now
  | Prim_amount
  | Prim_gas
  | Prim_Left
  | Prim_Right
  | Prim_Source
  | Prim_eq
  | Prim_neq
  | Prim_lt
  | Prim_le
  | Prim_gt
  | Prim_ge
  | Prim_compare
  | Prim_add
  | Prim_sub
  | Prim_mul
  | Prim_ediv

  | Prim_map_find
  | Prim_map_update
  | Prim_map_mem
  | Prim_map_reduce
  | Prim_map_map
  | Prim_map_size

  | Prim_set_update
  | Prim_set_mem
  | Prim_set_reduce
  | Prim_set_size
  | Prim_set_map

  | Prim_Some
  | Prim_concat

  | Prim_list_reduce
  | Prim_list_map
  | Prim_list_size

  | Prim_manager
  | Prim_create_account
  | Prim_create_contract
  | Prim_hash
  | Prim_check
  | Prim_default_account


  | Prim_Cons
  | Prim_or
  | Prim_and
  | Prim_xor
  | Prim_not
  | Prim_abs
  | Prim_int
  | Prim_neg
  | Prim_lsr
  | Prim_lsl

  | Prim_exec


let primitive_of_string = Hashtbl.create 101
let string_of_primitive = Hashtbl.create 101
let () =
  List.iter (fun (n,p) ->
      Hashtbl.add primitive_of_string n p;
      Hashtbl.add string_of_primitive p n;
    )
            [
              "get", Prim_tuple_get;
              "get_last", Prim_tuple_get_last;
              "Array.get", Prim_tuple_get;
              "set_last", Prim_tuple_set_last;
              "set", Prim_tuple_set;
              "Array.set", Prim_tuple_set;
              "tuple", Prim_tuple;
              "Current.fail", Prim_fail;
              "Current.contract", Prim_self;
              "Current.balance", Prim_balance;
              "Current.time", Prim_now;
              "Current.amount", Prim_amount;
              "Current.gas", Prim_gas;
              "Left", Prim_Left;
              "Right", Prim_Right;
              "Source", Prim_Source;
              "=", Prim_eq;
              "<>", Prim_neq;
              "<", Prim_lt;
              "<=", Prim_le;
              ">", Prim_gt;
              ">=", Prim_ge;
              "compare", Prim_compare;
              "+", Prim_add;
              "-", Prim_sub;
              "*", Prim_mul;
              "/", Prim_ediv;

              "Map.find", Prim_map_find;
              "Map.update", Prim_map_update;
              "Map.mem", Prim_map_mem;
              "Map.reduce", Prim_map_reduce;
              "Map.map", Prim_map_map;

              "Set.update", Prim_set_update;
              "Set.mem", Prim_set_mem;
              "Set.reduce", Prim_set_reduce;
              "Set.map", Prim_set_map;

              "Some", Prim_Some;
              "@", Prim_concat;

              "List.reduce", Prim_list_reduce;
              "List.map", Prim_list_map;

              "Contract.manager", Prim_manager;
              "Account.create", Prim_create_account;
              "Contract.create", Prim_create_contract;
              "Crypto.hash", Prim_hash;
              "Crypto.check", Prim_check;
              "Account.default", Prim_default_account;
              "List.size", Prim_list_size;
              "Set.size", Prim_set_size;
              "Map.size", Prim_map_size;

              "::", Prim_Cons;
              "or", Prim_or;
              "&", Prim_and;
              "xor", Prim_xor;
              "not", Prim_not;
              "abs", Prim_abs;
              "int", Prim_int;
              ">>", Prim_lsr;
              "<<", Prim_lsl;

              "|>", Prim_exec;
              "Lambda.pipe" , Prim_exec;

              "Coll.update", Prim_coll_update;
              "Coll.mem", Prim_coll_mem;
              "Coll.find", Prim_coll_find;
              "Coll.map", Prim_coll_map;
              "Coll.reduce", Prim_coll_reduce;
              "Coll.size",Prim_coll_size;

              "<unknown>", Prim_unknown;
              "<unused>", Prim_unused;

            ]

let primitive_of_string s =
  try
    Hashtbl.find primitive_of_string s
  with Not_found ->
    Printf.eprintf "Debug: primitive_of_string(%S) raised Not_found\n%!" s;
    raise Not_found

let string_of_primitive prim =
  try
    Hashtbl.find string_of_primitive prim
  with Not_found ->
    Printf.eprintf "Debug: string_of_primitive(%d) raised Not_found\n%!"
                   (Obj.magic prim : int);
    raise Not_found


(* `variant` is the only parameterized type authorized in Liquidity.
   Its constructors, `Left` and `Right` must be constrained with type
   annotations, for the correct types to be propagated in the sources.
*)
type constructor =
  Constr of string
| Left of datatype
| Right of datatype
| Source of datatype * datatype

type 'ty exp = {
    desc : 'ty exp_desc;
    ty : 'ty;
    bv : StringSet.t;
    fail : bool;
  }

 and 'ty exp_desc =
  | Let of string * location * 'ty exp * 'ty exp
  | Var of string * location * string list
  | SetVar of string * location * string list * 'ty exp
  | Const of datatype * const
  | Apply of primitive * location * 'ty exp list
  | If of 'ty exp * 'ty exp * 'ty exp
  | Seq of 'ty exp * 'ty exp
  | LetTransfer of (* storage *) string * (* result *) string
                                 * location
                   * (* contract_ *) 'ty exp
                   * (* tez_ *) 'ty exp
                   * (* storage_ *) 'ty exp
                   * (* arg_ *) 'ty exp
                   * 'ty exp (* body *)
  | MatchOption of 'ty exp  (* argument *)
                     * location
                     * 'ty exp  (* ifnone *)
                     * string * 'ty exp (*  ifsome *)
  | MatchList of 'ty exp  (* argument *)
                 * location
                 * string * string * 'ty exp * (* ifcons *)
                       'ty exp (*  ifnil *)
  | Loop of string * location
              * 'ty exp  (* body *)
              * 'ty exp (*  arg *)

  | Lambda of string (* argument name *)
              * datatype (* argument type *)
              * location
              * 'ty exp (* body *)
              * datatype (* final datatype,
                            inferred during typechecking *)

  | Closure of string (* argument name *)
              * datatype (* argument type *)
              * location
              * (string * 'ty exp) list (* call environment *)
              * 'ty exp (* body *)
              * datatype (* final datatype,
                            inferred during typechecking *)

  | Record of location * (string * 'ty exp) list
  | Constructor of location * constructor * 'ty exp

  | MatchVariant of 'ty exp
                    * location
                    * (string * string list * 'ty exp) list

type syntax_exp = unit exp
type typed_exp = datatype exp
type live_exp = (datatype * datatype StringMap.t) exp




type michelson_exp =
  | M_INS of string
  | M_INS_CST of string * datatype * const
  | M_INS_EXP of string * datatype list * michelson_exp list

type pre_michelson =
  | SEQ of pre_michelson list
  | DIP of int * pre_michelson
  | IF of pre_michelson * pre_michelson
  | IF_NONE of pre_michelson * pre_michelson
  | IF_CONS of pre_michelson * pre_michelson
  | IF_LEFT of pre_michelson * pre_michelson
  | LOOP of pre_michelson

  | LAMBDA of datatype * datatype * pre_michelson
  | EXEC

  | DUP of int
  | DIP_DROP of int * int
  | DROP
  | CAR
  | CDR
  | CDAR of int
  | CDDR of int
  | PUSH of datatype * const
  | PAIR
  | COMPARE
  | LE | LT | GE | GT | NEQ | EQ
  | FAIL
  | NOW
  | TRANSFER_TOKENS
  | ADD
  | SUB
  | BALANCE
  | SWAP
  | GET
  | UPDATE
  | SOME
  | CONCAT
  | MEM
  | MAP
  | REDUCE

  | SELF
  | AMOUNT
  | STEPS_TO_QUOTA
  | MANAGER
  | CREATE_ACCOUNT
  | CREATE_CONTRACT
  | H
  | CHECK_SIGNATURE

  | CONS
  | OR
  | XOR
  | AND
  | NOT

  | INT
  | ABS
  | NEG
  | MUL

  | LEFT of datatype
  | RIGHT of datatype

  | EDIV
  | LSL
  | LSR

  | SOURCE of datatype * datatype

  | SIZE
  | DEFAULT_ACCOUNT

  (* obsolete *)
  | MOD
  | DIV

type type_kind =
  | Type_record of datatype list * int StringMap.t
  | Type_variant of
      (string
       * datatype (* final type *)
       * datatype (* left type *)
       * datatype (* right type *)
      ) list

type closure_env = {
  env_vars :  (string (* name outside closure *)
               * datatype
               * int (* index *)
               * (int ref * (* usage counter inside closure *)
                  int ref (* usage counter outside closure *)
                 )) StringMap.t;
  env_bindings : (typed_exp (* expression to access variable inside closure *)
                  * (int ref * (* usage counter inside closure *)
                     int ref (* usage counter outside closure *)
                    )) StringMap.t;
  call_bindings : (string * typed_exp) list;
}

type env = {
    (* name of file being compiled *)
    filename : string;

    (* fields modified in LiquidFromOCaml *)
    (* type definitions *)
    mutable types : (datatype * type_kind) StringMap.t;
    (* labels of records in type definitions *)
    mutable labels : (string * int * datatype) StringMap.t;
    (* constructors of sum-types in type definitions *)
    mutable constrs : (string * datatype) StringMap.t;
  }

(* fields updated in LiquidCheck *)
type 'a typecheck_env = {
    warnings : bool;
    counter : int ref;
    vars : (string * datatype * int ref) StringMap.t;
    env : env;
    to_inline : datatype exp StringMap.t ref;
    contract : 'a contract;
    clos_env : closure_env option;
}

(* decompilation *)

type node = {
    num : int;
    mutable kind : node_kind;
    mutable args : node list; (* dependencies *)

    mutable next : node option;
    mutable prevs : node list;
  }

 and node_kind =
   | N_UNKNOWN of string
   | N_VAR of string
   | N_START
   | N_IF of node * node
   | N_IF_RESULT of node * int
   | N_IF_THEN of node
   | N_IF_ELSE of node
   | N_IF_END of node * node
   | N_IF_END_RESULT of node * node option * int
   | N_IF_NONE of node
   | N_IF_SOME of node * node
   | N_IF_NIL of node
   | N_IF_CONS of node * node * node
   | N_IF_LEFT of node * node
   | N_IF_RIGHT of node * node
   | N_TRANSFER of node * node
   | N_TRANSFER_RESULT of int
   | N_CONST of datatype * const
   | N_PRIM of string
   | N_FAIL
   | N_LOOP of node * node
   | N_LOOP_BEGIN of node
   | N_LOOP_ARG of node * int
   | N_LOOP_RESULT of (* N_LOOP *) node
                                   * (* N_LOOP_BEGIN *) node * int
   | N_LOOP_END of (* N_LOOP *) node
                                * (* N_LOOP_BEGIN *) node
                                * (* final_cond *) node
   | N_LAMBDA of node * node * datatype * datatype
   | N_LAMBDA_BEGIN
   | N_LAMBDA_END of node
   | N_END
   | N_LEFT of datatype
   | N_RIGHT of datatype
   | N_SOURCE of datatype * datatype

type node_exp = node * node

type warning =
  | Unused of string
