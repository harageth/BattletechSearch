# Requirements
1. PostgresSQL installed
1. Manually create the 'battletechSearch' database using this command: `createdb -U username -W battletechSearch`
1. in the `/src/main/resources/application.yml` file, set your username and password for postgres
1. repeat the above step in the `pom.xml` just find where the password is set and replace the username and password in there (I will eventually set those to env variables but right now it doesn't matter)
1. maven installed
1. checkout megamek source code `git clone git@github.com:MegaMek/megamek.git`
1. in the UnitService.persistUnits replace the filepath to the mech files with your path to those same files
1. import the `bt-search-insomnia.json` into insomnia (ignore the Read Files endpoint)

# starting the application
I'll get to this soon...
This is the general way of doing it... I do everything through intellij ultimate which automates it all for me.
1. `mvn antlr4:antlr4`
1. `mvn compile`
1. `mvn spring-boot:run`
