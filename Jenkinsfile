pipeline {
    agent any
    stages {
        stage('build') {
            steps {
                sh 'bash -lc bash -lc "RAILS_ENV=test bundle"'
                sh 'bash -lc "RAILS_ENV=test bundle exec rake db:recreate -t"'
                sh 'bash -lc "RAILS_ENV=test bundle exec rake spec -t"'
            }
        }
    }
}
