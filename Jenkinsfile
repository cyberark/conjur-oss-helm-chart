#!/usr/bin/env groovy

import groovy.transform.Field

@Field
def TAG = ""

pipeline {
  agent { label 'conjur-enterprise-common-agent' }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '30'))
  }

  triggers {
    cron(getDailyCronString())
  }

  stages {

    stage('Get InfraPool Agent') {
      steps {
        script {
          INFRAPOOL_EXECUTORV2_AGENT_0 = getInfraPoolAgent.connected(type: "ExecutorV2", quantity: 1, duration: 1)[0]
        }
      }
    }

    stage('Changelog') {
      steps {
        parseChangelog(INFRAPOOL_EXECUTORV2_AGENT_0)
      }
    }

    stage('GKE Build and Test') {
      environment {
        HELM_VERSION = "3.1.3"
      }
      steps {
        script {
          INFRAPOOL_EXECUTORV2_AGENT_0.agentSh 'cd ci && summon ./jenkins_build.sh'
        }
      }
    }
  }

  post {
    always {
      releaseInfraPoolAgent(".infrapool/release_agents")
    }
  }
}
