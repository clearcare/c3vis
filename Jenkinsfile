pipeline {
  // Run on dynamially generated instance:
  agent { label 'eod-us-west-2' }
  // Parameters:
  // Run the the stages:
  stages {
    stage('Build') {
      steps {
        timestamps {
          ansiColor('xterm') {
            sh 'build/jenkins_build.sh'
            script {
              OUTPUT = sh (
                  script: 'cat jenkins.tag',
                  returnStdout: true
              ).trim()
            }
            script {
              currentBuild.description = "${OUTPUT}"
            }
          }
        }
      }
    }
  }
}
