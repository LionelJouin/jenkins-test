#! /bin/sh

# cat jenkins.json | jq -r '.allBuilds[] | select(.result == "SUCCESS") | [.description] | @tsv' | grep -v "^$" | grep -oP '(?<=Meridio version: ).*?(?=\/)' | sort | uniq -c
# cat jenkins.json | jq -r '.allBuilds[] | select(.result == "FAILURE") | [.description] | @tsv' | grep -v "^$" | grep -oP '(?<=Meridio version: ).*?(?=\/)' | sort | uniq -c

jenkins_url=''
data=$(curl -s -L "http://$jenkins_url/job/meridio-e2e-test-kind/api/json?tree=allBuilds\[status,timestamp,id,result,description\]&pretty=true")

# echo "$data"

success=$(echo "$data" | jq -r '.allBuilds[] | select(.result == "SUCCESS") | [.description] | @tsv' | grep -v '^$')
failure=$(echo "$data" | jq -r '.allBuilds[] | select(.result == "FAILURE") | [.description] | @tsv' | grep -v '^$')

# echo "$success"
# echo "$failure"

#######################################
# Meridio
#######################################

meridio_success=$(echo "$success" | grep -oP '(?<=Meridio version: ).*?(?=\/)' | sort | uniq -c | awk '{ printf "%s %s 0\n", $2, $1 }')
meridio_failure=$(echo "$failure" | grep -oP '(?<=Meridio version: ).*?(?=\/)' | sort | uniq -c | awk '{ printf "%s 0 %s\n", $2, $1 }')

# echo "$meridio_success"
# echo "$meridio_failure"

meridio=$(echo "$meridio_success\n$meridio_failure" | awk '{ success[$1] += $2 ; failure[$1] += $3 } END { for(elem in success) print elem, success[elem], failure[elem] }' | sort -k1)

# echo "$meridio"

formatted=$(echo "$meridio" | awk '{ printf "%s (✅ %s / ❌ %s)\n", $1, $2, $3  }' | sed ':a;N;$!ba;s/\n/ | /g') 

echo "Meridio: $formatted"

#######################################
# TAPA
#######################################

tapa_success=$(echo "$success" | grep -oP '(?<=TAPA version: ).*?(?=\/)' | sort | uniq -c | awk '{ printf "%s %s 0\n", $2, $1 }')
tapa_failure=$(echo "$failure" | grep -oP '(?<=TAPA version: ).*?(?=\/)' | sort | uniq -c | awk '{ printf "%s 0 %s\n", $2, $1 }')
tapa=$(echo "$tapa_success\n$tapa_failure" | awk '{ success[$1] += $2 ; failure[$1] += $3 } END { for(elem in success) print elem, success[elem], failure[elem] }' | sort -k1)
formatted=$(echo "$tapa" | awk '{ printf "%s (✅ %s / ❌ %s)\n", $1, $2, $3  }' | sed ':a;N;$!ba;s/\n/ | /g') 
echo "TAPA: $formatted"

#######################################
# NSM
#######################################

nsm_success=$(echo "$success" | grep -oP '(?<=NSM version: ).*?(?=\/)' | sort | uniq -c | awk '{ printf "%s %s 0\n", $2, $1 }')
nsm_failure=$(echo "$failure" | grep -oP '(?<=NSM version: ).*?(?=\/)' | sort | uniq -c | awk '{ printf "%s 0 %s\n", $2, $1 }')
nsm=$(echo "$nsm_success\n$nsm_failure" | awk '{ success[$1] += $2 ; failure[$1] += $3 } END { for(elem in success) print elem, success[elem], failure[elem] }' | sort -k1)
formatted=$(echo "$nsm" | awk '{ printf "%s (✅ %s / ❌ %s)\n", $1, $2, $3  }' | sed ':a;N;$!ba;s/\n/ | /g') 
echo "NSM: $formatted"

#######################################
# IP Family
#######################################

ip_family_success=$(echo "$success" | grep -oP '(?<=IP Family: ).*?(?=\/)' | sort | uniq -c | awk '{ printf "%s %s 0\n", $2, $1 }')
ip_family_failure=$(echo "$failure" | grep -oP '(?<=IP Family: ).*?(?=\/)' | sort | uniq -c | awk '{ printf "%s 0 %s\n", $2, $1 }')
ip_family=$(echo "$ip_family_success\n$ip_family_failure" | awk '{ success[$1] += $2 ; failure[$1] += $3 } END { for(elem in success) print elem, success[elem], failure[elem] }' | sort -k1)
formatted=$(echo "$ip_family" | awk '{ printf "%s (✅ %s / ❌ %s)\n", $1, $2, $3  }' | sed ':a;N;$!ba;s/\n/ | /g') 
echo "IP Family: $formatted"

#######################################
# Kubernetes
#######################################

kubernetes_success=$(echo "$success" | grep -oP '(?<=Kubernetes version: ).*?(?=\/)' | sort | uniq -c | awk '{ printf "%s %s 0\n", $2, $1 }')
kubernetes_failure=$(echo "$failure" | grep -oP '(?<=Kubernetes version: ).*?(?=\/)' | sort | uniq -c | awk '{ printf "%s 0 %s\n", $2, $1 }')
kubernetes=$(echo "$kubernetes_success\n$kubernetes_failure" | awk '{ success[$1] += $2 ; failure[$1] += $3 } END { for(elem in success) print elem, success[elem], failure[elem] }' | sort -k1)
formatted=$(echo "$kubernetes" | awk '{ printf "%s (✅ %s / ❌ %s)\n", $1, $2, $3  }' | sed ':a;N;$!ba;s/\n/ | /g') 
echo "Kubernetes: $formatted"
