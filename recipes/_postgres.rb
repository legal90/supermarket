#
# Author:: Seth Vargo (<sethvargo@gmail.com>)
# Recipe:: postgres
#
# Copyright 2014 Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'postgresql::server'
include_recipe 'postgresql::contrib'

execute 'postgres[user]' do
  user 'postgres'
  command "psql -c 'CREATE ROLE #{node['postgres']['user']} WITH LOGIN;'"
  not_if  "echo 'SELECT 1 FROM pg_roles WHERE rolname = \'#{node['postgres']['user']}\';' | psql | grep -q 1"
end

execute 'postgres[database]' do
  user 'postgres'
  command "psql -c 'CREATE DATABASE #{node['postgres']['database']};'"
  not_if  "echo 'SELECT 1 FROM pg_database WHERE datname = \'#{node['postgres']['database']}\';' | psql | grep -q 1"
end

execute 'postgres[privileges]' do
  user 'postgres'
  command "psql -c 'GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA #{node['postgres']['database']} TO #{node['postgres']['user']};'"
end

execute 'postgres[extensions][plpgsql]' do
  user 'postgres'
  command "psql -c 'CREATE EXTENSION IF NOT EXISTS plpgsql'"
  not_if "echo '\dx' | psql #{node['postgres']['database']} | grep plpgsql"
end

execute 'postgres[extensions][pg_trgm]' do
  user 'postgres'
  command "psql -c 'CREATE EXTENSION IF NOT EXISTS pg_trgm'"
  not_if "echo '\dx' | psql #{node['postgres']['database']} | grep pg_trgm"
end
