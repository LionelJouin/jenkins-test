import org.jenkinsci.plugins.pipeline.modeldefinition.Utils

pending = 'PENDING'
success = 'SUCCESS'
failure = 'FAILURE'
base_image = 'base-image'
in_progress = 'In Progress.'
completed = 'Completed.'
failed = 'Failed'

node {
    def image_names = params.IMAGE_NAMES.split(' ')
    def version = params.IMAGE_VERSION
    def e2e_enabled = params.E2E_ENABLED
    def git_project = params.GIT_PROJECT
    def current_branch = params.CURRENT_BRANCH
    def default_branch = params.DEFAULT_BRANCH
    def build_steps = params.BUILD_STEPS

    // stage ('Debug') {
    //     sh 'printenv'
    // }
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
        BaseImage(version, build_steps).call()
    }
    stage ('Images') {
        Images(image_names, version, build_steps).call()
    }
    stage ('E2E') {
        E2e(e2e_enabled).call()
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
                error e
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
                error e
            }
        }
    }
}

def GeneratedCode() {
    return {
        def context = 'Generated code verification'
        try {
            SetBuildStatus(in_progress, context, pending)
            stage('go generate ./...') {
                echo 'make generate' // todo
            }
            stage('Proto') {
                echo 'make proto' // todo
            }
            SetBuildStatus(completed, context, success)
        } catch (Exception e) {
            SetBuildStatus(failed, context, failure)
            error e
        }
    }
}

def BaseImage(version, build_steps) {
    return {
        Build(base_image, version, build_steps).call()
    }
}

def Images(images, version, build_steps) {
    return {
        def stages = [:]
        for (i in images) {
            stages.put(i, Build(i, version, build_steps))
        }
        parallel(stages)
    }
}

def Build(image, version, build_steps) {
    return {
        stage("${image} (${version}): ${build_steps}") {
            def context = "Image: ${image}"
            def pending_state = "${pending} - ${build_steps}"
            def success_state = "${pending} - ${build_steps}"
            def failure_state = "${pending} - ${build_steps}"
            try {
                SetBuildStatus(in_progress, context, pending_state)
                echo "make ${image} VERSION=${version} BUILD_STEPS='${build_steps}'" // todo
                SetBuildStatus(completed, context, success_state)
            } catch (Exception e) {
                SetBuildStatus(failed, context, failure_state)
                error e
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

// https://plugins.jenkins.io/github/#plugin-content-pipeline-examples
def SetBuildStatus(String message, String context, String state) {
    step([
        $class: 'GitHubCommitStatusSetter',
        reposSource: [$class: 'ManuallyEnteredRepositorySource', url: 'https://github.com/LionelJouin/jenkins-test'],
        commitShaSource: [$class: 'ManuallyEnteredShaSource', sha: getCommitSha()],
        contextSource: [$class: 'ManuallyEnteredCommitContextSource', context: context],
        errorHandlers: [[$class: 'ChangingBuildStatusErrorHandler', result: 'UNSTABLE']],
        statusResultSource: [ $class: 'ConditionalStatusResultSource', results: [[$class: 'AnyBuildResult', message: message, state: state]] ]
  ])
}

def getCommitSha() {
    sh 'git rev-parse HEAD > .git/current-commit'
    return readFile('.git/current-commit').trim()
}
