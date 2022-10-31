import org.jenkinsci.plugins.pipeline.modeldefinition.Utils

node {
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

        def seed = params.SEED

        stage('Debug') {
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
        timeout(60) {
            stage('Environment') {
                currentBuild.description = "Meridio version: $meridio_version / TAPA version: $tapa_version / NSM version: $nsm_version / IP Family: $ip_family / Kubernetes version: $kubernetes_version / Current Branch: $current_branch / Seed: $seed"

                try {
                    echo "make -s -C test/e2e/environment/$environment_name/ KUBERNETES_VERSION=$kubernetes_version NSM_VERSION=$nsm_version KUBERNETES_IP_FAMILY=$ip_family KUBERNETES_WORKERS=$number_of_workers"
                    def random = sh(script: 'shuf -i 1-8 -n1', returnStdout: true).trim()
                    if (random == '2') {
                        sh 'sdfsf'
                    }
                } catch (Exception e) {
                    unstable 'Environment setup failed'
                    currentBuild.result = 'FAILURE'
                }
            }
            stage('E2E') {
                if (currentBuild.result != 'FAILURE') {
                    try {
                        echo "Meridio version: $meridio_version"
                        echo "TAPA version: $tapa_version"
                        echo "make e2e E2E_PARAMETERS=\"\$(cat ./test/e2e/environment/$environment_name/$ip_family/config.txt | tr '\\n' ' ')\" E2E_SEED=$seed"
                        def random = sh(script: 'shuf -i 1-8 -n1', returnStdout: true).trim()
                        if (random == '2') {
                            sh 'sdfsf'
                        }
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
            } catch (Exception e) {
                unstable 'Failed to create the report'
                currentBuild.result = 'FAILURE'
            }
        }
        stage('Next') {
            Next(next, number_of_workers, environment_name).call()
        }
        stage('Cleanup') {
            Cleanup()
        }
    }
}

def Next(next, number_of_workers, environment_name) {
    if (next == 'true') {
        return {
            def meridio_version = GetMeridioVersion()
            def tapa_version = GetTAPAVersion()
            def nsm_version = GetNSMVersion()
            def kubernetes_version = GetKubernetesVersion()
            def ip_family = GetIPFamily()
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
                string(name: 'SEED', value: "$seed")
            ], wait: false
        }
    } else {
        return {
            Utils.markStageSkippedForConditional('Next')
        }
    }
}

def GetMeridioVersion() {
    def number_of_versions = sh(script: 'cat test/e2e/environment/kind-helm/test-scope.yaml | yq ".Meridio[]" | wc -l', returnStdout: true).trim()
    def index_of_version_temp = sh(script: "shuf -i 1-$number_of_versions -n1", returnStdout: true).trim()
    def index_of_version = sh(script: "expr $index_of_version_temp - 1 || true", returnStdout: true).trim()
    return sh(script: "cat test/e2e/environment/kind-helm/test-scope.yaml | yq '.Meridio[$index_of_version]'", returnStdout: true).trim()
}

def GetTAPAVersion() {
    def number_of_versions = sh(script: 'cat test/e2e/environment/kind-helm/test-scope.yaml | yq ".TAPA[]" | wc -l', returnStdout: true).trim()
    def index_of_version_temp = sh(script: "shuf -i 1-$number_of_versions -n1", returnStdout: true).trim()
    def index_of_version = sh(script: "expr $index_of_version_temp - 1 || true", returnStdout: true).trim()
    return sh(script: "cat test/e2e/environment/kind-helm/test-scope.yaml | yq '.TAPA[$index_of_version]'", returnStdout: true).trim()
}

def GetNSMVersion() {
    def number_of_versions = sh(script: 'cat test/e2e/environment/kind-helm/test-scope.yaml | yq ".NSM[]" | wc -l', returnStdout: true).trim()
    def index_of_version_temp = sh(script: "shuf -i 1-$number_of_versions -n1", returnStdout: true).trim()
    def index_of_version = sh(script: "expr $index_of_version_temp - 1 || true", returnStdout: true).trim()
    return sh(script: "cat test/e2e/environment/kind-helm/test-scope.yaml | yq '.NSM[$index_of_version]'", returnStdout: true).trim()
}

def GetKubernetesVersion() {
    def number_of_versions = sh(script: 'cat test/e2e/environment/kind-helm/test-scope.yaml | yq ".Kubernetes[]" | wc -l', returnStdout: true).trim()
    def index_of_version_temp = sh(script: "shuf -i 1-$number_of_versions -n1", returnStdout: true).trim()
    def index_of_version = sh(script: "expr $index_of_version_temp - 1 || true", returnStdout: true).trim()
    return sh(script: "cat test/e2e/environment/kind-helm/test-scope.yaml | yq '.Kubernetes[$index_of_version]'", returnStdout: true).trim()
}

def GetIPFamily() {
    def number_of_ip_family = sh(script: 'cat test/e2e/environment/kind-helm/test-scope.yaml | yq ".IP-Family[]" | wc -l', returnStdout: true).trim()
    def index_of_ip_family_temp = sh(script: "shuf -i 1-$number_of_ip_family -n1", returnStdout: true).trim()
    def index_of_ip_family = sh(script: "expr $index_of_ip_family_temp - 1 || true", returnStdout: true).trim()
    return sh(script: "cat test/e2e/environment/kind-helm/test-scope.yaml | yq '.IP-Family[$index_of_ip_family]'", returnStdout: true).trim()
}

def GetSeed() {
    return sh(script: 'shuf -i 1-2147483647 -n1', returnStdout: true).trim()
}

// http://JENKINS_URL/job/meridio-e2e-test-kind/api/json?tree=allBuilds[status,timestamp,id,result,description]{0,9}&pretty=true
def Report() {
    return {
        def jenkins_url = ''

        def success = ''
        try {
            success = sh(script: """
            data=\$(curl -s -L "http://$jenkins_url/job/meridio-e2e-test-kind/api/json?tree=allBuilds\\[status,timestamp,id,result,description\\]\\{0,200\\}&pretty=true")
            success=\$(echo \"\$data\" | jq -r '.allBuilds[] | select(.result == \"SUCCESS\") | [.description] | @tsv' | grep -v \"^\$\")
            echo \$success
            """, returnStdout: true).trim()
        } catch (Exception e) {
        }

        def failure = ''
        try {
            failure = sh(script: """
            data=\$(curl -s -L "http://$jenkins_url/job/meridio-e2e-test-kind/api/json?tree=allBuilds\\[status,timestamp,id,result,description\\]\\{0,200\\}&pretty=true")
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
    }
}

def ReportMeridio(success, failure) {
    return {
        def meridio_success = sh(script: "echo \"$success\" | grep -oP '(?<=Meridio version: ).*?(?=\\/)' | sort | uniq -c | awk '{ printf \"%s %s 0\\n\", \$2, \$1 }'", returnStdout: true).trim()
        def meridio_failure = sh(script: "echo \"$failure\" | grep -oP '(?<=Meridio version: ).*?(?=\\/)' | sort | uniq -c | awk '{ printf \"%s 0 %s\\n\", \$2, \$1 }'", returnStdout: true).trim()
        def meridio = sh(script: "echo \"$meridio_success\\n$meridio_failure\" | grep -v '^\$' | awk '{ success[\$1] += \$2 ; failure[\$1] += \$3 } END { for(elem in success) print elem, success[elem], failure[elem] }' | sort -k1", returnStdout: true).trim()
        def formatted = sh(script: "echo \"$meridio\" | awk '{ printf \"%s (✅ %s / ❌ %s)\\n\", \$1, \$2, \$3  }' | sed ':a;N;\$!ba;s/\\n/ | /g'", returnStdout: true).trim()
        echo "Meridio: $formatted"
        def meridio_badge = addEmbeddableBadgeConfiguration(id: 'meridio-e2e-kind-meridio', subject: 'Meridio', color: '#0B1F67', status: "$formatted")
    }
}

def ReportTAPA(success, failure) {
    return {
        def tapa_success = sh(script: "echo \"$success\" | grep -oP '(?<=TAPA version: ).*?(?=\\/)' | sort | uniq -c | awk '{ printf \"%s %s 0\\n\", \$2, \$1 }'", returnStdout: true).trim()
        def tapa_failure = sh(script: "echo \"$failure\" | grep -oP '(?<=TAPA version: ).*?(?=\\/)' | sort | uniq -c | awk '{ printf \"%s 0 %s\\n\", \$2, \$1 }'", returnStdout: true).trim()
        def tapa = sh(script: "echo \"$tapa_success\\n$tapa_failure\" | grep -v '^\$' | awk '{ success[\$1] += \$2 ; failure[\$1] += \$3 } END { for(elem in success) print elem, success[elem], failure[elem] }' | sort -k1", returnStdout: true).trim()
        def formatted = sh(script: "echo \"$tapa\" | awk '{ printf \"%s (✅ %s / ❌ %s)\\n\", \$1, \$2, \$3  }' | sed ':a;N;\$!ba;s/\\n/ | /g'", returnStdout: true).trim()
        echo "TAPA: $formatted"
        def tapa_badge = addEmbeddableBadgeConfiguration(id: 'meridio-e2e-kind-tapa', subject: 'TAPA', color: '#0B1F67', status: "$formatted")
    }
}

def ReportNSM(success, failure) {
    return {
        def nsm_success = sh(script: "echo \"$success\" | grep -oP '(?<=NSM version: ).*?(?=\\/)' | sort | uniq -c | awk '{ printf \"%s %s 0\\n\", \$2, \$1 }'", returnStdout: true).trim()
        def nsm_failure = sh(script: "echo \"$failure\" | grep -oP '(?<=NSM version: ).*?(?=\\/)' | sort | uniq -c | awk '{ printf \"%s 0 %s\\n\", \$2, \$1 }'", returnStdout: true).trim()
        def nsm = sh(script: "echo \"$nsm_success\\n$nsm_failure\" | grep -v '^\$' | awk '{ success[\$1] += \$2 ; failure[\$1] += \$3 } END { for(elem in success) print elem, success[elem], failure[elem] }' | sort -k1", returnStdout: true).trim()
        def formatted = sh(script: "echo \"$nsm\" | awk '{ printf \"%s (✅ %s / ❌ %s)\\n\", \$1, \$2, \$3  }' | sed ':a;N;\$!ba;s/\\n/ | /g'", returnStdout: true).trim()
        echo "NSM: $formatted"
        def nsm_badge = addEmbeddableBadgeConfiguration(id: 'meridio-e2e-kind-nsm', subject: 'NSM', color: '#0B1F67', status: "$formatted")
    }
}

def ReportIPFamily(success, failure) {
    return {
        def ip_family_success = sh(script: "echo \"$success\" | grep -oP '(?<=IP Family: ).*?(?=\\/)' | sort | uniq -c | awk '{ printf \"%s %s 0\\n\", \$2, \$1 }'", returnStdout: true).trim()
        def ip_family_failure = sh(script: "echo \"$failure\" | grep -oP '(?<=IP Family: ).*?(?=\\/)' | sort | uniq -c | awk '{ printf \"%s 0 %s\\n\", \$2, \$1 }'", returnStdout: true).trim()
        def ip_family = sh(script: "echo \"$ip_family_success\\n$ip_family_failure\" | grep -v '^\$' | awk '{ success[\$1] += \$2 ; failure[\$1] += \$3 } END { for(elem in success) print elem, success[elem], failure[elem] }' | sort -k1", returnStdout: true).trim()
        def formatted = sh(script: "echo \"$ip_family\" | awk '{ printf \"%s (✅ %s / ❌ %s)\\n\", \$1, \$2, \$3  }' | sed ':a;N;\$!ba;s/\\n/ | /g'", returnStdout: true).trim()
        echo "IP Family: $formatted"
        def ip_family_badge = addEmbeddableBadgeConfiguration(id: 'meridio-e2e-kind-ip-family', subject: 'IP Family', color: '#0B1F67', status: "$formatted")
    }
}

def ReportKubernetes(success, failure) {
    return {
        def kubernetes_success = sh(script: "echo \"$success\" | grep -oP '(?<=Kubernetes version: ).*?(?=\\/)' | sort | uniq -c | awk '{ printf \"%s %s 0\\n\", \$2, \$1 }'", returnStdout: true).trim()
        def kubernetes_failure = sh(script: "echo \"$failure\" | grep -oP '(?<=Kubernetes version: ).*?(?=\\/)' | sort | uniq -c | awk '{ printf \"%s 0 %s\\n\", \$2, \$1 }'", returnStdout: true).trim()
        def kubernetes = sh(script: "echo \"$kubernetes_success\\n$kubernetes_failure\" | grep -v '^\$' | awk '{ success[\$1] += \$2 ; failure[\$1] += \$3 } END { for(elem in success) print elem, success[elem], failure[elem] }' | sort -k1", returnStdout: true).trim()
        def formatted = sh(script: "echo \"$kubernetes\" | awk '{ printf \"%s (✅ %s / ❌ %s)\\n\", \$1, \$2, \$3  }' | sed ':a;N;\$!ba;s/\\n/ | /g'", returnStdout: true).trim()
        echo "Kubernetes: $formatted"
        def kubernetes_badge = addEmbeddableBadgeConfiguration(id: 'meridio-e2e-kind-kubernetes', subject: 'Kubernetes', color: '#0B1F67', status: "$formatted")
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
    ExecSh("echo 'make -s -C docs/demo/scripts/kind/ clean'").call()
    cleanWs()
}

// Execute command
def ExecSh(command) {
    return {
        sh """
            . \${HOME}/.profile
            ${command}
        """
    }
}

// data=$(curl -s -L "http://JENKINS_URL/job/meridio-e2e-test-kind/api/json?tree=allBuilds\[status,timestamp,id,result,description\]&pretty=true")
// data=$(cat config/test-1.json)
// success=$(echo "$data" | jq -r '.allBuilds[] | select(.result == "SUCCESS") | [.description] | @tsv' | grep -v '^$')
// failure=$(echo "$data" | jq -r '.allBuilds[] | select(.result == "FAILURE") | [.description] | @tsv' | grep -v '^$')
// meridio_success=$(echo "$success" | grep -oP '(?<=Meridio version: ).*?(?=\/)' | sort | uniq -c | awk '{ printf "%s %s 0\n", $2, $1 }')
// meridio_failure=$(echo "$failure" | grep -oP '(?<=Meridio version: ).*?(?=\/)' | sort | uniq -c | awk '{ printf "%s 0 %s\n", $2, $1 }')
// meridio=$(echo "$meridio_success\n$meridio_failure" | awk '{ success[$1] += $2 ; failure[$1] += $3 } END { for(elem in success) print elem, success[elem], failure[elem] }' )
// formatted=$(echo "$meridio" | awk '{ printf "%s (✅ %s / ❌ %s)\n", $1, $2, $3  }' | sed ':a;N;$!ba;s/\n/ | /g')
// echo "$formatted"
