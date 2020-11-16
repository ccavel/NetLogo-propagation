globals [
  opinion-somme ;; somme de l'opinion de toute la population
  opinion-globale ;; l'opinion de la population entre 0 (bleu) et la population (rouge) (opinion-somme/population)
  opinion-autre ;; opinion de la tortue discutant avec la tortue sujet
  alea ;; variable permettant de définir un nombre entre 0 et 100
  i ;; compteur
]

turtles-own [
  rural? ;; est-il de la ville ou de la campagne, si c'est vrai, il est de la campagne
  vieux? ;; est-il vieux ou jeune, si c'est vrai, il est vieux
  cadre? ;; est-il cadre ou non, si c'est vrai, il est cadre
  opinion ;; quel est son opinion politique de 0 (bleu) à 100 (rouge)
  influence ;; c'est le nombre de personnes autour de lui qu'il peut influencer à chaque tick de 1 à 50
  maleabilite ;; taux de 0 à 100 qui détermine à quel point quelqu'un peut changer d'avis
]

to setup
  clear-all
  stop-inspecting-dead-agents
  set-default-shape turtles "person"
  set i 0 ;; initialisation du compteur
  create-turtles population
  [ setxy random-xcor random-ycor ;; place les agents de manière aléatoire dans l'environnement
	set opinion random 101 ;; donne une opinion aléatoire entre 0 et 100
	set opinion-somme opinion-somme + opinion ;; fait la somme de tous les opinions pour vérifier les conditions initiales
	set influence random 51 ;; donne la force d'influence de 0 à 10
	set size 1
	;; donne la couleur en fonction de l'opinion
	ifelse opinion < 20 [set color blue]
	[ifelse opinion < 40  [set color sky]
  	[ifelse opinion < 60  [set color violet]
    	[ifelse opinion < 80  [set color orange] [set color red]]]]
	if influence = 50 [set size 2] ;; représente les plus gros influenceurs
	ifelse i < vieux/jeunes [set vieux? true set shape "star"] [set vieux? false set shape "triangle"] ;; divise la population en vieux et jeunes
	ifelse i < noncadres/cadres [set cadre? true] [set cadre? false] ;; divise la population en cadres et non cadres
	ifelse i < ruraux/urbains [set rural? true] [set rural? false] ;; divise la population en ruraux et urbains
	set i i + 1 ;; tour de compteur
	ifelse vieux? [set maleabilite random 31] [set maleabilite random 71] ;;définie la maléabilité de chaque tortue entre 0 et 30 pour les vieux ou entre 0 et 70 pour les jeunes
	ifelse cadre? [set maleabilite maleabilite - 10] [set maleabilite maleabilite + 10] ;; coeff de maleabilite en fct de si une personne est cadre ou non
  ]
  ;;setup-patches
  set opinion-globale opinion-somme / population ;; calcul de l'opinion global
  set i 0 ;; reset du compteur pour d'autres utilisation dans le reste du code
  watch one-of turtles with [ not hidden? ]
      clear-drawing
      ask subject [ pen-down ]
      inspect subject
  reset-ticks
end

to go
  ask turtles
  [
	ifelse rural? [chercher-ami-campagne] [chercher-ami-ville] ;; recherche d'un ami avec qui discuter
	convaincre-moi ;; modification de l'opinion et actualisation de la couleur de la tortue en fonction
	ifelse opinion < 20 [set color blue]
	[ifelse opinion < 40 [set color sky]
  	[ifelse opinion < 60 [set color violet]
    	[ifelse opinion < 80 [set color orange] [set color red]]]]
	set i i + 1 ;; tour de compteur
	if i = 1000 ;; si on a fait toutes les tortues, on actualise l'opinion globale sinon rien
	[
	set opinion-globale opinion-somme / population
	set opinion-somme 0 ;; remise a 0 de la variable intermédiaire
	set i 0 ;; remise à 0 du compteur
	]
  ]
  tick
end

to chercher-ami-campagne
  set alea random 101
  ifelse alea < 90 ;; 90% de chance d'aller voir quelqu'un qui nous ressemble sinon voir un différent
  [
	if vieux? and one-of (turtles in-radius 3) with [vieux? = true] != nobody ;; si il existe quelqu'un dans les 3 patch et que c'est un vieux faire
	[
  	face one-of (turtles in-radius 3) with [vieux? = true] ;; se tourner vers un des vieux
  	fd random 2 ;; avancer de 0 ou 1 patch
	]
	if not vieux? and one-of (turtles in-radius 3) with [vieux? = false] != nobody
	[
  	face one-of (turtles in-radius 3) with [vieux? = false] ;; se tourner vers un jeune
  	fd random 3 ;; avancer de 0, 1 ou 2 patch
	]
  ]
  [
	if vieux? and one-of (turtles in-radius 3) with [vieux? = false] != nobody ;; si il existe quelqu'un dans les 3 patch et que c'est un jeune faire
	[
  	face one-of (turtles in-radius 3) with [vieux? = false] ;; se tourner vers un des jeunes
  	fd random 2 ;; avancer de 0 ou 1 patch
	]
	if not vieux? and one-of (turtles in-radius 3) with [vieux? = true] != nobody
	[
  	face one-of (turtles in-radius 3) with [vieux? = true] ;; se tourner vers un vieux
  	fd random 3 ;; avancer de 0, 1 ou 2 patch
	]
  ]
end

to chercher-ami-ville ;; pareil que pour chercher-ami-campagne mais avec un plus grand rayon d'action
  if vieux? and one-of (turtles in-radius 5) with [vieux? = true] != nobody
  [
	face one-of (turtles in-radius 5) with [vieux? = true]
	fd random 3
  ]
 if not vieux? and one-of (turtles in-radius 5) with [vieux? = false] != nobody
  [
	face one-of (turtles in-radius 5) with [vieux? = false]
	fd random 4
  ]
end

to convaincre-moi
  set alea random 101 ;; tirer au sort un nombre représentant si la discussion avec un ami a su convaincre ou non
  ifelse one-of (turtles in-radius 1) with [influence = 50] != nobody ;; si un de ses voisins direct est un influenceur et qu'il existe un voisin avec qui discuter alors la tortue deviens plus maléable
	[set maleabilite maleabilite + 10
  	if alea < maleabilite ;; si la discussion a été convaincante alors
  	[
    	set opinion-autre [opinion] of one-of turtles in-radius 1 ;; choisir une opinion parmis ses voisins
    	ifelse opinion-autre >= opinion [set opinion opinion + 5] [set opinion opinion - 5] ;; //!!\\ A REVOIR si son opinion est supérieure, augmenter la sienne sinon la diminuer
    	set opinion [opinion] of one-of turtles in-radius 1
  	]
	set maleabilite maleabilite - 10]
	[if alea < maleabilite
  	[
    	set opinion-autre [opinion] of one-of turtles in-radius 1
    	ifelse opinion-autre >= opinion [set opinion opinion + 5] [set opinion opinion - 5] ;; //!!\\ A REVOIR
    	;set opinion [opinion] of one-of turtles in-radius 1
  	]
	]
  set opinion-somme opinion-somme + opinion
end
