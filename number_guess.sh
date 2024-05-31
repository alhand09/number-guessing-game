#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Ask for username
echo -e "Enter your username:"
read USERNAME

# Check if the user exists
USER_EXISTS=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
# Pull previous data
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")

# Does username exist?
if [[ -z $USER_EXISTS ]]
then
    # Doesn't exist
    echo -e "Welcome, $USERNAME! It looks like this is your first time here."
    # Add to database
    INSERT_USERNAME=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 1000)")
    GAMES_PLAYED=0
    BEST_GAME=1000
else
    # Username exists
    echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))

# Start guessing
echo -e "Guess the secret number between 1 and 1000:"

NUMBER_OF_GUESSES=0
while true
do
    read GUESS
    # Check if the input is an integer
    if ! [[ $GUESS =~ ^[0-9]+$ ]]
    then
        echo -e "That is not an integer, guess again:"
        continue
    fi

    ((NUMBER_OF_GUESSES++))
    if [[ $GUESS -gt $SECRET_NUMBER ]]
    then
        echo -e "It's lower than that, guess again:"
    elif [[ $GUESS -lt $SECRET_NUMBER ]]
    then
        echo -e "It's higher than that, guess again:"
    else
        echo -e "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
        break
    fi
done

# Update the user's data
NEW_GAMES_PLAYED=$(($GAMES_PLAYED + 1))
if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
then
    NEW_BEST_GAME=$NUMBER_OF_GUESSES
else
    NEW_BEST_GAME=$BEST_GAME
fi

UPDATE_USER_TOTALS=$($PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED, best_game=$NEW_BEST_GAME WHERE username='$USERNAME'")
