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
            sh 'echo "- v1.25.2" >> test-scope.yaml'
            sh 'echo "- v1.24.6" >> test-scope.yaml'
            sh 'echo "- v1.23.12" >> test-scope.yaml'
            sh 'echo "- v1.22.15" >> test-scope.yaml'
            sh 'echo "- v1.21.14" >> test-scope.yaml'
            sh 'echo "IP-Family:" >> test-scope.yaml'
            sh 'echo "- dualstack" >> test-scope.yaml'
            sh 'echo "- ipv4" >> test-scope.yaml'
            sh 'echo "- ipv6" >> test-scope.yaml'
            sh 'cat test-scope.yaml'
        // Meridio:
        // - v0.8.0
        // - latest
        // TAPA:
        // - v0.8.0
        // - latest
        // NSM:
        // - v1.4.0
        // - v1.5.0
        // - v1.6.0
        // Kubernetes:
        // - v1.25.2
        // - v1.24.6
        // - v1.23.12
        // - v1.22.15
        // - v1.21.14
        // IP-Family:
        // - dualstack
        // - ipv4
        // - ipv6
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
