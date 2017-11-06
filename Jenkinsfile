pipeline {
   agent {
       docker {
           image 'praqma/native-gradle'
           args '-v $HOME/.m2:/home/jenkins/.m2 -v $HOME/.gradle:/home/jenkins/.gradle'
       }
   }
   stages {
      stage ('Clean'){
            steps {
                sh './gradlew clean'
            }
        }
        stage ('Increment version'){
            steps {
                sh './gradlew incrementVersion'
            }
        }
      stage ('Build'){
         steps{
             sh './gradlew publish'
         }
      }
      stage ('Results'){
         steps{
             junit 'out/bin/results_junit.xml'
             archiveArtifacts 'build/distributions/*.zip'
         }
      }
   }
}
