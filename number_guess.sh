#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~~~~~~ Number Guessing Game ~~~~~~~\n"

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
echo $SECRET_NUMBER

echo "Enter your username:"
read USERNAME

USERNAME_EXISTENCE=$($PSQL "select username from players where username='$USERNAME'")
GAME_PLAYED=$($PSQL "select games_played from players where username='$USERNAME'")
GAME_BEST=$($PSQL "select best_game from players where username='$USERNAME'")
NUMBER_GAMES=$($PSQL "select number_games_played from players where username='$USERNAME'")


if [[ -z $GAME_PLAYED ]]
then 
GAME_PLAYED=0
fi 

if [[ -z $GAME_BEST ]]
then 
GAME_BEST=0
fi

if [[ -z $NUMBER_GAMES ]]
then 
NUMBER_GAMES=0
fi

if [[ -z $USERNAME_EXISTENCE ]]
then 
  INSERT_USERNAME=$($PSQL "insert into players(username,games_played,best_game,number_games_played) values('$USERNAME',$GAME_PLAYED,$GAME_BEST,$NUMBER_GAMES)")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
  echo "Guess the secret number between 1 and 1000:"
  read GUESSED_NUMBER
      while [[ ! $GUESSED_NUMBER =~ ^[0-9]+$ ]]
      do 
         echo -e "\nThat is not an integer, guess again:"
         read GUESSED_NUMBER
      done
      GAME_PLAYED=0
       while [[ $GUESSED_NUMBER -ne $SECRET_NUMBER ]]
      do 
         if [[ $GUESSED_NUMBER -lt $SECRET_NUMBER ]]
         then 
          echo -e "\nIt's higher than that, guess again:"
          GAME_PLAYED=`expr $GAME_PLAYED + 1`
          else
          echo -e "\nIt's lower than that, guess again:"
          GAME_PLAYED=`expr $GAME_PLAYED + 1`
         fi
          read GUESSED_NUMBER
      done
      if [[ $GUESSED_NUMBER -eq $SECRET_NUMBER ]]
      then
          GAME_PLAYED=`expr $GAME_PLAYED + 1`
          GAME_BEST=$GAME_PLAYED
          NUMBER_GAMES=`expr $NUMBER_GAMES + 1`
      UPDATE_GAME=$($PSQL "update players set games_played=$NUMBER_GAMES, best_game=$GAME_BEST, number_games_played=$NUMBER_GAMES where username='$USERNAME'")
        echo -e "\nYou guessed it in $GAME_PLAYED tries. The secret number was $SECRET_NUMBER. Nice job!"
         fi
else 
    GAME_PLAYED_PREV=$($PSQL "select games_played from players where username='$USERNAME'")
    GAME_BESTPREV=$($PSQL "select best_game from players where username='$USERNAME'")
    echo -e "\nWelcome back, $USERNAME! You have played $NUMBER_GAMES games, and your best game took $GAME_BESTPREV guesses."
    echo "Guess the secret number between 1 and 1000:"
    read GUESSED_NUMBER
      while [[ ! $GUESSED_NUMBER =~ ^[0-9]+$ ]]   
      do 
         echo -e "\nThat is not an integer, guess again:"
         read GUESSED_NUMBER
      done
      GAME_PLAYED=0
       while [[ $GUESSED_NUMBER -ne $SECRET_NUMBER ]]
      do 
         if [[ $GUESSED_NUMBER -lt $SECRET_NUMBER ]]
         then 
          echo -e "\nIt's higher than that, guess again:"
          GAME_PLAYED=`expr $GAME_PLAYED + 1`
          else
          echo -e "\nIt's lower than that, guess again:"
          GAME_PLAYED=`expr $GAME_PLAYED + 1`
         fi
          read GUESSED_NUMBER
      done
      if [[ $GUESSED_NUMBER -eq $SECRET_NUMBER ]]
      then
          GAME_PLAYED=`expr $GAME_PLAYED + 1`
          GAME_BEST_PREV=$($PSQL "select best_game from players where username='$USERNAME_EXISTENCE'")
            if [[ $GAME_BEST_PREV -lt $GAME_PLAYED ]] 
              then 
              GAME_BEST=$GAME_BEST_PREV 
               else 
              GAME_BEST=$GAME_PLAYED
            fi
              NUMBER_GAMES=`expr $NUMBER_GAMES + 1`  
   UPDATE_GAME=$($PSQL "update players set games_played=$GAME_PLAYED, best_game=$GAME_BEST, number_games_played=$NUMBER_GAMES where username='$USERNAME'")
   echo -e "\nYou guessed it in $GAME_PLAYED tries. The secret number was $SECRET_NUMBER. Nice job!"
         fi
fi

