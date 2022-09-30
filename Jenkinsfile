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
        sh "echo '${currentBuild.number}'"
        sh "echo '${currentBuild.result}'"
        sh "echo '${currentBuild.currentResult}'"
        sh "echo '${currentBuild.displayName}'"
        sh "echo '${currentBuild.fullDisplayName}'"
        sh "echo '${currentBuild.projectName}'"
        sh "echo '${currentBuild.fullProjectName}'"
        sh "echo '${currentBuild.description}'"
        sh "echo '${currentBuild.id}'"
        sh "echo '${currentBuild.timeInMillis}'"
        sh "echo '${currentBuild.startTimeInMillis}'"
        sh "echo '${currentBuild.duration}'"
        sh "echo '${currentBuild.durationString}'"
        sh "echo '${currentBuild.previousBuild}'"
        sh "echo '${currentBuild.previousBuildInProgress}'"
        sh "echo '${currentBuild.previousBuiltBuild}'"
        sh "echo '${currentBuild.previousCompletedBuild}'"
        sh "echo '${currentBuild.previousFailedBuild}'"
        sh "echo '${currentBuild.previousNotFailedBuild}'"
        sh "echo '${currentBuild.previousSuccessfulBuild}'"
        sh "echo '${currentBuild.nextBuild}'"
        sh "echo '${currentBuild.absoluteUrl}'"
        sh "echo '${currentBuild.buildVariables}'"
        sh "echo '${currentBuild.changeSets}'"
        sh "echo '${currentBuild.upstreamBuilds}'"
        sh "echo '${currentBuild.keepLog}'"
      }
    }

  }
}
