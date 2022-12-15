/*
Copyright (c) 2022 Nordix Foundation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
import org.jenkinsci.plugins.pipeline.modeldefinition.Utils

node('nordix-nsm-build-ubuntu2204') {
    build_number = env.BUILD_NUMBER
    workspace = env.WORKSPACE
    ws("${workspace}/${build_number}") {
        def git_project = params.GIT_PROJECT
        def current_branch = params.CURRENT_BRANCH
        def default_branch = params.DEFAULT_BRANCH

        def meridio_version = params.MERIDIO_VERSION
        def tapa_version = params.TAPA_VERSION
        def kubernetes_version = params.KUBERNETES_VERSION
        def nsm_version = params.NSM_VERSION
        def ip_family = params.IP_FAMILY
        def number_of_workers = params.NUMBER_OF_WORKERS
        def environment_name = params.ENVIRONMENT_NAME
        def focus = params.FOCUS
        def skip = params.SKIP

        def number_of_runs = params.NUMBER_OF_RUNS
        def interval = params.INTERVAL

        stage('Clone/Checkout') {
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
        timeout(30) {
            stage('Environment') {
                def command = "make -s -C test/e2e/environment/$environment_name/ KUBERNETES_VERSION=$kubernetes_version NSM_VERSION=$nsm_version IP_FAMILY=$ip_family KUBERNETES_WORKERS=$number_of_workers MERIDIO_VERSION=$meridio_version TAPA_VERSION=$tapa_version"
                try {
                    ExecSh(command).call()
                } catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException e) {
                    currentBuild.result = 'ABORTED'
                } catch (Exception e) {
                    unstable 'Environment setup failed'
                    currentBuild.result = 'FAILURE'
                }
            }
        }
        stage('E2E List') {
            E2EList(number_of_runs, interval, environment_name, ip_family, focus, skip).call()
        }
        stage('Cleanup') {
            Cleanup()
        }
    }
}

// Creates the list of e2e to run during this job
def E2EList(number_of_runs, interval, environment_name, ip_family, focus, skip) {
    return {
        def stages = [:]
        def list = sh(script: "seq -w 1 $number_of_runs | paste -sd ' ' -", returnStdout: true).trim().split(' ')
        def previous = '0'
        env.E2E_PREVIOUSLY_EXECUTED = previous
        for (i in list) {
            stages.put("$i", E2E(i, previous, interval, environment_name, ip_family, focus, skip))
            previous = i
        }
        parallel(stages)
    }
}

// Run e2e
def E2E(id, previous_id, interval, environment_name, ip_family, focus, skip) {
    return {
        stage('Wait for previous') {
            waitUntil(initialRecurrencePeriod: 15000, quiet: true) {
                return env.E2E_PREVIOUSLY_EXECUTED == previous_id
            }
        }
        if (previous_id != '0') {
            stage("Wait $interval seconds") {
                sh "sleep $interval"
            }
        }
        stage('E2E') {
            def command = "make e2e E2E_ENVIRONMENT=\"$environment_name\" E2E_IP_FAMILY=\"$ip_family\" E2E_FOCUS=\"$focus\" E2E_SKIP=\"$skip\""
            try {
                ExecSh(command).call()
            } catch (Exception e) {
                unstable 'Failing e2e'
            }
        }
        env.E2E_PREVIOUSLY_EXECUTED = id
    }
}

// Raise error in Jenkins job
def Error(e) {
    return {
        Cleanup()
        error e
    }
}

// Cleanup directory and kind cluster
def Cleanup() {
    def command = 'make -s -C docs/demo/scripts/kind/ clean'
    ExecSh(command).call()
    cleanWs()
}

// Execute command
def ExecSh(command) {
    return {
        if (env.DRY_RUN != 'true') {
            sh """
                . \${HOME}/.profile
                ${command}
            """
        } else {
            echo "${command}"
        }
    }
}
