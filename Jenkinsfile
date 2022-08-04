pipeline {
  agent any

  stages {
    stage("test") {
      steps {
        sh "./test.sh"
      }
    }
    stage("Build") {
      steps {
        sh "./build.sh"
      }
    }
  }

}