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
        def next = params.NEXT

        def meridio_version = params.MERIDIO_VERSION
        def tapa_version = params.TAPA_VERSION
        def kubernetes_version = params.KUBERNETES_VERSION
        def nsm_version = params.NSM_VERSION
        def ip_family = params.IP_FAMILY
        def number_of_workers = params.NUMBER_OF_WORKERS
        def environment_name = params.ENVIRONMENT_NAME
        def focus = params.FOCUS
        def skip = params.SKIP

        def seed = params.SEED

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
        timeout(120) {
            stage('Environment') {
                currentBuild.description = "Meridio version: $meridio_version / TAPA version: $tapa_version / NSM version: $nsm_version / IP Family: $ip_family / Kubernetes version: $kubernetes_version / Current Branch: $current_branch / Seed: $seed"

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
            stage('E2E') {
                if (currentBuild.result != 'FAILURE' && currentBuild.result != 'ABORTED') {
                    def command = "make e2e E2E_PARAMETERS=\"\$(cat ./test/e2e/environment/$environment_name/$ip_family/config.txt | tr '\\n' ' ')\" E2E_SEED=$seed E2E_FOCUS=\"$focus\" E2E_SKIP=\"$skip\""
                    try {
                        ExecSh(command).call()
                        currentBuild.result = 'SUCCESS'
                    } catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException e) {
                        currentBuild.result = 'ABORTED'
                    } catch (Exception e) {
                        unstable 'E2E Tests failed'
                        currentBuild.result = 'FAILURE'
                    }
                } else {
                    Utils.markStageSkippedForConditional('E2E')
                }
            }
        }
        stage('Report') {
            try {
                Report().call()
            } catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException e) {
                currentBuild.result = 'ABORTED'
            } catch (Exception e) {
                unstable 'Failed to create the report'
            }
        }
        stage('Next') {
            if (next == true && currentBuild.result != 'ABORTED') {
                Next(next, number_of_workers, environment_name, focus, skip, current_branch).call()
            } else {
                Utils.markStageSkippedForConditional('Next')
            }
        }
        stage('Cleanup') {
            Cleanup()
        }
    }
}

def Next(next, number_of_workers, environment_name, focus, skip, current_branch) {
    return {
        def meridio_version = GetMeridioVersion(environment_name)
        def tapa_version = GetTAPAVersion(environment_name)
        def nsm_version = GetNSMVersion(environment_name)
        def kubernetes_version = GetKubernetesVersion(environment_name)
        def ip_family = GetIPFamily(environment_name)
        def seed = GetSeed()
        echo "Meridio version: $meridio_version / TAPA version: $tapa_version / NSM version: $nsm_version / IP Family: $ip_family / Kubernetes version: $kubernetes_version / Seed: $seed"
        build job: 'meridio-e2e-test-kind', parameters: [
                string(name: 'NEXT', value: 'true'),
                string(name: 'MERIDIO_VERSION', value: "$meridio_version"),
                string(name: 'TAPA_VERSION', value: "$tapa_version"),
                string(name: 'KUBERNETES_VERSION', value: "$kubernetes_version"),
                string(name: 'NSM_VERSION', value: "$nsm_version"),
                string(name: 'IP_FAMILY', value: "$ip_family"),
                string(name: 'NUMBER_OF_WORKERS', value: "$number_of_workers"),
                string(name: 'ENVIRONMENT_NAME', value: "$environment_name"),
                string(name: 'SEED', value: "$seed"),
                string(name: 'FOCUS', value: "$focus"),
                string(name: 'SKIP', value: "$skip"),
                string(name: 'CURRENT_BRANCH', value: "$current_branch"),
                string(name: 'DRY_RUN', value: env.DRY_RUN)
            ], wait: false
    }
}

def GetMeridioVersion(environment_name) {
    def number_of_versions = sh(script: "cat test/e2e/environment/$environment_name/test-scope.yaml | yq '.Meridio[]' | wc -l", returnStdout: true).trim()
    def index_of_version_temp = sh(script: "shuf -i 1-$number_of_versions -n1", returnStdout: true).trim()
    def index_of_version = sh(script: "expr $index_of_version_temp - 1 || true", returnStdout: true).trim()
    return sh(script: "cat test/e2e/environment/$environment_name/test-scope.yaml | yq '.Meridio[$index_of_version]'", returnStdout: true).trim()
}

def GetTAPAVersion(environment_name) {
    def number_of_versions = sh(script: "cat test/e2e/environment/$environment_name/test-scope.yaml | yq '.TAPA[]' | wc -l", returnStdout: true).trim()
    def index_of_version_temp = sh(script: "shuf -i 1-$number_of_versions -n1", returnStdout: true).trim()
    def index_of_version = sh(script: "expr $index_of_version_temp - 1 || true", returnStdout: true).trim()
    return sh(script: "cat test/e2e/environment/$environment_name/test-scope.yaml | yq '.TAPA[$index_of_version]'", returnStdout: true).trim()
}

def GetNSMVersion(environment_name) {
    def number_of_versions = sh(script: "cat test/e2e/environment/$environment_name/test-scope.yaml | yq '.NSM[]' | wc -l", returnStdout: true).trim()
    def index_of_version_temp = sh(script: "shuf -i 1-$number_of_versions -n1", returnStdout: true).trim()
    def index_of_version = sh(script: "expr $index_of_version_temp - 1 || true", returnStdout: true).trim()
    return sh(script: "cat test/e2e/environment/$environment_name/test-scope.yaml | yq '.NSM[$index_of_version]'", returnStdout: true).trim()
}

def GetKubernetesVersion(environment_name) {
    def number_of_versions = sh(script: "cat test/e2e/environment/$environment_name/test-scope.yaml | yq '.Kubernetes[]' | wc -l", returnStdout: true).trim()
    def index_of_version_temp = sh(script: "shuf -i 1-$number_of_versions -n1", returnStdout: true).trim()
    def index_of_version = sh(script: "expr $index_of_version_temp - 1 || true", returnStdout: true).trim()
    return sh(script: "cat test/e2e/environment/$environment_name/test-scope.yaml | yq '.Kubernetes[$index_of_version]'", returnStdout: true).trim()
}

def GetIPFamily(environment_name) {
    def number_of_ip_family = sh(script: "cat test/e2e/environment/$environment_name/test-scope.yaml | yq '.IP-Family[]' | wc -l", returnStdout: true).trim()
    def index_of_ip_family_temp = sh(script: "shuf -i 1-$number_of_ip_family -n1", returnStdout: true).trim()
    def index_of_ip_family = sh(script: "expr $index_of_ip_family_temp - 1 || true", returnStdout: true).trim()
    return sh(script: "cat test/e2e/environment/$environment_name/test-scope.yaml | yq '.IP-Family[$index_of_ip_family]'", returnStdout: true).trim()
}

def GetSeed() {
    return sh(script: 'shuf -i 1-2147483647 -n1', returnStdout: true).trim()
}

// http://JENKINS_URL/job/meridio-e2e-test-kind/api/json?tree=allBuilds[status,timestamp,id,result,description]{0,9}&pretty=true
def Report() {
    return {
        def jenkins_url = 'jenkins.nordix.org'

        def success = ''
        try {
            success = sh(script: """
            data=\$(curl -s -L "http://$jenkins_url/job/meridio-e2e-test-kind/api/json?tree=allBuilds\\[status,timestamp,id,result,description\\]\\{0,1000\\}&pretty=true")
            success=\$(echo \"\$data\" | jq -r '.allBuilds[] | select(.result == \"SUCCESS\") | [.description] | @tsv' | grep -v \"^\$\")
            echo \$success
            """, returnStdout: true).trim()
        } catch (Exception e) {
        }

        def failure = ''
        try {
            failure = sh(script: """
            data=\$(curl -s -L "http://$jenkins_url/job/meridio-e2e-test-kind/api/json?tree=allBuilds\\[status,timestamp,id,result,description\\]\\{0,1000\\}&pretty=true")
            failure=\$(echo \"\$data\" | jq -r '.allBuilds[] | select(.result == \"FAILURE\") | [.description] | @tsv' | grep -v \"^\$\")
            echo \$failure
            """, returnStdout: true).trim()
        } catch (Exception e) {
        }

        ReportMeridio(success, failure).call()
        ReportTAPA(success, failure).call()
        ReportNSM(success, failure).call()
        ReportIPFamily(success, failure).call()
        ReportKubernetes(success, failure).call()

        try {
            archiveArtifacts artifacts: '_output/**/*.*', followSymlinks: false
        } catch (Exception e) {
        }
    }
}

def ReportMeridio(success, failure) {
    return {
        def meridio_success = sh(script: "echo \"$success\" | grep -oP '(?<=Meridio version: ).*?(?=\\/)' | sort | uniq -c | awk '{ printf \"%s %s 0\\n\", \$2, \$1 }'", returnStdout: true).trim()
        def meridio_failure = sh(script: "echo \"$failure\" | grep -oP '(?<=Meridio version: ).*?(?=\\/)' | sort | uniq -c | awk '{ printf \"%s 0 %s\\n\", \$2, \$1 }'", returnStdout: true).trim()
        def meridio = sh(script: "echo \"$meridio_success\\n$meridio_failure\" | grep -v '^\$' | awk '{ success[\$1] += \$2 ; failure[\$1] += \$3 } END { for(elem in success) print elem, success[elem], failure[elem] }' | sort -k1", returnStdout: true).trim()
        def formatted = sh(script: "echo \"$meridio\" | awk '{ printf \"%s (✅ %s / ❌ %s)\\n\", \$1, \$2, \$3  }' | sed ':a;N;\$!ba;s/\\n/ | /g'", returnStdout: true).trim()
        echo "Meridio: $formatted"
        badge('meridio-e2e-kind-meridio', 'Meridio', formatted)
    }
}

def ReportTAPA(success, failure) {
    return {
        def tapa_success = sh(script: "echo \"$success\" | grep -oP '(?<=TAPA version: ).*?(?=\\/)' | sort | uniq -c | awk '{ printf \"%s %s 0\\n\", \$2, \$1 }'", returnStdout: true).trim()
        def tapa_failure = sh(script: "echo \"$failure\" | grep -oP '(?<=TAPA version: ).*?(?=\\/)' | sort | uniq -c | awk '{ printf \"%s 0 %s\\n\", \$2, \$1 }'", returnStdout: true).trim()
        def tapa = sh(script: "echo \"$tapa_success\\n$tapa_failure\" | grep -v '^\$' | awk '{ success[\$1] += \$2 ; failure[\$1] += \$3 } END { for(elem in success) print elem, success[elem], failure[elem] }' | sort -k1", returnStdout: true).trim()
        def formatted = sh(script: "echo \"$tapa\" | awk '{ printf \"%s (✅ %s / ❌ %s)\\n\", \$1, \$2, \$3  }' | sed ':a;N;\$!ba;s/\\n/ | /g'", returnStdout: true).trim()
        echo "TAPA: $formatted"
        badge('meridio-e2e-kind-tapa', 'TAPA', formatted)
    }
}

def ReportNSM(success, failure) {
    return {
        def nsm_success = sh(script: "echo \"$success\" | grep -oP '(?<=NSM version: ).*?(?=\\/)' | sort | uniq -c | awk '{ printf \"%s %s 0\\n\", \$2, \$1 }'", returnStdout: true).trim()
        def nsm_failure = sh(script: "echo \"$failure\" | grep -oP '(?<=NSM version: ).*?(?=\\/)' | sort | uniq -c | awk '{ printf \"%s 0 %s\\n\", \$2, \$1 }'", returnStdout: true).trim()
        def nsm = sh(script: "echo \"$nsm_success\\n$nsm_failure\" | grep -v '^\$' | awk '{ success[\$1] += \$2 ; failure[\$1] += \$3 } END { for(elem in success) print elem, success[elem], failure[elem] }' | sort -k1", returnStdout: true).trim()
        def formatted = sh(script: "echo \"$nsm\" | awk '{ printf \"%s (✅ %s / ❌ %s)\\n\", \$1, \$2, \$3  }' | sed ':a;N;\$!ba;s/\\n/ | /g'", returnStdout: true).trim()
        echo "NSM: $formatted"
        badge('meridio-e2e-kind-nsm', 'NSM', formatted)
    }
}

def ReportIPFamily(success, failure) {
    return {
        def ip_family_success = sh(script: "echo \"$success\" | grep -oP '(?<=IP Family: ).*?(?=\\/)' | sort | uniq -c | awk '{ printf \"%s %s 0\\n\", \$2, \$1 }'", returnStdout: true).trim()
        def ip_family_failure = sh(script: "echo \"$failure\" | grep -oP '(?<=IP Family: ).*?(?=\\/)' | sort | uniq -c | awk '{ printf \"%s 0 %s\\n\", \$2, \$1 }'", returnStdout: true).trim()
        def ip_family = sh(script: "echo \"$ip_family_success\\n$ip_family_failure\" | grep -v '^\$' | awk '{ success[\$1] += \$2 ; failure[\$1] += \$3 } END { for(elem in success) print elem, success[elem], failure[elem] }' | sort -k1", returnStdout: true).trim()
        def formatted = sh(script: "echo \"$ip_family\" | awk '{ printf \"%s (✅ %s / ❌ %s)\\n\", \$1, \$2, \$3  }' | sed ':a;N;\$!ba;s/\\n/ | /g'", returnStdout: true).trim()
        echo "IP Family: $formatted"
        badge('meridio-e2e-kind-ip-family', 'IP Family', formatted)
    }
}

def ReportKubernetes(success, failure) {
    return {
        def kubernetes_success = sh(script: "echo \"$success\" | grep -oP '(?<=Kubernetes version: ).*?(?=\\/)' | sort | uniq -c | awk '{ printf \"%s %s 0\\n\", \$2, \$1 }'", returnStdout: true).trim()
        def kubernetes_failure = sh(script: "echo \"$failure\" | grep -oP '(?<=Kubernetes version: ).*?(?=\\/)' | sort | uniq -c | awk '{ printf \"%s 0 %s\\n\", \$2, \$1 }'", returnStdout: true).trim()
        def kubernetes = sh(script: "echo \"$kubernetes_success\\n$kubernetes_failure\" | grep -v '^\$' | awk '{ success[\$1] += \$2 ; failure[\$1] += \$3 } END { for(elem in success) print elem, success[elem], failure[elem] }' | sort -k1", returnStdout: true).trim()
        def formatted = sh(script: "echo \"$kubernetes\" | awk '{ printf \"%s (✅ %s / ❌ %s)\\n\", \$1, \$2, \$3  }' | sed ':a;N;\$!ba;s/\\n/ | /g'", returnStdout: true).trim()
        echo "Kubernetes: $formatted"
        badge('meridio-e2e-kind-kubernetes', 'Kubernetes', formatted)
    }
}

def badge(id, subject, message) {
    addEmbeddableBadgeConfiguration(id: "${id}", subject: "${subject}", color: '#0B1F67', status: "$message")
    sh """
    mkdir -p _output
    echo '{' >> _output/${id}.json
    echo '"schemaVersion": 1,' >> _output/${id}.json
    echo '"label": "${subject}",' >> _output/${id}.json
    echo '"message": "${message}",' >> _output/${id}.json
    echo '"color": "#0B1F67"' >> _output/${id}.json
    echo '}' >> _output/${id}.json
    """
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
