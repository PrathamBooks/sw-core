# config/puma.rb
threads 8,32
workers 3
port 3000
preload_app!

