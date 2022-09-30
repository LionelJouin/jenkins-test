pipeline {
  agent any
  stages {
    stage('Build') {
      parallel {
        stage('Build') {
          steps {
            sh './build.sh'
          }
        }

        stage('j') {
          steps {
            sh 'echo "koukou"'
          }
        }

      }
    }

    stage('printenv') {
      steps {
        sh 'printenv'
      }
    }

  }
}