namespace :db do
  task :create do
    sh 'mysql -uroot -e "CREATE DATABASE IF NOT EXISTS datamapper_default_tests;"'
    sh 'mysql -uroot -e "CREATE DATABASE IF NOT EXISTS datamapper_alternate_tests;"'
  end

  task :drop do
    sh 'mysql -uroot -e "DROP DATABASE IF EXISTS datamapper_default_tests;"'
    sh 'mysql -uroot -e "DROP DATABASE IF EXISTS datamapper_alternate_tests;"'
  end
end
