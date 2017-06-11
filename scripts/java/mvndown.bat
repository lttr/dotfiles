@REM Downloads maven artifact directly into the current directory, places its dependencies into ./lib directory.
@REM Leaves artifact's pom.xml in the current dir.
@REM Usage: mvndown [groupId] [artifactId] [version]

@echo off
call mvn org.apache.maven.plugins:maven-dependency-plugin:2.8:copy -Dmdep.useBaseVersion=true -DoutputDirectory=. -Dartifact=%1:%2:%3
call mvn org.apache.maven.plugins:maven-dependency-plugin:2.8:copy -Dmdep.stripVersion=true  -DoutputDirectory=. -Dartifact=%1:%2:%3:pom
call mvn -f %2.pom org.apache.maven.plugins:maven-dependency-plugin:2.8:copy-dependencies -DoutputDirectory=lib
