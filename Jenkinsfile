import org.jenkinsci.plugins.pipeline.modeldefinition.Utils

pending = 'PENDING'
success = 'SUCCESS'
failure = 'FAILURE'
base_image = 'base-image'
in_progress = 'In Progress.'
completed = 'Completed.'
failed = 'Failed'

node {
    build_number = env.BUILD_NUMBER
    workspace = env.WORKSPACE
    ws("${workspace}/${build_number}") {
        def image_names = params.IMAGE_NAMES.split(' ')
        def version = params.IMAGE_VERSION
        def e2e_enabled = params.E2E_ENABLED
        def git_project = params.GIT_PROJECT
        def current_branch = params.CURRENT_BRANCH
        def default_branch = params.DEFAULT_BRANCH
        def build_steps = params.BUILD_STEPS
        def image_registry = params.IMAGE_REGISTRY
        def local_version =  "${env.JOB_NAME}-${build_number}"

        stage ('Debug') {
            sh 'ls'
            sh 'pwd'
            env.PATH = "${env.PATH}:/usr/local/go/bin"
            env.HARBOR_USERNAME = ''
            env.HARBOR_PASSWORD = ''
            sh 'printenv'
            sh 'who'
            sh 'which go'
            sh 'go version'
        }
        stage ('Clone/Checkout') {
            git branch: default_branch, url: git_project
            checkout([
                $class: 'GitSCM',
                branches: [[name: current_branch]],
                extensions: [],
                userRemoteConfigs: [[
                    refspec: '+refs/pull/*/head:refs/remotes/origin/pr/*',
                    url: git_project
                ]]
            ])
            sh 'git show'
        }
        stage ('Verify') {
            Verify().call()
        }
        stage ('Docker login') {
            wrap([$class: 'MaskPasswordsBuildWrapper', varPasswordPairs: [[password: env.HARBOR_USERNAME, var: 'HARBOR_USERNAME'], [password: env.HARBOR_PASSWORD, var: 'HARBOR_PASSWORD'], [password: image_registry, var: 'IMAGE_REGISTRY']]]) {
                sh '''#!/bin/bash -eu
                echo ${HARBOR_PASSWORD} | docker login --username ${HARBOR_USERNAME} --password-stdin ${IMAGE_REGISTRY}
                '''
            }
        }
        stage ('Base Image') {
            BaseImage(version, build_steps, image_registry, local_version).call()
        }
        stage ('Images') {
            Images(image_names, version, build_steps, image_registry, local_version).call()
        }
        stage ('E2E') {
            E2e(e2e_enabled).call()
        }
        stage('Cleanup') {
            Cleanup()
        }
    }
}

// Static analysis: Runs the GeneratedCode function and then UnitTests and Linter in parallel
def Verify() {
    return {
        GeneratedCode().call() // cannot generate code and run the linter and tests at the same time
        // Linter().call()
        // UnitTests().call()
        def stages = [:]
        stages.put('Unit Tests', UnitTests())
        stages.put('Linter', Linter())
        // stages.put('Generated code verification', GeneratedCode())
        parallel(stages)
    }
}

// Runs the unit tests and set the github commit status
def UnitTests() {
    return {
        def context = 'Unit Tests'
        stage('Unit Tests') {
            try {
                SetBuildStatus(in_progress, context, pending)
                sh 'make test'
                SetBuildStatus(completed, context, success)
            } catch (Exception e) {
                SetBuildStatus(failed, context, failure)
                Error(e).call()
            }
        }
    }
}

// Runs the linter and set the github commit status
def Linter() {
    return {
        def context = 'Linter'
        stage('Linter') {
            try {
                SetBuildStatus(in_progress, context, pending)
                sh 'make lint'
                SetBuildStatus(completed, context, success)
            } catch (Exception e) {
                SetBuildStatus(failed, context, failure)
                Error(e).call()
            }
        }
    }
}

// Check if code has been generated correctly and set the github commit status:
// go.mod: runs "go mod tidy"
// go generate ./...: Code should be generated using "make genrate" command
// proto: skipped due to version of protoc
// If files are generated correctly then GetModifiedFiles function should return an empty string
def GeneratedCode() {
    return {
        def context = 'Generated code verification'
        def exception_message = 'Generated code verification failed'
        SetBuildStatus(in_progress, context, pending)
        stage('go mod tidy') {
            try {
                sh 'go mod tidy'
                if (GetModifiedFiles() != '') {
                    throw new Exception(exception_message)
                }
            } catch (Exception e) {
                SetBuildStatus(failed, context, failure)
                sh 'git diff'
                sh 'git status -s'
                Error(e).call()
            }
        }
        stage('go generate ./...') {
            try {
                sh 'make generate'
                if (GetModifiedFiles() != '') {
                    throw new Exception(exception_message)
                }
            } catch (Exception e) {
                SetBuildStatus(failed, context, failure)
                sh 'git diff'
                sh 'git status -s'
                Error(e).call()
            }
        }
        stage('Proto') {
            // TODO: protoc version could be different
            Utils.markStageSkippedForConditional('Proto')
        // try {
        //     sh 'make proto'
        //     if (GetModifiedFiles() != '') {
        //         throw new Exception(exception_message)
        //     }
        // } catch (Exception e) {
        //     SetBuildStatus(failed, context, failure)
        //     sh 'git diff'
        //     sh 'git status -s'
        //     Error(e).call()
        // }
        }
        SetBuildStatus(completed, context, success)
    }
}

def BaseImage(version, build_steps, registry, local_version) {
    return {
        Build(base_image, version, build_steps, registry, local_version).call()
    }
}

// Call Build function for every images in parallel
def Images(images, version, build_steps, registry, local_version) {
    return {
        def stages = [:]
        for (i in images) {
            stages.put(i, Build(i, version, build_steps, registry, local_version))
        }
        parallel(stages)
    }
}

// Build set the github commit status
def Build(image, version, build_steps, registry, local_version) {
    return {
        stage("${image} (${version}): ${build_steps}") {
            def context = "Image: ${image}"
            def in_progress_message = "${in_progress} (${build_steps})"
            def completed_message = "${completed} (${build_steps})"
            def failed_message = "${failed} (${build_steps})"
            try {
                SetBuildStatus(in_progress_message, context, pending)
                sh "make ${image} VERSION=${version} BUILD_STEPS='${build_steps}' REGISTRY=${registry} LOCAL_VERSION=${local_version} BASE_IMAGE=${base_image}:${local_version}"
                SetBuildStatus(completed_message, context, success)
            } catch (Exception e) {
                SetBuildStatus(failed_message, context, failure)
                Error(e).call()
            }
        }
    }
}

// Run the E2e Tests
// Currently skipped
def E2e(e2e_enabled) {
    if (e2e_enabled == 'true') {
        return {
            echo 'make e2e' // todo
        }
    } else {
        return {
            Utils.markStageSkippedForConditional('E2E')
        }
    }
}

// Raise error in Jenkins job
def Error(e) {
    return {
        Cleanup()
        error e
    }
}

// Cleanup directory
def Cleanup() {
    cleanWs()
}

// Set the commit status on Github
// https://plugins.jenkins.io/github/#plugin-content-pipeline-examples
def SetBuildStatus(String message, String context, String state) {
    step([
        $class: 'GitHubCommitStatusSetter',
        reposSource: [$class: 'ManuallyEnteredRepositorySource', url: 'https://github.com/LionelJouin/jenkins-test'],
        commitShaSource: [$class: 'ManuallyEnteredShaSource', sha: GetCommitSha()],
        contextSource: [$class: 'ManuallyEnteredCommitContextSource', context: context],
        errorHandlers: [[$class: 'ChangingBuildStatusErrorHandler', result: 'UNSTABLE']],
        statusResultSource: [ $class: 'ConditionalStatusResultSource', results: [[$class: 'AnyBuildResult', message: message, state: state]] ]
  ])
}

// Return the current commit sha
def GetCommitSha() {
    return sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
}

// Returns if any files has been modified/added/removed
def GetModifiedFiles() {
    return sh(script: 'git status -s', returnStdout: true).trim()
}
