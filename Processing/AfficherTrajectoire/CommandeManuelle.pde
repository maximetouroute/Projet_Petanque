


/*
Gestion de la commande manuelle
 */
class CommandeManuelle
{

  // Variables de conditions initiales
  float masse = 0.8;
  float gterre = 9.81;


  // Les deux vecteurs qui stockent les coordonnées de la trajectoire : limite de points imposée à 2000.
  float[] coordonnees_trajectoire_x = new float[2000];
  float[] coordonnees_trajectoire_y = new float[2000];

  float[] coordonnees_trajectoire_x_triche = new float[2000];
  float[] coordonnees_trajectoire_y_triche = new float[2000];
  

  // L'instant t d'execution
  int instant_t = 0;


  // Nos equations discretes 

  // MAtrice 4x4
  float[][] Ad = { 
    {
      1.0, 0.03, 0, 0
    }
    , 
    {
      0.0, 1.0, 0.0, 0.0
    }
    , 
    {
      0.0, 0.0, 1.0, 0.03
    }
    , 
    {
      0.0, 0.0, 0.0, 1.0
    }
  }; 

  // MAtrice 2x'4
  float[][] Bd = { 
    {
      0.00045, 0
    }
    , {
      0.03, 0
    }
    , {
      0, 0.00045
    }
    , {
      0, 0.03
    }
  }; 

  // Vecteur a
  float[][] a = { 
    {
      0
    }
    , 
    {
      -gterre
    }
  };


  // Vecteur initial
  float[][] X0 = {
    {
      0
    }
    , 
    {
      0
    }
    , 
    {
      0
    }
    , 
    {
      0
    }
  }; 


  /*
  Initialisation des conditions initiales
   @params force, la force du lancer
   @p_angle_dattaque l'angle d'attaque du lancer
   */
  void set_conditions_initiales(float force, float p_angle_dattaque)
  {
    float angle_dattaque = p_angle_dattaque;

    // Calcul de la vitesse d'attaque
    float v0x = force * cos( radians(angle_dattaque) );
    float v0y = force * sin( radians(angle_dattaque) );

    // Vecteur de conditions initiales
    X0[0][0] = 0;
    X0[1][0] = v0x;
    X0[2][0] = HAUTEUR_INITIALE;
    X0[3][0] = v0y;
  }


  /*
  * Calcule tous les points de trajectoire, et stocke les réultats 
   * dans les tableaux coordonnees_trajectoire_x et coordonnees_trajectoire_y
   */
  void compute_trajectoire()
  {

    // Initialisation du prochain vecteur à calculer
    float[][] Xsuivant = {  
      {
        0
      }
      , 
      {
        0
      }
      , 
      {
        0
      }
      , 
      {
        0
      }
    };

    // Le X précédent
    float[][] X = new float[4][1]; // Le X d'avant
    
    
      X[0][0] = X0[0][0];
      X[1][0] = X0[1][0];
      X[2][0] = X0[2][0];
      X[3][0] = X0[3][0];
      
    // Stockage des premières valeurs
    coordonnees_trajectoire_x[0] = X[0][0]; // x
    coordonnees_trajectoire_y[0] = X[2][0]; // y

    while ( X[2][0] > 0 ) // Tant que la position en y est supérieure à 0 (par encore par terre)
    {
      // on réinitialise Xsuivant avant de ré-itérer la boucle
      Xsuivant[0][0] = 0;
      Xsuivant[1][0] = 0;
      Xsuivant[2][0] = 0;
      Xsuivant[3][0] = 0;

      instant_t++;

      // Produit matriciel inspiré de celui du code Scilab

      for (int i = 0; i < 4; i++) // Les 4 lignes
      {
        for (int j = 0; j < 4; j++) // les 4 colonnes
        {
          Xsuivant[i][0] += Ad[i][j]*X[j][0] ;//+ Bd*a;
        }
      }

      for (int i = 0; i < 4; i++) // ajout du terme Bd*a;
      {
        for (int j = 0; j < 2; j++)
        {

          Xsuivant[i][0] += Bd[i][j]*a[j][0];
        }
      }

      // L'ancien X devient le nouveau X.
      X[0][0] = Xsuivant[0][0];
      X[1][0] = Xsuivant[1][0];
      X[2][0] = Xsuivant[2][0];
      X[3][0] = Xsuivant[3][0];

      // Stockage des nouvelles coordonnées de trajectoire
      coordonnees_trajectoire_x[instant_t] = Xsuivant[0][0];
      coordonnees_trajectoire_y[instant_t] = Xsuivant[2][0];
    }
  }


  void compute_cheatmode()
  {
    // En entrée, le vecteur X0 d'où on est.
    //               x   vx   y   vy
    float[][] XDebutTriche = {
      {
        0
      }
      , {
        X0[1][0]
      }
      , {
        X0[2][0]
      }
      , {
        X0[3][0]
      }
    }; 
    print("potision cochonnet:", position_cochonnet, "\n");
    // On veut aller à 
    float[][] Xh = {
      {
        position_cochonnet/SCALE
      }
      , {
        1
      }
      , {
        0
      }
      , {
        -1
      }
    };   // TODO: remplacer ça par la position du cochonnet

    // en h étapes TODO: euh... jouer avec ça ?
    int h = 30;

    // Matrice de gouvernabilité : les premières valeurs c'est Bd
    // MAtrice 2x'4
    //float[][] Bd = { {0.00045, 0},{0.03, 0},{0, 0.00045},{0, 0.03} }; 

    float[][] G = new float[4][2*h]; // G est une matrice contenant une liste de vecteurs 4 (sur chaque colonne) 

    //TODO: récupérer proprement les vraies valeurs de Bd parce que là merci bien
    // Scilab: G = Bd
    //[ligne][colonne]
    //
    G[0][(2*h)-2] = 0.00045;
    G[1][(2*h)-2] = 0.03;
    G[2][(2*h)-2] = 0;
    G[3][(2*h)-2] = 0;

    G[0][(2*h)-1] = 0;
    G[1][(2*h)-1] = 0;
    G[2][(2*h)-1] = 0.00045;
    G[3][(2*h)-1] = 0.03;


    //Mat.print(G,5);
    //*********************************************************** Calcul de la matrice de gouvernabilité

    // Code Scilab
    /*
    for k=1:h-1
     G=[(Ad^k)*Bd,G]; // On 
     end*/

    float[][] Adk = new float[4][4];

    for (int i = 0; i < 4; i++)
      for (int j = 0; j < 4; j++)
        Adk[i][j]=Ad[i][j];

    print("Adk initial\n");
    Mat.print(Adk, 5);

    int indice_courant_de_G = (2*h)-3; // Indice où il faut écrire

    for (int k = 1; k < h; k++)
    {
      print("\n*************iteration", k, "\n");

      // On multiplie Adk par Ad voilà. Testé OK (normalement)
      if (k != 1)
      {

        // Le Adk d'avant.
        float[][] prev_Adk = Adk;

        // Calcul du Adk
        for (int i = 0; i < 4; i++) // Les 4 lignes
        {
          for (int j = 0; j < 4; j++) // les 4 colonnes
          {
            // calcul de la valeur en ce point
            float sum = 0;

            for (int p = 0; p < 4; p++)
            {
              // Adk ligne i colonne j est égal à la la somme des produits de prev_adk[i][j]*Ad[k]
              sum = sum + prev_Adk[i][p]*Ad[p][j] ;
            }

            Adk[i][j] = sum;
          }
        }
      }

      print("\nAdk\n");
      Mat.print(Adk, 5);

      print("\nBd\n");
      Mat.print(Bd, 5);

      // Calcul de la matrice 4x2 à ajouter dans G : Testé OK

      float[][] temp_G = new float[4][2]; // G est une matrice contenant une liste de vecteurs 4 (sur chaque colonne) 

      for (int i = 0; i < 4; i++) // Les 4 lignes
      {
        for (int j = 0; j < 2; j++) // les 2 colonnes
        {
          float sum = 0;
          // à chaque étape, on ajoute DEUX colonnes
          for (int p = 0; p < 4; p++)
          {
            sum += Adk[i][p]*Bd[p][j];
          }
          temp_G[i][j] = sum;
        }
      }

      print("\ntemp_G\n");
      Mat.print(temp_G, 5);

      // Derniere etape: concatener la matrice temp_G à G.
      // TODO: c'est vraimen bien fait ?
      for (int i = 0; i < 4; i++)
      {
        G[i][indice_courant_de_G] = temp_G[i][1];
      }

      indice_courant_de_G--;

      for (int i = 0; i < 4; i++)
      {
        G[i][indice_courant_de_G] = temp_G[i][0];
      }

      indice_courant_de_G--;
    }


    print("final G\n");
    Mat.print(G, 5);
    
    
    //* *************************** Jusqu'ici ça marche OMG ! ********************************************************/


    //************************************************************************************************************************************************************************************************ Calcul de la solution
    //*****************************************************************************************************************************************************************************************************************
    /*
    Code Scilab
     y = Xh - (Ad^h) * X0; // y, le vecteur final qu'on veut atteindre ?
     Gt = G'; // G' donne la transposée de G
     u = (Gt * inv(G * Gt)) * y; 
     */

    float[][] y = { 
      {
        0
      }
      , {
        0
      }
      , {
        0
      }
      , {
        0
      }
    };

    // Initialisation du vecteur y avec Xh dedans
    y[0][0] = Xh[0][0];
    y[1][0] = Xh[1][0];
    y[2][0] = Xh[2][0];
    y[3][0] = Xh[3][0];

    // On reprend le Adk qui est à h maintenant? (ou peut-être qu'il manque 1 multiplication?)
    // Adk devient Adh.
    {

      // Le Adk d'avant.
      float[][] prev_Adk = Adk;

      // Calcul du Adk
      for (int i = 0; i < 4; i++) // Les 4 lignes
      {
        for (int j = 0; j < 4; j++) // les 4 colonnes
        {
          // calcul de la valeur en ce point
          float sum = 0;

          for (int p = 0; p < 4; p++)
          {
            // Adk ligne i colonne j est égal à la la somme des produits de prev_adk[i][j]*Ad[k]
            sum = sum + prev_Adk[i][p]*Ad[p][j] ;
          }

          Adk[i][j] = sum;
        }
      }
    }

    // * vecteur X0
    // ad^h*X0
    float[][] temp_result = { 
      {
        0
      }
      , {
        0
      }
      , {
        0
      }
      , {
        0
      }
    };

    for (int i = 0; i < 4; i++) // Les 4 lignes
    {
      for (int j = 0; j < 4; j++) // les 4 colonnes
      {
        temp_result[i][0] += Adk[i][j]*XDebutTriche[j][0] ;
      }
    }

    print("\ntemp_result pour y \n");
    Mat.print(temp_result, 5);

    y[0][0] -= temp_result[0][0];
    y[1][0] -= temp_result[1][0];
    y[2][0] -= temp_result[2][0];
    y[3][0] -= temp_result[3][0];

    // On a y.

    print("\ny\n");
    Mat.print(y, 5)
    ;
    float[][] Gt = new float[2*h][4];

    for (int i = 0; i < 2*h; i++) // 2*h lignes dans la matrice transposée
      for (int j = 0; j < 4; j++ ) // et 4 colonnes
        Gt[i][j] = G[j][i];

    print("\nGt!\n");
    Mat.print(Gt, 5);

    // Derniere etape: code scilab : u = (Gt * inv(G * Gt)) * y; 

    // U, la matrice des vecteurs de commande qui remplacent a
    // Gt * inv(G * Gt)

    float[][] GxGt = new float[4][4];

    for (int i = 0; i < 4; i++) // Les 4 lignes
    {
      for (int j = 0; j < 4; j++) // les 4 colonnes
      {
        //java.math.BigDecimal sum = new java.math.BigDecimal("0");
        // à chaque étape, 
        float sum = 0.0;
        for (int p = 0; p < 2*h; p++)
        {
          sum += G[i][p]*Gt[p][j];
        }
        GxGt[i][j] = sum;
      }
    }

    // Bon jusqu'ici !!

    print("\nGxGt!\n");
    Mat.print(GxGt, 6);
    // On fait l'inverse de ce truc infame (et dieu merci papaya le fait)

    float[][] invGxGt = Mat.inverse(GxGt);

    print("\ninvGxGt!\n");
    Mat.print(invGxGt, 5);
    //  Gt*invGxGt
    float[][] GtxinvGxGt = new float[2*h][4];

    for (int i = 0; i < 2*h; i++) // Les 2*h lignes
    {
      for (int j = 0; j < 4; j++) // les 4 colonnes
      {
        float sum = 0;
        // à chaque étape, 
        for (int p = 0; p < 4; p++)
        {
          sum += Gt[i][p]*invGxGt[j][p];
        }
        GtxinvGxGt[i][j] = sum;
      }
    }

    print("\nGtinvGxGt!\n");
    Mat.print(GtxinvGxGt, 5);
    // ça marche !!

    // Plus qu'à faire tout ça *y
    float[][] u = new float[2*h][1];

    for (int i = 0; i < 2*h; i++) // Les 2*h lignes
    {
      float sum = 0;
      // à chaque étape, 
      for (int p = 0; p < 4; p++)
      {
        sum += GtxinvGxGt[i][p]*y[p][0];
      }
      u[i][0] = sum;
    }

    print("\nu!\n");
    Mat.print(u, 5);

  // TODO: dire que là on a pas la rgavité hein ! si on la rajoute dans scilab faut aussi la rajouter ici

  for(int k = 0 ; k < h*2 ; k+=2)
  {
    u[k][0] -= gterre;
  } 


    // ************************************************************************Plus qu'à balance
        // Initialisation du prochain vecteur à calculer
    float[][] Xsuivant = {  
      {
        0
      }
      , 
      {
        0
      }
      , 
      {
        0
      }
      , 
      {
        0
      }
    };
    
        // Le X précédent
    float[][] X = new float[4][1];
    
   X[0][0] = XDebutTriche[0][0]; // Le X d'avant
   X[1][0] = XDebutTriche[1][0]; // Le X d'avant
   X[2][0] = XDebutTriche[2][0]; // Le X d'avant
   X[3][0] = XDebutTriche[3][0]; // Le X d'avant

    // Stockage des premières valeurs
    coordonnees_trajectoire_x_triche[0] = X[0][0]; // x
    coordonnees_trajectoire_y_triche[0] = X[2][0]; // y

    instant_t = temps;
    for(int k = 0 ; k < h ; k++) 
    {
      // on réinitialise Xsuivant avant de ré-itérer la boucle
      Xsuivant[0][0] = 0;
      Xsuivant[1][0] = 0;
      Xsuivant[2][0] = 0;
      Xsuivant[3][0] = 0;

      instant_t++;

      // Produit matriciel inspiré de celui du code Scilab

      for (int i = 0; i < 4; i++) // Les 4 lignes
      {
        for (int j = 0; j < 4; j++) // les 4 colonnes
        {
          Xsuivant[i][0] += Ad[i][j]*X[j][0] ;//+ Bd*a;
        }
      }
      
      float[][] vecteur_commande = new float[2][1];
      
      vecteur_commande[0][0] = u[k][0];
      
      if(k != 0)
      vecteur_commande[1][0] = u[2*k][0];
      else
      vecteur_commande[1][0] = u[1][0]; // Cas particulier TODO faire propre!
      
      for (int i = 0; i < 4; i++) // ajout du terme Bd*a;
      {
        for (int j = 0; j < 2; j++)
        {

          Xsuivant[i][0] += Bd[i][j]*vecteur_commande[j][0];
        }
      }

      // L'ancien X devient le nouveau X.
      X[0][0] = Xsuivant[0][0];
      X[1][0] = Xsuivant[1][0];
      X[2][0] = Xsuivant[2][0];
      X[3][0] = Xsuivant[3][0];
      
        
    // Attention, ici maintenant on bosse avec le vrai temps ! du jeu ! eh ouais ! voir si on peut pas améliorer ça quand même..
          // Stockage des nouvelles coordonnées de trajectoire
      coordonnees_trajectoire_x_triche[instant_t] = Xsuivant[0][0];
      coordonnees_trajectoire_y_triche[instant_t] = Xsuivant[2][0];
      
      print(coordonnees_trajectoire_x_triche[instant_t], ",");
      print(coordonnees_trajectoire_y_triche[instant_t], "\n");
      print("X a atteindre!", Xh[0][0], "\n");
      //if ( X[2][0] > 0 ) // Tant que la position en y est supérieure à 0 (par encore par terre)
        //break;
    }
    
    
  }  // Fin  de méthode
  
  // TODO : convertir les X en matrices avec toutes les valeurs ? ou osef ?
}

