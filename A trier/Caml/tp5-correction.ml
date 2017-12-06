(* constantes *)
let grid_sample = 
  [[5; 3; 0; 6; 0; 0; 0; 9; 8];
   [0; 7; 0; 1; 9; 5; 0; 0; 0];
   [0; 0; 0; 0; 0; 0; 0; 6; 0];
   [8; 0; 0; 4; 0; 0; 7; 0; 0];
   [0; 6; 0; 8; 0; 3; 0; 2; 0];
   [0; 0; 3; 0; 0; 1; 0; 0; 6];
   [0; 6; 0; 0; 0; 0; 0; 0; 0];
   [0; 0; 0; 4; 1; 9; 0; 8; 0];
   [2; 8; 0; 0; 0; 5; 0; 7; 9]];;

(* prof only *)
let l1 = [1;2;3;4;5;6;7;8;9]
and l2 = [1;3;5;0;4;6;0;0;2]
and l3 = [0;1;3;4;0;0;0;1;9];;
let values = [1; 2; 3; 4; 5; 6; 7; 8; 9];;
let null = 0;;

(***************************************)
(*************** Level 0 ***************)

(* longueur d'une liste en terminale *)
let length l = 
  let rec len r = function
    | [] -> r
    | e::l -> len (r+1) l
  in len 0 l;;

(* applatie une liste de liste en liste *)
let rec flatten = function 
  | [] -> []
  | e::l -> e @ (flatten l);;

(* verifie la presence d'un element x dans une liste par la fonction de comparaison *)
let rec check f x = function
  | [] -> false 
  | e::l when f e x -> true
  | _::l -> check f x l;;

(* retire un element dans une liste par la fonction de comparaison  *)
let rec remove f x = function
  | [] -> []
  | e::l when f e x -> l
  | e::l -> e::(remove f x l);;

(* retourne une liste des elements uniques de l1 en utilisant la fonction de comparaison *)
let list_uniq f l1 = 
  let rec l_exist x = function
    | [] -> false
    | e::l when f e x -> true
    | _::l -> l_exist x l
  and l_match = function
    | [] -> []
    | e::l when not (l_exist e l) -> e::(l_match l)
    | _::l -> l_match l
  in l_match l1;;

list_uniq (=) [1;2;3;5;6;8;0;0;0;2;0;3;0;5;6;0;1;4];;  
  
(* retourne la liste des elements uniques de l1 et l2 (testes via la fonction de comparaison *)
let list_match f l1 l2 = 
  list_uniq f (flatten (l1::[l2]));;

list_match (=) [1;2;3;5;6;8;0;0;0] [2;0;3;0;5;6;0;1;4];;
  

(***************************************)
(*************** Level 1 ***************)
  
(* genere y listes de x listes de valeurs null *)
let grid_make_rectangle x y null = 
  let rec row null = function
    | 0 -> []
    | n -> null :: row null (n-1)
  in
  row (row null x) y;;

(* genere x listes de x listes de valeurs null *) 
let grid_make_square x null = 
  grid_make_rectangle x x null;;

(* genere une grille de jeu de la taille correspondante pour stocker nos elements *)
let grid_make elements null = 
  let s = length elements in
  grid_make_square s null;;

(***************************************)
(*************** Level 2 ***************)  
 
(* tools *)
(* racine carree entiere du nombre d'elements - sans verification - besoin d'un carre parfait *)
let dimensions elements = int_of_float (sqrt (float_of_int (length elements)));;
let sqrt_int x = int_of_float (sqrt (float_of_int x));;


(* extrait la r ieme ligne de notre matrice *)
let extract_row grid r elements =
  let s = length elements in
  if s <= r then failwith "out of range"
  else
    let rec row = function
      | ([],_) -> []
      | (e::l,0) -> e
      | (e::l, n) -> row (l,n-1)
    in row (grid,r);;

(* extrait la ieme colonne de notre matrice *)
let extract_column grid c elements = 
  let s = length elements in
  if s <= c then failwith "out of range"
  else
    let rec row = function
      | ([],_) -> failwith "impossibru"
      | (e::_,0) -> e
      | (_::l,n) -> row (l,n-1)
    and col = function
      | [] -> []
      | e::l -> (row (e,c))::(col l)
    in col grid;;

(*
 ** extrait une sous-matrice de notre matrice principale
 ** sous-matrices numerote de gauche a droite du haut vers le bas
 ** applatie en une liste de valeurs
 *)
let extract_square grid c elements =
  let s = length elements in
  let d = sqrt_int s in
  if s <= c then failwith "out of range"
  else
    let rec row = function
      | ([],_,_) | (_,0,0) -> []
      | (e::l, 0, n) -> e::(row (l,0,n-1))
      | (_::l, x, n) -> row (l,x-1,n)
    and col = function
      | ([],_,_) | (_,0,0) -> []
      | (e::l, 0, n) -> (row (e,(c mod d)*d,d)) :: (col (l,0,n-1))
      | (_::l,x,n) -> col (l,x-1,n)
    in flatten (col (grid, (c / d) * d, d));;

(* affichage de la grille *)
let grid_print p grid = 
    List.iter (function x -> 
      List.iter (function e -> p e; print_string " ") x; print_newline()) grid;;

(***************************************)
(*************** Level 3 ***************)  
	  
(* 
 ** permet de verifier que les elements sont dans une liste d'element autorises
 ** une seule et unique occurence est autorisee
 *)
let list_validate f elements null liste =
  let rec validate elts = function
    | [] -> true
    | e::l when f null e -> validate elts l
    | e::l when not (check f e elts) -> false
    | e::l -> validate (remove f e elts) l
  in validate elements liste;;

(* valide qu'une grille vérifie la regle  d'unicite du sudoku *)
let grid_validate f grid elements null =
  let rec validate = function
    | 0 -> true
    | n -> 
	list_validate f elements null (extract_row grid n values) &&
	list_validate f elements null (extract_column grid n values) &&
	list_validate f elements null (extract_square grid n values) &&
	validate (n-1)
  in validate (length elements);;

(* verife qu'une grille ne contient plus de case libre *)
let grid_isfull f grid null =
  let l = flatten grid in
  let rec isfull = function
    | [] -> true
    | e::_ when f null e -> false
    | _::l -> isfull l
  in isfull l;;

(***************************************)
(*************** Level 4 ***************)  

(* retourne la liste des elements de l2 non present dans l1 *)
let find_missing f l1 l2 =
  let rec l_exist x = function
    | [] -> false 
    | e::l -> f e x || l_exist x l
  and missing = function
    | [] -> []
    | e::l when not (l_exist e l2) -> e::(missing l)
    | _::l -> missing l
  in missing l1;;

(* retourne la liste des possibilites de valeurs pour une case *) 
let grid_find f grid x y elements =
  let s = length elements in
  let d = sqrt_int s in 
  let c = x/d + (y/d)*d in
  let row = extract_row grid y elements and
      col = extract_column grid x elements and
      mat = extract_square grid c elements
  in
  find_missing f elements (list_match f (list_match f row col) mat);;

(* solution rang n+1 *)
let grid_nsolve f grid null elements =
  let rec row = function
    | ([], _) -> []
    | (e::l, y) -> (col (e,y,0))::(row (l,y+1))
  and col = function
    | ([], _, _) -> []
    | (e::l, y, x) -> (solve x y e)::(col (l,y,x+1))
  and solve x y e =
    if not (f null e) then e else
    match (grid_find f grid x y elements) with
    | [] -> e
    | e::[] -> e
    |  _::l -> e
  in row (grid, 0);;

(***************************************)
(*************** Level 5 ***************) 
  
(* solution d'une grille *)
let solve grid f elements null =
  let rec check = function
    | g when grid_isfull f g null -> g
    | g -> check (grid_nsolve f g null elements)
  in check grid;;
