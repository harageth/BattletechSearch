# Requirements
1. PostgresSQL installed
1. Manually create the 'battletechSearch' database using this command: `createdb -U username -W battletechSearch`
1. in the `/src/main/resources/application.yml` file, set your username and password for postgres
1. maven installed
1. checkout megamek source code `git clone git@github.com:MegaMek/megamek.git`
1. in the UnitService.persistUnits replace the filepath to the mech files with your path to those same files
1. import the `bt-search-insomnia.json` into insomnia

# starting the application
I'll get to this soon...
This is the general way of doing it... I do everything through intellij ultimate which automates it all for me.
mvn antlr4
mvn compile
mvn spring-boot:run