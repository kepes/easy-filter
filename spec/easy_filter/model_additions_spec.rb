require 'spec_helper'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'easy_filter_test.db'
)

# This class create database table for RSPec tests
class CreateUsersTable < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :born
      t.string :field_with_underscore
    end
    puts 'Users created'
  end

  def self.down
    drop_table :users
  end
end

# Model class for testing
class User < ActiveRecord::Base
  extend EasyFilter::ModelAdditions
end

describe EasyFilter::ModelAdditions do
  before(:all) do
    CreateUsersTable.migrate(:up)
    User.create!(id: 1, name: 'aaaa aaaa', born: '2001.01.01', field_with_underscore: 'aaaa')
    User.create!(id: 2, name: 'aaaa bbbb', born: '2002.01.01', field_with_underscore: 'aaaa')
    User.create!(id: 3, name: 'bbbb bbbb', born: '2003.01.01', field_with_underscore: 'bbbb')
    User.create!(id: 4, name: 'aaaa cccc', born: '2004.01.01', field_with_underscore: 'aaaa')
  end

  after(:all) do
    CreateUsersTable.migrate(:down)
  end

  it 'should not filter without parameters' do
    expect(User.scoped.easy_filter({}).count).to eq(4)
  end

  it 'should reverse order by ID default' do
    (0..3).each do |i|
      expect(User.scoped.easy_filter({})[i][:id]).to eq(4 - i)
    end
  end

  it 'should order by name' do
    users = User.scoped.easy_filter('sort' => 'name', 'direction' => 'asc')
    expect(users[0][:id]).to eq(1)
    expect(users[1][:id]).to eq(2)
    expect(users[2][:id]).to eq(4)
    expect(users[3][:id]).to eq(3)
  end

  it 'should reverse order by name' do
    users = User.scoped.easy_filter('sort' => 'name', 'direction' => 'desc')
    expect(users[0][:id]).to eq(3)
    expect(users[1][:id]).to eq(4)
    expect(users[2][:id]).to eq(2)
    expect(users[3][:id]).to eq(1)
  end

  it 'should filter by name' do
    users = User.scoped.easy_filter('filter_name' => 'aa')
    expect(users.count).to eq(3)

    users = User.scoped.easy_filter('filter_name' => 'bb')
    expect(users.count).to eq(2)
  end

  it 'should filter by first_name' do
    users = User.scoped.easy_filter('filter_field_with_underscore' => 'aa')
    expect(users.count).to eq(3)

    users = User.scoped.easy_filter('filter_field_with_underscore' => 'bb')
    expect(users.count).to eq(1)
  end

  it 'should exact filter by id' do
    users = User.scoped.easy_filter('filter_exact_id' => '1')
    expect(users.count).to eq(1)

    users = User.scoped.easy_filter('filter_exact_name' => 'aaaa bbbb')
    expect(users.count).to eq(1)
  end

  it 'should filter by time' do
    users = User.scoped.easy_filter('filter_from_born' => '2001.01.01',
                                    'filter_to_born' => '2001.02.01')
    expect(users.count).to eq(1)

    users = User.scoped.easy_filter('filter_from_born' => '2001.01.01',
                                    'filter_to_born' => '2002.01.01')
    expect(users.count).to eq(2)

    users = User.scoped.easy_filter('filter_from_born' => '2003.01.01')
    expect(users.count).to eq(2)

    users = User.scoped.easy_filter('filter_to_born' => '2003.01.01')
    expect(users.count).to eq(3)
  end
end
