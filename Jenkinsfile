import org.jenkinsci.plugins.pipeline.modeldefinition.Utils

pending = 'PENDING'
success = 'SUCCESS'
failure = 'FAILURE'
base_image = 'base-image'
in_progress = 'In Progress.'
completed = 'Completed.'
failed = 'Failed'

node {
    image_names = params.IMAGE_NAMES.split(' ')
    version = params.IMAGE_VERSION
    e2e_enabled = params.E2E_ENABLED
    git_project = params.GIT_PROJECT
    current_branch = params.CURRENT_BRANCH
    build_steps = params.BUILD_STEPS

    stage ('Clone') {
        git branch: current_branch, url: git_project
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
        e2e(e2e_enabled).call()
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
    context = 'Unit Tests'
    return {
        stage('Unit Tests') {
            try {
                setBuildStatus(in_progress, context, pending)
                echo 'make test' // todo
                setBuildStatus(completed, context, success)
            } catch (Exception e) {
                setBuildStatus(failed, context, failure)
                error e
            }
        }
    }
}

def Linter() {
    context = 'Linter'
    return {
        stage('Linter') {
            try {
                setBuildStatus(in_progress, context, pending)
                echo 'make lint' // todo
                setBuildStatus(completed, context, success)
            } catch (Exception e) {
                setBuildStatus(failed, context, failure)
                error e
            }
        }
    }
}

def GeneratedCode() {
    context = 'Generated code verification'
    return {
        try {
            setBuildStatus(in_progress, context, pending)
            stage('go generate ./...') {
                echo 'make generate' // todo
            }
            stage('Proto') {
                echo 'make proto' // todo
            }
            setBuildStatus(completed, context, success)
        } catch (Exception e) {
            setBuildStatus(failed, context, failure)
            error e
        }
    }
}

def BaseImage(version, build_steps) {
    context = "${base_image}: ${build_steps}"
    return {
        try {
            setBuildStatus(in_progress, context, pending)
            echo "Build base-image version: ${version}..."
            echo "make ${base_image} VERSION=${version} BUILD_STEPS=${build_steps}"
            setBuildStatus(completed, context, success)
        } catch (Exception e) {
            // echo "Exception occurred: " + e
            // sh "Handle the exception!"
            setBuildStatus(failed, context, failure)
            error e
        }
    }
}

def Images(images, version, build_steps) {
    return {
        def stages = [:]
        for (i in images) {
            stages[i] = {
                build(i, version, build_steps).call()
            }
        }
        parallel(stages)
    }
}

def build(image, version, build_steps) {
    context = "${image}: ${build_steps}"
    return {
        stage("${image} (${version}): ${build_steps}") {
            try {
                setBuildStatus(in_progress, context, pending)
                echo "make ${image} VERSION=${version} BUILD_STEPS=${build_steps}" // todo
                setBuildStatus(completed, context, success)
            } catch (Exception e) {
                setBuildStatus(failed, context, failure)
                error e
            }
        }
    }
}

def e2e(e2e_enabled) {
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
void setBuildStatus(String message, String context, String state) {
    step([
      $class: 'GitHubCommitStatusSetter',
      reposSource: [$class: 'ManuallyEnteredRepositorySource', url: 'https://github.com/LionelJouin/jenkins-test'],
      contextSource: [$class: 'ManuallyEnteredCommitContextSource', context: context],
      errorHandlers: [[$class: 'ChangingBuildStatusErrorHandler', result: 'UNSTABLE']],
      statusResultSource: [ $class: 'ConditionalStatusResultSource', results: [[$class: 'AnyBuildResult', message: message, state: state]] ]
  ])
}
