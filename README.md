# jenkins-test

jenkins-jobs --conf config/jenkins_jobs.ini update periodic.yaml

jenkins-jobs --conf config/jenkins_jobs.ini update meridio-periodic-security-scan.yaml

https://citizix.com/how-to-create-jenkins-jobs-using-jenkins-job-builder/

## issues
 
docker: Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Post "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/containers/create?name=Grype": dial unix /var/run/docker.sock: connect: permission denied.

sudo setfacl --modify user:jenkins:rw /var/run/docker.sock


sudo iptables -I INPUT -p tcp -m tcp --dport 8080 -j ACCEPT

# Artifactory 

sudo mkdir -p $JFROG_HOME/artifactory/var/etc/
sudo cd $JFROG_HOME/artifactory/var/etc/
sudo touch ./system.yaml
sudo chown -R 1030:1030 $JFROG_HOME/artifactory/var
sudo chmod -R 777 $JFROG_HOME/artifactory/var

docker run --name artifactory -v $JFROG_HOME/artifactory/var/:/var/opt/jfrog/artifactory -d -p 8081:8081 -p 8082:8082 releases-docker.jfrog.io/jfrog/artifactory-oss:latest

sudo iptables -I INPUT -p tcp -m tcp --dport 8081 -j ACCEPT
sudo iptables -I INPUT -p tcp -m tcp --dport 8082 -j ACCEPT

http://:8080/manage/configure#jfrog

https://stackoverflow.com/questions/46832989/artifactory-use-jenkins-pipeline-script-to-upload/46835485#46835485
https://stackoverflow.com/questions/38878620/publishing-to-artifactory-from-jenkins-pipeline
```
def server = Artifactory.server 'jenkins-server'
def uploadSpec = '''{
        "files": [{
            "pattern": "_output/",
            "target": "cloud-native/meridio/e2e-test-reports/"
        }]
        }'''

server.upload(uploadSpec)
```
