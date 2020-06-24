#!/usr/bin/env groovy

import groovy.transform.Field

@Field
def TAG = ""

pipeline {
  agent { label 'executor-v2' }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '30'))
  }

  triggers {
    cron(getDailyCronString())
  }

  stages {

    stage('GKE Build and Test') {
      environment {
        HELM_VERSION = "3.1.3"
      }
      steps {
        sh 'cd ci && summon ./jenkins_build.sh'
      }
    }
  }

  post {
    always {
      cleanupAndNotify(currentBuild.currentResult)
    }
  }
}
