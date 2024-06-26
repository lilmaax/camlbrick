#load "CPtest.cmo";;
#load "camlbrick.cmo";;

open CPtest;;
open Camlbrick;;

let canvas_height : int = 20;;
let canvas_width : int = 31;;

let game : t_camlbrick = {
  param = make_camlbrick_param ();
  matrix = Array.make_matrix canvas_height canvas_width BK_empty;
  paddle =  {
    size = ref PS_MEDIUM;
    position = (ref 0, 0)
  };
  balls = [{
    position = ref (make_vec2 (0, 0));
    speed = ref (make_vec2 (0, 0));
    size = BS_MEDIUM
  }];
  speed = ref 0
};;

(**
  Test fonctionnel de la spécification de `make_vec2`.

  Construit un vecteur à partir de deux entiers.

  @author Matéo Abrane
*)
let test_fonc_make_vec2 () : unit =
  let res : t_vec2 t_test_result = test_exec (
    make_vec2,
    "Fonctionnel -> make_vec2",
    (1, 2)
  )
  in

  assert_equals ({ x = 1 ; y = 2 }, test_get res)
;;

(**
  Test fonctionnel de la spécification de `vec2_add`.

  Calcul de la somme de deux vecteurs.

  @author Matéo Abrane
*)
let test_fonc_vec2_add () : unit =
  let res : t_vec2 t_test_result = test_exec (
    vec2_add,
    "Fonctionnel -> vec2_add",
    ({ x = 1 ; y = 1 }, { x = 2 ; y = 2 })
  )
  in

  assert_equals ({ x = 3 ; y = 3 }, test_get res)
;;

(**
  Test fonctionnel de la spécification de `vec2_mult`.

  @author Matéo Abrane
*)
let test_fonc_vec2_mult () : unit =
  let res : t_vec2 t_test_result = test_exec (
    vec2_mult,
    "Fonctionnel -> vec2_mult",
    ({ x = 1 ; y = 1 }, { x = 2 ; y = 2 })
  )
  in

  assert_equals ({ x = 2 ; y = 2 }, test_get res)
;;

(**
  Test structurel de `param_get`.

  @author Max Charrier
*)
let test_struct_param_get () : unit =
  let res : t_camlbrick_param t_test_result = test_exec (
    param_get,
    "Structurel -> param_get",
    game
  )
  in

  assert_true (test_has_value res);
;;

(**
  Test fonctionnel de la spécification de `brick_get`.

  Renvoie le type de brique à partir des coordonées dans la zone de briques.

  @author Max Charrier
*)
let test_fonc_brick_get () : unit =
  let res : t_brick_kind t_test_result = test_exec (
    brick_get,
    "Fonctionnel -> brick_get",
    (game, 13, 9)
  )
  in

  assert_equals (BK_empty, test_get res) (* Aucune brique par défaut sur toutes les cases *)
;;

(**
  Test structurel de `brick_hit`.

  Retrace grâce au coordonnées de i et j le type dans la matrice de brique et
  change son type en fonction de son type précedemment.

  @author Max Charrier
*)
let test_struct_brick_hit () : unit =
  let res : t_brick_kind t_test_result = test_exec (
    brick_hit,
    "Structurel -> brick_hit",
    (game, 0, 0)
  )
  in

  assert_true (test_has_value res)
;;

(**
  Test fonctionnel de la spécification de `brick_hit` avec des briques simple.

  Retrace grâce au coordonnées de i et j le type dans la matrice de brique et
  change son type en fonction de son type précedemment.

  @author Max Charrier
*)
let test_fonc_brick_hit_simple () : unit =
  (* On génère que des briques simple *)
  let game_brick_simple : t_camlbrick = {
    param = make_camlbrick_param ();
    matrix = Array.make_matrix canvas_height canvas_width BK_simple;
    paddle =  {
      size = ref PS_MEDIUM;
      position = (ref 0, 0)
    };
    balls = [{
      position = ref (make_vec2 (0, 0));
      speed = ref (make_vec2 (0, 0));
      size = BS_MEDIUM
    }];
    speed = ref 0
  }
  in

  let res : t_brick_kind t_test_result = test_exec (
    brick_hit,
    "Fonctionnel -> brick_hit_simple",
    (game_brick_simple, 0, 0)
  )
  in

  assert_equals (BK_empty, test_get res)
;;

(**
  Test fonctionnel de la spécification de `brick_hit` avec des briques double.

  Retrace grâce au coordonnées de i et j le type dans la matrice de brique et
  change son type en fonction de son type précedemment.

  @author Max Charrier
*)
let test_fonc_brick_hit_double () : unit =
  (* On génère que des briques double *)
  let game_brick_double : t_camlbrick = {
    param = make_camlbrick_param ();
    matrix = Array.make_matrix canvas_height canvas_width BK_double;
    paddle =  {
      size = ref PS_MEDIUM;
      position = (ref 0, 0)
    };
    balls = [{
      position = ref (make_vec2 (0, 0));
      speed = ref (make_vec2 (0, 0));
      size = BS_MEDIUM
    }];
    speed = ref 0
  }
  in

  let res : t_brick_kind t_test_result = test_exec (
    brick_hit,
    "Fonctionnel -> brick_hit_double",
    (game_brick_double, 0, 0)
  )
  in

  assert_equals (BK_simple, test_get res)
;;

(**
  Test fonctionnel de la spécification de `brick_hit` avec des briques bonus.

  Retrace grâce au coordonnées de i et j le type dans la matrice de brique et
  change son type en fonction de son type précedemment.

  @author Max Charrier
*)
let test_fonc_brick_hit_bonus () : unit =
  (* On génère que des briques bonus *)
  let game_brick_bonus : t_camlbrick = {
    param = make_camlbrick_param ();
    matrix = Array.make_matrix canvas_height canvas_width BK_bonus;
    paddle =  {
      size = ref PS_MEDIUM;
      position = (ref 0, 0)
    };
    balls = [{
      position = ref (make_vec2 (0, 0));
      speed = ref (make_vec2 (0, 0));
      size = BS_MEDIUM
    }];
    speed = ref 0
  }
  in

  let res : t_brick_kind t_test_result = test_exec (
    brick_hit,
    "Fonctionnel -> brick_hit_bonus",
    (game_brick_bonus, 0, 0)
  )
  in

  assert_equals (BK_empty, test_get res)
;;

(**
  Test fonctionnel de la spécification de `brick_hit` avec des briques block.

  Retrace grâce au coordonnées de i et j le type dans la matrice de brique et
  change son type en fonction de son type précedemment.

  @author Max Charrier
*)
let test_fonc_brick_hit_block () : unit =
  (* On génère que des briques block *)
  let game_brick_block : t_camlbrick = {
    param = make_camlbrick_param ();
    matrix = Array.make_matrix canvas_height canvas_width BK_block;
    paddle =  {
      size = ref PS_MEDIUM;
      position = (ref 0, 0)
    };
    balls = [{
      position = ref (make_vec2 (0, 0));
      speed = ref (make_vec2 (0, 0));
      size = BS_MEDIUM
    }];
    speed = ref 0
  }
  in

  let res : t_brick_kind t_test_result = test_exec (
    brick_hit,
    "Fonctionnel -> brick_hit_block",
    (game_brick_block, 0, 0)
  )
  in

  assert_equals (BK_block, test_get res)
;;

(**
  Test fonctionnel de la spécification de `brick_color` avec une brique vide.

  Renvoie une couleur en focnction du type de brique.

  @author Max Charrier
*)
let test_fonc_brick_color_empty () : unit =
  (* On génère que des briques vide *)
  let game_brick_empty : t_camlbrick = {
    param = make_camlbrick_param ();
    matrix = Array.make_matrix canvas_height canvas_width BK_empty;
    paddle =  {
      size = ref PS_MEDIUM;
      position = (ref 0, 0)
    };
    balls = [{
      position = ref (make_vec2 (0, 0));
      speed = ref (make_vec2 (0, 0));
      size = BS_MEDIUM
    }];
    speed = ref 0
  }
  in

  let res : t_camlbrick_color t_test_result = test_exec (
    brick_color,
    "Fonctionnel -> brick_color_empty",
    (game_brick_empty, 0, 0)
  )
  in

  assert_equals (BLACK, test_get res)
;;

(**
  Test fonctionnel de la spécification de `brick_color` avec une brique simple.

  Renvoie une couleur en fonction du type de brique.

  @author Max Charrier
*)
let test_fonc_brick_color_simple () : unit =
  (* On génère que des briques simple *)
  let game_brick_simple : t_camlbrick = {
    param = make_camlbrick_param ();
    matrix = Array.make_matrix canvas_height canvas_width BK_simple;
    paddle =  {
      size = ref PS_MEDIUM;
      position = (ref 0, 0)
    };
    balls = [{
      position = ref (make_vec2 (0, 0));
      speed = ref (make_vec2 (0, 0));
      size = BS_MEDIUM
    }];
    speed = ref 0
  }
  in

  let res : t_camlbrick_color t_test_result = test_exec (
    brick_color,
    "Fonctionnel -> brick_color_simple",
    (game_brick_simple, 0, 0)
  )
  in

  assert_equals (GREEN, test_get res)
;;

(**
  Test fonctionnel de la spécification de `brick_color` avec une brique double.

  Renvoie une couleur en focnction du type de brique.

  @author Max Charrier
*)
let test_fonc_brick_color_double () : unit =
  (* On génère que des briques double *)
  let game_brick_double : t_camlbrick = {
    param = make_camlbrick_param ();
    matrix = Array.make_matrix canvas_height canvas_width BK_double;
    paddle =  {
      size = ref PS_MEDIUM;
      position = (ref 0, 0)
    };
    balls = [{
      position = ref (make_vec2 (0, 0));
      speed = ref (make_vec2 (0, 0));
      size = BS_MEDIUM
    }];
    speed = ref 0
  }
  in

  let res : t_camlbrick_color t_test_result = test_exec (
    brick_color,
    "Fonctionnel -> brick_color_double",
    (game_brick_double, 0, 0)
  )
  in

  assert_equals (RED, test_get res)
;;

(**
  Test fonctionnel de la spécification de `brick_color` avec une brique bonus.

  Renvoie une couleur en focnction du type de brique.

  @author Max Charrier
*)
let test_fonc_brick_color_bonus () : unit =
  (* On génère que des briques bonus *)
  let game_brick_bonus : t_camlbrick = {
    param = make_camlbrick_param ();
    matrix = Array.make_matrix canvas_height canvas_width BK_bonus;
    paddle =  {
      size = ref PS_MEDIUM;
      position = (ref 0, 0)
    };
    balls = [{
      position = ref (make_vec2 (0, 0));
      speed = ref (make_vec2 (0, 0));
      size = BS_MEDIUM
    }];
    speed = ref 0
  }
  in

  let res : t_camlbrick_color t_test_result = test_exec (
    brick_color,
    "Fonctionnel -> brick_color_bonus",
    (game_brick_bonus, 0, 0)
  )
  in

  assert_equals (BLUE, test_get res)
;;

(**
  Test fonctionnel de la spécification de `brick_color` avec une brique block.

  Renvoie une couleur en focnction du type de brique.

  @author Max Charrier
*)
let test_fonc_brick_color_block () : unit =
  (* On génère que des briques block *)
  let game_brick_block : t_camlbrick = {
    param = make_camlbrick_param ();
    matrix = Array.make_matrix canvas_height canvas_width BK_block;
    paddle =  {
      size = ref PS_MEDIUM;
      position = (ref 0, 0)
    };
    balls = [{
      position = ref (make_vec2 (0, 0));
      speed = ref (make_vec2 (0, 0));
      size = BS_MEDIUM
    }];
    speed = ref 0
  }
  in

  let res : t_camlbrick_color t_test_result = test_exec (
    brick_color,
    "Fonctionnel -> brick_color_block",
    (game_brick_block, 0, 0)
  )
  in

  assert_equals (ORANGE, test_get res)
;;

test_reset_report ();;

test_fonc_make_vec2 ();;
test_fonc_vec2_add ();;
test_fonc_vec2_mult ();;
test_struct_param_get ();;
test_fonc_brick_get ();;
test_struct_brick_hit ();;
test_fonc_brick_hit_simple ();;
test_fonc_brick_hit_double ();;
test_fonc_brick_hit_bonus ();;
test_fonc_brick_hit_block ();;
test_fonc_brick_color_empty ();;
test_fonc_brick_color_simple ();;
test_fonc_brick_color_double ();;
test_fonc_brick_color_bonus ();;
test_fonc_brick_color_block ();;

test_report ();;
