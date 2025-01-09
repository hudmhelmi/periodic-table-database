#!/bin/bash

# allow querying periodic_table database
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# if run without arguments, output err msg and exit
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit 0
fi

# fetch atomic numbers, symbols, and names
RESULT=$($PSQL "SELECT atomic_number, symbol, name FROM elements")

# loop through and match argument
while IFS='|' read -r ATOMIC_NUMBER SYMBOL NAME
do
  if [[ $1 == "$ATOMIC_NUMBER" || $1 == "$SYMBOL" || $1 == "$NAME" ]]
  then
    # get properties of matched element using FULL JOIN with USING
    PROPERTIES=$($PSQL "
      SELECT elements.atomic_number, elements.name, elements.symbol, types.type, 
             properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius
      FROM elements
      FULL JOIN properties USING (atomic_number)
      FULL JOIN types USING (type_id)
      WHERE elements.atomic_number = $ATOMIC_NUMBER OR elements.symbol = '$SYMBOL' OR elements.name = '$NAME';
    ")

    # format and output details of the element
    IFS='|' read -r ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING_POINT BOILING_POINT <<< "$PROPERTIES"
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    exit 0
  fi
done <<< "$RESULT"

echo "I could not find that element in the database."
exit 0
