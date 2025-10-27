pipeline {
  agent any

  environment {
	APP_SERV_IP = '52.66.255.233'
    	IMAGE = 'anitodevops/react-app'
        DOCKER_CRED_ID = 'dockerhub-creds'
  }

  triggers {
       githubPush ()
  }

  stages {

    stage('Build') {
      steps {
        script {

          sh "docker build -t ${IMAGE}:${env.BUILD_NUMBER} ." 
        }
      }
    }

    stage('Push') {
      steps {
        script {
          def imageno = "${IMAGE}:${env.BUILD_NUMBER}" 
          def envType = (env.BRANCH_NAME == 'master') ? 'prod' : 'dev'
          def imagetype = "${IMAGE}-${envType}" 
          def imagetypeNo = "${imagetype}:${env.BUILD_NUMBER}" 
          def imageLatest = "${imagetype}:latest"



          withCredentials([usernamePassword(credentialsId: "${DOCKER_CRED_ID}", usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]){
            sh """
              echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
	      docker tag ${imageno} ${imagetypeNo}
              docker push ${imagetypeNo}

              docker tag ${imageno} ${imageLatest} 
              docker push ${imageLatest}
	      docekr rmi ${IMAGE}:${env.BUILD_NUMBER}

            """
          }
        }
      }
    } 

    stage('Deploy') {
      steps {
        script {

          def envType = (env.BRANCH_NAME == 'master') ? 'prod' : 'dev'
          def port = '80:80'
          def container = "app-cont-${envType}"
          
          if (envType == 'prod') {
          //logging to Production server to perform Application deployment from Master.

            withCredentials([usernamePassword(credentialsId: "${DOCKER_CRED_ID}", usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]) {

              sshagent (credentials: ['newtestkey.pem']) {
                sh """
                  ssh -o StrictHostKeyChecking=no ubuntu@${APP_SERV_IP} '
                    echo "$DH_PASS" | sudo docker login -u "$DH_USER" --password-stdin

                    if [ "\$(sudo docker ps -q -f name=${container})" ]; then
                        sudo docker stop ${container}
                        sudo docker rm ${container}
                    elif [ "\$(sudo docker ps -aq -f name=${container})" ]; then
                        sudo docker rm ${container}
                    fi

                    sudo docker pull ${imageLatest}
                    sudo docker run -d --name ${container} -p ${port} ${imageLatest}
                  '
                """
              }
            }
          } 
          else {
                echo "Skipping deployment for Dev Branch on Application-Production Server."
          } 
       }
     }
   }
 }
}
