# jenkins-test

jenkins-jobs --conf config/jenkins_jobs.ini update periodic.yaml

jenkins-jobs --conf config/jenkins_jobs.ini update meridio-periodic-security-scan.yaml

https://citizix.com/how-to-create-jenkins-jobs-using-jenkins-job-builder/

## issues
 
docker: Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Post "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/containers/create?name=Grype": dial unix /var/run/docker.sock: connect: permission denied.

sudo setfacl --modify user:jenkins:rw /var/run/docker.sock
