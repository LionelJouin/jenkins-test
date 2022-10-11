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
        stage('Environment') {
            currentBuild.description = "Meridio version: $meridio_version / TAPA version: $tapa_version / NSM version: $nsm_version / IP Family: $ip_family / Kubernetes version: $kubernetes_version / Current Branch: $current_branch"
            echo "IP Family: $ip_family"
            echo "Kubernetes version: $kubernetes_version"
            echo "NSM version: $nsm_version"
        }
        timeout(60) {
            stage('E2E') {
                echo "Meridio version: $meridio_version"
                echo "TAPA version: $tapa_version"
            // sh 'sleep 10'
            }
        }
        stage('Cleanup') {
            Cleanup()
        }
        stage('Debug') {
            sh 'echo "Meridio:" >> test-scope.yaml'
            sh 'echo "- v0.8.0" >> test-scope.yaml'
            sh 'echo "- latest" >> test-scope.yaml'
            sh 'echo "TAPA:" >> test-scope.yaml'
            sh 'echo "- v0.8.0" >> test-scope.yaml'
            sh 'echo "- latest" >> test-scope.yaml'
            sh 'echo "NSM:" >> test-scope.yaml'
            sh 'echo "- v1.4.0" >> test-scope.yaml'
            sh 'echo "- v1.5.0" >> test-scope.yaml'
            sh 'echo "- v1.6.0" >> test-scope.yaml'
            sh 'echo "Kubernetes:" >> test-scope.yaml'
            sh 'echo "- v1.25" >> test-scope.yaml'
            sh 'echo "- v1.24" >> test-scope.yaml'
            sh 'echo "- v1.23" >> test-scope.yaml'
            sh 'echo "- v1.22" >> test-scope.yaml'
            sh 'echo "- v1.21" >> test-scope.yaml'
            sh 'echo "IP-Family:" >> test-scope.yaml'
            sh 'echo "- dualstack" >> test-scope.yaml'
            sh 'echo "- ipv4" >> test-scope.yaml'
            sh 'echo "- ipv6" >> test-scope.yaml'
            sh 'cat test-scope.yaml'
        }
        stage('Report') {
            Report().call()
        }
        stage('Next') {
            Next(next).call()
        }
    }
}

def Next(next) {
    if (next == 'true') {
        return {
            def meridio_version = GetMeridioVersion()
            def tapa_version = GetTAPAVersion()
            def nsm_version = GetNSMVersion()
            def kubernetes_version = GetKubernetesVersion()
            def ip_family = GetIPFamily()
            echo "Meridio version: $meridio_version / TAPA version: $tapa_version / NSM version: $nsm_version / IP Family: $ip_family / Kubernetes version: $kubernetes_version"
            build job: 'meridio-e2e-test-kind', parameters: [
                string(name: 'NEXT', value: 'true'),
                string(name: 'MERIDIO_VERSION', value: "$meridio_version"),
                string(name: 'TAPA_VERSION', value: "$tapa_version"),
                string(name: 'KUBERNETES_VERSION', value: "$kubernetes_version"),
                string(name: 'NSM_VERSION', value: "$nsm_version"),
                string(name: 'IP_FAMILY', value: "$ip_family")
            ], wait: false
        }
    } else {
        return {
            Utils.markStageSkippedForConditional('Next')
        }
    }
}

def GetMeridioVersion() {
    def number_of_versions = sh(script: 'cat test-scope.yaml | yq ".Meridio[]" | wc -l', returnStdout: true).trim()
    def index_of_version_temp = sh(script: "shuf -i 1-$number_of_versions -n1", returnStdout: true).trim()
    def index_of_version = sh(script: "expr $index_of_version_temp - 1 || true", returnStdout: true).trim()
    return sh(script: "cat test-scope.yaml | yq '.Meridio[$index_of_version]'", returnStdout: true).trim()
}

def GetTAPAVersion() {
    def number_of_versions = sh(script: 'cat test-scope.yaml | yq ".TAPA[]" | wc -l', returnStdout: true).trim()
    def index_of_version_temp = sh(script: "shuf -i 1-$number_of_versions -n1", returnStdout: true).trim()
    def index_of_version = sh(script: "expr $index_of_version_temp - 1 || true", returnStdout: true).trim()
    return sh(script: "cat test-scope.yaml | yq '.TAPA[$index_of_version]'", returnStdout: true).trim()
}

def GetNSMVersion() {
    def number_of_versions = sh(script: 'cat test-scope.yaml | yq ".NSM[]" | wc -l', returnStdout: true).trim()
    def index_of_version_temp = sh(script: "shuf -i 1-$number_of_versions -n1", returnStdout: true).trim()
    def index_of_version = sh(script: "expr $index_of_version_temp - 1 || true", returnStdout: true).trim()
    return sh(script: "cat test-scope.yaml | yq '.NSM[$index_of_version]'", returnStdout: true).trim()
}

def GetKubernetesVersion() {
    def number_of_versions = sh(script: 'cat test-scope.yaml | yq ".Kubernetes[]" | wc -l', returnStdout: true).trim()
    def index_of_version_temp = sh(script: "shuf -i 1-$number_of_versions -n1", returnStdout: true).trim()
    def index_of_version = sh(script: "expr $index_of_version_temp - 1 || true", returnStdout: true).trim()
    return sh(script: "cat test-scope.yaml | yq '.Kubernetes[$index_of_version]'", returnStdout: true).trim()
}

def GetIPFamily() {
    def number_of_ip_family = sh(script: 'cat test-scope.yaml | yq ".IP-Family[]" | wc -l', returnStdout: true).trim()
    def index_of_ip_family_temp = sh(script: "shuf -i 1-$number_of_ip_family -n1", returnStdout: true).trim()
    def index_of_ip_family = sh(script: "expr $index_of_ip_family_temp - 1 || true", returnStdout: true).trim()
    return sh(script: "cat test-scope.yaml | yq '.IP-Family[$index_of_ip_family]'", returnStdout: true).trim()
}

def Report() {
    return {
        def meridio_badge = addEmbeddableBadgeConfiguration(id: 'meridio-e2e-kind-meridio', subject: 'Meridio', color: 'mediumslateblue', status: '?')
        meridio_badge.setStatus('latest (✔ 4 / ✘ 15) | v0.8.0 (✔ 50 / ✘ 1)')

        def tapa_badge = addEmbeddableBadgeConfiguration(id: 'meridio-e2e-kind-tapa', subject: 'TAPA', color: 'mediumslateblue', status: '?')
        tapa_badge.setStatus('latest (✔ 4 / ✘ 15) | v0.8.0 (✔ 50 / ✘ 1)')

        def nsm_badge = addEmbeddableBadgeConfiguration(id: 'meridio-e2e-kind-nsm', subject: 'NSM', color: 'mediumslateblue', status: '?')
        nsm_badge.setStatus('v1.6.0 (✔ 3 / ✘ 4) | v1.5.0 (✔ 5 / ✘ 7) | v1.4.0 (✔ 4 / ✘ 8)')

        def ip_family_badge = addEmbeddableBadgeConfiguration(id: 'meridio-e2e-kind-ip-family', subject: 'IP Family', color: 'mediumslateblue', status: '?')
        ip_family_badge.setStatus('ipv4 (✔ 2 / ✘ 23) | ipv6 (✔ 5 / ✘ 1) | dualstack (✔ 30 / ✘ 8)')

        def kubernetes_badge = addEmbeddableBadgeConfiguration(id: 'meridio-e2e-kind-kubernetes', subject: 'Kubernetes', color: 'mediumslateblue', status: '?')
        kubernetes_badge.setStatus('v1.25 (✔ 3 / ✘ 4) | v1.24 (✔ 5 / ✘ 7) | v1.23 (✔ 4 / ✘ 8) | v1.22 (✔ 12 / ✘ 1) | v1.21 (✔ 0 / ✘ 1)')
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
