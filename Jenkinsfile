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
            sh 'printenv'
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

def Verify() {
    return {
        def stages = [:]
        stages.put('Unit Tests', UnitTests())
        stages.put('Linter', Linter())
        stages.put('Generated code verification', GeneratedCode())
        parallel(stages)
    }
}

def UnitTests() {
    return {
        def context = 'Unit Tests'
        stage('Unit Tests') {
            try {
                SetBuildStatus(in_progress, context, pending)
                echo 'make test' // todo
                SetBuildStatus(completed, context, success)
            } catch (Exception e) {
                SetBuildStatus(failed, context, failure)
                Error(e).call()
            }
        }
    }
}

def Linter() {
    return {
        def context = 'Linter'
        stage('Linter') {
            try {
                SetBuildStatus(in_progress, context, pending)
                echo 'make lint' // todo
                SetBuildStatus(completed, context, success)
            } catch (Exception e) {
                SetBuildStatus(failed, context, failure)
                Error(e).call()
            }
        }
    }
}

def GeneratedCode() {
    return {
        def context = 'Generated code verification'
        def exception_message = 'Generated code verification failed'
        SetBuildStatus(in_progress, context, pending)
        stage('go mod tidy') {
            try {
                echo 'go mod tidy' // todo
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
                echo 'make generate' // todo
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
            try {
                echo 'make proto' // todo
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
        SetBuildStatus(completed, context, success)
    }
}

def BaseImage(version, build_steps, registry, local_version) {
    return {
        Build(base_image, version, build_steps, registry, local_version).call()
    }
}

def Images(images, version, build_steps, registry, local_version) {
    return {
        def stages = [:]
        for (i in images) {
            stages.put(i, Build(i, version, build_steps, registry, local_version))
        }
        parallel(stages)
    }
}

def Build(image, version, build_steps, registry, local_version) {
    return {
        stage("${image} (${version}): ${build_steps}") {
            def context = "Image: ${image}"
            def in_progress_message = "${in_progress} (${build_steps})"
            def completed_message = "${completed} (${build_steps})"
            def failed_message = "${failed} (${build_steps})"
            try {
                SetBuildStatus(in_progress_message, context, pending)
                echo "make ${image} VERSION=${version} BUILD_STEPS='${build_steps}' REGISTRY=${registry} LOCAL_VERSION=${local_version} BASE_IMAGE=${base_image}:${local_version}" // todo
                SetBuildStatus(completed_message, context, success)
            } catch (Exception e) {
                SetBuildStatus(failed_message, context, failure)
                Error(e).call()
            }
        }
    }
}

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

def Error(e) {
    return {
        echo 'make lint'
        Cleanup()
        error e
    }
}

def Cleanup() {
    cleanWs()
}

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

def GetCommitSha() {
    sh 'git rev-parse HEAD > .git/current-commit'
    return readFile('.git/current-commit').trim()
}

def GetModifiedFiles() {
    sh 'git status -s > .git/current-modified-files'
    return readFile('.git/current-modified-files').trim()
}
