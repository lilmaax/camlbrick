(**
  Ce module CamlBrick représente le noyau fonctionnel du jeu de casse-brique.

  Le noyau fonctionnel consiste à réaliser l'ensemble des structures et autres fonctions capables d'être utilisées par une interface graphique.
  Par conséquent, dans ce module il n'y a aucun aspect visuel.
  Vous pouvez cependant utiliser le mode console.

  Le principe du jeu de casse-brique consiste à faire disparaître toutes les briques d'un niveau en utilisant les rebonds d'une balle depuis une raquette contrôlée par l'utilisateur.

  @author Max Charrier
  @author Paul Ourliac
  @author Matéo Abrane
  @author Axel De Les Champs--Vieira

  @version 1
*)


(**
  Compteur utilisé en interne pour afficher le numéro de la frame du jeu vidéo.
  A utiliser uniquement en lecture.

  NE PAS MODIFIER SA VALEUR !

  @deprecated Ne pas modifier cette valuer !
*)
let frames = ref 0;;

(**
  Attributs globaux pour paramétrer le casse-brique

  <b>Attention:</b> Il doit y avoir des cohérences entre les différents paramètres:
  <ul>
  <li>la hauteur totale de la fenêtre est égale à la somme des hauteurs de la zone de briques du monde et de la hauteur de la zone libre.</li>
  <li>la hauteur de la zone des briques du monde est un multiple de la hauteur d'une seule brique.</li>
  <li>la largeur du monde est un multiple de la largeur d'une seule brique.</li>
  <li>initialement la largeur de la raquette doit correspondre à la taille moyenne.</li>
  <li>la hauteur initiale de la raquette doit être raisonnable et ne pas toucher un bord de la fenêtre.</li>
  <li>La variable <u>time_speed</u> doit être strictement positive, elle représente l'écoulement du temps.</li>
  </ul>
*)
type t_camlbrick_param = {
  world_width : int;          (** largeur de la zone de dessin des briques *)
  world_bricks_height : int;  (** hauteur de la zone de dessin des briques *)
  world_empty_height : int;   (** hauteur de la zone vide pour que la bille puisse évoluer un petit peu *)

  brick_width : int;          (** largeur d'une brique *)
  brick_height : int;         (** hauteur d'une brique *)

  paddle_init_width : int;    (** largeur initiale de la raquette *)
  paddle_init_height : int;   (** hauteur initiale de la raquette *)

  time_speed : int ref;       (** indique l'écoulement du temps en millisecondes (c'est une durée approximative) *)
};;

(**
  Représentation des différents états du jeu.

  Les trois états de base sont :
  <ul>
  <li>[GAMEOVER]: qui indique si une partie est finie typiquement lors du lancement du jeu</li>
  <li>[PLAYING]: qui indique qu'une partie est en cours d'exécution</li>
  <li>[PAUSING]: indique qu'une partie en cours d'exécution est actuellement en pause</li>
  </ul>

  Dans le cadre des extensions, possibilité de modifier ce type pour adopter d'autres états du jeu selon le besoin.
*)
type t_gamestate = GAMEOVER | PLAYING | PAUSING;;

(**
  Représentation des différentes couleurs prise en charge par notre moteur de jeu.

  NE PAS MODIFIER CE TYPE !

  @deprecated Ne pas modifier ce type !
*)
type t_camlbrick_color = WHITE | BLACK | GRAY | LIGHTGRAY | DARKGRAY | BLUE | RED | GREEN | YELLOW | CYAN | MAGENTA | ORANGE | LIME | PURPLE;;

(**
  Représentation des différents types de briques.

  NE PAS MODIFIER CE TYPE !

  @deprecated Ne pas modifier ce type !
*)
type t_brick_kind = BK_empty | BK_simple | BK_double | BK_block | BK_bonus;;

(**
  Retourne le type de brique pour représenter les briques de vide.
  C'est à dire, l'information qui encode l'absence de brique à un emplacement sur la grille du monde.

  @return Renvoie le type correspondant à la notion de vide.
  @deprecated Cette fonction est utilisé en interne.
*)
let make_empty_brick () : t_brick_kind =
  BK_empty
;;

(**
  Représeantion des différentes tailles des billes.
  La taille par défaut d'une bille est [BS_MEDIUM].

  Possibilité d'ajouter d'autres valeurs sans modifier les valeurs existantes.
*)
type t_ball_size = BS_SMALL | BS_MEDIUM | BS_BIG;;

(**
  Représenation des différentes taille de la raquette.
  La taille par défaut d'une raquette est [PS_SMALL].

  Possibilité d'ajouter d'autres valeurs sans modifier les valeurs existantes.
*)
type t_paddle_size = PS_SMALL | PS_MEDIUM | PS_BIG;;

(**
  Définition des composantes d'un vecteur.
*)
type t_vec2 = {
  x : int;
  y : int
};;

(**
  Création un vecteur 2D à partir de deux entiers.
  Les entiers représentent la composante en X et en Y du vecteur.

  @author Paul Ourliac
  @param x première composante du vecteur
  @param y seconde composante du vecteur
  @return vecteur dont les composantes sont (x,y).
*)
let make_vec2 (x, y : int * int) : t_vec2 =
  {
    x = x;
    y = y
  }
;;

(**
  Somme des composantes de deux vecteurs.

  @author Paul Ourliac
  @param a premier vecteur
  @param b second vecteur
  @return vecteur égale à la somme des vecteurs.
*)
let vec2_add (a, b : t_vec2 * t_vec2) : t_vec2 =
  {
    x = a.x + b.x;
    y = a.y + b.y
  }
;;

(**
  Somme des composantes d'un vecteur et d'un vecteur construit à partir de (x,y).

  Il s'agit d'une optimisation du code suivant :
  {[
    let vec2_add_scalar (a, x, y : t_vec2 * int * int) : t_vec2 =
      vec2_add (a, make_vec2 (x, y))
    ;;
  ]}

  @author Paul Ourliac
  @param a premier vecteur
  @param x composante en x du second vecteur
  @param y composante en y du second vecteur
  @return vecteur égale à la somme du vecteur et du vecteur construit.
*)
let vec2_add_scalar (a, x, y : t_vec2 * int * int) : t_vec2 =
  {
    x = a.x + x;
    y = a.y + y
  }
;;

(**
  Multiplication des composantes de deux vecteurs.

  @author Max Charrier
  @param a premier vecteur
  @param b second vecteur
  @return vecteur égale à la multiplication des vecteurs.
*)
let vec2_mult (a, b : t_vec2 * t_vec2) : t_vec2 =
  {
    x = a.x * b.x;
    y = a.y * b.y
  }
;;

(**
  Multiplication des composantes d'un vecteur et d'un vecteur construit à partir de (x,y).

  Il s'agit d'une optimisation du code suivant :
  {[
    let vec2_mult_scalar (a, x, y : t_vec2 * int * int) : t_vec2 =
      vec2_mult (a, make_vec2 (x, y))
    ;;
  ]}

  @author Max Charrier
  @param a premier vecteur
  @param x composante en x du second vecteur
  @param y composante en y du second vecteur
  @return vecteur égale à la multiplication du vecteur et du vecteur construit.
*)
let vec2_mult_scalar (a, x, y : t_vec2 * int * int) : t_vec2 =
  {
    x = a.x * x;
    y = a.y * y
  }
;;

(**
  Définition de la balle par sa position, son vecteur vitesse et sa taille.

  D'un point de vue de l'affichage, une balle se représente par un cercle.
*)
type t_ball  =
  {
    position : t_vec2 ref;
    speed : t_vec2 ref;
    size : t_ball_size
  }
;;

(**
  Définition de la raquette par sa taille et sa position en mouvement sur l'axe X.
*)
type t_paddle =
  {
    position : (int ref) * int;
    size : t_paddle_size ref
  }
;;

(**
  Représentation du jeu de manière fonctionnel, avec tout les composants affichés à l'écran.
*)
type t_camlbrick =
  {
    param: t_camlbrick_param;
    matrix : t_brick_kind array array;
    paddle : t_paddle;
    balls : t_ball list;
    speed : int ref
  }
;;

(**
  Paramètres du casse-brique via des informations personnalisables selon les contraintes du sujet.

  Aucune vérification n'est réalisé, s'assurer que les valeurs données en argument soient cohérentes.

  @return paramétrage de jeu par défaut.
*)
let make_camlbrick_param () : t_camlbrick_param = {
    world_width = 800;
    world_bricks_height = 600;
    world_empty_height = 200;

    brick_width = 40;
    brick_height = 20;

    paddle_init_width = 100;
    paddle_init_height = 20;

    time_speed = ref 20;
};;

(**
  Extraction des paramètres du casse-brique à partir de la partie du jeu.

  @param game partie en cours d'exécution
  @return paramétrage actuel.
*)
let param_get (game : t_camlbrick) : t_camlbrick_param =
  make_camlbrick_param ()
;;

(**
  Création d'une nouvelle structure qui initialise le monde avec aucune brique visible, une raquette et une balle par défaut dans la zone libre.

  @author Max Charrier
  @author Paul Ourliac
  @return partie correctement initialisé.
*)
let make_camlbrick () : t_camlbrick =
  {
    param = make_camlbrick_param ();
    matrix = Array.make_matrix 20 30 BK_empty;
    paddle =  {
      size = ref PS_MEDIUM;
      position = (ref 0, 0)
    };
    balls = [{
      position = ref (make_vec2 (400, 750));
      speed = ref (make_vec2 (-1, -3));
      size = BS_MEDIUM
    }];
    speed = ref 5
  }
;;

(**
  Création d'une raquette par défaut au milieu de l'écran et de taille normal.

  @author Paul Ourliac
  @deprecated Cette fonction est là juste pour le debug ou pour débuter certains traitements de test.
*)
let make_paddle () : t_paddle =
  {
    size = ref PS_MEDIUM;
    position = (ref 0, 0)
  }
;;

(**
  Création d'un balle par défaut.

  @author Max Charrier
  @param x position en abscisse
  @param y position en ordonnée
  @param size taille de la balle
  @return balle initialisée.
*)
let make_ball (x, y, size : int * int * int) : t_ball =
  if size = 5 then
    {
      position = ref (make_vec2 (x, y));
      speed = ref (make_vec2 (0, 0));
      size = BS_SMALL
    }
  else if size = 10 then
    {
      position = ref (make_vec2 (x, y));
      speed = ref (make_vec2 (0, 0));
      size = BS_MEDIUM
    }
  else
    {
      position = ref (make_vec2 (x, y));
      speed = ref (make_vec2 (0, 0));
      size = BS_BIG
    }
;;

(**
  Traduction de l'état du jeu sous la forme d'une chaîne de caractère.
  Cette fonction est appelée à chaque frame, et est affichée directement dans l'interface graphique.

  TODO : modifier cette fonction.

  @author Max Charrier
  @param game la partie en cours d'exécution.
  @return chaîne de caractère représentant l'état de la partie.
*)
let string_of_gamestate (game : t_camlbrick) : string =
  (* Itération 1,2,3 et 4 *)
  "INCONNU"
;;

(**
  Renvoie le type de la brique en fonction des coordonnées.

  @author Paul Ourliac
  @param game partie en cours d'exécution
  @param i partie horizontal de la matrice de brique
  @param j partie vertical de la matrice de brique
  @return type d'une brique.
*)
let brick_get (game, i, j : t_camlbrick * int * int) : t_brick_kind =
  game.matrix.(i).(j)
;;

(**
  Retrace grâce au coordonnées de i et j le type dans la matrice de brique et
  change son type en fonction de son type précedemment.

  @author Axel De Les Champs--Vieira
  @author Max Charrier
  @param game partie en cours d'exécution
  @param i partie horizontal de la matrice de brique
  @param j partie vertical de la matrice de brique
  @return type de brique
*)
let brick_hit (game, i, j : t_camlbrick * int * int) : t_brick_kind =
  let brick : t_brick_kind = brick_get (game, i, j) in

  if brick = BK_simple then
    BK_empty
  else if brick = BK_double then
    BK_simple
  else if brick = BK_bonus then
    BK_empty
  else if brick = BK_block then
    BK_block
  else
    BK_empty
;;

(**
  Renvoie la couleur de la brique en fonction des coordonnées.

  @author Paul Ourliac
  @param game partie en cours d'exécution
  @param i partie horizontal de la matrice de brique
  @param j partie vertical de la matrice de brique
  @return couleur d'une brique.
*)
let brick_color (game, i, j : t_camlbrick * int * int) : t_camlbrick_color =
  let brick : t_brick_kind = brick_get (game, i, j) in

  if brick = BK_empty then
    BLACK
  else if brick = BK_simple then
    GREEN
  else if brick = BK_double then
    RED
  else if brick = BK_block then
    ORANGE
  else
    BLUE
;;

(**
  Renvoie la position selon l'axe horizontale de la raquette.

  @author Paul Ourliac
  @author Max Charrier
  @param game partie en cours d'exécution
  @return position en abscisse de la raquette.
*)
let paddle_x (game : t_camlbrick) : int =
  !(fst game.paddle.position)
;;

(**
  Renvoie la taille en pixel de la raquette.

  @author Paul Ourliac
  @param game partie en cours d'exécution
  @return taille en pixel de la raquette.
*)
let paddle_size_pixel (game : t_camlbrick) : int =
  let param : t_camlbrick_param = param_get game in

  if !(game.paddle.size) = PS_SMALL then
    param.paddle_init_width
  else if !(game.paddle.size) = PS_MEDIUM then
    param.paddle_init_width * 2
  else
    param.paddle_init_width * 4
;;

(**
  Déplace la raquette vers la gauche.

  @author Paul Ourliac
  @param game partie en cours d'exécution
*)
let paddle_move_left (game : t_camlbrick) : unit =
  if
    paddle_x game > (paddle_size_pixel game) / 4 - game.param.world_width / 2
  then
    fst game.paddle.position := !(fst game.paddle.position) - 10
  else
    ()
;;

(**
  Déplace la raquette vers la droite.

  @author Paul Ourliac
  @param game partie en cours d'exécution
*)
let paddle_move_right (game : t_camlbrick) : unit =
  let param : t_camlbrick_param = param_get game in

  if
    paddle_x game < (param.world_width / 2) - (paddle_size_pixel game) / 4
  then
    fst game.paddle.position := !(fst game.paddle.position) + 10
  else
    ()
;;

(**
  Indique si la partie en cours possèdes des balles.

  @author Axel De Les Champs--Vieira
  @author Max Charrier
  @param game partie en cours d'exécution
  @return s'il y a une balle ou non dans la partie.
*)
let has_ball (game : t_camlbrick) : bool =
  game.balls <> []
;;

(**
  Renvoie le nombre de balle présente dans une partie.

  @author Axel De Les Champs--Vieira
  @author Max Charrier
  @param game partie en cours d'exécution
  @return nombre de balle dans la partie.
*)
let balls_count (game : t_camlbrick) : int =
  if game.balls = [] then
    0
  else
    List.length game.balls
;;

(**
  Récupérer la liste de toutes les balles de la partie en cours.

  @author Axel De Les Champs--Vieira
  @param game partie en cours d'exécution
  @return liste des balles de la partie.
*)
let balls_get (game : t_camlbrick) : t_ball list =
  game.balls
;;

(**
  Récupère la i-ième balle d'une partie, i compris entre 0 et n, avec n le nombre de balles.

  @author Axel De Les Champs--Vieira
  @author Max Charrier
  @param game partie en cours d'exécution
  @param i partie horizontal de la matrice de brique
  @return paramètres de la balle.
*)
let ball_get (game, i : t_camlbrick * int) : t_ball =
  (*
    Il s'agit d'une optimisation du code suivant :
    {[
      let eol : t_ball list ref = ref game.ball in
      let incr : int ref = ref 0 in

      while !incr != i do
        eol := List.tl !eol;
        incr := !incr + 1
      done;

      List.hd !eol
    ]}
  *)

  List.nth game.balls i
;;

(**
  Renvoie l'abscisse du centre d'une balle.

  @author Axel De Les Champs--Vieira
  @author Max Charrier
  @param game partie en cours d'exécution
  @param ball balle
  @return position en abscisse de la balle
*)
let ball_x (game, ball : t_camlbrick * t_ball) : int =
  !(ball.position).x
;;

(**
  Renvoie l'ordonnée du centre d'une balle.

  @author Axel De Les Champs--Vieira
  @author Max Charrier
  @param game partie en cours d'exécution
  @param ball balle
  @return position en ordonnée de la balle
*)
let ball_y (game, ball : t_camlbrick * t_ball) : int =
  !(ball.position).y
;;

(**
  Indique le diamètre du cercle représentant la balle en fonction de sa taille.

  @author Axel De Les Champs--Vieira
  @author Max Charrier
  @param game partie en cours d'exécution
  @param ball balle
  @return taille de la balle
*)
let ball_size_pixel (game, ball : t_camlbrick * t_ball) : int =
  if ball.size = BS_SMALL then
    5
  else if ball.size = BS_MEDIUM then
    10
  else
    15
;;

(**
  Donne une couleur différentes pour chaque taille de balle.

  @author Axel De Les Champs--Vieira
  @param game partie en cours d'exécution
  @param ball balle
  @return couleur de la balle
*)
let ball_color (game, ball : t_camlbrick * t_ball) : t_camlbrick_color =
  if ball.size = BS_SMALL then
    LIME
  else if ball.size = BS_MEDIUM then
    LIGHTGRAY
  else
    GRAY
;;

(**
  Modifie la vitesse d'une balle par accumulation avec un vecteur.

  On peut alors augmenter ou diminuer la vitesse de la balle.

  @author Max Charrier
  @param game partie en cours d'exécution
  @param ball balle
  @param dv vecteur
*)
let ball_modif_speed (game, ball, dv : t_camlbrick * t_ball * t_vec2) : unit =
  ball.speed := vec2_add (!(ball.speed), dv)
;;

(**
  Modifie la vitesse d'une balle par multiplication avec un vecteur.

  On peut alors augmenter ou diminuer la vitesse de la balle.

  @author Max Charrier
  @param game partie en cours d'exécution
  @param ball balle
  @param sv vecteur
*)
let ball_modif_speed_sign (game, ball, sv : t_camlbrick * t_ball * t_vec2) : unit =
  ball.speed := vec2_mult (!(ball.speed), sv)
;;

(**
  Détecte si un point (x,y) se trouve à l'intérieur d'un disque de centre (cx,cy) et de rayon rad.

  @author Matéo Abrane
  @author Max Charrier
  @param cx centre du disque en abscisse
  @param cy centre du disque en ordonnée
  @param rad rayon du cercle
  @param x point en abscisse
  @param y point en ordonnée
  @return si le point est dans le cercle
*)
let is_inside_circle (cx, cy, rad, x, y : int * int * int * int * int) : bool =
  let fst_point : float = float_of_int (x - cx) ** 2. in
  let snd_point : float = float_of_int (y - cy) ** 2. in

  Float.sqrt (fst_point +. snd_point) < (float_of_int rad)
;;

(**
  Détecte si un point (x,y) se trouve à l'intérieur d'un rectangle formé.

  @author Matéo Abrane
  @param x1 coordonnée (0, 0) du rectangle
  @param y1 coordonnée (0, 1) du rectangle
  @param x2 coordonnée (1, 0) du rectangle
  @param y2 coordonnée (1, 1) du rectangle
  @param x point en abscisse
  @param y point en ordonnée
  @return si le point est dans le rectangle
*)
let is_inside_quad (x1, y1, x2, y2, x, y : int * int * int * int * int * int) : bool =
  x >= x1 && x <= x2 && y >= y1 && y <= y2
;;

(**
  Renvoie une nouvelle liste sans les balles qui dépassent la zone de rebond.

  @author Max Charrier
  @author Paul Ourliac
  @param game partie en cours
  @param balls balle de la partie
  @return balle restante
*)
let ball_remove_out_of_border (game, balls : t_camlbrick * t_ball list ) : t_ball list =
  let param : t_camlbrick_param = param_get game in

  let aux (ball : t_ball) : bool =
    !(ball.position).y < param.world_width
  in

  List.filter aux balls
;;

(**
  Rebondit si une balle touche la raquette.

  @author Paul Ourliac
  @author Max Charrier
  @param game partie en cours
  @param ball balle courante
  @param paddle la raquette
  @return si touché ou non
*)
let ball_hit_paddle (game, ball, paddle : t_camlbrick * t_ball * t_paddle) : unit =
  let param : t_camlbrick_param = param_get game in
  let ball_position : t_vec2 = !(ball.position) in
  let ball_speed : t_vec2 = !(ball.speed) in

  let paddle_x1 : int =
    paddle_x game - (paddle_size_pixel game) / 4
  and paddle_x2 : int =
    (paddle_x game - (paddle_size_pixel game) / 4) + param.paddle_init_width
  and paddle_y1 : int =
    param.world_bricks_height + param.world_empty_height - param.paddle_init_height - 10
  and paddle_y2 : int =
    param.world_bricks_height + param.world_empty_height - 10
  in

  if
    is_inside_quad (paddle_x1, paddle_y1, paddle_x2 - 4 * 20 , paddle_y2, ball_position.x - (param.world_width / 2), ball_position.y)
  then begin
    ball_modif_speed_sign (game, ball, make_vec2 (0, 0));
    ball_modif_speed (game, ball, make_vec2 (-2, - ball_speed.y))
  end else if
    is_inside_quad (paddle_x1 + 1 * 20, paddle_y1, paddle_x2 - 3 * 20, paddle_y2, ball_position.x - (param.world_width / 2), ball_position.y)
  then begin
    ball_modif_speed_sign (game, ball, make_vec2 (0, 0));
    ball_modif_speed (game, ball, make_vec2 (-1, - ball_speed.y))
  end else if
    is_inside_quad (paddle_x1 + 2 * 20, paddle_y1, paddle_x2 - 2 * 20, paddle_y2, ball_position.x - (param.world_width / 2), ball_position.y)
  then begin
    ball_modif_speed_sign (game, ball, make_vec2 (0, 0));
    ball_modif_speed (game, ball, make_vec2 (0, - ball_speed.y))
  end else if
    is_inside_quad (paddle_x1 + 3 * 20, paddle_y1, paddle_x2 - 1 * 20, paddle_y2, ball_position.x - (param.world_width / 2), ball_position.y)
  then begin
    ball_modif_speed_sign (game, ball, make_vec2 (0, 0));
    ball_modif_speed(game, ball, make_vec2 (1, - ball_speed.y))
  end else if
    is_inside_quad (paddle_x1 + 4 * 20, paddle_y1, paddle_x2 , paddle_y2, ball_position.x - (param.world_width / 2), ball_position.y)
  then begin
    ball_modif_speed_sign (game, ball, make_vec2 (0, 0));
    ball_modif_speed (game, ball, make_vec2 (2, - ball_speed.y))
  end
;;

(**
  Vérifie si une balle touche un des sommets des briques.

  @author Max Charrier
  @author Paul Ourliac
  @param game partie en cours
  @param ball balle courante
  @param i partie horizontal de la matrice de brique
  @param j partie vertical de la matrice de brique
  @return si touché ou non
*)
let ball_hit_corner_brick (game, ball, i, j : t_camlbrick * t_ball * int * int) : bool =
  let param : t_camlbrick_param = param_get game in
  let ball_position = !(ball.position) in
  let ball_radius = ball_size_pixel (game, ball) in
  let (pos_x, pos_y) : int * int =
    (i * param.brick_width, j * param.brick_height)
  in

  is_inside_circle (ball_position.x, ball_position.y, ball_radius, pos_x, pos_y)
  || is_inside_circle (ball_position.x, ball_position.y, ball_radius, pos_x + param.brick_width, pos_y)
  || is_inside_circle (ball_position.x, ball_position.y, ball_radius, pos_x, pos_y + param.brick_height)
  || is_inside_circle (ball_position.x, ball_position.y, ball_radius, pos_x + param.brick_width, pos_y + param.brick_height)
;;

(**
  Vérifie si une balle touche une des arrêtes des briques.

  @author Max Charrier
  @author Paul Ourliac
  @param game partie en cours
  @param ball balle courante
  @param i partie horizontal de la matrice de brique
  @param j partie vertical de la matrice de brique
  @return si touché ou non
*)
let ball_hit_side_brick (game, ball, i, j : t_camlbrick * t_ball * int * int) : bool =
  let param : t_camlbrick_param = param_get game in
  let ball_position = !(ball.position) in
  let ball_radius = ball_size_pixel (game, ball) in
  let (pos_x, pos_y) : int * int =
    (i * param.brick_width, j * param.brick_height)
  in

  is_inside_circle (ball_position.x, ball_position.y, ball_radius, pos_x + (param.brick_width / 2), pos_y)
  || is_inside_circle (ball_position.x, ball_position.y, ball_radius, pos_x + param.brick_width, pos_y + param.brick_height)
  || is_inside_circle (ball_position.x, ball_position.y, ball_radius, pos_x, pos_y + (param.brick_height / 2))
  || is_inside_circle (ball_position.x, ball_position.y, ball_radius, pos_x + param.brick_width, pos_y + (param.brick_height / 2))
;;

(**
  Gère les collisions des balles.

  TODO : découper `animate_action` pour le mettre ici.

  @author ...
  @param game partie en cours
  @param balls liste des balles en jeu
*)
let game_test_hit_balls (game, balls : t_camlbrick * t_ball list) : unit =
  (* Itération 3 *)
  ()
;;

(**
  Appelée par l'interface graphique avec le jeu en argument et la position de
  la souris dans la fenêtre lorsqu'elle se déplace.

  Vous pouvez réaliser des traitements spécifiques, mais comprenez bien que
  cela aura un impact sur les performances si vous dosez mal les temps de
  calcul.

  @param game la partie en cours
  @param x l'abscisse de la position de la souris
  @param y l'ordonnée de la position de la souris
*)
let canvas_mouse_move (game, x, y : t_camlbrick * int * int) : unit =
  ()
;;

(**
  Appelée par l'interface graphique avec le jeu en argument et la position
  de la souris dans la fenêtre lorsqu'un bouton est enfoncé.

  Vous pouvez réaliser des traitements spécifiques, mais comprenez bien que
  cela aura un impact sur les performances si vous dosez mal les temps de
  calcul.

  @param game la partie en cours
  @param button numero du bouton de la souris enfoncé
  @param x l'abscisse de la position de la souris
  @param y l'ordonnée de la position de la souris
*)
let canvas_mouse_click_press (game, button, x, y : t_camlbrick * int * int * int) : unit =
  let param : t_camlbrick_param = param_get game in
  let canvas_height : int =
    param.world_empty_height + param.world_bricks_height
  in
  let pos_x : int =
    if x > param.world_width / 2 then
      if x / 2 >= param.world_width / 2 - paddle_size_pixel game / 4 then
        param.world_width / 2 - paddle_size_pixel game / 4
      else
        x - param.world_width / 2
    else
      -1 * (-(x + param.world_width / 2) + param.world_width)
  in

  if y >= canvas_height - param.paddle_init_height - 10 && y < canvas_height then begin
    print_string "pos init=";
    print_int (paddle_x game);
    print_string " new pos=";
    print_int pos_x;
    print_newline ();
    fst game.paddle.position := pos_x
  end else
    ()
;;

(**
  Appelée par l'interface graphique avec le jeu en argument et la position
  de la souris dans la fenêtre lorsqu'un bouton est relaché.

  Vous pouvez réaliser des traitements spécifiques, mais comprenez bien que
  cela aura un impact sur les performances si vous dosez mal les temps de
  calcul.

  @param game la partie en cours
  @param button numero du bouton de la souris relaché
  @param x l'abscisse de la position du relachement
  @param y l'ordonnée de la position du relachement
*)
let canvas_mouse_click_release (game, button, x, y : t_camlbrick * int * int * int) : unit =
  ()
;;

(**
  Appelée par l'interface graphique lorsqu'une touche du clavier est appuyée.
  Les arguments sont le jeu en cours, la touche enfoncé sous la forme d'une
  chaine et sous forme d'un code spécifique à labltk.

  Le code fourni initialement permet juste d'afficher les touches appuyées au
  clavier afin de pouvoir les identifiées facilement dans nos traitements.

  Vous pouvez réaliser des traitements spécifiques, mais comprenez bien que
  cela aura un impact sur les performances si vous dosez mal les temps de
  calcul.

  @param game la partie en cours
  @param keyString nom de la touche appuyée
  @param keyCode code entier de la touche appuyée
*)
let canvas_keypressed (game, key_string, key_code : t_camlbrick * string * int) : unit =
  let left_key_code : int = 65361 in
  let q_key_code : int = 113 in
  let right_key_code : int = 65363 in
  let d_right_code : int = 100 in

  if key_code = left_key_code || key_code = q_key_code then
    paddle_move_left game
  else if key_code = right_key_code || key_code = d_right_code then
    paddle_move_right game
  else
    ()
;;

(**
  Appelée par l'interface graphique lorsqu'une touche du clavier est relachée.
  Les arguments sont le jeu en cours, la touche relachée sous la forme d'une
  chaine et sous forme d'un code spécifique à labltk.

  Le code fourni initialement permet juste d'afficher les touches appuyées au
  clavier afin de pouvoir les identifiées facilement dans nos traitements.

  Vous pouvez réaliser des traitements spécifiques, mais comprenez bien que
  cela aura un impact sur les performances si vous dosez mal les temps de
  calcul.

  @param game la partie en cours
  @param keyString nom de la touche relachée
  @param keyCode code entier de la touche relachée
*)
let canvas_keyreleased (game, key_string, key_code : t_camlbrick * string * int) : unit =
  ()
;;

(**
  Cette fonction est utilisée par l'interface graphique pour connaitre
  l'information à afficher dans la zone Custom1 de la zone du menu.
*)
let custom1_text () : string =
  (* Iteration 4 *)
  "<Rien1>"
;;

(**
  Cette fonction est utilisée par l'interface graphique pour connaitre
  l'information à afficher dans la zone Custom2 de la zone du menu.
*)
let custom2_text () : string =
  (* Iteration 4 *)
  "<Rien2>"
;;

(**
  Cette fonction est appelée par l'interface graphique lorsqu'on clique sur le
  bouton de la zone de menu et que ce bouton affiche "Start".

  Vous pouvez réaliser des traitements spécifiques, mais comprenez bien que
  cela aura un impact sur les performances si vous dosez mal les temps de
  calcul.

  @author Max Charrier
  @param game la partie en cours
*)
let start_onclick (game : t_camlbrick) : unit =
  ()
;;

(**
  Appelée par l'interface graphique lorsqu'on clique sur le bouton
  de la zone de menu et que ce bouton affiche "Stop".

  Vous pouvez réaliser des traitements spécifiques, mais comprenez bien que
  cela aura un impact sur les performances si vous dosez mal les temps de
  calcul.

  @param game la partie en cours
*)
let stop_onclick (game : t_camlbrick) : unit =
  let balls : t_ball list ref = ref game.balls in

  (* Supprimer toutes les balles *)
  balls := []
;;

(**
  Appelée par l'interface graphique pour connaitre la valeur
  du slider Speed dans la zone du menu.

  Vous pouvez donc renvoyer une valeur selon votre désir afin d'offrir la
  possibilité d'interagir avec le joueur.

  @param game partie en cours d'exécution
  @return vitesse du slider speed dans le menu contextuel.
*)
let speed_get (game : t_camlbrick) : int =
  !(game.speed)
;;

(**
  Appelée par l'interface graphique pour indiquer que le slide Speed dans la
  zone de menu a été modifiée.

  Ainsi, vous pourrez réagir selon le joueur.

  @param game partie en cours d'exécution
  @param xspeed vitesse à modifier
*)
let speed_change (game, xspeed : t_camlbrick * int) : unit =
  (* print_endline ("Change speed : " ^ string_of_int xspeed); *)
  game.speed := xspeed
;;

(**
  Anime la balle vers une direction.

  @author Max Charrier
  @param game partie en cours
  @param ball balle courante
  @param direction direction souhaitée
*)
let animate_ball (game, ball, direction : t_camlbrick * t_ball * t_vec2) : unit =
  ball_modif_speed_sign (game, ball, direction);
  ball.position := vec2_add (!(ball.position), !(ball.speed))
;;

(**
  Met à jour de l'état du jeu.

  Détruit les balles en dehors des limites et vérification de si la partie
  est gagnée ou perdue.

  @author Max Charrier
  @param game partie en cours
  @param ball balle courante
*)
let update_gamestate (game, balls : t_camlbrick * t_ball list ref) : unit =
  (* Supprimer les balles qui sortent *)
  balls := ball_remove_out_of_border (game, !balls);
;;

(**
  Animation des balles dans la partie en cours.

  Appelée par l'interface graphique à chaque frame du jeu vidéo.
  Mettre ici tout le code qui permet de montrer l'évolution du jeu.

  @author Paul Ourliac
  @author Max Charrier
  @param game partie en cours d'exécution
*)
let animate_action (game : t_camlbrick) : unit =
  let param : t_camlbrick_param = param_get game in
  let balls : t_ball list ref = ref game.balls in

  update_gamestate (game, balls);

  while !balls <> [] do
    (* Récupère la première balle *)
    let ball : t_ball = List.hd !balls in
    let pos_x : int = !(ball.position).x / param.brick_width in
    let pos_y : int = !(ball.position).y / param.brick_height in

    (* Collision avec la raquette *)
    ball_hit_paddle (game, ball, game.paddle);

    (* Collision avec les briques *)
    if
      pos_x <= Array.length game.matrix - 1
      && pos_y <= Array.length game.matrix.(0) - 1
    then begin
      (* Vérification de s'il y a une brique *)
      if brick_get (game, pos_x, pos_y) <> BK_empty then (
        if
          ball_hit_corner_brick (game, ball, pos_x, pos_y)
          || ball_hit_side_brick(game, ball, pos_x, pos_y)
        then begin
          ball_modif_speed_sign (game, ball, make_vec2 (1, -1));
          game.matrix.(pos_x).(pos_y) <- brick_hit (game, pos_x, pos_y)
        end
      );
    end;

    if
      !(ball.position).x <= 0
    then
      (* Bord latéral gauche *)
      animate_ball (game, ball, make_vec2 (-1, 1))
    else if
      !(ball.position).x >= game.param.world_width
    then
      (* Bord latéral droite *)
      animate_ball (game, ball, make_vec2 (-1, 1))
    else if
      !(ball.position).y <= 0
    then
      (* Bord supérieur *)
      animate_ball (game, ball, make_vec2 (1, -1))
    else
        (* Cas par défault *)
        ball.position := vec2_add (!(ball.position), !(ball.speed));

    (* Passage à la balle suivante *)
    balls := List.tl !balls
  done
;;
