pipeline {
  agent any

  parameters {
    choice(name: 'ENV', choices: ['dev','qa','prod'])
  }

  environment {
    APP_NAME = "myapp"
    REGION = "us-east-1"
  }



    stage('Assume Role') {
      steps {
        script {
          if (params.ENV == "dev") {
            ACCOUNT_ID="140191459435"
          } else if (params.ENV == "qa") {
            ACCOUNT_ID="222222222"
          } else {
            ACCOUNT_ID="333333333"
          }
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        sh """
        docker build -t ${APP_NAME}:${params.ENV}-${BUILD_NUMBER} .
        """
      }
    }

    stage('Login to ECR') {
      steps {
        sh """
        aws ecr get-login-password --region ${REGION} \
        | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com
        """
      }
    }

    stage('Push Image') {
      steps {
        sh """
        docker tag ${APP_NAME}:${params.ENV}-${BUILD_NUMBER} \
        ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${APP_NAME}:${params.ENV}-${BUILD_NUMBER}

        docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${APP_NAME}:${params.ENV}-${BUILD_NUMBER}
        """
      }
    }

    stage('Deploy using Helm') {
      steps {
        sh """
        aws eks update-kubeconfig --name ${params.ENV}-eks-cluster --region ${REGION}

        helm upgrade --install myapp ./myapp-chart \
        -f myapp-chart/values-${params.ENV}.yaml \
        --set image.tag=${params.ENV}-${BUILD_NUMBER}
        """
      }
    }
  }
}
