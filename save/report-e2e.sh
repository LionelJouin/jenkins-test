// def meridio_badge = addEmbeddableBadgeConfiguration(id: 'meridio-e2e-kind-meridio', subject: 'Meridio', color: '#0B1F67', status: '?')
// // meridio_badge.setStatus('latest (✔ 4 / ✘ 15) | v0.8.0 (✔ 50 / ✘ 1)')

// def tapa_badge = addEmbeddableBadgeConfiguration(id: 'meridio-e2e-kind-tapa', subject: 'TAPA', color: '#0B1F67', status: '?')
// // tapa_badge.setStatus('latest (✔ 4 / ✘ 15) | v0.8.0 (✔ 50 / ✘ 1)')

// def nsm_badge = addEmbeddableBadgeConfiguration(id: 'meridio-e2e-kind-nsm', subject: 'NSM', color: '#0B1F67', status: '?')
// // nsm_badge.setStatus('v1.6.0 (✔ 3 / ✘ 4) | v1.5.0 (✔ 5 / ✘ 7) | v1.4.0 (✔ 4 / ✘ 8)')

// def ip_family_badge = addEmbeddableBadgeConfiguration(id: 'meridio-e2e-kind-ip-family', subject: 'IP Family', color: '#0B1F67', status: '?')
// // ip_family_badge.setStatus('ipv4 (✔ 2 / ✘ 23) | ipv6 (✔ 5 / ✘ 1) | dualstack (✔ 30 / ✘ 8)')

// def kubernetes_badge = addEmbeddableBadgeConfiguration(id: 'meridio-e2e-kind-kubernetes', subject: 'Kubernetes', color: '#0B1F67', status: '?')
// kubernetes_badge.setStatus('v1.25 (✔ 3 / ✘ 4) | v1.24 (✔ 5 / ✘ 7) | v1.23 (✔ 4 / ✘ 8) | v1.22 (✔ 12 / ✘ 1) | v1.21 (✔ 0 / ✘ 1)')

// cat jenkins.json | jq -r ".allBuilds[] | [.description] | @tsv" | grep -v "^$" | grep -oP '(?<=Meridio version: ).*?(?=\/)'

// cat jenkins.json | jq -r ".allBuilds[] | [.description] | @tsv" | grep -v "^$" | grep -oP '(?<=Meridio version: ).*?(?=\/)' | sort | uniq -c
// cat jenkins.json | jq -r ".allBuilds[] | [.description] | @tsv" | grep -v "^$" | grep -oP '(?<=TAPA version: ).*?(?=\/)' | sort | uniq -c
// cat jenkins.json | jq -r ".allBuilds[] | [.description] | @tsv" | grep -v "^$" | grep -oP '(?<=NSM version: ).*?(?=\/)' | sort | uniq -c
// cat jenkins.json | jq -r ".allBuilds[] | [.description] | @tsv" | grep -v "^$" | grep -oP '(?<=IP Family: ).*?(?=\/)' | sort | uniq -c
// cat jenkins.json | jq -r ".allBuilds[] | [.description] | @tsv" | grep -v "^$" | grep -oP '(?<=Kubernetes version: ).*?(?=\/)' | sort | uniq -c

// cat jenkins.json | jq -r '.allBuilds[] | select(.result == "SUCCESS") | [.description] | @tsv' | grep -v "^$" | grep -oP '(?<=Meridio version: ).*?(?=\/)' | sort | uniq -c
// cat jenkins.json | jq -r '.allBuilds[] | select(.result == "FAILURE") | [.description] | @tsv' | grep -v "^$" | grep -oP '(?<=Meridio version: ).*?(?=\/)' | sort | uniq -c

// cat jenkins.json | jq -r '.allBuilds[] | select(.result == "SUCCESS") | [.description] | @tsv' | grep -v "^$" | grep -oP '(?<=TAPA version: ).*?(?=\/)' | sort | uniq -c
// cat jenkins.json | jq -r '.allBuilds[] | select(.result == "FAILURE") | [.description] | @tsv' | grep -v "^$" | grep -oP '(?<=TAPA version: ).*?(?=\/)' | sort | uniq -c

// cat jenkins.json | jq -r '.allBuilds[] | select(.result == "SUCCESS") | [.description] | @tsv' | grep -v "^$" | grep -oP '(?<=NSM version: ).*?(?=\/)' | sort | uniq -c
// cat jenkins.json | jq -r '.allBuilds[] | select(.result == "FAILURE") | [.description] | @tsv' | grep -v "^$" | grep -oP '(?<=NSM version: ).*?(?=\/)' | sort | uniq -c

// cat jenkins.json | jq -r '.allBuilds[] | select(.result == "SUCCESS") | [.description] | @tsv' | grep -v "^$" | grep -oP '(?<=IP Family: ).*?(?=\/)' | sort | uniq -c
// cat jenkins.json | jq -r '.allBuilds[] | select(.result == "FAILURE") | [.description] | @tsv' | grep -v "^$" | grep -oP '(?<=IP Family: ).*?(?=\/)' | sort | uniq -c

// cat jenkins.json | jq -r '.allBuilds[] | select(.result == "SUCCESS") | [.description] | @tsv' | grep -v "^$" | grep -oP '(?<=Kubernetes version: ).*?(?=\/)' | sort | uniq -c
// cat jenkins.json | jq -r '.allBuilds[] | select(.result == "FAILURE") | [.description] | @tsv' | grep -v "^$" | grep -oP '(?<=Kubernetes version: ).*?(?=\/)' | sort | uniq -c

// cat test.json | jq -r '.status'