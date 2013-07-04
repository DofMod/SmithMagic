SmithMagic
==========

By *ExiTeD* (improved by *Relena*)

Ce module est un assistant à la forgemagie.

Celui-ci se compose d'une unique interface se plaçant au dessus du module de forgemagie d'Ankama, il est donc dépendant de ce dernier.

Son interface possède plusieurs améliorations:
* Affichage du poids des runes.
* Affichage du poids des effets.
* Affichage de 14lignes d'effets (contre 5 pour l'interface officielle).
* Affichage du poids maximum et minimum de chaque effets de l'objet.
* Affichage des jets disparu.
* Trie et affiche la liste des runes associées à chaque effet.
* Calcul et affiche la valeur du puits.
* Fonctionnel en mode coopératif.
* Mise en valeur de la ligne d'effet modifiée par la rune présente dans l'interface.
* Lors d'un craft, affichage de la modification de chaque effets à coté de ceux-ci.

![Interface du module](http://imageshack.us/a/img41/9254/5m60.png "Interface du module")
![Interface en mode minimisé (le bouton '+')](http://imageshack.us/a/img707/2590/u4d.png "Interface en mode minimisé (le bouton '+')")

Une vidéo de présentation du module est visualisable sur la chaine Youtube [DofusModules](https://www.youtube.com/user/dofusModules "Youtube, DofusModules"):

[Lien vers la vidéo](https://www.youtube.com/watch?v=0RCBJrVAE7E "Vidéo de présentation du module")

Download + Compile:
-------------------

1. Install Git
2. git clone --recursive https://github.com/Dofus/SmithMagic.git
3. cd SmithMagic/dmUtils/
4. Compile dmUtils library (see README)
5. cd ..
6. mxmlc -output SmithMagic.swf -compiler.library-path+=./modules-library.swc -compiler.library-path+=dmUtils/dmUtils.swc -source-path src -keep-as3-metadata Api Module DevMode -- src/SmithMagic.as

Installation:
=============

1. Create a new *SmithMagic* folder in the *ui* folder present in your Dofus instalation folder. (i.e. *ui/SmithMagic*)
2. Copy the following files in this new folder:
    * xml/
    * css/
    * SoulStone.swf
    * ExiTeD_SmithMagic.dm
3. Launch Dofus
4. Enable the module in your config menu.
5. ...
6. Profit!
