
(************************************************************)
(*                     Game of life                         *)
(************************************************************)

#load "graphics.cma";;
open Graphics;;


(* original game of life definitions *)

let cell_color = function
  | 0 -> white
  | _ -> black ;;

let new_cell = 1 ;;

let empty = 0 ;;

let size_cell = 10 ;;

let is_alive cell = cell <> empty ;;

let rules cell near = 
  if (cell = empty) && (near = 3) then 
    new_cell
  else 
    if (near = 3) || (near = 2) then 
      cell
    else 
      empty ;;


(************************************************************)
(*                     Preliminaries                        *)
(************************************************************)

(************   list *************)

(* generate a square size matrix filled with x *)    

let gen_board size x =
  let rec gen_row value = function
    | 0 -> []
    | n -> value :: gen_row value (n-1)
  in gen_row (gen_row x size) size;;


(*** extract value from an  'a list list, position (x,y) ***)
(* failwith replaced by empty if "out of bounds" *)

let get_cell (x,y) board =
  let rec extract_row = function
    | (_, []) -> empty
    | (1, e::_) -> extract_cell (y,e)
    | (n, _::l) -> extract_row ((n-1), l)
  and extract_cell = function 
    | (_, []) -> empty
    | (1, e::l) -> e
    | (n, _::l) -> extract_cell ((n-1), l)
  in extract_row (x, board);;

(* replace value at (x,y) in board by cell *)

let put_cell cell (x,y) board =
  let rec process_row = function
    | (_, []) -> []
    | (1, e::l) -> (process_column (y,e)) :: l
    | (n, e::l) -> e :: (process_row ((n-1), l))
  and process_column = function
    | (_, []) -> []
    | (1, e::l) -> cell :: l
    | (n, e::l) -> e :: (process_column ((n-1), l))
  in process_row (x, board);;

(*** extract number of values around cell at (x,y) from an 'a list list ***)
(* uses get_cell *)

let count_neighbours (x,y) board = 
  let add (x,y) = 
    if is_alive (get_cell (x,y) board) then
      1
    else
      0
  in
      add (x-1,y-1) + add (x-1,y) + add (x-1,y+1)
    + add (x,y-1) + add (x,y+1)
    + add (x+1,y-1) + add (x+1,y) + add (x+1,y+1) ;;

 
(************************************************************)
(*                  graphics                                *)
(************************************************************)

let open_window size = open_graph(string_of_int size ^ "x" ^ string_of_int (size+20));;

let grey = rgb 127 127 127 ;;

(* draw a grey square with left corner at (x,y) with given size filled with color *)

let draw_fill_square (x,y) size color = 
  set_color color; fill_rect x y size size;
  set_color grey; draw_rect x y size size;;

let draw_cell (x,y) size c =  
  draw_fill_square (x * size, y * size) size c ;;

(* draw a board ('a list list) *)
(* j'ai changé le point de départ (1,1) pour pas que ça colle au cadre ! *)

let draw_board board size =
  let rec iter_row x = function
    | [] -> ()
    | e::l -> iter_column x 1 e; iter_row (x+1) l
  and iter_column x y = function
    | [] -> ()
    | e::l -> draw_cell(x,y) size (cell_color e); iter_column x (y+1) l
  in 
  clear_graph () ;      
  iter_row 1 board       
;;

(************************************************************)
(*                   The game                               *)
(************************************************************)

(* place count new cells randomly in board (size is the board size!) *)

let seed_life board size count = 
  let rec plant board = function
    | 0 -> board
    | n -> plant (put_cell new_cell (1 + Random.int size, 1+ Random.int size) board) (n-1)
  in plant board count ;;


let new_board size n = seed_life (gen_board size empty) size n ;;

let next_generation board = 
  let rec map_row x = function
    | [] -> []
    | e::l -> map_column x 1 e :: map_row (x+1) l
  and map_column x y = function
    | [] -> []
    | e::l -> rules e (count_neighbours (x,y) board) :: map_column x (y+1) l
  in 
  map_row 1 board ;;

let rec game board = function
  | 0 -> ()
  | n -> draw_board board size_cell ; game (next_generation board) (n-1) ;;


let new_game size nb = 
  open_window (size*size_cell + 40) ;
  game (new_board size (size*size_cell)) nb ;;

new_game 50 200 ;;
