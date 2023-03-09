PSQL="psql --username=postgres --dbname=periodic_table -t --no-align -c"

if [[ $# -eq 0 ]]
then
  echo Please provide an element as an argument.
else
  # arguments has been provided
  USER_INPUT=$1

  # try as atomic_number
  regexNum='^[0-9]+$'
  if [[ $USER_INPUT =~ $regexNum ]]
  then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1")
  else
    # try as symbol
    regexSym='^[A-Za-z]{1,2}$'
    if [[ $USER_INPUT =~ $regexSym ]]
    then
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1'")
      # try as name
    else
      regexName='^[A-Z][a-z]*$'
      if [[ $USER_INPUT =~ $regexName ]]
      then
        ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$1'")
      fi
    fi
  fi  

  if [[ -z $ATOMIC_NUMBER ]]
  then
    # the given request does not fit any element
    echo I could not find that element in the database.
  else
    NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
    TYPE=$($PSQL "SELECT type FROM types LEFT JOIN properties USING(type_id) WHERE atomic_number = $ATOMIC_NUMBER")
    MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
    MELTING=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
    BOILING=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  fi
fi