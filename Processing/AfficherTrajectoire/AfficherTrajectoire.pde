import papaya.*;

import papaya.*;


/* Le Coeur du programme. draw et keyPressed s'executent en boucle */


void setup() 
{
  // Ouverture de la fenêtre
  size(window_size_x, window_size_y);
  background(0);
  stroke(255);
  frameRate(framerate);
  
  setup_game();

}



void draw() {
  
  // Mise à jour des données du jeu.
  update_game();
  
  // Dessin de la fenêtre
  
  if (GAME_STATE == START_MENU) 
  {
    draw_menu();
  }
  else
  {
    draw_game();
  }
  


}


/**
 * Gestion des évènements clavier
 */
void keyPressed() {
  
  if (GAME_STATE == START_MENU) 
  {
    if (key == 'x') {
      init_game();

    }
  } 
  else if (GAME_STATE == INIT_LANCER) {
    if (key == CODED && keyCode == UP) // monter l'angle
    {
      player_angle_dattaque += 2;
      if (player_angle_dattaque > 80) player_angle_dattaque = 80; // Limite
      play_roll_fx();
      // Faire tout les
    } else if (key == CODED && keyCode == DOWN) // baisser l'angle
    {
      player_angle_dattaque -= 2;
      if (player_angle_dattaque < -80) player_angle_dattaque = -80; // Limite
      play_roll_fx();
    } else if (key == CODED && keyCode == LEFT) // Baisser player_force
    {
      player_force -= 0.2;
      if (player_force < 1) player_force = 1; // Limite
      play_roll_fx();
    } else if (key == CODED && keyCode == RIGHT) // Monter player_force
    {
      player_force += 0.2;
      if (player_force > 10) player_force = 10; // Limite
      play_roll_fx();
    }

    if (key == ' ') // Lancer la boule
    {
      commande_manuelle = new CommandeManuelle();
      commande_manuelle.set_conditions_initiales(player_force, player_angle_dattaque);
      commande_manuelle.compute_trajectoire();
      
      commande_manuelle.compute_cheatmode(); 
      CHEAT_MODE = true;
      
      
      GAME_STATE = LANCER_BOULE;
    }
  } else if (GAME_STATE == END_GAME)
  {
    
    
    if (key == 't') // Retour au menu principal
    {
      init_game();
    }
  }

  key = 0; // Nettoyage de l'entrée sur key
}


void stop()
{
  stop_sound();
}

