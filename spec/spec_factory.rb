module SpecFactory
  require 'factory_girl'
  
  # ----------SEQUENCES------------
  Factory.sequence :email do |n|
    "somebody#{n}@example.com"
  end
  
  Factory.sequence :name do |n|
    "name_#{n}"
  end
  
  Factory.sequence :login do |n|
    "login_#{n}"
  end
  
  Factory.sequence :login do |n|
    "login_#{n}"
  end
  
  Factory.sequence :controller do |n|
    "controller_#{n}"
  end
  
  Factory.sequence :action do |n|
    "action_#{n}"
  end

  
  
  #------------FACTORIES-----------
  Factory.define :user do |u|
    # These properties are set statically, and are evaluated when the factory is
    # defined.
    u.point_value 1
    # This property is set lazily. The block will be called whenever an
    # instance is generated, and the return value of the block is used as the
    # value for the attribute.
    u.name                        { Factory.next(:name) }
    u.email                       { Factory.next(:email) }
    u.login                       { Factory.next(:login) }
    u.crypted_password            "00742970dc9e6319f8019fd54864d3ea740f04b1"  #test
    u.salt                        "7e3041ebc2fc05a40c60028e2c4901a81035d3cd"
    u.remember_token              nil
    u.remember_token_expires_at   nil
  end
  
  Factory.define :billing_cycle do |bc|
    # Attributes
    bc.name         { Factory.next(:name) }
    bc.day_of_month 25
  end

  Factory.define :customer do |c|
    # Associations
    c.association :billing_cycle
    # Attributes
    c.name        { Factory.next(:name) }
  end
  
  Factory.define :point_contract do |c|  # < Contract
    # Associations
    c.association :customer
    # Attributes
    c.name                  { Factory.next(:name) }
    c.retainer_hours        nil
    c.oh_hourly_rate        nil
    c.ah_hourly_rate        nil
    c.retainer_includes_ah  false
    c.point_rate            250.00
    c.ah_point_adjustment   1.5
    c.retainer_points       30
    # type is taken care of by STI
  end
  
  Factory.define :rate_contract do |c|  # < Contract
    # Associations
    c.association :customer
    # Attributes
    c.name                  { Factory.next(:name) }
    c.retainer_hours        30
    c.oh_hourly_rate        250
    c.ah_hourly_rate        375
    c.retainer_includes_ah  false
    c.point_rate            nil
    c.ah_point_adjustment   nil
    c.retainer_points       nil
    # type is taken care of by STI
  end
  
  Factory.define :role do |r|
    # No has_and_belongs_to_many :users association
    r.name                  { Factory.next(:name) }
    r.description           "Factory Generated Role"
  end
  
  Factory.define :right do |r|
    # No has_and_belongs_to_many :roles association
    r.name                  { Factory.next(:name) }
    r.controller            { Factory.next(:controller) }
    r.action                { Factory.next(:action) }
  end
end