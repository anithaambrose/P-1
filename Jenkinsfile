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

          def imageno = "${IMAGE}:${env.BUILD_NUMBER}"

          sh "docker build -t ${imageno} ." 
        }
      }
    }

    stage('Push') {
      steps {
        script {
          
          def env = (env.BRANCH_NAME == 'master') ? 'prod' : 'dev'
          def imagetype = "${IMAGE}-${env}" 
          def imagetypeNo = "${imagetype}:${env.BUILD_NUMBER}" 
          def imageLatest = "${imagetype}:latest"



          withCredentials([usernamePassword(credentialsId: "${DOCKER_CRED_ID}", usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]){
            sh """
              echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
	      docker tag ${imageno} ${imagetypeNo}
              docker push ${imagetypeNo}

              docker tag ${imageno} ${imageLatest} 
              docker push ${imageLatest} 

            """
          }
        }
      }
    } 

    stage('Deploy') {
      steps {
        script {

          def env = (env.BRANCH_NAME == 'master') ? 'prod' : 'dev'
          def port = '80:80'
          def container = "app-cont-${env}"
          
          if (env == 'prod') {
          //logging to Production server to perform Application deployment from Master.

            withCredentials([usernamePassword(credentialsId: "${DOCKER_CRED_ID}", usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]) {

              sshagent (credentials: ['newtestkey.pem']) {
                sh """
                  ssh -o StrictHostKeyChecking=no ubuntu@${IP} '
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
