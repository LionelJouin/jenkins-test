node {
    image_names = params.IMAGE_NAMES.split(' ')
    version = params.IMAGE_VERSION
    stage ('Debug') {
        sh 'printenv'
    }
    stage ('Verify') {
        Verify().call()
    }
    stage ('Base Image') {
        BaseImage(version).call()
    }
    stage ('Images') {
        Images(image_names, version).call()
    }
    stage ('E2E') {
        e2e().call()
    }
}

def Verify() {
    return {
        def stages = [:]
        stages['Unit Tests'] = {
            UnitTests().call()
        }
        stages['Linter'] = {
            Linter().call()
        }
        stages['Generated code verification'] = {
            GeneratedCode().call()
        }
        parallel(stages)
    }
}

def UnitTests() {
    return {
        stage('Unit Tests') {
            echo 'make test'
        }
    }
}

def Linter() {
    return {
        stage('Linter') {
            echo 'make lint'
        }
    }
}

def GeneratedCode() {
    return {
        stage('go generate ./...') {
            echo 'make generate'
        }
        stage('Proto') {
            echo 'make proto'
        }
    }
}

def BaseImage(version) {
    sh """#!/bin/bash
        echo "version"
        echo "version: ${version}"
        echo "version: ${version}"
    """
    sh "echo 'version: ${version}'"
    setBuildStatus('Build complete', 'SUCCESS')
    return {
        echo 'Build base-image version: ${version}...'
    }
}

def Images(images, version) {
    return {
        def stages = [:]
        for (i in images) {
            stages[i] = {
                build(i, version).call()
            }
        }
        parallel(stages)
    }
}

def build(images, version) {
    sh "echo '${images}:${version}'"
    return {
        stage('Build/Tag/Push') {
            echo 'make build'
        }
    }
}

def e2e() {
    return {
        stage('E2E') {
            echo 'make e2e'
        }
    }
}

// https://plugins.jenkins.io/github/#plugin-content-pipeline-examples
void setBuildStatus(String message, String state) {
    step([
      $class: 'GitHubCommitStatusSetter',
      reposSource: [$class: 'ManuallyEnteredRepositorySource', url: 'https://github.com/LionelJouin/jenkins-test'],
      contextSource: [$class: 'ManuallyEnteredCommitContextSource', context: 'ci/jenkins/build-status'],
      errorHandlers: [[$class: 'ChangingBuildStatusErrorHandler', result: 'UNSTABLE']],
      statusResultSource: [ $class: 'ConditionalStatusResultSource', results: [[$class: 'AnyBuildResult', message: message, state: state]] ]
  ])
}

// pipeline {
//     agent any

//     stages {
//         stage('Verify') {
//             steps {
//                 script {
//                     // Verify().call()
//                     makeStage().call()
//                 }
//             }
//         }
//     // stage('Build/tag/push base image') {
//     //     steps {
//     //         echo 'build base image...'
//     //     }
//     // }
//     // stage('Build/tag/push') {
//     //     parallel {
//     //         stage('Load-Balancer') {
//     //             steps {
//     //                 echo 'protoc...'
//     //             }
//     //         }
//     //     }
//     // }
//     }
// }

// def makeStage() {
//     return {
//         stage('a') {
//             echo 'Hello World'
//         }
//     }
// }

// def Verify() {
//     return {
//         stage('Verify') {
//             parallel {
//                 stage('Test On Windows') {
//                     steps {
//                         echo 'Unit tests + Cover...'
//                     }
//                 }
//             }
//         }
//     }
// }

// pipeline {
//     agent any

//     stages {
//         stage('Verify') {
//             steps {
//                 // makeStage()
//                 script {
//                     makeStage().call()
//                 }
//             }
//         }
//     }
// }

// def Verify() {
//     stage('Verify') {
//         parallel {
//             UnitTests()
//             Linter()
//             GeneratedCode()
//         }
//     }
// }

// def makeStage = {
//     return {
//         stage('a') {
//             echo 'Hello World'
//         }
//     }
// }

// def Verify() {
//     return {
//         parallel {
//             stage('Test On Windows') {
//                 steps {
//                     echo 'Test On Windows...'
//                 }
//             }
//         }
//     }
// }

// def Verify() {
//     stages {
//         parallel {
//             stage('Unit Tests') {
//                 UnitTests()
//             }
//             stage('Linter') {
//                 Linter()
//             }
//             stage('Generated code verification') {
//                 GeneratedCode()
//             }
//         }
//     }
// }

// def UnitTests() {
//     stage('Unit Tests') {
//         steps {
//             stages {
//                 stage('Run') {
//                     steps {
//                         echo 'Unit tests + Cover...'
//                     }
//                 }
//             }
//         }
//     }
// }

// def Linter() {
//     stage('Linter') {
//         steps {
//             stages {
//                 stage('Run') {
//                     steps {
//                         echo 'Linter...'
//                     }
//                 }
//             }
//         }
//     }
// }

// def GeneratedCode() {
//     stage('Generated code verification') {
//         steps {
//             stages {
//                 stage('go generate ./...') {
//                     steps {
//                         echo 'make generate...'
//                     }
//                 }
//                 stage('proto') {
//                     steps {
//                         echo 'protoc...'
//                     }
//                 }
//             }
//         }
//     }
// }

// ---------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------

// pipeline {
//     agent any

//     stages {
//         stage('Verify') {
//             parallel {
//                 stage('Unit Tests') {
//                     stages {
//                         stage('Unit Tests') {
//                             steps {
//                                 echo 'Unit tests + Cover...'
//                             }
//                         }
//                     }
//                 }
//                 stage('Linter') {
//                     steps {
//                         echo 'Linter...'
//                     }
//                 }
//                 stage('Generated code verification') {
//                     stages {
//                         stage('go generate ./...') {
//                             steps {
//                                 echo 'make generate...'
//                             }
//                         }
//                         stage('proto') {
//                             steps {
//                                 echo 'protoc...'
//                             }
//                         }
//                     }
//                 }
//             }
//         }
//         stage('Build/tag/push base image') {
//             steps {
//                 echo 'build base image...'
//             }
//         }
//         stage('Build/tag/push') {
//             parallel {
//                 stage('Load-Balancer') {
//                     steps {
//                         echo 'protoc...'
//                     }
//                 }
//             }
//         }
//     }
// }
