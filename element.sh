#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"

PRINT_QUERY() {
	if [[ $1 ]]
	then 
		echo "$1" | while IFS='|' read ATOMIC_NUMBER SYMBOL NAME TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT
		do
			echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
		done
	fi
}

if [[ $1 ]]
then
  ATOMIC_NUMBER=0
	SYMBOL=''
	NAME=''
	
	if [[ $1 =~ ^[0-9]*$ ]]
	then
		ATOMIC_NUMBER=$1
		SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
		NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
		
	elif [[ $1 =~ ^[A-Z][a-z]$|^[A-Z]$ ]]
	then
		SYMBOL=$1
		NAME=$($PSQL "SELECT name FROM elements WHERE symbol='$SYMBOL'");
		ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$SYMBOL'");
	
	elif [[ $1 =~ ^[A-Z][a-z]* ]]
	then
		NAME=$1
		SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name='$NAME'")
		ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$NAME'")
		
	fi

  if [[ -z $ATOMIC_NUMBER || -z $NAME || -z $SYMBOL ]]
	then 		
		echo "I could not find that element in the database."
	else
		Query=$($PSQL "SELECT elements.atomic_number, symbol, name, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER")
		PRINT_QUERY $Query
	fi
	
else
	echo "Please provide an element as an argument."
fi
